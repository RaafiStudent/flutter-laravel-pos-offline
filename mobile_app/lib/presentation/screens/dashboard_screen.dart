import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/presentation/providers/product_provider.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/presentation/providers/cart_provider.dart';
import 'package:mobile_app/presentation/screens/cart_screen.dart';
import 'package:mobile_app/presentation/screens/login_screen.dart';
import 'package:mobile_app/presentation/screens/history_screen.dart'; // <--- JANGAN LUPA INI

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).syncData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Kasir", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // --- TOMBOL HISTORY BARU ---
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const HistoryScreen())
              );
            }, 
          ),
          
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
               productProvider.syncData();
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sinkronisasi Data...")));
            }, 
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
      
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.totalItems == 0) return const SizedBox();
          
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFF2962FF),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              "${cart.totalItems} Item | ${currencyFormat.format(cart.totalAmount)}", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          );
        },
      ),

      body: productProvider.isLoading && productProvider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productProvider.products.length,
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  
                  return GestureDetector(
                    onTap: () {
                      Provider.of<CartProvider>(context, listen: false).addItem(product);
                      
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${product.name} masuk keranjang (+1)"),
                          duration: const Duration(milliseconds: 600),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
                        )
                      );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                    ),
                  );
                },
              ),
            ),
    );
  }
}