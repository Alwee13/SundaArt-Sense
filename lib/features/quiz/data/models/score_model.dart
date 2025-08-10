import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreModel {
  final String userId;
  final String userName; // Simpan nama untuk ditampilkan di leaderboard
  final int score;
  final DateTime timestamp;

  ScoreModel({
    required this.userId,
    required this.userName,
    required this.score,
    required this.timestamp,
  });

  factory ScoreModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ScoreModel(
      userId: doc.id,
      userName: data['userName'] ?? 'Tanpa Nama',
      score: data['score'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'score': score,
      'timestamp': timestamp,
    };
  }
}
