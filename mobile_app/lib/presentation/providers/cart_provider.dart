import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/cart_item_model.dart';
import 'package:mobile_app/data/models/product_model.dart';

class CartProvider with ChangeNotifier {
  // List penyimpanan sementara
  final List<CartItem> _items = [];
  
  List<CartItem> get items => _items;

  // Hitung Total Item (untuk badge di icon keranjang)
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Hitung Total Uang yang harus dibayar
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.totalPrice);

  // 1. Tambah ke Keranjang
  void addItem(ProductModel product) {
    // Cek apakah produk sudah ada di cart?
    int index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      // Jika ada, tambah quantity-nya saja
      _items[index].quantity++;
    } else {
      // Jika belum ada, masukkan sebagai item baru
      _items.add(CartItem(product: product));
    }
    notifyListeners(); // Update UI
  }

  // 2. Kurangi Quantity
  void removeSingleItem(int productId) {
    int index = _items.indexWhere((item) => item.product.id == productId);
    
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        // Jika sisa 1 dan dikurangi, hapus dari list
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // 3. Hapus 1 Item Full (Tong Sampah)
  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // 4. Bersihkan Keranjang (Setelah Transaksi selesai)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}