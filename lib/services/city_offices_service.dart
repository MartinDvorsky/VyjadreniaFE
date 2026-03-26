import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';
import '../widgets/permission_denied_dialog.dart';

/// Service pre správu väzieb medzi mestami a úradmi
class CityOfficesService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, String>> _getAuthHeaders() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception('Nie ste prihlásený. Chýba autorizačný token.');
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

  /// Získaj všetky úrady pre dané mesto
  Future<List<Application>> getOfficesForCity(int cityId) async {
    try {
      // ✅ SPRÁVNY endpoint - vracia plné údaje s JOIN
      final uri = Uri.parse('${ApiConfig.baseUrl}/application-city/city/$cityId/all');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} offices for city $cityId');

        // 🔍 DEBUG: Vypíš prvý úrad
        if (data.isNotEmpty) {
          print('🔍 First office JSON: ${data[0]}');
          print('🔍 Office name: ${data[0]['name']}');
        }

        return data.map((json) => Application.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // Mesto nemá žiadne úrady
        print('ℹ️ No offices found for city $cityId');
        return [];
      } else {
        throw Exception('Chyba pri načítaní úradov: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getOfficesForCity: $e');
      rethrow;
    }
  }

  /// Helper: Získaj plné údaje o úrade podľa ID
  Future<Application?> _getApplicationById(int applicationId) async {
    try {
      // ✅ Správny endpoint
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/$applicationId');
      print('   📤 GET full data: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('   ✅ Loaded: ${data['name']}');
        return Application.fromJson(data);
      } else {
        print('❌ Failed to load application $applicationId: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error loading application $applicationId: $e');
      return null;
    }
  }

  /// Získaj filtrované úrady pre dané mesto
  Future<List<Application>> getFilteredOfficesForCity({
    required int cityId,
    bool? fireProtection,
    bool? waterManagement,
    bool? publicHealth,
    bool? railways,
    bool? roads1,
    bool? roads2,
    bool? municipality,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (fireProtection != null) {
        queryParams['fire_protection'] = fireProtection.toString();
      }
      if (waterManagement != null) {
        queryParams['water_management'] = waterManagement.toString();
      }
      if (publicHealth != null) {
        queryParams['public_health'] = publicHealth.toString();
      }
      if (railways != null) {
        queryParams['railways'] = railways.toString();
      }
      if (roads1 != null) {
        queryParams['roads_1'] = roads1.toString();
      }
      if (roads2 != null) {
        queryParams['roads_2'] = roads2.toString();
      }
      if (municipality != null) {
        queryParams['municipality'] = municipality.toString();
      }

      final uri = Uri.parse(
          '${ApiConfig.baseUrl}/application-city/city/$cityId/filtered'
      ).replace(queryParameters: queryParams);

      print('🔍 Fetching filtered offices: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} filtered offices');
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception(
            'Chyba pri načítaní filtrovaných úradov: ${response.statusCode}'
        );
      }
    } catch (e) {
      print('❌ Error in getFilteredOfficesForCity: $e');
      rethrow;
    }
  }

  /// Pridaj úrad k mestu (vytvor väzbu)
  Future<bool> addOfficeToCity(int applicationId, int cityId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application-city');
      print('📤 POST: $uri');

      final data = {
        'application_id': applicationId,
        'city_id': cityId,
      };
      print('📦 Data: $data');

      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        print('✅ Office added to city successfully');
        return true;
      } else if (response.statusCode == 400) {
        final errorBody = utf8.decode(response.bodyBytes);
        final error = json.decode(errorBody);
        throw Exception(error['detail'] ?? 'Táto väzba už existuje');
      } else {
        throw Exception('Chyba pri pridávaní úradu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in addOfficeToCity: $e');
      rethrow;
    }
  }

  /// Odstráň väzbu medzi mestom a úradom
  Future<bool> removeOfficeFromCity(int applicationId, int cityId) async {
    try {
      final uri = Uri.parse(
          '${ApiConfig.baseUrl}/application-city/remove/$applicationId/$cityId'
      );

      print('📤 DELETE: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Office removed from city successfully');
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Väzba nebola nájdená');
      } else {
        throw Exception('Chyba pri odstraňovaní väzby: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in removeOfficeFromCity: $e');
      rethrow;
    }
  }
}