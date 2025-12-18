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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              receipt!['store']['name'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${receipt!['transaction']['date']} '
              '${receipt!['transaction']['time']}',
            ),
            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item['name']} x${item['qty']}'),
                      Text('Rp ${item['subtotal']}'),
                    ],
                  );
                },
              ),
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL'),
                Text('Rp ${receipt!['summary']['total']}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('BAYAR'),
                Text('Rp ${receipt!['summary']['paid']}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('KEMBALI'),
                Text('Rp ${receipt!['summary']['change']}'),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Print thermal akan ditambahkan'),
                  ),
                );
              },
              icon: const Icon(Icons.print),
              label: const Text('Print Struk'),
            ),
          ],
        ),
      ),
    );
  }
}
