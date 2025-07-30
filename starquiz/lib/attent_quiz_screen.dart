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
    _answers = List<int?>.filled(widget.quiz['Questions'].length ?? [], null);
  }

  void _submitAnswer(int selected) {
    final correct = widget.quiz['Questions'][_current]['Answer'];
    setState(() {
      _answers[_current] = selected;
      if (selected == correct) _score++;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_current < widget.quiz['Questions'].length - 1) {
        setState(() => _current++);
      } else {

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quiz['Questions'][_current] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz['Topic'] ?? 'Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${_current + 1}/${widget.quiz['Questions'].length}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(q['Text'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...List.generate(q['Options'].length, (i) {
              final isSelected = _answers[_current] == i;
              final isCorrect = q['Answer'] == i;
              Color? color;
              if (_answers[_current] != null) {
                color = isSelected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : (isCorrect ? Colors.green : null);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _answers[_current] == null
                      ? () => _submitAnswer(i)
                      : null,
                  child: Text(q['Options'][i]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}