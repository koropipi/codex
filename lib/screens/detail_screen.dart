import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_screen.dart';
import '../services/database_service.dart';

class DetailScreen extends StatelessWidget {
  final String docId;
  final String title;
  final String content;
  final String uid;
  final List likes;

  const DetailScreen({
    super.key,
    required this.docId,
    required this.title,
    required this.content,
    required this.uid,
    this.likes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(title),
        actions: [

          if (currentUser?.uid == uid)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.cyan),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditScreen(
                      docId: docId,
                      currentTitle: title,
                      currentContent: content,
                    ),
                  ),
                );
              },
            ),

          if (currentUser?.uid == uid)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await db.deleteStory(docId);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .doc(docId)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final liveLikes = List.from(data['likes'] ?? []);
          final isLiked = liveLikes.contains(currentUser?.uid);

          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  data['content'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [

                    IconButton(
                      onPressed: () async {
                        await db.toggleLike(docId, currentUser!.uid);
                      },
                      icon: Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),

                    Text(
                      "${liveLikes.length}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}