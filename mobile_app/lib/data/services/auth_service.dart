import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/core/database/database_helper.dart';
import 'package:mobile_app/data/models/user_model.dart';

class AuthService {
  // Login: API -> SQLite
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        body: {
          'email': email,
          'password': password,
        },
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // 1. Parsing JSON ke Model
          UserModel user = UserModel.fromJson(data['data']['user']);
          // Masukkan token manual karena biasanya token terpisah dari object user di response API tertentu
          // Tapi di backend kita tadi, token ada di sibling 'user'. 
          // Kita update model user dengan token yang didapat.
          UserModel userWithToken = UserModel(
            id: user.id, 
            name: user.name, 
            email: user.email, 
            token: data['data']['token']
          );

          // 2. Simpan ke SQLite (Session Persistence)
          final db = await DatabaseHelper.instance.database;
          
          // Hapus user lama (Single User Mode)
          await db.delete('users'); 
          
          // Simpan user baru
          await db.insert('users', userWithToken.toJson());

          return userWithToken;
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Gagal terhubung ke server (Error ${response.statusCode})');
      }
    } catch (e) {
      rethrow; // Lempar error ke UI
    }
  }

  // Logout: Hapus dari SQLite
  Future<void> logout() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('users');
  }
}