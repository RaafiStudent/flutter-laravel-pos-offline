class UserModel {
  final int id;
  final String name;
  final String email;
  final String? token; // Token bisa null jika diambil dari profil, bukan saat login

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  // Factory: Mengubah JSON (dari API) menjadi Object Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: json['token'], // Bisa null
    );
  }

  // Method: Mengubah Object Dart menjadi JSON (untuk disimpan ke Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}