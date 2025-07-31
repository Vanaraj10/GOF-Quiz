import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class CreateQuizWidget extends StatefulWidget {
  const CreateQuizWidget({super.key});

  @override
  State<CreateQuizWidget> createState() => _CreateQuizWidgetState();
}

class _CreateQuizWidgetState extends State<CreateQuizWidget> {
  final TextEditingController _titleController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();
  bool _loading = false;

  Future<void> _createQuiz() async {
    final topic = _titleController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a quiz title')));
      return;
    }
    setState(() {
      _loading = true;
    });

    final jwtToken = await _secureStorage.read(key: "jwt_token");
    final url = Uri.parse(
      "https://gof-quiz-production-4390.up.railway.app/quiz/generate",
    );
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization" :"Bearer $jwtToken",
      },
      body: '{"topic": "$topic"}',
    );
    setState(() {
      _loading = false;
    });
    if ( response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quiz created successfully!')),
      );
      _titleController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create quiz: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                !_loading
                    ? Lottie.asset('assets/lotties/ai.json', width: 350, height: 350,repeat: true)
                    : const  CircularProgressIndicator(strokeWidth: 8.0, color: Colors.orange),
                Text(
                  "Create Your Quiz",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Quiz Title',
                    hintText: 'Enter the title of your quiz',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: _createQuiz,
                  label: const Text("Create Quiz"),
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 213, 128, 0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
