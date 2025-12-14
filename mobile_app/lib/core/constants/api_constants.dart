class ApiConstants {
  // Ganti 10.0.2.2 dengan IP Laptop Anda jika pakai HP Asli (misal: 192.168.1.5)
  // Jika pakai Emulator Android Studio, gunakan 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String products = '$baseUrl/products';
}