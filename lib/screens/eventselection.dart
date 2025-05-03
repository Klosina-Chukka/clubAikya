import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ClubPage extends StatefulWidget {
  final String clubName;

  ClubPage({required this.clubName});

  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function to pick a time
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Function to save the event
  void _saveEvent() {
    if (_eventTitleController.text.isEmpty ||
        _eventDescController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Mock saving function (Replace with DB logic)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Event Saved for ${widget.clubName} on ${_selectedDate!.toLocal().toString().split(' ')[0]} at ${_selectedTime!.format(context)}')),
    );

    // Clear fields after saving
    _eventTitleController.clear();
    _eventDescController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.clubName} - Admin Panel'),
        backgroundColor: Color(0xff75bdc4),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _eventTitleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _eventDescController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Date Picker
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Event Date'
                    : 'Selected Date: ${_selectedDate!.toLocal()}'
                        .split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),

              // Time Picker
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Select Event Time'
                    : 'Selected Time: ${_selectedTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(context),
              ),

              // Image Picker
              SizedBox(height: 16),
              Text(
                "Upload Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Center(
                          child: Icon(Icons.add_a_photo,
                              size: 50, color: Colors.grey),
                        ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Save',selectionColor: Colors.black,),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff75bdc4),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}