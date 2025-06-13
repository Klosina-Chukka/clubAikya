import 'dart:convert';
import 'dart:io';
import 'package:clubaikya/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
class DetailsPage extends StatefulWidget {
  @override
   final String phone;
   final String token;
 const DetailsPage({required this.phone, required this.token, super.key});
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF75BDC4);

  String selectedRole = 'Student';
  String adminCode = '';

  String name = '', rollNo = '', course = '', branch = '';
  DateTime? dob;
  String? validityMonthYear;
  bool showForm = false;

  final List<String> courses = ['B.Tech', 'M.Tech', 'MBA'];
  final List<String> branches = ['CSE', 'ECE', 'EEE', 'MECH'];

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndScanImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndScanImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final fields = _extractFields(recognizedText);
      await textRecognizer.close();

      setState(() {
        name = fields["Name"] ?? '';
        rollNo = fields["Roll No"] ?? '';
        course = fields["Course"] ?? '';
        branch = fields["Branch"] ?? '';

        final dobText = fields["D.O.B"];
        if (dobText != null && dobText.isNotEmpty) {
          try {
            dob = DateFormat('dd-MM-yyyy').parseStrict(dobText.replaceAll('/', '-'));
          } catch (_) {}
        }

        validityMonthYear = fields["Validity"];
        showForm = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR data filled. Please verify and save.')),
      );
    }
  }

  Map<String, String> _extractFields(RecognizedText recognizedText) {
    Map<String, String> fields = {
      "Name": "",
      "Roll No": "",
      "Course": "",
      "Branch": "",
      "D.O.B": "",
      "Validity": ""
    };

    List<String> lines = [];
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        lines.add(line.text.toUpperCase().trim());
      }
    }

    final fullText = lines.join(' ');
    final rollNoRegex = RegExp(r'\b\d{5}[A-Z]\d{4}\b');
    final rollMatch = rollNoRegex.firstMatch(fullText);
    if (rollMatch != null) fields["Roll No"] = rollMatch.group(0)!;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('ROLL NO') || lines[i].contains(fields["Roll No"] ?? '')) {
        for (int j = i - 1; j >= 0 && j >= i - 3; j--) {
          if (!lines[j].contains('COLLEGE') &&
              !lines[j].contains('KUKATPALLY') &&
              !lines[j].contains('HYDERABAD') &&
              !lines[j].contains('COURSE') &&
              !lines[j].contains('BRANCH') &&
              !lines[j].contains('SCIENCE') &&
              !lines[j].contains('TECHNOLOGY') &&
              !lines[j].contains('ENGINEERING') &&
              lines[j].length >= 3) {
            fields["Name"] = lines[j].replaceAll(RegExp(r'[^A-Z ]'), '').trim();
            break;
          }
        }
        break;
      }
    }

    final dobRegex = RegExp(r'\b\d{2}[-/]\d{2}[-/]\d{4}\b');
    final dobMatch = dobRegex.firstMatch(fullText);
    if (dobMatch != null) fields["D.O.B"] = dobMatch.group(0)!;

    final validityRegex = RegExp(r'\b(JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+\d{4}\b');
    final validityMatch = validityRegex.firstMatch(fullText);
    if (validityMatch != null) fields["Validity"] = validityMatch.group(0)!;

    if (fullText.contains('B.TECH')) fields["Course"] = 'B.Tech';
    else if (fullText.contains('B.E')) fields["Course"] = 'B.E';

    if (fullText.contains('CSE')) fields["Branch"] = 'CSE';
    else if (fullText.contains('ECE')) fields["Branch"] = 'ECE';
    else if (fullText.contains('EEE')) fields["Branch"] = 'EEE';
    else if (fullText.contains('IT')) fields["Branch"] = 'IT';
    else if (fullText.contains('MECH')) fields["Branch"] = 'MECH';

    return fields;
  }

  Future<void> _pickDate(BuildContext context, bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isDob ? DateTime(1980) : DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() {
      if (isDob) dob = picked;
      else validityMonthYear = DateFormat('MMMM yyyy').format(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (!showForm) ...[
                SizedBox(height: 30),
                Image.asset('assets/idpic2.png', height: 180, fit: BoxFit.contain),
                SizedBox(height: 20),
                Text("One more step to go!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1)),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _showImageSourceOptions,
                  icon: Icon(Icons.camera_alt, color: Colors.white),
                  label: Text('Scan ID Card', style: TextStyle(fontSize: 18, color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                ),
                SizedBox(height: 30),
                Row(children: [Expanded(child: Divider(color: Colors.grey)), Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text("OR", style: TextStyle(color: Colors.black54))), Expanded(child: Divider(color: Colors.grey))]),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => setState(() => showForm = true),
                  child: Text("Enter Details Manually", style: TextStyle(color: Colors.black, fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                ),
              ] else _buildFormView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(onPressed: () => setState(() => showForm = false), icon: Icon(Icons.arrow_back,size: 25.0), label: Text('')),
          ),
          SizedBox(height: 20),
          _buildTextField(label: 'Full Name', hint: 'Enter your name', icon: Icons.person, initialValue: name, onChanged: (val) => name = val),
          SizedBox(height: 16),
          _buildTextField(label: 'Roll Number', hint: 'Enter your roll number', icon: Icons.badge, initialValue: rollNo, onChanged: (val) => rollNo = val),
          SizedBox(height: 16),
          _buildDropdown(label: 'Course', value: course, items: courses, onChanged: (val) => setState(() => course = val!)),
          SizedBox(height: 16),
          _buildDropdown(label: 'Branch', value: branch, items: branches, onChanged: (val) => setState(() => branch = val!)),
          SizedBox(height: 16),
          _buildDateField(label: 'Date of Birth', selected: dob != null ? DateFormat('yyyy-MM-dd').format(dob!) : '', onTap: () => _pickDate(context, true)),
          SizedBox(height: 16),
          _buildDateField(label: 'Validity', selected: validityMonthYear ?? '', onTap: () => _pickDate(context, false)),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(labelText: 'Role', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            items: ['Student', 'Admin'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
            onChanged: (val) => setState(() => selectedRole = val!),
          ),
          if (selectedRole == 'Admin') ...[
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: 'Admin Code', hintText: 'Enter admin access code', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter Admin Code' : null,
              onChanged: (val) => adminCode = val,
            ),
          ],
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () async {
  if (_formKey.currentState!.validate()) {
    if (selectedRole == 'Admin' && adminCode != 'admin123') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Admin Code.')),
      );
      return;
    }

    final userData = {
      'phone': widget.phone,
      'name': name,
      'rollNo': rollNo,
      'course': course,
      'branch': branch,
      'dob': dob != null ? DateFormat('yyyy-MM-dd').format(dob!) :null,
      'validity': validityMonthYear ?? '',
      'role': selectedRole
    };

    final response = await http.post(
      Uri.parse('https://3332-2405-201-c42a-4810-a00f-8fa1-4c71-7bf0.ngrok-free.app/api/users'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}', },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Details saved successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(widget.token)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save details')),
      );
    }
  }
},
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              child: Text('Save Details', style: TextStyle(color: Colors.black, fontSize: 18)),
              
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required IconData icon, required String initialValue, required Function(String) onChanged}) =>
      TextFormField(initialValue: initialValue, decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), validator: (value) => value!.isEmpty ? 'Please enter $label' : null, onChanged: onChanged);

  Widget _buildDropdown({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
  return DropdownButtonFormField<String>(
    value: value.isEmpty ? null : value,
    onChanged: onChanged,
    validator: (val) => val == null ? 'Please select $label' : null,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    style: TextStyle(fontSize: 16, color: Colors.black),
    dropdownColor: Colors.white,
    icon: Icon(Icons.arrow_drop_down),
    items: items
        .map((item) => DropdownMenuItem(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(item, style: TextStyle(fontSize: 16)),
              ),
            ))
        .toList(),
  );
}


  Widget _buildDateField({required String label, required String selected, required VoidCallback onTap}) =>
      GestureDetector(onTap: onTap, child: AbsorbPointer(child: TextFormField(decoration: InputDecoration(labelText: label, prefixIcon: Icon(Icons.calendar_today), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), controller: TextEditingController(text: selected), validator: (value) => value!.isEmpty ? 'Please pick $label' : null)));
}
