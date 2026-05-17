import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Write a Story")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [

            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Story Title",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TextFormField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Once upon a time...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 151, 8, 8),
                minimumSize: const Size(double.infinity, 50),
              ),

              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_titleController.text.isEmpty ||
                          _contentController.text.isEmpty) return;

                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Not logged in")),
                        );
                        return;
                      }

                      setState(() => _isLoading = true);

                      try {
                        final db = DatabaseService();

                        await db.addStory(
                          _titleController.text.trim(),
                          _contentController.text.trim(),
                          user.uid,
                        );

                        if (context.mounted) Navigator.pop(context);
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },

              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Publish Story",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}