import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../utils/api_config.dart';

class AdminService {
  // Firebase Auth inštancia na získanie tokenu - rovnako ako v CityService
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Metóda na získanie autorizačných hlavičiek s Firebase ID tokenom
  Future<Map<String, String>> getAuthHeaders() async {
    final user = firebaseAuth.currentUser;
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

  // Získaj všetkých používateľov (iba admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/users');
      final headers = await getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Prihláste sa znova.');
      } else if (response.statusCode == 403) {
        throw Exception('Nemáte oprávnenie na túto akciu.');
      } else {
        throw Exception('Chyba pri načítavaní používateľov: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri načítavaní používateľov: $e');
    }
  }

  // Vytvor nového používateľa (iba admin)
  Future<UserModel> createUser({
    required String email,
    required String password,
    String? fullName,
    String role = 'user',
  }) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/users/create');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
          if (fullName != null) 'fullname': fullName,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return UserModel.fromJson(data);
      } else if (response.statusCode == 400) {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(error['detail'] ?? 'Používateľ už existuje');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Neoprávnený prístup. Nemáte oprávnenie.');
      } else {
        throw Exception('Chyba pri vytváraní používateľa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri vytváraní používateľa: $e');
    }
  }

  // Zmeň rolu používateľa (iba admin)
  Future<UserModel> updateUserRole(int userId, String newRole) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/users/$userId/role');

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode({'role': newRole}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Používateľ nenájdený');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Nemáte oprávnenie na túto akciu.');
      } else {
        throw Exception('Chyba pri zmene role: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri zmene role: $e');
    }
  }

  // Aktivuj/Deaktivuj používateľa (iba admin)
  Future<UserModel> toggleUserStatus(int userId, bool isActive) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/users/$userId/toggle-status');

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode({'isactive': isActive}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Používateľ nenájdený');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Nemáte oprávnenie na túto akciu.');
      } else {
        throw Exception('Chyba pri zmene statusu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri zmene statusu: $e');
    }
  }

  // Zmaž používateľa (iba admin) - bonus metóda
  Future<bool> deleteUser(int userId) async {
    try {
      final headers = await getAuthHeaders();
      final uri = Uri.parse('${ApiConfig.baseUrl}/users/$userId');

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Používateľ nenájdený');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Nemáte oprávnenie na túto akciu.');
      } else {
        throw Exception('Chyba pri mazaní používateľa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri mazaní používateľa: $e');
    }
  }
}
