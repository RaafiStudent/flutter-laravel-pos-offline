import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Input Formatter
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/presentation/providers/cart_provider.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
import 'package:mobile_app/data/services/order_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Controller untuk input uang bayar
  final TextEditingController _paymentController = TextEditingController();
  
  // Format mata uang Indonesia
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  // Fungsi Helper: Format angka saat diketik (50000 -> 50.000)
  String _formatNumber(String s) {
    if (s.isEmpty) return "";
    s = s.replaceAll('.', ''); // Hapus titik lama
    if (s.isEmpty) return "";
    try {
      final number = int.parse(s);
      return NumberFormat.decimalPattern('id').format(number);
    } catch (e) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Keranjang", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${cart.totalItems} Item", style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // LIST ITEM KERANJANG
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text("Keranjang Kosong"))
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items.values.toList()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: item.product.image != null
                              ? Image.network(item.product.image!, width: 50, height: 50, fit: BoxFit.cover)
                              : Container(color: Colors.grey, width: 50, height: 50, child: const Icon(Icons.fastfood)),
                          title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(currencyFormat.format(item.product.price)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => cart.removeItem(item.product.id),
                              ),
                              Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () => cart.addItem(item.product),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // BAGIAN PEMBAYARAN DI BAWAH
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2962FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: cart.items.isEmpty 
                      ? null 
                      : () {
                          _paymentController.clear(); // Reset input
                          _showPaymentDialog(context, cart, authProvider);
                      },
                    child: const Text("PROSES PEMBAYARAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC DIALOG PEMBAYARAN (MALL STYLE) ---
  void _showPaymentDialog(BuildContext context, CartProvider cart, AuthProvider auth) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (ctx) {
        // StatefulBuilder AGAR DIALOG BISA UPDATE SAAT KETIK
        return StatefulBuilder(
          builder: (context, setState) {
            
            double totalBill = cart.totalAmount;
            double paymentAmount = 0;
            
            // Logic parse uang (hapus titik)
            if (_paymentController.text.isNotEmpty) {
              try {
                paymentAmount = double.parse(_paymentController.text.replaceAll('.', ''));
              } catch (e) {
                paymentAmount = 0;
              }
            }
            double change = paymentAmount - totalBill;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Center(child: Text("Pembayaran", style: TextStyle(fontWeight: FontWeight.bold))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Total Tagihan", style: TextStyle(color: Colors.grey.shade600)),
                  Text(currencyFormat.format(totalBill), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // INPUT UANG (BANK STYLE)
                  TextField(
                    controller: _paymentController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Masukkan Uang Diterima",
                      prefixText: "Rp ",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      // Error merah jika uang kurang
                      errorText: (paymentAmount > 0 && paymentAmount < totalBill) 
                          ? "Kurang ${currencyFormat.format(totalBill - paymentAmount)}" 
                          : null,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, 
                    ],
                    onChanged: (string) {
                      // Logic format ribuan real-time
                      if (string.isNotEmpty) {
                        String formatted = _formatNumber(string);
                        // Trik agar kursor tidak lompat ke depan
                        _paymentController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                      setState(() {}); // Refresh dialog agar kembalian terhitung
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // KOTAK KEMBALIAN (Muncul jika uang cukup)
                  if (paymentAmount >= totalBill) 
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kembalian:", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(change),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2962FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  // Tombol mati jika uang kurang
                  onPressed: (paymentAmount >= totalBill) 
                    ? () async {
                        Navigator.pop(context); // Tutup dialog input

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Memproses Transaksi...")));

                        // PANGGIL SERVICE
                        final OrderService service = OrderService();
                        bool success = await service.processTransaction(
                          user: auth.user!,
                          items: cart.items.values.toList(),
                          totalAmount: totalBill,
                          paymentAmount: paymentAmount,
                          changeAmount: change,
                        );

                        if (success) {
                          cart.clearCart();
                          if (mounted) {
                            _showSuccessDialog(context, totalBill, paymentAmount, change);
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaksi Gagal!")));
                          }
                        }
                      } 
                    : null,
                  child: const Text("Bayar & Cetak", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG SUKSES (STRUK DIGITAL) ---
  void _showSuccessDialog(BuildContext context, double total, double pay, double change) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text("Transaksi Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Divider(),
              
              _buildStrukRow("Total Tagihan", total, isBold: true),
              const SizedBox(height: 8),
              _buildStrukRow("Tunai", pay),
              const SizedBox(height: 8),
              _buildStrukRow("Kembalian", change, color: Colors.green, isBold: true),
              
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "Data tersimpan di perangkat.\nAkan diupload saat online.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2962FF)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Transaksi Baru", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // WIDGET KECIL UNTUK BARIS STRUK
  Widget _buildStrukRow(String label, double value, {bool isBold = false, Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Text(
          currencyFormat.format(value),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
            fontSize: isBold ? 16 : 14
          ),
        ),
      ],
    );
  }
}