import 'dart:convert';
import 'dart:math'; // Untuk Random Data Dummy
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
      await db.transaction((txn) async {
        // A. Insert Header Order
        int orderId = await txn.insert('orders', {
          'transaction_code': transactionCode,
          'total_amount': totalAmount,
          'payment_amount': paymentAmount,
          'change_amount': changeAmount,
          'payment_method': 'cash',
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
      await _uploadTransaction(
        token: user.token!,
        transactionCode: transactionCode,
        totalAmount: totalAmount,
        paymentAmount: paymentAmount,
        changeAmount: changeAmount,
        transactionDate: transactionDate,
        items: items
      );

      return true; 

    } catch (e) {
      print("Transaction Local Error: $e");
      return false; 
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

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
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
      }
    } catch (e) {
      print("Upload Gagal (Koneksi Offline): $e");
    }
  }

  // Ambil History Transaksi
  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('orders', orderBy: 'transaction_date DESC');
  }

  // Sync Manual
  Future<int> syncOfflineOrders(String token) async {
    final db = await DatabaseHelper.instance.database;
    final unsyncedOrders = await db.query('orders', where: 'is_synced = 0');
    int successCount = 0;

    for (var order in unsyncedOrders) {
      try {
        final items = await db.query('order_items', where: 'order_id = ?', whereArgs: [order['id']]);
        final body = jsonEncode({
          'transaction_code': order['transaction_code'],
          'total_amount': order['total_amount'],
          'payment_amount': order['payment_amount'],
          'change_amount': order['change_amount'],
          'payment_method': order['payment_method'],
          'transaction_date': order['transaction_date'],
          'items': items.map((item) => {
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'price': item['price'],
          }).toList(),
        });

        final response = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/orders'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          await db.update('orders', {'is_synced': 1}, where: 'id = ?', whereArgs: [order['id']]);
          successCount++;
        }
      } catch (e) {
        print("Gagal sync order ID ${order['id']}: $e");
      }
    }
    return successCount;
  }

  // --- QUERY PINTAR UNTUK CHART ---
  // days: Berapa hari ke belakang (7, 30, 90, 365)
  // isMonthly: Jika true, data dikelompokkan per Bulan. Jika false, per Hari.
  Future<List<Map<String, dynamic>>> getRevenueReport({required int days, bool isMonthly = false}) async {
    final db = await DatabaseHelper.instance.database;
    
    // Tentukan Tanggal Mulai
    DateTime startDate = DateTime.now().subtract(Duration(days: days));
    String startStr = startDate.toIso8601String();

    String query;

    if (isMonthly) {
      // GROUP BY BULAN (Format YYYY-MM)
      query = '''
        SELECT substr(transaction_date, 1, 7) as period, SUM(total_amount) as total
        FROM orders
        WHERE transaction_date >= '$startStr'
        GROUP BY period
        ORDER BY period ASC
      ''';
    } else {
      // GROUP BY HARI (Format YYYY-MM-DD)
      query = '''
        SELECT substr(transaction_date, 1, 10) as period, SUM(total_amount) as total
        FROM orders
        WHERE transaction_date >= '$startStr'
        GROUP BY period
        ORDER BY period ASC
      ''';
    }

    return await db.rawQuery(query);
  }

  // --- GENERATOR DATA DUMMY (UNTUK TESTING CHART) ---
  Future<void> generateDummyData() async {
    final db = await DatabaseHelper.instance.database;
    final random = Random();

    await db.transaction((txn) async {
      for (int i = 0; i < 90; i++) {
        DateTime date = DateTime.now().subtract(Duration(days: i));
        int dailyTransactionCount = random.nextInt(4); 

        for (int j = 0; j < dailyTransactionCount; j++) {
          DateTime transactionTime = date.add(Duration(hours: 8 + random.nextInt(12), minutes: random.nextInt(60)));
          double total = (random.nextInt(18) + 2) * 10000.0; 

          await txn.insert('orders', {
            'transaction_code': "DUMMY-${i}-${j}-${random.nextInt(999)}",
            'total_amount': total,
            'payment_amount': total,
            'change_amount': 0,
            'payment_method': 'cash',
            'transaction_date': transactionTime.toIso8601String(),
            'user_id': 1,
            'is_synced': 1 
          });
        }
      }
    });
    print("Data Dummy 3 Bulan Berhasil Dibuat!");
  }
}