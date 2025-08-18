import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      _initialized = true;
    } catch (_) {
      // Running without Firebase config. Keep app functional offline.
      _initialized = false;
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      await ensureInitialized();
      if (!_initialized) return null;
      final cred = await FirebaseAuth.instance.signInAnonymously();
      return cred.user;
    } catch (_) {
      return null;
    }
  }

  Future<void> syncProgress(String uid, Map<String, dynamic> progress) async {
    try {
      await ensureInitialized();
      if (!_initialized) return;
      await FirebaseFirestore.instance.collection('progress').doc(uid).set(progress, SetOptions(merge: true));
    } catch (_) {
      // ignore
    }
  }
}