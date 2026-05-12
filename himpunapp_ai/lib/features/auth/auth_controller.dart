import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/remote/firestore_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      if (user != null) {
        _syncUserProfile(user);
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await credential.user?.updateDisplayName(name.trim());
      final currentUser = credential.user;
      if (currentUser != null) {
        await _firestoreService.upsertUserProfile(
          uid: currentUser.uid,
          email: currentUser.email ?? email.trim(),
          name: name.trim(),
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> updateProfile({
    required String name,
    String? photoBase64,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = 'Sesi login tidak ditemukan.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await currentUser.updateDisplayName(name.trim());
      await _firestoreService.upsertUserProfile(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        name: name.trim(),
        photoBase64: photoBase64,
      );
      await currentUser.reload();
      _user = _auth.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _syncUserProfile(User user) async {
    try {
      await _firestoreService.upsertUserProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: (user.displayName == null || user.displayName!.trim().isEmpty)
            ? 'Pengguna'
            : user.displayName!.trim(),
      );
    } catch (_) {
      // Keep auth flow resilient even when profile sync fails.
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah (min. 6 karakter).';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
