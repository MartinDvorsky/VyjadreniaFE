import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vyjadrenia/utils/api_config.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole; // 'admin' alebo 'user'

  // Getters
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get userRole => _userRole;
  bool get isAdmin => _userRole == 'admin';

  AuthProvider() {
    // Načúvaj zmenám auth stavu
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserRoleFromBackend();
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  // 🔥 NOVÉ - Načítaj rolu z backendu (ktorý overí Firebase token)
  Future<void> _loadUserRoleFromBackend() async {
    try {
      if (_currentUser == null) {
        _userRole = null;
        print('❌ Current user is null');
        return;
      }

      print('🔄 Loading user role from backend...');

      // Získaj Firebase ID token
      final idToken = await _currentUser?.getIdToken(true); // force refresh
      if (idToken == null) {
        print('❌ Failed to get ID token');
        _userRole = 'user';
        notifyListeners();
        return;
      }

      // Zavolaj backend API
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userMe}'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final isSuperuser = data['is_superuser'] as bool? ?? false;
        _userRole = isSuperuser ? 'admin' : 'user';

        print('✅ User role from backend: $_userRole (admin: $isAdmin)');
        print('🔍 Backend response: $data');
      } else {
        print('❌ Backend returned ${response.statusCode}');
        _userRole = 'user';
      }

      notifyListeners();
    } catch (e) {
      print('❌ Error loading role from backend: $e');
      _userRole = 'user'; // Default
      notifyListeners();
    }
  }

  // 🔥 PRIHLÁSENIE
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Načítaj rolu z backendu
      await _loadUserRoleFromBackend();

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Neznáma chyba: $e';
      notifyListeners();
      return false;
    }
  }

  // 🔥 ODHLÁSENIE
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    _userRole = null;
    notifyListeners();
  }

  // Kontrola auth stavu pri štarte
  Future<void> checkAuthStatus() async {
    _currentUser = _firebaseAuth.currentUser;
    if (_currentUser != null) {
      await _loadUserRoleFromBackend();
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // 🔥 Firebase ID Token (pre backend API)
  Future<String?> getIdToken() async {
    return await _currentUser?.getIdToken();
  }

  // ✅ Manually refresh role
  Future<void> refreshUserRole() async {
    await _loadUserRoleFromBackend();
  }

  // Preklad Firebase error kódov
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Nesprávny email alebo heslo';
      case 'user-disabled':
        return 'Tento účet bol deaktivovaný';
      case 'too-many-requests':
        return 'Príliš veľa pokusov. Skúste neskôr.';
      case 'network-request-failed':
        return 'Problém so sieťou';
      default:
        return 'Chyba pri prihlasovaní: $code';
    }
  }
}