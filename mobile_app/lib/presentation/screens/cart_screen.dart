import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/presentation/providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _paymentController = TextEditingController();

  // Helper: Format Rupiah
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  // 1. Logic Pembayaran
  void _processPayment(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: User tidak ditemukan")));
      return;
    }

    String input = _paymentController.text.replaceAll(RegExp(r'[^0-9]'), ''); // Hanya ambil angka
    double paymentAmount = double.tryParse(input) ?? 0;

    if (paymentAmount < cart.totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text("Uang pembayaran kurang!"))
      );
      return;
    }

    // Tutup Dialog Input
    Navigator.pop(context); 

    // Eksekusi Logic
    bool success = await cart.checkout(auth.user!, paymentAmount);

    if (success && mounted) {
      _showSuccessDialog(paymentAmount, paymentAmount - cart.totalAmount);
    } else {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaksi Gagal Disimpan"))
        );
      }
    }
  }

  // 2. Dialog Input Uang
  void _showPaymentInput(BuildContext context, double total) {
    _paymentController.text = ""; // Reset input
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pembayaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Total: ${currencyFormat.format(total)}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Masukkan Jumlah Uang",
                border: OutlineInputBorder(),
                prefixText: "Rp ",
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => _processPayment(context),
            child: const Text("Bayar"),
          ),
        ],
      ),
    );
  }

  // 3. Dialog Sukses (Struk Simple)
  void _showSuccessDialog(double pay, double change) {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib klik tombol tutup
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            const Text("Transaksi Berhasil!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bayar:"),
                Text(currencyFormat.format(pay)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Kembalian:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(currencyFormat.format(change), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 18)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text("Data tersimpan di perangkat.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Text("Akan diupload saat online.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2962FF), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx); // Tutup Dialog
                Navigator.pop(context); // Kembali ke Dashboard
              },
              child: const Text("Transaksi Baru"),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Keranjang", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${cart.totalItems} Item", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("Keranjang Kosong", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (ctx, i) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final item = cart.items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                            image: item.product.image != null
                                ? DecorationImage(image: NetworkImage(item.product.image!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: item.product.image == null ? const Icon(Icons.fastfood, size: 20) : null,
                        ),
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(currencyFormat.format(item.product.price)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => cart.removeSingleItem(item.product.id),
                            ),
                            Text("${item.quantity}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => cart.addItem(item.product),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Bayar", style: TextStyle(fontSize: 16)),
                            Text(
                              currencyFormat.format(cart.totalAmount),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2962FF)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _showPaymentInput(context, cart.totalAmount),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2962FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("PROSES PEMBAYARAN", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}