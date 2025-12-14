import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/product_model.dart';
import 'package:mobile_app/data/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Constructor: Load data local saat Provider pertama kali dibuat
  ProductProvider() {
    loadLocalProducts(); 
  }

  Future<void> loadLocalProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _service.getLocalProducts();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncData() async {
    // Jalankan sync di background
    await _service.syncProducts();
    // Setelah selesai, refresh data local ke UI
    await loadLocalProducts();
  }
}