// lib/services/city_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/city_model.dart';
import '../utils/api_config.dart';

class CityService {
  // 🔥 Firebase Auth inštancia na získanie tokenu
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // 🔥 Metóda na získanie autorizačných hlavičiek s Firebase ID tokenom
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
        // Formát "Bearer <token>" pre Firebase JWT
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };
    } catch (e) {
      throw Exception('Chyba pri získavaní tokenu: $e');
    }
  }

  // ==========================================
  // GET METÓDY
  // ==========================================

  // Vyhľadaj mestá (Vyžaduje prihlásenie)
  Future<List<City>> searchCities({
    String? name,
    String? district,
    String? region,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (district != null && district.isNotEmpty) queryParams['district'] = district;
      if (region != null && region.isNotEmpty) queryParams['region'] = region;

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.citiesSearch}')
          .replace(queryParameters: queryParams);

      // 🆕 Získaj a použi autorizačné hlavičky
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => City.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Prihláste sa znova.');
      } else {
        throw Exception('Chyba pri vyhľadávaní miest: ${response.statusCode}');
      }
    } catch (e) {
      // V prípade chyby pri získavaní tokenu alebo inej chyby
      throw Exception('Chyba pri vyhľadávaní miest: $e');
    }
  }

  // Získaj všetky mestá (Vyžaduje prihlásenie)
  Future<List<City>> getAllCities({int skip = 0, int limit = 100}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cities}')
          .replace(queryParameters: {'skip': skip.toString(), 'limit': limit.toString()});

      // 🆕 Získaj a použi autorizačné hlavičky
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => City.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Prihláste sa znova.');
      } else {
        throw Exception('Chyba pri načítaní miest: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri načítaní miest: $e');
    }
  }

  // Získaj mesto podľa ID (Vyžaduje prihlásenie)
  Future<City> getCityById(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cities}/$id');

      // 🆕 Získaj a použi autorizačné hlavičky
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return City.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Mesto nenájdené');
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Prihláste sa znova.');
      } else {
        throw Exception('Chyba pri načítaní mesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri načítaní mesta: $e');
    }
  }

  // ==========================================
  // POST METÓDY (Vyžadujú superuser/admina)
  // ==========================================

  // Vytvor nové mesto
  Future<City> createCity(Map<String, dynamic> cityData) async {
    try {
      // DÔLEŽITÉ: Bez lomítka na konci
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cities}');

      print('Creating city at: $uri'); // Debug
      print('Data: $cityData'); // Debug

      // 🆕 Získaj a použi autorizačné hlavičky
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        // 🆕 Použi hlavičky s autorizáciou a Content-Type
        headers: headers,
        body: json.encode(cityData),
      ).timeout(const Duration(seconds: 15)); // Timeout

      print('Response status: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug

      // Skontroluj aj 307 redirect (ak by sa objavil)
      if (response.statusCode == 307 || response.statusCode == 308) {
        throw Exception('Server redirect (${response.statusCode}). Skontrolujte URL endpoint.');
      }

      if (response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return City.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Nemáte oprávnenie na vytvorenie mesta.');
      } else if (response.statusCode == 400) {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception('${error['detail'] ?? 'Neplatné údaje'}');
      } else {
        throw Exception('Chyba pri vytváraní mesta: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating city: $e'); // Debug
      throw Exception('Chyba pri vytváraní mesta: $e');
    }
  }

  // ==========================================
  // PUT/DELETE METÓDY (Vyžadujú superuser/admina)
  // ==========================================

  // Aktualizuj mesto
  Future<City> updateCity(int id, Map<String, dynamic> cityData) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cities}/$id');

      // 🆕 Získaj a použi autorizačné hlavičky
      final headers = await _getAuthHeaders();

      final response = await http.put(
        uri,
        // 🆕 Použi hlavičky s autorizáciou a Content-Type
        headers: headers,
        body: json.encode(cityData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return City.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Mesto nenájdené');
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Nemáte oprávnenie na aktualizáciu mesta.');
      } else if (response.statusCode == 400) {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception('${error['detail'] ?? 'Neplatné údaje'}');
      } else {
        throw Exception('Chyba pri aktualizácii mesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri aktualizácii mesta: $e');
    }
  }

  // Zmaž mesto
  Future<bool> deleteCity(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cities}/$id');

      // 🆕 Získaj a použi autorizačné hlavičky
      final headers = await _getAuthHeaders();

      // 🆕 Pridaj hlavičky
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Mesto nenájdené');
      } else if (response.statusCode == 401) {
        throw Exception('Neoprávnený prístup. Nemáte oprávnenie na zmazanie mesta.');
      } else {
        throw Exception('Chyba pri mazaní mesta: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Chyba pri mazaní mesta: $e');
    }
  }
}