import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/core/database/database_helper.dart'; // <--- 1. JANGAN LUPA IMPORT INI

// 2. Ubah main() jadi async agar bisa tunggu database dibuat
void main() async {
  // 3. Wajib ada baris ini jika main() pakai async
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Pancing DatabaseHelper untuk membuat file database 'kasir_pintar.db'
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // KITA HAPUS MultiProvider SEMENTARA (Sama seperti sebelumnya)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir Pintar',
      theme: _buildThemeData(),
      home: const Scaffold(
        body: Center(
          child: Text(
            "Kasir Pintar Setup\nDatabase SQLite Ready!", // <-- Kita ganti teksnya biar ketahuan
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Konfigurasi Tema Premium (Blue & White Clean Look)
  ThemeData _buildThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2962FF),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    );
  }
}