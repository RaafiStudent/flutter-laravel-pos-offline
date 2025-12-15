import 'package:mobile_app/data/models/product_model.dart';

class CartItem {
  final String id; // Kita tetapkan sebagai String agar cocok dengan Provider
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });
}