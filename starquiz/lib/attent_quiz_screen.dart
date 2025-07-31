import 'package:flutter/material.dart';

class AttendQuizScreen extends StatefulWidget {
  final Map quiz;
  const AttendQuizScreen({super.key, required this.quiz});

  @override
  State<AttendQuizScreen> createState() => _AttendQuizScreenState();
}

class _AttendQuizScreenState extends State<AttendQuizScreen> {
  int _current = 0;
  int _score = 0;
  List<int?> _answers = [];

  @override
  void initState() {
    super.initState();
    final questions = widget.quiz['Questions'] ?? [];
    _answers = List<int?>.filled(questions.length, null);
  }

  void _submitAnswer(int selected) {
    final questions = widget.quiz['Questions'] ?? [];
    final correctValue = questions[_current]['Answer'].toString().trim();
    final selectedValue = questions[_current]['Options'][selected].toString().trim();
    setState(() {
      _answers[_current] = selected;
      if (selectedValue == correctValue) _score++;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_current < questions.length - 1) {
        setState(() => _current++);
      } else {
        // TODO: Navigate to result screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.quiz['Questions'] ?? [];
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text("No questions found for this quiz.")),
      );
    }
    final q = questions[_current];
    final answerValue = q['Answer'].toString().trim();
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz['Topic'] ?? 'Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_current + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              q['Text'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(q['Options'].length, (i) {
              Color? color;
              if (_answers[_current] != null) {
                // Normalize both option and answer for comparison
                final optionValue = q['Options'][i].toString().trim();
                color = (optionValue == answerValue)
                    ? Colors.green
                    : Colors.red;
              } else {
                color = null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    side: (_answers[_current] == i && _answers[_current] != null)
                        ? const BorderSide(color: Colors.black, width: 2)
                        : BorderSide.none,
                  ),
                  onPressed: _answers[_current] == null
                      ? () => _submitAnswer(i)
                      : null,
                  child: Text(q['Options'][i]),
                ),
              );
            }),
            if (_answers[_current] != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  q['Options'][_answers[_current]!].toString().trim() == answerValue
                      ? "Correct!"
                      : "Incorrect!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: q['Options'][_answers[_current]!].toString().trim() == answerValue
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}