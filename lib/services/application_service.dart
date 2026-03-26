// lib/services/application_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';

class ApplicationService {
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
  // ZÁKLADNÉ API METÓDY (bez UI logiky)
  // ==========================================

  /// Získaj všetky aplikácie
  Future<List<Application>> getAllApplications() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} applications');
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní aplikácií: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllApplications: $e');
      rethrow;
    }
  }

  /// Vyhľadaj aplikácie podľa kritérií
  Future<List<Application>> searchApplications({
    String? name,
    String? department,
    String? city,
    String? textType,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }
      if (department != null && department.isNotEmpty) {
        queryParams['department'] = department;
      }
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (textType != null && textType.isNotEmpty) {
        queryParams['text_type'] = textType;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/application/search')
          .replace(queryParameters: queryParams);

      print('🔎 Searching: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Found ${data.length} applications');
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri vyhľadávaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in searchApplications: $e');
      rethrow;
    }
  }

  /// Vytvor novú aplikáciu
  Future<Application> createApplication(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application');
      print('📤 POST: $uri');
      print('📦 Data: $data');

      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Application created: ${jsonData['id']}');
        return Application.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri vytváraní: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in createApplication: $e');
      rethrow;
    }
  }

  /// Aktualizuj existujúcu aplikáciu
  Future<Application> updateApplication(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/$id');
      print('📤 PUT: $uri');
      print('📦 Data: $data');

      final headers = await _getAuthHeaders();

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Application updated: $id');
        return Application.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri aktualizácii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in updateApplication: $e');
      rethrow;
    }
  }

  /// Zmaž aplikáciu
  Future<void> deleteApplication(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/$id');
      print('📤 DELETE: $uri');

      final headers = await _getAuthHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Application deleted: $id');
      } else {
        throw Exception('Chyba pri mazaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteApplication: $e');
      rethrow;
    }
  }

  /// Získaj filtrované úrady pre dané mesto
  Future<List<Application>> getFilteredApplicationsForCity({
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

      print('🔎 Fetching filtered applications: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} applications');
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception(
            'Chyba pri načítaní úradov: ${response.statusCode} - ${response.body}'
        );
      }
    } catch (e) {
      print('❌ Error in getFilteredApplicationsForCity: $e');
      rethrow;
    }
  }

  /// Získaj filtrované úrady pre zoznam miest — jeden HTTP request, jeden SQL dopyt
  Future<List<Application>> getFilteredApplicationsForCities({
    required List<int> cityIds,
    bool? fireProtection,
    bool? waterManagement,
    bool? publicHealth,
    bool? railways,
    bool? roads1,
    bool? roads2,
    bool? municipality,
  }) async {
    try {
      print('🔎 Fetching filtered applications for cities: $cityIds');

      // Uri.replace nepodporuje list parametre — skladáme manuálne
      final buffer = StringBuffer('${ApiConfig.baseUrl}/application-city/cities/filtered?');
      for (final id in cityIds) {
        buffer.write('city_ids=$id&');
      }
      if (fireProtection != null) buffer.write('fire_protection=$fireProtection&');
      if (waterManagement != null) buffer.write('water_management=$waterManagement&');
      if (publicHealth != null) buffer.write('public_health=$publicHealth&');
      if (railways != null) buffer.write('railways=$railways&');
      if (roads1 != null) buffer.write('roads_1=$roads1&');
      if (roads2 != null) buffer.write('roads_2=$roads2&');
      if (municipality != null) buffer.write('municipality=$municipality&');

      final uriString = buffer.toString().replaceAll(RegExp(r'&$'), '');
      final uri = Uri.parse(uriString);

      print('📡 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} unique applications for ${cityIds.length} cities');
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception(
          'Chyba pri načítaní úradov: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in getFilteredApplicationsForCities: $e');
      rethrow;
    }
  }

}