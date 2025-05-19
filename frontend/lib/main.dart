import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:clubaikya/screens/sign_in_screen.dart';
import 'package:clubaikya/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Club Aikya',
      debugShowCheckedModeBanner: false,
      home: SplashHandlerScreen(),
      routes: {
        '/login': (_) => SignInScreen(),
        '/home': (_) => HomeScreen(),
      },
    );
  }
}

class SplashHandlerScreen extends StatefulWidget {
  const SplashHandlerScreen({super.key});

  @override
  State<SplashHandlerScreen> createState() => _SplashHandlerScreenState();
}

class _SplashHandlerScreenState extends State<SplashHandlerScreen> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    handleStartupLogic();
  }

  Future<void> handleStartupLogic() async {
    await Firebase.initializeApp();
    await Future.delayed(const Duration(seconds: 3)); // splash delay

    String? token = await storage.read(key: 'jwt');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, token != null ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xff75bdc4)),
      ),
    );
  }
}
