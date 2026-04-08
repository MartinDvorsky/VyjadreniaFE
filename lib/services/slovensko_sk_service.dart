import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../utils/api_config.dart';

class SlovenskoSkService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, String>> _getAuthHeaders() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Nie ste prihlásený');
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Nie je možné získať token');
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }


  /// Overí identitu cez slovensko.sk API (Health check)
  Future<Map<String, dynamic>> verifyIdentity() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/slovensko-sk-api/verify-identity');
      print('📤 GET: $uri');

      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Identity verified');
        return data;
      } else {
        throw Exception('Chyba pri overení identity: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in verifyIdentity: $e');
      rethrow;
    }
  }

  /// Odošle vyjadrenie s prílohami
  ///
  /// ✅ OPRAVENÉ: Používa správne názvy form fieldov podľa BE expectation
  Future<Map<String, dynamic>> submitStatement({
    required int applicationId,
    required String statementXml,
    required Map<String, PlatformFile> attachments,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/slovensko-sk-api/application/$applicationId/submit-statement',
      );
      print('📤 POST: $uri');
      print('📎 Prílohy na odoslanie: ${attachments.keys.toList()}');

      final headers = await _getAuthHeaders();

      // Multipart request pre súbory
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Pridaj XML vyjadrenia
      request.fields['statement_content'] = statementXml;

      // ✅ MAPPING: Názvy príloh MUSIA sedieť s BE endpointom
      // FE používa: 'technical_situation', 'situation', 'situation_a3', 'broader_relations'
      // BE očakáva: 'technical_situation_file', 'situation_file', atď.

      final fieldNameMapping = {
        'technical_situation': 'technical_situation_file',
        'situation': 'situation_file',
        'situation_a3': 'situation_a3_file',
        'broader_relations': 'broader_relations_file',
        'fire_protection': 'fire_protection_file',
        'water_management': 'water_management_file',
        'public_health': 'public_health_file',
        'railways': 'railways_file',
        'roads_1': 'roads_1_file',
        'roads_2': 'roads_2_file',
        'municipality': 'municipality_file',
      };

      // Pridaj prílohy s SPRÁVNYMI názvami
      for (var entry in attachments.entries) {
        final attachmentType = entry.key;
        final file = entry.value;

        // Získaj správny názov fieldu pre BE
        final beFieldName = fieldNameMapping[attachmentType];

        if (beFieldName == null) {
          print('⚠️  Neznámy typ prílohy: $attachmentType');
          continue;
        }

        // Pridaj prílohy s SPRÁVNYMI názvami
        Uint8List? bytes = file.bytes;
        if (bytes == null && !kIsWeb && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        if (bytes == null) {
          print('⚠️  Nepodarilo sa načítať dáta pre: $beFieldName');
          continue;
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            beFieldName,
            bytes,
            filename: file.name,
          ),
        );

        print('  ✓ Pridaná: $beFieldName (${file.size} bytes)');
      }

      // Odošli request
      print('🚀 Odosielam request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Statement submitted successfully');
        print('   Message ID: ${data['message_id']}');
        print('   Attachments sent: ${data['attachments_count']}');
        return data;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response (${response.statusCode}): $errorBody');

        // Parse error detail
        try {
          final errorJson = json.decode(errorBody);
          throw Exception(errorJson['detail'] ?? 'Chyba pri odosielaní: ${response.statusCode}');
        } catch (_) {
          throw Exception('Chyba pri odosielaní: ${response.statusCode}\n$errorBody');
        }
      }
    } catch (e) {
      print('❌ Error in submitStatement: $e');
      rethrow;
    }
  }

  /// Overí či aplikácia má vyplnené IČO
  Future<bool> hasValidIco(int applicationId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application/$applicationId');
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['sender_ico'] != null && data['sender_uri'] != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}