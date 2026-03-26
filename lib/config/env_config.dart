// lib/config/env_config.dart
// Všetky citlivé kľúče sa načítavajú z ENV premenných (--dart-define-from-file=.env)
// NIKDY neukladaj reálne hodnoty priamo do tohto súboru!

class EnvConfig {
  // Firebase
  static const String firebaseApiKey =
      String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId =
      String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'vyjadreniaelprokan');
  static const String firebaseAuthDomain =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'vyjadreniaelprokan.firebaseapp.com');
  static const String firebaseStorageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'vyjadreniaelprokan.firebasestorage.app');
  static const String firebaseMeasurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  // Supabase
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // Backend API
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL');
}
