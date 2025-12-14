class ProductModel {
  final int id;
  final int categoryId;
  final String name;
  final String? sku;
  final double price;
  final int stock;
  final String? image;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.sku,
    required this.price,
    required this.stock,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: int.parse(json['category_id'].toString()),
      name: json['name'],
      sku: json['sku'],
      // Parse aman: Kadang API kirim string "15000.00" atau int 15000
      price: double.parse(json['price'].toString()), 
      stock: int.parse(json['stock'].toString()),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'sku': sku,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }
}