import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starquiz/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

final _secureStorage = FlutterSecureStorage();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'GOF Quiz', home: const LoginScreen());
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AppLinks _appLinks;
  late final Stream<Uri> _linkStream;
  late final StreamSubscription<Uri> _sub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _linkStream = _appLinks.uriLinkStream;
    _sub = _linkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'myapp' && uri.host == 'auth') {
        final token = uri.queryParameters['token'];
        await _secureStorage.write(key: 'jwt_token', value: token);
        print('Token saved: $token');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _loginWithGoogle() async {
    final url = Uri.parse(
      'https://gof-quiz-production-4390.up.railway.app/auth/google/login',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loginWithGoogle,
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
