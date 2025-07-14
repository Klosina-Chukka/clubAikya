import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ClubPage extends StatefulWidget {
  final String clubName;
  final token;
  ClubPage({required this.clubName,this.token});
  @override
  _ClubPageState createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  String _eventMode = 'Offline';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _registrationDeadline;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, TextEditingController>> _associatedLinks = [];
  final TextEditingController _customFieldLabelController = TextEditingController();
  final TextEditingController _customFieldValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addLinkField();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
       firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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

  Future<void> _pickRegistrationDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
       firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _registrationDeadline = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _addLinkField() {
    setState(() {
      _associatedLinks.add({
        'label': TextEditingController(),
        'url': TextEditingController(),
      });
    });
  }

  void _removeLinkField(int index) {
    setState(() {
      _associatedLinks.removeAt(index);
    });
  }

  
  void _saveEvent() async {
  if (_eventTitleController.text.isEmpty ||
      _eventDescController.text.isEmpty ||
      _eventLocationController.text.isEmpty ||
      _selectedDate == null ||
      _selectedTime == null ||
      _registrationDeadline == null ||
      _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  List<Map<String, String>> finalLinks = _associatedLinks.map((link) {
    return {
      'label': link['label']!.text.trim(),
      'url': link['url']!.text.trim(),
    };
  }).where((link) => link['label']!.isNotEmpty && link['url']!.isNotEmpty).toList();

  var uri = Uri.parse('https://ff4b1329b0dc.ngrok-free.app/api/events');
  var request = http.MultipartRequest('POST', uri);
  request.headers['Authorization'] = 'Bearer ${widget.token}';

  request.fields['clubName'] = widget.clubName;
  request.fields['title'] = _eventTitleController.text.trim();
  request.fields['description'] = _eventDescController.text.trim();
  request.fields['location'] = _eventLocationController.text.trim();
  request.fields['mode'] = _eventMode;

  // ✅ Set safe noon time to avoid date shifting
  request.fields['date'] = DateTime(
    _selectedDate!.year,
    _selectedDate!.month,
    _selectedDate!.day,
    _selectedTime!.hour,
  _selectedTime!.minute,
    12, 0, 0,
  ).toUtc().toIso8601String();

  request.fields['time'] = _selectedTime!.format(context);

  request.fields['registrationDeadline'] = DateTime(
    _registrationDeadline!.year,
    _registrationDeadline!.month,
    _registrationDeadline!.day,
    _registrationDeadline!.hour,
    _registrationDeadline!.minute,
    12, 0, 0,
  ).toUtc().toIso8601String();

  request.fields['customFieldLabel'] = _customFieldLabelController.text.trim();
  request.fields['customFieldValue'] = _customFieldValueController.text.trim();
  request.fields['associatedLinks'] = jsonEncode(finalLinks);

  request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

  var response = await request.send();

  if (response.statusCode == 201 || response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event saved successfully')),
    );
    _eventTitleController.clear();
    _eventDescController.clear();
    _eventLocationController.clear();
    _customFieldLabelController.clear();
    _customFieldValueController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _registrationDeadline = null;
      _selectedImage = null;
      _associatedLinks = [];
      _eventMode = 'Offline';
      _addLinkField();
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save event')),
    );
  }
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
              TextField(
                controller: _eventLocationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eventMode,
                items: ['Offline', 'Online'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _eventMode = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Mode',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Event Date'
                    : 'Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'Select Event Time'
                    : 'Selected Time: ${_selectedTime!.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _pickTime(context),
              ),
              ListTile(
                title: Text(_registrationDeadline == null
                    ? 'Select Registration Deadline'
                    : 'Deadline: ${_registrationDeadline!.toLocal().toString().split(' ')[0]}'),
                trailing: Icon(Icons.event_busy),
                onTap: () => _pickRegistrationDeadline(context),
              ),
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
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Associated Links",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ..._associatedLinks.asMap().entries.map((entry) {
                int index = entry.key;
                var controllers = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: controllers['label'],
                          decoration: InputDecoration(labelText: 'Label'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: controllers['url'],
                          decoration: InputDecoration(labelText: 'URL'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeLinkField(index),
                      ),
                    ],
                  ),
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addLinkField,
                icon: Icon(Icons.add),
                label: Text("Add Link"),
              ),
              SizedBox(height: 16),
    
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Save', selectionColor: Colors.black),
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