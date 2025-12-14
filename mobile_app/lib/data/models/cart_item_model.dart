import 'package:mobile_app/data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  // Getter untuk total harga per item (Harga x Jumlah)
  double get totalPrice => product.price * quantity;
}