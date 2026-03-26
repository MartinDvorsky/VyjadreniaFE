import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_edit_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';
import '../widgets/permission_denied_dialog.dart';

/// Service pre prácu s úradmi v databázovej sekcii
class ApplicationEditService {
  // 🔥 Firebase Auth inštancia
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 🔥 Metóda na získanie autorizačných hlavičiek s Firebase ID tokenom
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

  /// Získaj všetky úrady
  Future<List<ApplicationEdit>> getAllApplications() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} applications');
        return data.map((json) => ApplicationEdit.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní aplikácií: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllApplications: $e');
      rethrow;
    }
  }

  /// Vyhľadaj úrady podľa kritérií
  Future<List<ApplicationEdit>> searchApplications({
    String? name,
    String? department,
    String? city,
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

      final uri = Uri.parse('${ApiConfig.baseUrl}/application/search')
          .replace(queryParameters: queryParams);

      print('🔍 Searching: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Found ${data.length} applications');
        return data.map((json) => ApplicationEdit.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri vyhľadávaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in searchApplications: $e');
      rethrow;
    }
  }

  /// Vytvor nový úrad
  Future<ApplicationEdit> createApplication(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application');
      print('📤 POST: $uri');
      print('📦 Data: $data');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Application created: ${jsonData['id']}');
        return ApplicationEdit.fromJson(jsonData);
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

  /// Aktualizuj existujúci úrad
  Future<ApplicationEdit> updateApplication(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/$id');
      print('📤 PUT: $uri');
      print('📦 Data: $data');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Application updated: $id');
        return ApplicationEdit.fromJson(jsonData);
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

  /// Zmaž úrad
  Future<bool> deleteApplication(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/$id');
      print('📤 DELETE: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Application deleted: $id');
        return true;
      } else {
        throw Exception('Chyba pri mazaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteApplication: $e');
      rethrow;
    }
  }


}