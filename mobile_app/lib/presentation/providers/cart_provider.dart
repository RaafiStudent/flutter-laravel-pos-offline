import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/cart_item_model.dart';
import 'package:mobile_app/data/models/product_model.dart';
import 'package:mobile_app/data/models/user_model.dart'; // <--- Import User
import 'package:mobile_app/data/services/order_service.dart'; // <--- Import Order Service

class CartProvider with ChangeNotifier {
  // List penyimpanan sementara
  final List<CartItem> _items = [];
  
  // Instance Service untuk Transaksi
  final OrderService _orderService = OrderService(); // <--- Inisialisasi Service

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

  // 4. Bersihkan Keranjang
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // 5. FUNGSI CHECKOUT (PENGHUBUNG KE LOGIC TRANSAKSI)
  Future<bool> checkout(UserModel user, double paymentAmount) async {
    // Validasi sederhana: Uang cukup gak?
    if (paymentAmount < totalAmount) {
      return false;
    }
    
    double change = paymentAmount - totalAmount;

    // Panggil OrderService untuk simpan ke SQLite & Upload ke Server
    bool success = await _orderService.processTransaction(
      user: user, 
      items: _items, 
      totalAmount: totalAmount, 
      paymentAmount: paymentAmount, 
      changeAmount: change
    );

    // Jika transaksi berhasil diproses (disimpan di SQLite), kosongkan keranjang
    if (success) {
      clear(); 
    }

    return success;
  }
}