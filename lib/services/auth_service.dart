import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // ✅ Zmenené
import '../models/auth_model.dart';
import '../utils/api_config.dart';

class AuthService {
  // ✅ Použijeme SharedPreferences namiesto SecureStorage
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';

  // ==========================================
  // PRIHLÁSENIE
  // ==========================================
  Future<TokenResponse> login(LoginRequest loginRequest) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(loginRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final tokenResponse = TokenResponse.fromJson(data);

        // ✅ Ulož token
        await saveToken(tokenResponse);

        return tokenResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Nesprávne prihlasovacie údaje');
      } else {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(error['detail'] ?? 'Chyba pri prihlasovaní');
      }
    } catch (e) {
      throw Exception('Chyba pri prihlasovaní: $e');
    }
  }

  // ==========================================
  // REGISTRÁCIA
  // ==========================================
  Future<UserInfo> register(String email, String password, String? fullName) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.register}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'email': email,
          'password': password,
          if (fullName != null) 'full_name': fullName,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return UserInfo.fromJson(data);
      } else if (response.statusCode == 400) {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(error['detail'] ?? 'Používateľ už existuje');
      } else {
        throw Exception('Chyba pri registrácii: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri registrácii: $e');
    }
  }

  // ==========================================
  // ZÍSKAJ INFO O AKTUÁLNOM USEROVI
  // ==========================================
  Future<UserInfo> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('Nie ste prihlásený');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userMe}');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return UserInfo.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token neplatný - odhlásiť
        await logout();
        throw Exception('Relácia vypršala, prihláste sa znova');
      } else {
        throw Exception('Chyba pri načítaní používateľa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri načítaní používateľa: $e');
    }
  }

  // ==========================================
  // TOKEN MANAGEMENT - ✅ ZMENENÉ NA SharedPreferences
  // ==========================================
  Future<void> saveToken(TokenResponse tokenResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, tokenResponse.accessToken);
    await prefs.setString(_tokenTypeKey, tokenResponse.tokenType);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
  }
}