import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/presentation/providers/history_provider.dart';
import 'package:mobile_app/presentation/providers/auth_provider.dart';
// --- IMPORT BARU ---
import 'package:mobile_app/data/services/printer_service.dart';
import 'package:mobile_app/core/database/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<HistoryProvider>(context, listen: false).loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<HistoryProvider>(context);
    final currencyFormat = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: "Upload Data Offline",
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final history = Provider.of<HistoryProvider>(context, listen: false);

              if (auth.user?.token == null) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sedang mengupload data...")),
              );

              int count = await history.syncManual(auth.user!.token!);

              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (count > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.green, content: Text("Berhasil mengupload $count transaksi!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua data sudah sinkron (atau gagal koneksi).")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("Belum ada transaksi",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.orders.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final order = history.orders[i];
                    bool isSynced = order['is_synced'] == 1;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order['transaction_code'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormat.format(DateTime.parse(
                                          order['transaction_date'])),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                
                                // --- TOMBOL PRINT & STATUS ---
                                Row(
                                  children: [
                                    // Tombol Print (Baru)
                                    IconButton(
                                      icon: const Icon(Icons.print, color: Colors.blue),
                                      onPressed: () async {
                                        final db = await DatabaseHelper.instance.database;
                                        
                                        // 1. Ambil Detail Item + Nama Produk
                                        final items = await db.rawQuery('''
                                          SELECT i.*, p.name 
                                          FROM order_items i
                                          JOIN products p ON i.product_id = p.id
                                          WHERE i.order_id = ?
                                        ''', [order['id']]);

                                        // 2. Panggil Printer Service
                                        final printer = PrinterService();
                                        if (await printer.isConnected) {
                                          await printer.printStruk(order, items);
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Printer belum terkoneksi. Buka menu Settings."))
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    
                                    const SizedBox(width: 8),

                                    // Indikator Status
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSynced
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSynced
                                                ? Icons.check_circle
                                                : Icons.cloud_off,
                                            size: 16,
                                            color: isSynced
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSynced ? "Synced" : "Offline",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isSynced
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total"),
                                Text(
                                  currencyFormat.format(order['total_amount']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF2962FF)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}