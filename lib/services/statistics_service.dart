// lib/services/statistics_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/api_config.dart';

class StatisticsService {
  // 🔥 Firebase Auth inštancia
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Získaj autorizačné hlavičky s Firebase ID tokenom
  Future<Map<String, String>?> _getAuthHeaders() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        print('⚠️ User nie je prihlásený');
        return null;
      }

      final token = await user.getIdToken();

      if (token == null || token.isEmpty) {
        print('⚠️ Firebase token je prázdny');
        return null;
      }

      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };
    } catch (e) {
      print('⚠️ Chyba pri získavaní tokenu: $e');
      return null;
    }
  }

  /// Získaj štatistiky pre home screen
  Future<HomeStatistics> getHomeStatistics() async {
    try {
      // Paralelné načítanie všetkých štatistík
      final results = await Future.wait([
        _getGeneratedDocumentsCount(),
        _getCitiesCount(),
        _getApplicationsCount(),
      ]);

      return HomeStatistics(
        generatedDocuments: results[0],
        cities: results[1],
        applications: results[2],
      );
    } catch (e) {
      print('❌ Chyba pri načítaní štatistík: $e');
      // Vrát prázdne štatistiky
      return HomeStatistics(
        generatedDocuments: 0,
        cities: 0,
        applications: 0,
      );
    }
  }

  /// Počet generovaných dokumentov (zatiaľ placeholder)
  Future<int> _getGeneratedDocumentsCount() async {
    // TODO: Implementovať keď bude API endpoint
    // Zatiaľ vráť 0 alebo nejaký mock
    return 0;
  }

  /// Počet miest/obcí (vyžaduje prihlásenie)
  Future<int> _getCitiesCount() async {
    try {
      final headers = await _getAuthHeaders();

      // Ak nie je prihlásený, vráť 0
      if (headers == null) {
        print('⚠️ User nie je prihlásený - Cities count = 0');
        return 0;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cities}/')
          .replace(queryParameters: {
        'skip': '0',
        'limit': '100000', // Načítaj všetky
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Cities count: ${data.length}');
        return data.length;
      } else if (response.statusCode == 401) {
        print('⚠️ Neautorizovaný prístup - Cities count = 0');
        return 0;
      } else {
        print('⚠️ Chyba pri načítaní miest: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('❌ Chyba v _getCitiesCount: $e');
      return 0;
    }
  }

  /// Počet úradov/aplikácií (vyžaduje prihlásenie)
  Future<int> _getApplicationsCount() async {
    try {
      final headers = await _getAuthHeaders();

      // Ak nie je prihlásený, vráť 0
      if (headers == null) {
        print('⚠️ User nie je prihlásený - Applications count = 0');
        return 0;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/application/')
          .replace(queryParameters: {
        'skip': '0',
        'limit': '100000', // Načítaj všetky
      });

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Applications count: ${data.length}');
        return data.length;
      } else if (response.statusCode == 401) {
        print('⚠️ Neautorizovaný prístup - Applications count = 0');
        return 0;
      } else {
        print('⚠️ Chyba pri načítaní aplikácií: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('❌ Chyba v _getApplicationsCount: $e');
      return 0;
    }
  }
}

/// Model pre štatistiky
class HomeStatistics {
  final int generatedDocuments;
  final int cities;
  final int applications;

  HomeStatistics({
    required this.generatedDocuments,
    required this.cities,
    required this.applications,
  });

  @override
  String toString() {
    return 'HomeStatistics(generated: $generatedDocuments, cities: $cities, apps: $applications)';
  }
}