// lib/services/ai_usage_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/api_config.dart';

// ==========================================
// DATA MODEL
// ==========================================

class TotalUsage {
  final double totalSpent;
  final double myDeposit;
  final double remainingCredit;
  final double percentageUsed;
  final int daysSinceDeposit;
  final String? alertMessage;

  TotalUsage({
    required this.totalSpent,
    required this.myDeposit,
    required this.remainingCredit,
    required this.percentageUsed,
    required this.daysSinceDeposit,
    this.alertMessage,
  });

  factory TotalUsage.fromJson(Map<String, dynamic> json) {
    return TotalUsage(
      totalSpent: (json['total_spent'] ?? 0.0).toDouble(),
      myDeposit: (json['my_deposit'] ?? 0.0).toDouble(),
      remainingCredit: (json['remaining_credit'] ?? 0.0).toDouble(),
      percentageUsed: (json['percentage_used'] ?? 0.0).toDouble(),
      daysSinceDeposit: json['days_since_deposit'] ?? 0,
      alertMessage: json['alert_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_spent': totalSpent,
      'my_deposit': myDeposit,
      'remaining_credit': remainingCredit,
      'percentage_used': percentageUsed,
      'days_since_deposit': daysSinceDeposit,
      'alert_message': alertMessage,
    };
  }

  @override
  String toString() {
    return 'TotalUsage(spent: \$$totalSpent, remaining: \$$remainingCredit, ${percentageUsed.toStringAsFixed(1)}%)';
  }
}

// ==========================================
// SERVICE CLASS
// ==========================================

class AIUsageService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Získa autorizačné hlavičky s Firebase tokenom
  Future<Map<String, String>> _getAuthHeaders() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Nie ste prihlásený. Prihláste sa prosím.');
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

  /// Získa celkové usage dáta (od septembra)
  Future<TotalUsage> getTotalUsage({bool forceRefresh = false}) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/ai-usage/total');

      print('📡 Fetching total usage from API: $uri');

      final response = await http.get(uri, headers: headers);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        final usage = TotalUsage.fromJson(json);

        print('✅ Total usage loaded: $usage');
        return usage;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        print('❌ Error response: $errorBody');
        throw Exception('Chyba pri načítaní usage: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getTotalUsage: $e');
      rethrow;
    }
  }
}