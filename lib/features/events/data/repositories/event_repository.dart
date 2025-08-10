import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sundaart_sense/features/events/data/models/event_model.dart';

/// EventRepository adalah pusat untuk semua operasi data yang berkaitan dengan 'events'.
/// Repository ini melayani baik aplikasi mobile pengguna maupun Admin Panel.
class EventRepository {
  final FirebaseFirestore _firestore;

  // Constructor yang memungkinkan injeksi Firestore untuk testing,
  // namun secara default menggunakan instance global.
  EventRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // --- Metode untuk Aplikasi Mobile ---

  /// Mengambil daftar event sekali jalan (Future).
  /// Digunakan di aplikasi mobile untuk menampilkan daftar event.
  Future<List<EventModel>> getEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList();
    } catch (e) {
      print(e);
      throw Exception('Gagal memuat data event');
    }
  }

  // --- Metode untuk Admin Panel ---

  /// Mengambil daftar event secara real-time (Stream).
  /// Digunakan di Admin Panel agar daftar event otomatis ter-update.
  Stream<List<EventModel>> getEventsStream() {
    return _firestore
        .collection('events')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc))
              .toList();
        });
  }

  /// CREATE: Menambahkan event baru ke Firestore.
  /// Digunakan oleh form di Admin Panel.
  Future<void> addEvent(Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection('events').add(eventData);
    } catch (e) {
      throw Exception('Gagal menambah event: $e');
    }
  }

  /// UPDATE: Memperbarui event yang sudah ada di Firestore.
  /// Digunakan oleh form di Admin Panel saat mode edit.
  Future<void> updateEvent(
    String eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      await _firestore.collection('events').doc(eventId).update(eventData);
    } catch (e) {
      throw Exception('Gagal memperbarui event: $e');
    }
  }

  /// DELETE: Menghapus event dari Firestore berdasarkan ID.
  /// Digunakan oleh tombol hapus di Admin Panel.
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus event: $e');
    }
  }
}
