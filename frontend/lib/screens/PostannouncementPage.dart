import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostAnnouncePage extends StatelessWidget {
  const PostAnnouncePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Announcement',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFFDF6F9),
        useMaterial3: true,
      ),
      home: const PostAnnouncementPage(clubName: 'Ragavarsha Club'),
    );
  }
}

class PostAnnouncementPage extends StatefulWidget {
  final String clubName;
  const PostAnnouncementPage({required this.clubName, super.key});

  @override
  State<PostAnnouncementPage> createState() => _PostAnnouncementPageState();
}

class _PostAnnouncementPageState extends State<PostAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _submitAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final eventName = _eventController.text.trim();

    if (title.isEmpty || message.isEmpty || eventName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final url = Uri.parse('https://ff4b1329b0dc.ngrok-free.app/api/announcements/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': message,
          'eventName': eventName,
          'club': widget.clubName,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Announcement Posted Successfully!')),
        );
        _titleController.clear();
        _messageController.clear();
        _eventController.clear();
        setState(() {
          _image = null;
        });
      } else {
        print('❌ Server error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to post announcement')),
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Network error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF75BDC4);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('${widget.clubName} - Post Announcement'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter announcement title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write the announcement message here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Event Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _eventController,
                decoration: const InputDecoration(
                  hintText: 'Enter event name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submitAnnouncement,
                  icon: const Icon(Icons.send, color: Colors.black),
                  label: const Text(
                    'Post Announcement',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
