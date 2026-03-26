// lib/utils/supabase_config.dart
// Hodnoty sa načítavajú z .env cez --dart-define-from-file=.env
import 'package:vyjadrenia/config/env_config.dart';

class SupabaseConfig {
  static const String supabaseUrl = EnvConfig.supabaseUrl;
  static const String supabaseAnonKey = EnvConfig.supabaseAnonKey;

  // Service role key patrí VÝHRADNE na backend, nikdy sem!
  static const String? supabaseServiceRoleKey = null;
}