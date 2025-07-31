import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class QuizResultScreen extends StatelessWidget {
  final String quizTitle;
  final int score;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Result'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Lottie.asset(
                "assets/lotties/congratulations.json",
                animate: true
              ),
              Text(
                'Congratulations!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              Text('Quiz: $quizTitle', style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                'Your Score: $score / $total',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
