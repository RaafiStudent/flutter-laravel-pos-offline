import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // GANTI IP jika pakai HP fisik

  // =======================
  // SHIFT KASIR
  // =======================

  static Future<Map<String, dynamic>> openShift(
      String token, double openingBalance) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shifts/open'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'opening_balance': openingBalance,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> closeShift(
      String token, double closingBalance) async {
    final response = await http.post(
      Uri.parse('$baseUrl/shifts/close'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'closing_balance': closingBalance,
      }),
    );

    return jsonDecode(response.body);
  }

    // =======================
  // LAPORAN PENJUALAN
  // =======================

  static Future<Map<String, dynamic>> getDailyReport(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/daily'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMonthlyReport(
      String token, int month, int year) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/monthly?month=$month&year=$year'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  // =======================
  // STRUK / RECEIPT
  // =======================

  static Future<Map<String, dynamic>> getReceipt(
      String token, int orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/receipt'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }
}
