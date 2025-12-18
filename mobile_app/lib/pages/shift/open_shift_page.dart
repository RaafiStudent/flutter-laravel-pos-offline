import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class OpenShiftPage extends StatefulWidget {
  final String token;

  const OpenShiftPage({super.key, required this.token});

  @override
  State<OpenShiftPage> createState() => _OpenShiftPageState();
}

class _OpenShiftPageState extends State<OpenShiftPage> {
  final TextEditingController saldoController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buka Shift')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: saldoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Saldo Awal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final result = await ApiService.openShift(
                        widget.token,
                        double.parse(saldoController.text),
                      );

                      setState(() => loading = false);

                      if (result['success'] == true) {
                        Navigator.pop(context, true);
                      }
                    },
              child: const Text('Konfirmasi Buka Shift'),
            ),
          ],
        ),
      ),
    );
  }
}
