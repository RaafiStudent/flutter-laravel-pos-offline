import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CloseShiftPage extends StatefulWidget {
  final String token;

  const CloseShiftPage({super.key, required this.token});

  @override
  State<CloseShiftPage> createState() => _CloseShiftPageState();
}

class _CloseShiftPageState extends State<CloseShiftPage> {
  final TextEditingController saldoController = TextEditingController();
  bool loading = false;
  Map<String, dynamic>? resultData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutup Shift')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (resultData != null) ...[
              Text('Total Transaksi: ${resultData!['data']['total_transaction']}'),
              Text('Total Omzet: ${resultData!['data']['total_omzet']}'),
              Text('Selisih Kas: ${resultData!['data']['cash_difference']}'),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: saldoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Uang Fisik di Laci',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final result = await ApiService.closeShift(
                        widget.token,
                        double.parse(saldoController.text),
                      );

                      setState(() {
                        loading = false;
                        resultData = result;
                      });

                      if (result['success'] == true) {
                        Navigator.pop(context, true);
                      }
                    },
              child: const Text('Tutup Shift'),
            ),
          ],
        ),
      ),
    );
  }
}
