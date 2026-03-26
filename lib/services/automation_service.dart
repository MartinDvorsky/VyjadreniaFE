import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/automation_bond_model.dart';
import '../models/automation_condition_model.dart';
import '../utils/api_config.dart';

class AutomationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Získaj autorizačné hlavičky s Firebase ID tokenom
  Future<Map<String, String>> _getAuthHeaders() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('Nie ste prihlásený. Prihláste sa prosím.');
    }

    try {
      final token = await user.getIdToken();

      if (token == null || token.isEmpty) {
        throw Exception('Nie je možné získať Firebase token.');
      }

      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };
    } catch (e) {
      throw Exception('Chyba pri získavaní tokenu: $e');
    }
  }

  // ==========================================
  // AUTOMATION BONDS - CRUD
  // ==========================================

  /// Získaj všetky automation bonds
  Future<List<AutomationBond>> getAllBonds({
    int skip = 0,
    int limit = 1000,
    bool activeOnly = false,
  }) async {
    try {
      final queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
        'active_only': activeOnly.toString(),
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/bonds')
          .replace(queryParameters: queryParams);

      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} automation bonds');
        return data.map((json) => AutomationBond.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Prihláste sa znova.');
      } else {
        throw Exception('Chyba pri načítaní automatizácií: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllBonds: $e');
      rethrow;
    }
  }

  /// Získaj bond podľa ID
  Future<AutomationBond> getBondById(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/bonds/$id');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return AutomationBond.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Automatizácia nenájdená');
      } else {
        throw Exception('Chyba pri načítaní automatizácie: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getBondById: $e');
      rethrow;
    }
  }

  /// Vytvor nový automation bond + podmienky
  Future<AutomationBond> createBond({
    required int applicationId,
    required bool active,
    required List<Map<String, dynamic>> conditions,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/bonds');
      print('📤 POST: $uri');

      final body = {
        'application_id': applicationId,
        'active': active,
        'conditions': conditions,
      };

      print('📦 Data: $body');

      final headers = await _getAuthHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Bond created: ${data['id']}');
        return AutomationBond.fromJson(data);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri vytváraní: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in createBond: $e');
      rethrow;
    }
  }

  /// Aktualizuj bond (len active status)
  Future<AutomationBond> updateBond(int id, {required bool active}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/bonds/$id');
      print('📤 PUT: $uri');

      final body = {'active': active};

      final headers = await _getAuthHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Bond updated: $id');
        return AutomationBond.fromJson(data);
      } else {
        throw Exception('Chyba pri aktualizácii: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in updateBond: $e');
      rethrow;
    }
  }

  /// Zmaž bond
  Future<bool> deleteBond(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/bonds/$id');
      print('📤 DELETE: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Bond deleted: $id');
        return true;
      } else {
        throw Exception('Chyba pri mazaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteBond: $e');
      rethrow;
    }
  }

  // ==========================================
  // CONDITIONS - CRUD
  // ==========================================

  /// Pridaj novú podmienku k existujúcemu bond
  Future<AutomationCondition> addCondition({
    required int bondId,
    String? region,
    String? district,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/bonds/$bondId/conditions');
      print('📤 POST: $uri');

      final body = {
        'region': region,
        'district': district,
      };

      final headers = await _getAuthHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Condition added');
        return AutomationCondition.fromJson(data);
      } else {
        throw Exception('Chyba pri pridávaní podmienky: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in addCondition: $e');
      rethrow;
    }
  }

  /// Zmaž podmienku
  Future<bool> deleteCondition(int conditionId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/conditions/$conditionId');
      print('📤 DELETE: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Condition deleted: $conditionId');
        return true;
      } else {
        throw Exception('Chyba pri mazaní podmienky: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteCondition: $e');
      rethrow;
    }
  }

  // ==========================================
  // MATCHING & SYNC
  // ==========================================

  /// Získaj úrady pre dané mesto (matching)
  Future<Map<String, dynamic>> matchCity(int cityId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/match-city/$cityId');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Matched applications: ${data['matching_application_ids'].length}');
        return data;
      } else {
        throw Exception('Chyba pri matching: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in matchCity: $e');
      rethrow;
    }
  }

  /// Validuj mesto (bez zmien)
  Future<Map<String, dynamic>> validateCity(int cityId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/validate/city/$cityId');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Chyba pri validácii: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in validateCity: $e');
      rethrow;
    }
  }

  /// Synchronizuj jedno mesto
  Future<Map<String, dynamic>> syncCity(int cityId, {bool removeExtra = false}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/sync/city/$cityId')
          .replace(queryParameters: {'remove_extra': removeExtra.toString()});
      print('📤 POST: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ City synced: ${data['city_name']}');
        return data;
      } else {
        throw Exception('Chyba pri synchronizácii: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in syncCity: $e');
      rethrow;
    }
  }

  /// Synchronizuj všetky mestá
  Future<Map<String, dynamic>> syncAllCities({
    bool removeExtra = false,
    int? limit,
  }) async {
    try {
      final queryParams = {
        'remove_extra': removeExtra.toString(),
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/sync/all')
          .replace(queryParameters: queryParams);
      print('📤 POST: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Sync completed: ${data['processed_cities']} cities');
        return data;
      } else {
        throw Exception('Chyba pri synchronizácii: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in syncAllCities: $e');
      rethrow;
    }
  }

  /// Validuj všetky mestá (report)
  Future<Map<String, dynamic>> validateAllCities({int? limit}) async {
    try {
      final queryParams = {
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/validate/all')
          .replace(queryParameters: queryParams);
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Validation completed');
        return data;
      } else {
        throw Exception('Chyba pri validácii: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in validateAllCities: $e');
      rethrow;
    }
  }

  /// Získaj štatistiky
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/automation/statistics');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data;
      } else {
        throw Exception('Chyba pri načítaní štatistík: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getStatistics: $e');
      rethrow;
    }
  }
}