import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/text_type_model.dart';
import '../utils/api_config.dart';

/// Service pre prácu s typmi textov v databázovej sekcii
class TextTypeService {
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

  /// Získaj všetky typy textov
  Future<List<TextType>> getAllTextTypes() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.textTypes}/');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} text types');
        return data.map((json) => TextType.fromJson(json)).toList();
      } else {
        throw Exception('Chyba pri načítaní typov textov: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getAllTextTypes: $e');
      rethrow;
    }
  }

  /// Aktualizuj typ textu (PATCH - iba text)
  Future<TextType> updateTextType(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.textTypes}/$id');
      print('📤 PATCH: $uri');
      print('📦 Data: $data');

      final headers = await _getAuthHeaders();
      final response = await http.patch(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Text type updated: $id');
        return TextType.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri aktualizácii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in updateTextType: $e');
      rethrow;
    }
  }
}
