import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      await _user?.updatePhotoURL(photoUrl);
      await _user?.reload();
      _user = _auth.currentUser;
      _photoUrl = _user?.photoURL;
      notifyListeners();
    } catch (e) {
      print('Error updating profile photo: $e');
    }
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
