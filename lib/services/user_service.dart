import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../services/auth_service.dart';
import '../models/designer_team_member_model.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> getAutoFillDesigner() async {
    print('volam getautofilldesigner');
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Nie ste prihlásený. Chýba autorizačný token.');
      }
      final token = await user.getIdToken();
      if (token == null) return false;

      Uri uri = Uri.parse('${ApiConfig.baseUrl}/users/me');
      http.Response response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['auto_fill_designer'] == true || data['auto_fill_designer'] == 'true';
      } else {
        print('Error fetching user config: statusCode ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception getting auto-fill designer setting: $e');
      return false;
    }
  }

  Future<void> setAutoFillDesigner(bool value) async {

    print('volam set autofilldesigner');

    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Nie ste prihlásený. Chýba autorizačný token.');
    }

    try {
      final token = await user.getIdToken();
      if (token == null) return;

      Uri uri = Uri.parse('${ApiConfig.baseUrl}/users/me/auto-fill-designer');
      print(uri);
      http.Response response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'auto_fill_designer': value}),
      );

      if (response.statusCode == 404) {
        uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userMe}/auto-fill-designer');
        await http.put(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'auto_fill_designer': value}),
        );
      }
    } catch (e) {
      print('Exception setting auto-fill designer setting: $e');
    }
  }

  Future<DesignerTeamMember?> getAutoFillDesignerTeamMember() async {
    try {

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Nie ste prihlásený. Chýba autorizačný token.');
      }

      final token = await user.getIdToken();
      if (token == null) return null;

      Uri uri = Uri.parse('${ApiConfig.baseUrl}/users/me/designer-team-member');
      http.Response response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });



      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return DesignerTeamMember.fromJson(data);
      } else {
        print('Error fetching auto-fill team member: statusCode ${response.statusCode} - body: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Exception fetching auto-fill team member: $e');
      return null;
    }
  }
}
