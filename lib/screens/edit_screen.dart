import 'package:flutter/material.dart';
import '../services/database_service.dart';

class EditScreen extends StatefulWidget {
  final String docId;
  final String currentTitle;
  final String currentContent;

  const EditScreen({super.key, required this.docId, required this.currentTitle, required this.currentContent});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _contentController = TextEditingController(text: widget.currentContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Edit Story")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Story Title",
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 151, 8, 8))),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextFormField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 151, 8, 8),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                DatabaseService db = DatabaseService();
                await db.updateStory(widget.docId, _titleController.text.trim(), _contentController.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}