import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/core/database/database_helper.dart';
import 'package:mobile_app/data/models/product_model.dart';
// import 'package:mobile_app/data/models/user_model.dart'; <--- HAPUS BARIS INI (Tidak kepakai)

class ProductService {
  // 1. Ambil Produk dari Local Database (SQLite)
  Future<List<ProductModel>> getLocalProducts() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('products', orderBy: 'id DESC'); // Produk baru di atas
    return result.map((json) => ProductModel.fromJson(json)).toList();
  }

  // 2. Sync: Download dari Server -> Simpan ke Local
  Future<void> syncProducts() async {
    try {
      // Ambil Token dulu dari SQLite untuk Authorization
      final db = await DatabaseHelper.instance.database;
      final userResult = await db.query('users', limit: 1);
      
      if (userResult.isEmpty) throw Exception("User belum login");
      
      // Kita ambil langsung string-nya, jadi tidak butuh UserModel
      String token = userResult.first['token'] as String;

      // Request ke API
      final response = await http.get(
        Uri.parse(ApiConstants.products),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          List products = data['data'];

          // Batch Insert/Update ke SQLite agar performa cepat
          final batch = db.batch();
          
          // Hapus data lama (Strategy: Full Replace)
          batch.delete('products');

          for (var item in products) {
            // Mapping Category ID
            item['category_id'] = item['category']['id']; 
            
            // Buat object Model Product
            ProductModel product = ProductModel.fromJson(item);
            
            batch.insert('products', product.toJson());
          }

          await batch.commit(noResult: true);
        }
      }
    } catch (e) {
      print("Sync Error: $e");
    }
  }
}