// lib/services/metrics_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/api_config.dart';

class MetricsService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<Map<String, String>> _getAuthHeaders() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Nie ste prihlásený.');
    }
    
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  /// Odošle metriku o generovaní na backend
  static Future<bool> sendGenerationMetric({
    required String znacka,
    required String nazovStavby,
    required int totalDurationMs,
    required int documentCount,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'znacka': znacka,
        'nazov_stavby': nazovStavby,
        'total_duration_ms': totalDurationMs,
        'document_count': documentCount,
      });

      print('📊 Sending metrics: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/metrics/generation'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Metrics sent successfully');
        return true;
      } else {
        print('❌ Failed to send metrics: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending metrics: $e');
      return false;
    }
  }
}
