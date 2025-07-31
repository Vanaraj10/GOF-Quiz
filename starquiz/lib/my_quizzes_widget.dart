import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:starquiz/attent_quiz_screen.dart';

class MyQuizzesWidget extends StatefulWidget {
  const MyQuizzesWidget({super.key});

  @override
  State<MyQuizzesWidget> createState() => _MyQuizzesWidgetState();
}

class _MyQuizzesWidgetState extends State<MyQuizzesWidget> {
  final _secureStorage = FlutterSecureStorage();
  late final String jwtToken;
  List<dynamic> _quizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _GetJwtToken();
  }

  Future<void> _GetJwtToken() async {
    jwtToken = await _secureStorage.read(key: "jwt_token") ?? "";
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    final url = Uri.parse(
      "https://gof-quiz-production-4390.up.railway.app/quiz/my",
    );
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $jwtToken"},
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        _quizzes = decoded['quizzes'] ?? [];
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load quizzes: ${response.body}')),
      );
    }
  }

  Future<void> _deleteQuiz(String quizId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Quiz"),
          content: const Text("Are you sure you want to delete this quiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                  "https://gof-quiz-production-4390.up.railway.app/quiz/$quizId",
                );
                final response = await http.delete(
                  url,
                  headers: {"Authorization": "Bearer $jwtToken"},
                );
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz deleted successfully!')),
                  );
                  _fetchQuizzes();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete quiz: ${response.body}'),
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_quizzes.isEmpty) {
      return const Center(child: Text("No quizzes found."));
    }
    return Column(
      children: [
        const SizedBox(height: 16,),
        Expanded(
          child: ListView.builder(
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              final quiz = _quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      textAlign: TextAlign.center,
                      quiz['Topic'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final quizID = quiz['ID'] ?? quiz['_id'] ?? quiz['id'];
                      final url = Uri.parse(
                        "https://gof-quiz-production-4390.up.railway.app/quiz/$quizID",
                      );
                      final response = await http.get(
                        url,
                        headers: {"Authorization": " Bearer $jwtToken"},
                      );
                      if (response.statusCode == 200) {
                        final decoded = json.decode(response.body);
                        final quizData = decoded['quiz'];
                        if (quizData != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AttendQuizScreen(quiz: quizData),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Quiz not found')));
                        }
                      }
                    },
                    onLongPress: () async {
                      _deleteQuiz(quiz['ID'] ?? quiz['_id']);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        Text("Long Press to delete a quiz", style: TextStyle(fontSize: 16, color: Colors.grey),),
      ],
    );
  }
}
