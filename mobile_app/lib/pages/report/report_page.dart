import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';

class ReportPage extends StatefulWidget {
  final String token;

  const ReportPage({super.key, required this.token});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool loading = true;
  Map<String, dynamic>? dailyReport;
  Map<String, dynamic>? monthlyReport;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final daily = await ApiService.getDailyReport(widget.token);
    final now = DateTime.now();
    final monthly = await ApiService.getMonthlyReport(
      widget.token,
      now.month,
      now.year,
    );

    setState(() {
      dailyReport = daily;
      monthlyReport = monthly;
      loading = false;
    });
  }

  Widget infoCard(String title, String value) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dailySummary = dailyReport!['summary'];
    final monthlySummary = monthlyReport!['summary'];
    final topProducts = dailyReport!['top_products'];

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HARIAN =====
            const Text(
              'Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: infoCard(
                    'Omzet',
                    'Rp ${dailySummary['total_omzet']}',
                  ),
                ),
                Expanded(
                  child: infoCard(
                    'Transaksi',
                    dailySummary['total_transaction'].toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== PRODUK TERLARIS =====
            const Text(
              'Produk Terlaris (Hari Ini)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topProducts.length,
                itemBuilder: (_, index) {
                  final item = topProducts[index];
                  return ListTile(
                    title: Text(item['name']),
                    trailing: Text('${item['total_qty']}x'),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ===== BULANAN =====
            const Text(
              'Bulan Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: infoCard(
                    'Omzet',
                    'Rp ${monthlySummary['total_omzet']}',
                  ),
                ),
                Expanded(
                  child: infoCard(
                    'Transaksi',
                    monthlySummary['total_transaction'].toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
