// lib/utils/api_config.dart
// Hodnoty sa načítavajú z .env cez --dart-define-from-file=.env
import 'package:vyjadrenia/config/env_config.dart';

class ApiConfig {
  static const String baseUrl = EnvConfig.apiBaseUrl;

  // Auth endpointy
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // User endpointy
  static const String userMe = '/users/me';
  static const String users = '/users';

  // Endpointy
  static const String cities = '/cities';
  static const String citiesSearch = '/cities/search';
  static const String buildingPurposes = '/building-purposes';
  static const String buildingPurposesSearch = '/building-purposes/search';
  static const String projectDesigners = '/project-designer';
  static const String textTypes = '/text-type';
  static const String chatMessage = '/chat/message';
  static String chatFeedback(String messageId) => '/chat/message/$messageId/feedback';
  static String chatHistory(String sessionId) => '/chat/session/$sessionId/history';
  static const String metricsTotalDocuments = '/metrics/generation/total-documents';

}