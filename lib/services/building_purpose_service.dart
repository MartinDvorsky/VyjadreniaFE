import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/building_purpose_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';
import '../widgets/permission_denied_dialog.dart';

/// Service pre prácu s účelmi stavby v databázovej sekcii
class BuildingPurposeService {
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

  /// Získaj všetky účely stavby
  Future<List<BuildingPurpose>> getAllBuildingPurposes() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.buildingPurposes}/');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} building purposes');
        return data.map((json) => BuildingPurpose.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní účelov stavby: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllBuildingPurposes: $e');
      rethrow;
    }
  }

  /// Vytvor nový účel stavby
  Future<BuildingPurpose> createBuildingPurpose(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.buildingPurposes}/');
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
        print('✅ Building purpose created: ${jsonData['id']}');
        return BuildingPurpose.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri vytváraní: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in createBuildingPurpose: $e');
      rethrow;
    }
  }

  /// Aktualizuj existujúci účel stavby
  Future<BuildingPurpose> updateBuildingPurpose(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.buildingPurposes}/$id');
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
        print('✅ Building purpose updated: $id');
        return BuildingPurpose.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri aktualizácii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in updateBuildingPurpose: $e');
      rethrow;
    }
  }

  /// Zmaž účel stavby
  Future<bool> deleteBuildingPurpose(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.buildingPurposes}/$id');
      print('📤 DELETE: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Building purpose deleted: $id');
        return true;
      } else {
        throw Exception('Chyba pri mazaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteBuildingPurpose: $e');
      rethrow;
    }
  }
}
