import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  QuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      // Pastikan options adalah List<String>
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
    );
  }
}
