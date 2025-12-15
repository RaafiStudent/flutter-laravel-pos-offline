import 'package:flutter/material.dart';
import 'package:mobile_app/data/models/cart_item_model.dart';
import 'package:mobile_app/data/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get totalItems {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id.toString())) {
      _items.update(
        product.id.toString(),
        (existing) => CartItem(
          id: existing.id, // ID lama (String) tetap dipakai
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id.toString(),
        () => CartItem(
          id: DateTime.now().toString(), // ID baru dibuat sebagai String
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    String key = productId.toString();
    if (!_items.containsKey(key)) {
      return;
    }

    if (_items[key]!.quantity > 1) {
      _items.update(
        key,
        (existing) => CartItem(
          id: existing.id,
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(key);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}