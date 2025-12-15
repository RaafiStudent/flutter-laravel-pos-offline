import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/core/database/database_helper.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/presentation/providers/product_provider.dart';
import 'package:mobile_app/presentation/providers/cart_provider.dart';
import 'package:mobile_app/presentation/providers/history_provider.dart'; // <--- Pastikan ini ada
import 'package:mobile_app/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()), // <--- Pastikan ini ada
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