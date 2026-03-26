// lib/services/ai_extraction_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ai_extraction_models.dart';
import '../utils/api_config.dart';

class AIExtractionService {
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

  /// Upload súboru a extrakcia dát pomocou AI
  Future<AIExtractionResponse> extractFromFile(File file) async {
    try {
      // Endpoint pre upload súboru
      final uri = Uri.parse('${ApiConfig.baseUrl}/ai-extraction/api/v1/extraction/file');

      print('📤 Uploading file to AI extraction: ${file.path}');

      // Získaj autorizačné hlavičky
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Nie ste prihlásený');
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        throw Exception('Chýba Firebase token');
      }

      // Vytvor multipart request
      final request = http.MultipartRequest('POST', uri);

      // Pridaj autorizačnú hlavičku
      request.headers['Authorization'] = 'Bearer $token';

      // Pridaj súbor
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );

      print('🔄 Sending request...');

      // Odošli request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ AI extraction successful');

        return AIExtractionResponse.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri extrakcii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in extractFromFile: $e');
      rethrow;
    }
  }

  /// Testovacia metóda pre priamy text (voliteľné)
  Future<AIExtractionResponse> extractFromText(String text) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/extraction/text');

      print('📤 Sending text to AI extraction');

      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'text': text,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        print('✅ AI extraction successful');

        return AIExtractionResponse.fromJson(jsonData);
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri extrakcii: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('❌ Error in extractFromText: $e');
      rethrow;
    }
  }
}