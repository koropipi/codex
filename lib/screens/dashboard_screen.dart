import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/database_service.dart';
import 'search_screen.dart';
import 'create_screen.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeBookListScreen(),
    const SearchFormScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'Codex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _screens[_selectedIndex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 151, 8, 8),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 151, 8, 8),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeBookListScreen extends StatelessWidget {
  HomeBookListScreen({super.key});

  final DatabaseService db = DatabaseService();

  Future<String> _getName(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = doc.data() as Map<String, dynamic>?;

    return data?['displayName'] ?? 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: db.stories,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView(
          padding: const EdgeInsets.all(16),

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Stories", docs.length.toString(), Icons.book),
                _buildStatCard("Community", "SDG 4", Icons.public),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Recent Stories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...docs.take(2).map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return FutureBuilder<String>(
                future: _getName(data['uid']),
                builder: (context, snap) {
                  final name = snap.data ?? 'unknown';

                  return _storyCard(
                    context,
                    doc.id,
                    data['title'] ?? '',
                    data['content'] ?? '',
                    name,
                    data['uid'] ?? '',
                    List.from(data['likes'] ?? []),
                  );
                },
              );
            }),

            const SizedBox(height: 20),

            const Text(
              "All Stories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ...docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return FutureBuilder<String>(
                future: _getName(data['uid']),
                builder: (context, snap) {
                  final name = snap.data ?? 'unknown';

                  return _storyCard(
                    context,
                    doc.id,
                    data['title'] ?? '',
                    data['content'] ?? '',
                    name,
                    data['uid'] ?? '',
                    List.from(data['likes'] ?? []),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _storyCard(
    BuildContext context,
    String docId,
    String title,
    String content,
    String username,
    String uid,
    List likes,
  ) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.cyan),

        title: Text(title, style: const TextStyle(color: Colors.white)),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              "by $username",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),

        trailing: const Icon(Icons.chevron_right, color: Colors.cyan),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                docId: docId,
                title: title,
                content: content,
                uid: uid,
                likes: likes,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 151, 8, 8)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.cyan),
          const SizedBox(height: 5),
          Text(count,
              style: const TextStyle(color: Colors.white, fontSize: 20)),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}