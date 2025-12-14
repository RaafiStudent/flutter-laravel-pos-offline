import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/presentation/providers/product_provider.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/presentation/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    // Trigger Sync saat halaman dibuka
    // Kita gunakan addPostFrameCallback agar tidak error saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).syncData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Format Uang Rupiah
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Kasir", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => productProvider.syncData(), // Manual Sync Button
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: productProvider.isLoading && productProvider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Kolom
                  childAspectRatio: 0.75, // Perbandingan Lebar:Tinggi Kartu
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Gambar Produk
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              color: Colors.grey.shade200,
                              image: product.image != null 
                                ? DecorationImage(image: NetworkImage(product.image!), fit: BoxFit.cover)
                                : null,
                            ),
                            child: product.image == null 
                              ? const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.grey))
                              : null,
                          ),
                        ),
                        
                        // 2. Detail Produk
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(product.price),
                                style: const TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Stok: ${product.stock}",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}