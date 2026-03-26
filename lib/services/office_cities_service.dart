import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/city_model.dart';
import '../utils/api_config.dart';
import '../utils/permission_helper.dart';
import '../widgets/permission_denied_dialog.dart';

/// Service pre správu väzieb medzi úradmi a mestami (opačný smer)
class OfficeCitiesService {
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

  /// Získaj všetky mestá pre daný úrad - NOVÝ ENDPOINT
  Future<List<City>> getCitiesForOffice(int officeId) async {
    try {
      // ✅ Použij nový endpoint, ktorý vráti priamo mestá s ich detailmi
      final uri = Uri.parse('${ApiConfig.baseUrl}/application-city/application/$officeId/cities');
      print('📤 GET: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Received ${data.length} cities for office $officeId');
        return data.map((json) => City.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Úrad nebol nájdený');
      } else {
        throw Exception('Chyba pri načítaní miest: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in getCitiesForOffice: $e');
      rethrow;
    }
  }

  /// Pridaj mesto k úradu (vytvor väzbu)
  Future<bool> addCityToOffice(int officeId, int cityId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/application-city');
      print('📤 POST: $uri');

      final data = {
        'application_id': officeId,
        'city_id': cityId,
      };
      print('📦 Data: $data');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        print('✅ City added to office successfully');
        return true;
      } else if (response.statusCode == 400) {
        final errorBody = utf8.decode(response.bodyBytes);
        final error = json.decode(errorBody);
        throw Exception(error['detail'] ?? 'Táto väzba už existuje');
      } else {
        throw Exception('Chyba pri pridávaní mesta: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in addCityToOffice: $e');
      rethrow;
    }
  }

  /// Odstráň väzbu medzi úradom a mestom
  Future<bool> removeCityFromOffice(int officeId, int cityId) async {
    try {
      final uri = Uri.parse(
          '${ApiConfig.baseUrl}/application-city/remove/$officeId/$cityId'
      );

      print('📤 DELETE: $uri');

      // 🔥 Získaj autentifikačné hlavičky s Firebase tokenom
      final headers = await _getAuthHeaders();

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 204) {
        print('✅ City removed from office successfully');
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Väzba nebola nájdená');
      } else {
        throw Exception('Chyba pri odstraňovaní väzby: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in removeCityFromOffice: $e');
      rethrow;
    }
  }
}
