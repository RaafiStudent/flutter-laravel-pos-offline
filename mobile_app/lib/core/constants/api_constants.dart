class ApiConstants {
  // Gunakan IP dari ipconfig (Wireless LAN adapter Wi-Fi)
  static const String baseUrl = 'http://192.168.0.108:8000/api'; // <--- TAMBAH http://
  
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String products = '$baseUrl/products';
}