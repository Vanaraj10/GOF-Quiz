import 'package:flutter/material.dart';
import 'package:starquiz/quiz_result_screen.dart';

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
    final correctIndex = questions[_current]['Answer'];

    setState(() {
      _answers[_current] = selected;
      if (selected == correctIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_current < questions.length - 1) {
        setState(() => _current++);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) {
              return QuizResultScreen(
                quizTitle: widget.quiz['Topic'],
                score: _score,
                total: questions.length,
              );
            },
          ),
        );
      }
    });
  }

  Color _getOptionColor(int optionIndex, int? selectedIndex, int correctIndex) {
    if (selectedIndex == null) {
      // No answer selected yet - default color
      return Colors.blueGrey.shade100;
    }

    if (optionIndex == correctIndex) {
      // This is the correct answer - always green
      return Colors.green.shade600;
    } else if (optionIndex == selectedIndex) {
      // This is the selected wrong answer - red
      return Colors.red.shade600;
    } else {
      // This is an unselected wrong answer - neutral color
      return Colors.grey.shade400;
    }
  }

  Color _getTextColor(int optionIndex, int? selectedIndex, int correctIndex) {
    if (selectedIndex == null) {
      return Colors.black87;
    }

    if (optionIndex == correctIndex || optionIndex == selectedIndex) {
      return Colors.white;
    } else {
      return Colors.black87;
    }
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
    final correctIndex = q['Answer'] as int;
    final selectedIndex = _answers[_current];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['Topic']?.toString() ?? 'Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_current + 1) / questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${_current + 1} of ${questions.length}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              q['Text']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 30),
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: q['Options']?.length ?? 0,
                itemBuilder: (context, i) {
                  final backgroundColor = _getOptionColor(
                    i,
                    selectedIndex,
                    correctIndex,
                  );
                  final textColor = _getTextColor(
                    i,
                    selectedIndex,
                    correctIndex,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Material(
                      elevation: selectedIndex == null ? 2 : 0,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: selectedIndex == null
                            ? () => _submitAnswer(i)
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                (selectedIndex == i && selectedIndex != null)
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedIndex == null
                                      ? Colors.grey.shade300
                                      : Colors.white.withOpacity(0.3),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + i), // A, B, C, D
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  q['Options'][i]?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (selectedIndex != null && i == correctIndex)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              if (selectedIndex != null &&
                                  i == selectedIndex &&
                                  i != correctIndex)
                                Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Feedback message
            if (selectedIndex != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: selectedIndex == correctIndex
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedIndex == correctIndex
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedIndex == correctIndex
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: selectedIndex == correctIndex
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedIndex == correctIndex ? "Correct!" : "Incorrect!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: selectedIndex == correctIndex
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
