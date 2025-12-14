import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/core/database/database_helper.dart';
import 'package:mobile_app/data/models/cart_item_model.dart';
import 'package:mobile_app/data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  // Fungsi Utama: Proses Checkout
  Future<bool> processTransaction({
    required UserModel user,
    required List<CartItem> items,
    required double totalAmount,
    required double paymentAmount,
    required double changeAmount,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final uuid = const Uuid();
    final String transactionCode = "TRX-${uuid.v4().substring(0, 8).toUpperCase()}";
    final String transactionDate = DateTime.now().toIso8601String();

    try {
      // 1. SIMPAN KE SQLite (OFFLINE FIRST)
      // Kita pakai Transaction SQL lokal agar aman
      await db.transaction((txn) async {
        // A. Insert Header Order
        // Perhatikan: is_synced defaultnya 0 (Belum upload)
        int orderId = await txn.insert('orders', {
          'transaction_code': transactionCode,
          'total_amount': totalAmount,
          'payment_amount': paymentAmount,
          'change_amount': changeAmount,
          'payment_method': 'cash', // Default cash dulu
          'transaction_date': transactionDate,
          'user_id': user.id,
          'is_synced': 0 
        });

        // B. Insert Detail Items
        for (var item in items) {
          await txn.insert('order_items', {
            'order_id': orderId,
            'product_id': item.product.id,
            'quantity': item.quantity,
            'price': item.product.price,
          });
        }
      });

      // 2. COBA UPLOAD KE SERVER (ONLINE SYNC)
      // Jika internet mati, codingan di bawah akan error/skip, tapi data sudah aman di SQLite
      await _uploadTransaction(
        token: user.token!,
        transactionCode: transactionCode,
        totalAmount: totalAmount,
        paymentAmount: paymentAmount,
        changeAmount: changeAmount,
        transactionDate: transactionDate,
        items: items
      );

      return true; // Transaksi sukses (Minimal tersimpan di HP)

    } catch (e) {
      print("Transaction Local Error: $e");
      return false; // Gagal total (Gagal simpan ke SQLite)
    }
  }

  // Helper: Upload ke API
  Future<void> _uploadTransaction({
    required String token,
    required String transactionCode,
    required double totalAmount,
    required double paymentAmount,
    required double changeAmount,
    required String transactionDate,
    required List<CartItem> items,
  }) async {
    try {
      // Siapkan Payload JSON sesuai permintaan Controller Laravel
      final body = jsonEncode({
        'transaction_code': transactionCode,
        'total_amount': totalAmount,
        'payment_amount': paymentAmount,
        'change_amount': changeAmount,
        'payment_method': 'cash',
        'transaction_date': transactionDate,
        'items': items.map((item) => {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        }).toList(),
      });

      // Tembak API
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      // Jika Sukses Upload (200 OK)
      if (response.statusCode == 200) {
        // UPDATE status di SQLite menjadi is_synced = 1
        final db = await DatabaseHelper.instance.database;
        await db.update(
          'orders', 
          {'is_synced': 1}, 
          where: 'transaction_code = ?', 
          whereArgs: [transactionCode]
        );
        print("Upload Sukses: Data Tersinkronisasi!");
      } else {
        print("Upload Gagal (Server Error): ${response.body}");
        // Data tetap ada di SQLite tapi is_synced = 0
      }
    } catch (e) {
      print("Upload Gagal (Koneksi Offline): $e");
      // Tidak masalah, data tetap aman di SQLite
    }
  }
}