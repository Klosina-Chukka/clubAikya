import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:clubaikya/screens/home_screen.dart';
import 'package:clubaikya/screens/ocranddetails.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String baseUrl = 'https://9cda-2405-201-c42a-4810-4c2-7d9-d550-20a1.ngrok-free.app';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isOtpVerified = false;
  bool _isSignIn = true;
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool isOtpSent = false;
  final storage = FlutterSecureStorage();

  Future<void> sendOtp() async {
    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter phone number in +91 format')));
      return;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    if (response.statusCode == 200) {
      setState(() => isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP sent to mobile')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP')));
    }
  }

  Future<void> verifyOtpForSignIn() async {
    final phone = _phoneController.text.trim();
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': _otpController.text}),
    );

    final result = jsonDecode(response.body);

    if (response.statusCode == 200 && result['success'] == true && result.containsKey('token')) {
      await storage.write(key: 'jwt', value: result['token']);
      String? check = await storage.read(key: 'jwt');
      print('Token written and now read back: $check');
      setState(() => isOtpVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP verified! You are logged in.')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(check)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP or user not registered.')));
    }
  }

  Future<void> verifyOtpForSignUp() async {
  final phone = _phoneController.text.trim();
  final response = await http.post(
    Uri.parse('$baseUrl/verify-otp'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone': phone, 'otp': _otpController.text}),
  );

  final result = jsonDecode(response.body);

  if (response.statusCode == 200 && result['success'] == true) {
    String jwtToken = '';
    if (result.containsKey('token')) {
      jwtToken = result['token'];
      await storage.write(key: 'jwt', value: jwtToken); 
      String? check = await storage.read(key: 'jwt');
      print('Token written and now read back: $check'); // Save token securely
    }
    
    setState(() => isOtpVerified = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP verified! Proceed to complete account.')));
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DetailsPage(phone: phone, token: jwtToken)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP')));
  }
}


  Future<void> storeUser() async {
    final phone = _phoneController.text.trim();
    final response = await http.post(
      Uri.parse('$baseUrl/api/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    final result = jsonDecode(response.body);
    if (result['success'] == true) {
      print('User stored in DB');
    } else {
      print('Failed to store user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 280,
                color: Colors.white,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/clublogin.jpg', height: 200, width: 200),
                    const SizedBox(height: 10),
                    const Text('Welcome!', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xff75bdc4))),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(_isSignIn ? Color(0xff75bdc4) : Colors.white)),
                            onPressed: () => setState(() => {_isSignIn = true, isOtpSent = false}),
                            child: Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(!_isSignIn ? Color(0xff75bdc4) : Colors.white)),
                            onPressed: () => setState(() => {_isSignIn = false, isOtpSent = false}),
                            child: Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_isSignIn) ...[
                      const SizedBox(height: 20),
                      const Text('Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Enter your mobile number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isOtpSent) ...[
                        const Text('Enter OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.security),
                            hintText: 'Enter OTP',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: sendOtp,
                          child: Text('Resend OTP', style: TextStyle(color: Color(0xff19919c))),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isOtpSent ? verifyOtpForSignIn : sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff75bdc4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isOtpSent ? 'Verify OTP' : 'Send OTP',
                            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff75bdc4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: isOtpSent ? verifyOtpForSignIn : sendOtp,
                          child: Text('Sign In', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                    if (!_isSignIn) ...[
                      const Text('Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Enter your mobile number',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isOtpSent) ...[
                        const Text('Enter OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.security),
                            hintText: 'Enter OTP',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: sendOtp,
                          child: Text('Resend OTP', style: TextStyle(color: Color(0xff19919c))),
                        ),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isOtpSent ? verifyOtpForSignUp : sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff75bdc4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isOtpSent ? 'Verify OTP' : 'Send OTP',
                            style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff75bdc4),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: isOtpSent ? verifyOtpForSignUp : sendOtp,
                          child: Text('Create Account', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
