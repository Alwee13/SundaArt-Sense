import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sundaart_sense/features/quiz/data/models/question_model.dart';
import 'package:sundaart_sense/features/quiz/data/models/score_model.dart';

/// QuizRepository adalah pusat untuk semua operasi data yang berkaitan dengan
/// soal kuis ('quizzes') dan papan peringkat ('leaderboard').
/// Repository ini melayani baik aplikasi mobile pengguna maupun Admin Panel.
class QuizRepository {
  final FirebaseFirestore _firestore;

  QuizRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // --- Metode untuk Aplikasi Mobile ---

  /// Mengambil sejumlah soal kuis secara acak untuk satu sesi permainan.
  Future<List<QuestionModel>> getQuizQuestions() async {
    try {
      // Di aplikasi nyata, Anda mungkin ingin logika yang lebih kompleks untuk mengambil soal.
      // Untuk saat ini, kita ambil 10 soal secara acak.
      final snapshot = await _firestore.collection('quizzes').limit(10).get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat soal kuis: $e');
    }
  }

  /// Mengirim skor pengguna ke koleksi 'leaderboard'.
  Future<void> submitScore(ScoreModel score) async {
    try {
      // Menggunakan ID pengguna sebagai ID dokumen untuk mencegah skor ganda.
      // 'set' akan menimpa skor lama jika ada, atau membuat baru jika tidak ada.
      await _firestore
          .collection('leaderboard')
          .doc(score.userId)
          .set(score.toMap());
    } catch (e) {
      throw Exception('Gagal mengirim skor: $e');
    }
  }

  /// Mengambil data papan peringkat, diurutkan dari skor tertinggi.
  Future<List<ScoreModel>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(50) // Ambil 50 skor teratas
          .get();
      return snapshot.docs.map((doc) => ScoreModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Gagal memuat leaderboard: $e');
    }
  }

  // --- Metode untuk Admin Panel ---

  /// Mengambil daftar soal kuis secara real-time (Stream).
  /// Digunakan di Admin Panel agar daftar soal otomatis ter-update.
  Stream<List<QuestionModel>> getQuizQuestionsStream() {
    return _firestore.collection('quizzes').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// CREATE: Menambahkan soal baru ke Firestore.
  Future<void> addQuestion(Map<String, dynamic> questionData) async {
    try {
      await _firestore.collection('quizzes').add(questionData);
    } catch (e) {
      throw Exception('Gagal menambah soal: $e');
    }
  }

  /// UPDATE: Memperbarui soal yang sudah ada di Firestore.
  Future<void> updateQuestion(
    String questionId,
    Map<String, dynamic> questionData,
  ) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(questionId)
          .update(questionData);
    } catch (e) {
      throw Exception('Gagal memperbarui soal: $e');
    }
  }

  /// DELETE: Menghapus soal dari Firestore berdasarkan ID.
  Future<void> deleteQuestion(String questionId) async {
    try {
      await _firestore.collection('quizzes').doc(questionId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus soal: $e');
    }
  }
}
