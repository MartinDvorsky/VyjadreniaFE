import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/api_config.dart';

class AiChatService {
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

  /// Odošle používateľovu správu a kontext na backend a vráti odpoveď AI.
  Future<String> sendMessage(List<Map<String, String>> messages, int currentStep) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.aiChat}');

    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'messages': messages,
          'current_step': currentStep,
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedResponse);
        return data['reply'] ?? 'Nepodarilo sa získať odpoveď.';
      } else {
        // Spracovanie chybových stavov
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
}
