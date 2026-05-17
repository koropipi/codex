import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'detail_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTab = 0;

  final TextEditingController nameController = TextEditingController();
  bool isEditingName = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Not logged in",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),

        builder: (context, userSnap) {
          final userData =
              userSnap.data?.data() as Map<String, dynamic>?;

          final displayName =
              userData?['displayName'] ?? 'unknown';

          nameController.text = displayName;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stories')
                .orderBy('createdAt', descending: true)
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data!.docs;

              final myPosts = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['uid'] == user.uid;
              }).toList();

              final favorites = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final likes = List.from(data['likes'] ?? []);
                return likes.contains(user.uid);
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16),

                children: [

                  // PROFILE CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          user.email ?? "unknown",
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 10),

                        // NAME EDIT + REALTIME
                        Row(
                          children: [

                            Expanded(
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  final data = snapshot.data?.data()
                                      as Map<String, dynamic>?;

                                  final name =
                                      data?['displayName'] ?? 'unknown';

                                  return isEditingName
                                      ? TextField(
                                          controller: nameController,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          autofocus: true,
                                          onSubmitted: (value) async {
                                            await FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(user.uid)
                                                .set({
                                              'displayName':
                                                  value.trim(),
                                            }, SetOptions(merge: true));

                                            setState(() {
                                              isEditingName = false;
                                            });
                                          },
                                        )
                                      : Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        );
                                },
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.cyan),
                              onPressed: () {
                                setState(() {
                                  isEditingName = !isEditingName;
                                });
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "My Posts: ${myPosts.length}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        Text(
                          "Favorites: ${favorites.length}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(height: 15),

                        // LOGOUT
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TAB
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              setState(() => selectedTab = 0),
                          child: const Text("My Posts"),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () =>
                              setState(() => selectedTab = 1),
                          child: const Text("Favorites"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MY POSTS
                  if (selectedTab == 0)
                    ...myPosts.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          title: Text(data['title'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white)),
                          subtitle: Text(data['content'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.grey)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  docId: doc.id,
                                  title: data['title'] ?? '',
                                  content: data['content'] ?? '',
                                  uid: data['uid'] ?? '',
                                  likes:
                                      List.from(data['likes'] ?? []),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),

                  // FAVORITES
                  if (selectedTab == 1)
                    ...favorites.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.favorite,
                              color: Colors.red),
                          title: Text(data['title'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white)),
                          subtitle: Text(data['content'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.grey)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  docId: doc.id,
                                  title: data['title'] ?? '',
                                  content: data['content'] ?? '',
                                  uid: data['uid'] ?? '',
                                  likes:
                                      List.from(data['likes'] ?? []),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}