import 'package:flutter/material.dart';
import 'package:mobile_app/data/services/order_service.dart';

class HistoryProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Load data saat halaman dibuka
  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _orderService.getOrders();

    _isLoading = false;
    notifyListeners();
  }

  // --- KODE BARU: SYNC MANUAL ---
  // Method untuk dipanggil dari Tombol UI
  Future<int> syncManual(String token) async {
    _isLoading = true;
    notifyListeners();

    // Panggil Service
    int count = await _orderService.syncOfflineOrders(token);

    // Refresh list agar warna berubah jadi hijau
    await loadOrders();

    _isLoading = false;
    notifyListeners();
    
    return count;
  }
}