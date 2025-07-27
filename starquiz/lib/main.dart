import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen());
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _loginWithGoogle() async {
    final url = Uri.parse(
      'https://gof-quiz-production.up.railway.app/auth/google/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
