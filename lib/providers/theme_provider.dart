import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      print('📦 Načítané z SharedPreferences: $_isDarkMode');
      notifyListeners();
    } catch (e) {
      print('❌ Chyba pri načítaní témy: $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    print('🔄 Prepínam tému na: $_isDarkMode');
    notifyListeners(); // ✅ KRITICKÉ - musí byť PRED await

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      print('💾 Uložené do SharedPreferences: $_isDarkMode');
    } catch (e) {
      print('❌ Chyba pri ukladaní témy: $e');
    }
  }
}