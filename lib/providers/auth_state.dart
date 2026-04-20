import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/error_utils.dart';

enum AuthStatus { loading, authenticated, anonymous, unauthenticated }

class AuthStateProvider extends ChangeNotifier {
  final AuthService _service;

  User? _user;
  AuthStatus _status = AuthStatus.loading;
  String? _errorMessage;

  AuthStateProvider({AuthService? authService}) 
      : _service = authService ?? AuthService() {
    try {
      _service.userStream.listen(_onAuthChange);
    } catch (_) {}
  }

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAnonymous => _status == AuthStatus.anonymous;
  bool get isLoggedOut => _status == AuthStatus.unauthenticated;

  /// Display name — shows Google name or 'Guest'
  String get displayName {
    if (_user == null) return 'Guest';
    if (_user!.isAnonymous) return 'Guest';
    return _user!.displayName ?? _user!.email ?? 'User';
  }

  /// Initials for avatar (up to 2 chars)
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G';
  }

  String? get email => _user?.email;
  String? get photoUrl => _user?.photoURL;
  String? get uid => _user?.uid;



  void _onAuthChange(User? user) {
    _user = user;
    if (user == null) {
      _status = AuthStatus.unauthenticated;
    } else if (user.isAnonymous) {
      _status = AuthStatus.anonymous;
    } else {
      _status = AuthStatus.authenticated;
    }
    _errorMessage = null;
    notifyListeners();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _service.signInWithGoogle();
      return cred != null;
    } catch (e) {
      _errorMessage = ErrorUtils.getFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInAsGuest() async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.signInAnonymously();
      return true;
    } catch (e) {
      _errorMessage = ErrorUtils.getFriendlyMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _service.updateProfile(displayName: name);
      // Firebase doesn't always trigger the stream for local profile updates immediately
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating profile display name: $e");
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
