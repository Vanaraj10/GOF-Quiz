import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:starquiz/create_quiz_widget.dart';
import 'package:starquiz/my_quizzes_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
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

  static const List<Widget> _pages = <Widget>[
    CreateQuizWidget(),
    MyQuizzesWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 67, 77, 83),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.vertical(
            bottom: Radius.elliptical(12, 12),
          )
        ),
        title : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 30, color: Colors.orange),
            const SizedBox(width: 10),
            _selectedIndex == 0
                ? const Text("StarQuiz", style: TextStyle(fontSize: 30))
                : const Text("My Quizzes", style: TextStyle(fontSize: 30),),
          ],
        ),
       
      ),
      body: jwtToken == null
          ? Center(child: CircularProgressIndicator(),)
          : _pages[_selectedIndex],
      bottomNavigationBar: Padding(
  padding: const EdgeInsets.all(16.0), // Creates space around the nav bar (floating effect)
  child: Container(
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(30), // Rounded corner
      
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white70,
        elevation: 5,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Quizzes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
  ),
),

    );
  }
}
