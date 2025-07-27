import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? jwtToken;
  
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
  final token = await _secureStorage.read(key: 'jwt_token');
  if (mounted) {
    setState(() {
      jwtToken = token;
    });
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: jwtToken != null
            ? Text('Logged in with token: $jwtToken')
            : Text('Not logged in'),
      ),
    );
  }
}
