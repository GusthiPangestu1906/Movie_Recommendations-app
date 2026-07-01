import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  String? _photoUrl;
  String? get photoUrl => _photoUrl;

  AuthProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _photoUrl = user.photoURL;
      } else {
        _photoUrl = null;
      }
      notifyListeners();
    });
  }

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    try {
      if (_user == null) return;

      // Update Firebase Auth
      if (name != null) await _user?.updateDisplayName(name);
      if (photoUrl != null) await _user?.updatePhotoURL(photoUrl);

      await _user?.reload();
      _user = _auth.currentUser;
      _photoUrl = _user?.photoURL;

      // Sync ke Firestore Database
      await _db.collection('users').doc(_user!.uid).set({
        'displayName': _user?.displayName,
        'photoURL': _user?.photoURL,
        'email': _user?.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    await updateProfile(photoUrl: photoUrl);
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        _user = _auth.currentUser;

        // Inisialisasi dokumen user di Firestore
        await _db.collection('users').doc(_user!.uid).set({
          'displayName': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        notifyListeners();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }
}
