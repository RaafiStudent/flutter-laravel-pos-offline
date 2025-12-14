import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart'; // <-- Tutup dulu sementara

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // KITA HAPUS MultiProvider SEMENTARA
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kasir Pintar',
      theme: _buildThemeData(),
      home: const Scaffold(
        body: Center(
          child: Text(
            "Kasir Pintar Setup\nReady to Code!",
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
        seedColor: const Color(0xFF2962FF), // Biru Profesional
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(), // Font Modern
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Abu-abu sangat muda (Soft)
    );
  }
}