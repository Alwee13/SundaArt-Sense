import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Penting untuk AuthBloc kamu:
  /// gunakan userChanges() (bukan authStateChanges()) supaya emit saat profile update.
  Stream<User?> get user => _firebaseAuth.userChanges();

  /// Email/Password Sign Up + set displayName + simpan ke Firestore
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Set nama ke profil Auth
    await cred.user!.updateDisplayName(name);
    await cred.user!.reload(); // refresh user di client

    // Ambil user yang sudah direfresh
    final refreshed = _firebaseAuth.currentUser;
    await _createUserDocument(refreshed!, name: name);
  }

  /// Email/Password Sign In
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Google Sign-In untuk Web & Mobile
  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final cred = await _firebaseAuth.signInWithPopup(provider);
        await _postSignInSetup(cred.user);
      } else {
        final gUser = await _googleSignIn.signIn();
        if (gUser == null) {
          throw FirebaseAuthException(
            code: 'sign_in_canceled',
            message: 'Login dibatalkan.',
          );
        }
        final gAuth = await gUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        final cred = await _firebaseAuth.signInWithCredential(credential);
        await _postSignInSetup(cred.user);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Gagal login dengan Google.');
    } catch (e) {
      throw Exception('Gagal login dengan Google: $e');
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } finally {
      await _firebaseAuth.signOut();
    }
  }

  /// ===== Helpers =====
  Future<void> _createUserDocument(User user, {String? name}) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': name ?? user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // merge displayName kalau sebelumnya null
      await ref.set({
        'displayName': name ?? user.displayName,
        'photoURL': user.photoURL,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _postSignInSetup(User? user) async {
    if (user == null) return;
    await _createUserDocument(user);
  }
}
