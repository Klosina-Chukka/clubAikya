import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  final token;
   const ProfilePage(this.token);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  
  Future<void> fetchProfile() async {
    try {
      // Read token from secure storage
      
      
      if (widget.token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'No authentication token found. Please login again.';
        });
        return;
      }

      print('Retrieved token: ${widget.token}');
      
      final url = Uri.parse('https://9cda-2405-201-c42a-4810-4c2-7d9-d550-20a1.ngrok-free.app/profile');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success']) {
        setState(() {
          userData = data['user'];
          isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load profile');
      }
    } catch (err) {
      print('Error fetching profile: $err');
      setState(() {
        isLoading = false;
        errorMessage = err.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Widget buildInfoTile(String label, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Color(0xff75bdc4)),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(value, style: TextStyle(fontSize: 15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xff75bdc4);

    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchProfile,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (userData == null) {
      return Scaffold(
        body: Center(child: Text("No profile data available.")),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 60, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xff75bdc4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      (userData!['name'] ?? 'U')[0].toUpperCase(),
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    userData!['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    userData!['role'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  buildInfoTile("Phone", userData!['phone'] ?? '', Icons.phone),
                  buildInfoTile("Roll No", userData!['rollNo'] ?? '', Icons.badge),
                  buildInfoTile("Course", userData!['course'] ?? '', Icons.school),
                  buildInfoTile("Branch", userData!['branch'] ?? '', Icons.account_tree_outlined),
                  buildInfoTile("Date of Birth", (userData!['dob'] ?? '').split('T')[0], Icons.cake),
                  buildInfoTile("Valid Till", userData!['validity'] ?? '', Icons.calendar_today),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}