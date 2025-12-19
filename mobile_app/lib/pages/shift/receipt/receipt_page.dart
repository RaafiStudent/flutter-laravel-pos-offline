import 'package:flutter/material.dart';
import 'package:mobile_app/services/api_service.dart';

class ReceiptPage extends StatefulWidget {
  final String token;
  final int orderId;

  const ReceiptPage({
    super.key,
    required this.token,
    required this.orderId,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  Map<String, dynamic>? receipt;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchReceipt();
  }

  Future<void> fetchReceipt() async {
    final result =
        await ApiService.getReceipt(widget.token, widget.orderId);

    setState(() {
      receipt = result['data'];
      loading = false;
    });
  }

  Widget dashedLine() {
    return const Text(
      '--------------------------------',
      style: TextStyle(fontSize: 12),
    );
  }

  Widget rowText(String left, String right,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = receipt!['items'];

    return Scaffold(
      appBar: AppBar(title: const Text('Struk Belanja')),
      body: Center(
        child: Container(
          width: 280, // mirip kertas thermal 58mm
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              // HEADER TOKO
              Text(
                receipt!['store']['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                receipt!['store']['address'] ?? '',
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '${receipt!['transaction']['date']} '
                '${receipt!['transaction']['time']}',
                style: const TextStyle(fontSize: 10),
              ),

              const SizedBox(height: 6),
              dashedLine(),

              // ITEM LIST
              ...items.map<Widget>((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: rowText(
                    '${item['name']} x${item['qty']}',
                    item['subtotal'].toString(),
                  ),
                );
              }).toList(),

              dashedLine(),

              // TOTAL
              rowText(
                'TOTAL',
                receipt!['summary']['total'].toString(),
                bold: true,
              ),
              rowText(
                'BAYAR',
                receipt!['summary']['paid'].toString(),
              ),
              rowText(
                'KEMBALI',
                receipt!['summary']['change'].toString(),
              ),

              dashedLine(),

              const SizedBox(height: 8),
              const Text(
                'Terima Kasih\nSelamat Berbelanja',
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // BUTTON PRINT (dummy dulu)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Print thermal akan ditambahkan'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
