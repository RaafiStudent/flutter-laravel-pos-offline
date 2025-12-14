import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/presentation/screens/dashboard_screen.dart'; // <--- BARU: Import Dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Default value biar cepat test (sesuai seeder database)
  final TextEditingController _emailController = TextEditingController(text: 'kasir@admin.com'); 
  final TextEditingController _passwordController = TextEditingController(text: 'password');
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Mengambil state dari Provider
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logo / Header
                const Icon(Icons.storefront_rounded, size: 80, color: Color(0xFF2962FF)),
                const SizedBox(height: 16),
                const Text(
                  "Kasir Pintar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Color(0xFF2D3436)
                  ),
                ),
                const Text(
                  "Masuk untuk memulai penjualan",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // 2. Error Message Box (Muncul jika ada error)
                if (authProvider.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 3. Input Fields
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Email wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 30),

                // 4. Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading 
                      ? null 
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await authProvider.login(
                              _emailController.text, 
                              _passwordController.text
                            );
                            
                            // LOGIKA NAVIGASI BARU DI SINI
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Login Berhasil!"))
                              );
                              
                              // Pindah ke Dashboard & Hapus Login dari Back Stack
                              Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(builder: (context) => const DashboardScreen())
                              );
                            }
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: authProvider.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}