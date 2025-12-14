import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- IMPORTS SENJATA KITA ---
import 'package:mobile_app/core/database/database_helper.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/presentation/providers/product_provider.dart'; // <--- 1. JANGAN LUPA IMPORT INI
import 'package:mobile_app/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pancing DatabaseHelper untuk membuat file database di HP
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider untuk Login
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
        
        // Provider untuk Produk (Dashboard)
        ChangeNotifierProvider(create: (_) => ProductProvider()), // <--- 2. TAMBAHKAN INI AGAR DASHBOARD TIDAK CRASH
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kasir Pintar',
        theme: _buildThemeData(),
        home: const LoginScreen(), 
      ),
    );
  }

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