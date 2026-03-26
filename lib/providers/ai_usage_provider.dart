// lib/providers/ai_usage_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/openai_usage_service.dart';

class AIUsageProvider with ChangeNotifier {
  final AIUsageService _usageService = AIUsageService();

  TotalUsage? _usage;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  // Cache duration
  static const Duration _cacheDuration = Duration(minutes: 10);
  static const String _prefsKey = 'ai_usage_cache';

  TotalUsage? get usage => _usage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Getter pre kontrolu či máme validné dáta
  bool get hasValidData => _usage != null && _error == null;

  // Getter pre kontrolu či cache je ešte platný
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    final age = DateTime.now().difference(_lastFetchTime!);
    return age < _cacheDuration;
  }

  // Načítaj usage (s automatickým cachovaním)
  Future<void> loadUsage({bool forceRefresh = false}) async {
    // Ak máme validný cache a nie je force refresh, vráť sa
    if (!forceRefresh && isCacheValid && _usage != null) {
      print('⚡ Používam existujúci cache (age: ${DateTime.now().difference(_lastFetchTime!).inMinutes}min)');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Najprv skús načítať z SharedPreferences
      if (!forceRefresh) {
        final cachedUsage = await _loadFromPrefs();
        if (cachedUsage != null) {
          _usage = cachedUsage;
          _lastFetchTime = DateTime.now();
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Načítaj z API
      final usage = await _usageService.getTotalUsage(forceRefresh: forceRefresh);

      _usage = usage;
      _lastFetchTime = DateTime.now();
      _error = null;

      // Ulož do SharedPreferences
      await _saveToPrefs(usage);

    } catch (e) {
      _error = e.toString();
      print('❌ Error in loadUsage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh (force reload z API)
  Future<void> refresh() async {
    print('🔄 Manual refresh triggered');
    await loadUsage(forceRefresh: true);
  }

  // Načítaj z SharedPreferences
  Future<TotalUsage?> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        final cacheTime = DateTime.parse(json['cached_at']);

        // Skontroluj či nie je cache príliš starý
        final age = DateTime.now().difference(cacheTime);
        if (age < _cacheDuration) {
          print('📦 Načítané z SharedPreferences (age: ${age.inMinutes}min)');
          return TotalUsage.fromJson(json['data']);
        } else {
          print('🗑️ Cache v SharedPreferences je starý, ignorujem');
        }
      }
    } catch (e) {
      print('⚠️ Chyba pri načítaní cache: $e');
    }
    return null;
  }

  // Ulož do SharedPreferences
  Future<void> _saveToPrefs(TotalUsage usage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': usage.toJson(),
        'cached_at': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_prefsKey, jsonEncode(cacheData));
      print('💾 Uložené do SharedPreferences');
    } catch (e) {
      print('⚠️ Chyba pri ukladaní cache: $e');
    }
  }

  // Vyčisti cache
  Future<void> clearCache() async {
    _usage = null;
    _lastFetchTime = null;
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      print('🗑️ Cache vymazaný');
    } catch (e) {
      print('⚠️ Chyba pri mazaní cache: $e');
    }

    notifyListeners();
  }

  // Vypočítaj či je kredit vyčerpaný
  bool get isCreditExhausted {
    if (_usage == null) return false;
    return _usage!.remainingCredit <= 0;
  }

  // Vypočítaj farbu progress baru
  String get usageColor {
    if (_usage == null) return 'green';
    final percentage = _usage!.percentageUsed;
    if (percentage >= 95) return 'red';
    if (percentage >= 90) return 'orange';
    if (percentage >= 80) return 'yellow';
    return 'green';
  }
}