import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starquiz/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';

final _secureStorage = FlutterSecureStorage();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      title: 'GOF Quiz',
      home: const LoginScreen(),
    );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTokenAndRedirect();
    });

    _appLinks = AppLinks();
    _linkStream = _appLinks.uriLinkStream;
    _sub = _linkStream.listen((Uri? uri) async {
      if (uri != null && uri.scheme == 'myapp' && uri.host == 'auth') {
        final token = uri.queryParameters['token'];

        await _secureStorage.write(key: 'jwt_token', value: token);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    });
  }

  Future<void> _checkTokenAndRedirect() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
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
      // Bright orange
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 130),
            Center(
              child: Image.asset('assets/images/welcome.png', height: 400),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  color: Colors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Smarter Questions. Sharper Minds.",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(221, 255, 255, 255),
                        ),
                        children: const [
                          TextSpan(text: "Upgrade For "),
                          TextSpan(
                            text: "Smart Learning",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Boost your knowledge with AI-driven quizzes. Get Started to unlock your full potential.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color.fromARGB(137, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 24,
                        width: 24,
                      ),
                      label: const Text(
                        "Continue With Google",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
