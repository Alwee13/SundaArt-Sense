import 'package:flutter/material.dart';

class QuizProgressBar extends StatelessWidget {
  final int totalQuestions;
  final int currentQuestion;

  const QuizProgressBar({
    super.key,
    required this.totalQuestions,
    required this.currentQuestion,
  });

  @override
  Widget build(BuildContext context) {
    // TweenAnimationBuilder memberikan animasi yang halus saat progress bar berubah
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      tween: Tween<double>(
        begin: (currentQuestion - 1) / totalQuestions,
        end: currentQuestion / totalQuestions,
      ),
      builder: (context, value, _) => LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
      ),
    );
  }
}
