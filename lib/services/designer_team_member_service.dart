import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/designer_team_member_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';
import '../widgets/permission_denied_dialog.dart';

class DesignerTeamMemberService {
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

  // Get all designer team members
  Future<List<DesignerTeamMember>> getAllDesignerTeamMembers() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} designer team members');
        return data.map((json) => DesignerTeamMember.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní členov tímu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllDesignerTeamMembers: $e');
      rethrow;
    }
  }

  // Search designer team members by name or email
  Future<List<DesignerTeamMember>> searchDesignerTeamMembers({
    String? name,
    String? email,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        queryParams['email'] = email;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/search')
          .replace(queryParameters: queryParams);

      print('🔍 Searching: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Found ${data.length} designer team members');
        return data.map((json) => DesignerTeamMember.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri vyhľadávaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in searchDesignerTeamMembers: $e');
      rethrow;
    }
  }

  // Get designer team member by ID
  Future<DesignerTeamMember> getDesignerTeamMemberById(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/$id');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Designer team member loaded: $id');
        return DesignerTeamMember.fromJson(jsonData);
      } else {
        throw Exception('Chyba pri načítaní člena tímu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getDesignerTeamMemberById: $e');
      rethrow;
    }
  }

  // Create new designer team member
  Future<DesignerTeamMember> createDesignerTeamMember(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/');
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
        print('✅ Designer team member created: ${jsonData['id']}');
        return DesignerTeamMember.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri vytváraní: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in createDesignerTeamMember: $e');
      rethrow;
    }
  }

  /// Aktualizuj existujúceho člena tímu
  Future<DesignerTeamMember> updateDesignerTeamMember(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/$id');
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
        print('✅ Designer team member updated: $id');
        return DesignerTeamMember.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri aktualizácii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in updateDesignerTeamMember: $e');
      rethrow;
    }
  }

  /// Zmaž člena tímu
  Future<bool> deleteDesignerTeamMember(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/$id');
      print('📤 DELETE: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ Designer team member deleted: $id');
        return true;
      } else {
        throw Exception('Chyba pri mazaní: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in deleteDesignerTeamMember: $e');
      rethrow;
    }
  }

  /// Vyhľadaj člena tímu podľa emailu
  Future<DesignerTeamMember?> searchByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/email/$encodedEmail');

      print('🔍 Searching designer team member by email: $email');
      print('🔗 URL: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Found member: ${data['name']}');
        return DesignerTeamMember.fromJson(data);
      } else if (response.statusCode == 404) {
        print('⚠️ Member with email $email not found');
        return null;
      } else {
        print('❌ Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error searching by email: $e');
      return null;
    }
  }

  /// Získaj počet členov tímu
  Future<int> getCount() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/designer-team-members/stats/count');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['total_members'] as int;
      } else {
        throw Exception('Chyba pri získavaní počtu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getCount: $e');
      rethrow;
    }
  }
}