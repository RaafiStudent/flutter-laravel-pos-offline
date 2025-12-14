import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- IMPORTS SENJATA KITA ---
import 'package:mobile_app/core/database/database_helper.dart'; // Untuk Database
import 'package:mobile_app/presentation/providers/auth_provider.dart'; // Untuk State Login
import 'package:mobile_app/presentation/screens/login_screen.dart'; // Untuk Tampilan Login

void main() async {
  // 1. Wajib ada jika main() pakai async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Pancing DatabaseHelper untuk membuat file database 'kasir_pintar.db' di HP
  // (Agar saat user login, tabel 'users' sudah pasti ada)
  await DatabaseHelper.instance.database;

  // 3. Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. MultiProvider: Tempat mendaftarkan semua "Otak" aplikasi
    return MultiProvider(
      providers: [
        // Daftarkan AuthProvider agar bisa diakses dari mana saja (LoginScreen, Dashboard, dll)
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Hilangkan pita "Debug" di pojok kanan atas
        title: 'Kasir Pintar',
        
        // 5. Setup Tema Premium
        theme: _buildThemeData(),
        
        // 6. Tentukan halaman pertama yang muncul
        home: const LoginScreen(), 
      ),
    );
  }

  // --- KONFIGURASI TEMA (STYLE) ---
  ThemeData _buildThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2962FF), // Biru Profesional
        brightness: Brightness.light,
      ),
      // Gunakan Font Poppins untuk seluruh teks aplikasi
      textTheme: GoogleFonts.poppinsTextTheme(), 
      
      // Style App Bar (Header)
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      
      // Warna Background Aplikasi (Abu-abu soft agar mata tidak cepat lelah)
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), 
    );
  }
}