import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vyjadrenia/utils/api_config.dart';
import 'dart:convert';
import 'models/chat_message_model.dart';

class ChatRepository {
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
        'Content-Type': 'application/json',
      };
    } catch (e) {
      throw Exception('Chyba pri získavaní tokenu: $e');
    }
  }

  /// Odošle správu a vráti odpoveď spolu so session_id
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
    String? screenId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatMessage}');

    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'session_id': sessionId,
        'screen_id': screenId,
        'message': message,
      });

      print('🚀 CHAT REQUEST: $body');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 CHAT RESPONSE (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        return jsonDecode(decodedResponse) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Chyba API: ${response.statusCode}';
        try {
          final decodedResponse = utf8.decode(response.bodyBytes);
          final errorData = jsonDecode(decodedResponse);
          if (errorData['detail'] != null) {
            errorMessage = errorData['detail'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Chyba pripojenia: $e');
    }
  }

  /// Odošle feedback pre danú správu
  Future<void> submitFeedback(String messageId, int rating, {String? comment}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatFeedback(messageId)}');

    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'rating': rating,
        'comment': comment,
      });

      print('👍 CHAT FEEDBACK REQUEST ($messageId): $body');
      
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 CHAT FEEDBACK RESPONSE: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Nepodarilo sa odoslať feedback (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Chyba pripojenia: $e');
    }
  }

  /// Načíta históriu konverzácie pre zadané session
  Future<List<ChatMessageModel>> getHistory(String sessionId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatHistory(sessionId)}');

    try {
      final headers = await _getAuthHeaders();
      
      print('📜 CHAT HISTORY REQUEST: $sessionId');

      final response = await http.get(
        url,
        headers: headers,
      );

      print('📥 CHAT HISTORY RESPONSE (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final list = jsonDecode(decodedResponse) as List<dynamic>;
        return list.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Nepodarilo sa načítať históriu (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Chyba pripojenia: $e');
    }
  }
}
