import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/project_designer_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';
import '../widgets/permission_denied_dialog.dart';

class ProjectDesignerService {
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

  // Get all project designers
  Future<List<ProjectDesigner>> getAllProjectDesigners() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} project designers');
        return data.map((json) => ProjectDesigner.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní projektantov: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllProjectDesigners: $e');
      rethrow;
    }
  }

  // Search project designers by name
  Future<List<ProjectDesigner>> searchProjectDesigners(String? name) async {
    try {
      final queryParams = <String, String>{};
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/search')
          .replace(queryParameters: queryParams);

      print('🔍 Searching: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Found ${data.length} project designers');
        return data.map((json) => ProjectDesigner.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri vyhľadávaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in searchProjectDesigners: $e');
      rethrow;
    }
  }

  // Get project designer by ID
  Future<ProjectDesigner> getProjectDesignerById(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/$id');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Project designer loaded: $id');
        return ProjectDesigner.fromJson(jsonData);
      } else {
        throw Exception('Chyba pri načítaní projektanta: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getProjectDesignerById: $e');
      rethrow;
    }
  }

  Future<ProjectDesigner> createProjectDesigner(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/');
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
        print('✅ Project designer created: ${jsonData['id']}');
        return ProjectDesigner.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri vytváraní: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in createProjectDesigner: $e');
      rethrow;
    }
  }

  /// Aktualizuj existujúceho projektanta
  Future<ProjectDesigner> updateProjectDesigner(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/$id');
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
        print('✅ Project designer updated: $id');
        return ProjectDesigner.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri aktualizácii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in updateProjectDesigner: $e');
      rethrow;
    }
  }

  /// Zmaž projektanta
  Future<bool> deleteProjectDesigner(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/$id');
      print('📤 DELETE: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Project designer deleted: $id');
        return true;
      } else {
        throw Exception('Chyba pri mazaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteProjectDesigner: $e');
      rethrow;
    }
  }

  Future<List<ProjectDesigner>> getAllProjectDesigners2() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} project designers');
        return data.map((json) => ProjectDesigner.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní projektantov: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllProjectDesigners: $e');
      rethrow;
    }
  }


  /// Vyhľadaj projektanta podľa čísla oprávnenia (license)
  Future<ProjectDesigner?> searchByLicense(String license) async {
    try {
      // ✅ Použiť path parameter namiesto query parameter
      final encodedLicense = Uri.encodeComponent(license);
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.projectDesigners}/license/$encodedLicense');

      print('🔍 Searching designer by license: $license');
      print('🔗 URL: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Found designer: ${data['name']}');
        return ProjectDesigner.fromJson(data);
      } else if (response.statusCode == 404) {
        print('⚠️ Designer with license $license not found');
        return null;
      } else {
        print('❌ Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error searching by license: $e');
      return null;
    }
  }
}