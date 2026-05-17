import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference storyCollection =
      FirebaseFirestore.instance.collection('stories');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // CREATE
  Future<void> addStory(
    String title,
    String content,
    String uid,
  ) async {
    await storyCollection.add({
      'title': title,
      'content': content,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [],
    });
  }

  // READ
  Stream<QuerySnapshot> get stories {
    return storyCollection
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // UPDATE STORY
  Future<void> updateStory(
    String docId,
    String title,
    String content,
  ) async {
    await storyCollection.doc(docId).update({
      'title': title,
      'content': content,
    });
  }

  // DELETE STORY
  Future<void> deleteStory(String docId) async {
    await storyCollection.doc(docId).delete();
  }

  // LIKE TOGGLE
  Future<void> toggleLike(String docId, String uid) async {
    final doc = await storyCollection.doc(docId).get();
    final data = doc.data() as Map<String, dynamic>;

    List likes = data['likes'] ?? [];

    if (likes.contains(uid)) {
      likes.remove(uid);
    } else {
      likes.add(uid);
    }

    await storyCollection.doc(docId).update({
      'likes': likes,
    });
  }


  Future<void> updateDisplayName(String uid, String name) async {
    await userCollection.doc(uid).set({
      'displayName': name.trim(),
    }, SetOptions(merge: true));
  }


  Future<String> getDisplayName(String uid) async {
    final doc = await userCollection.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;

    return data?['displayName'] ?? 'unknown';
  }
}