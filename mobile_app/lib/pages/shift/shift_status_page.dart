import 'package:flutter/material.dart';
import 'open_shift_page.dart';
import 'close_shift_page.dart';

class ShiftStatusPage extends StatefulWidget {
  final String token;

  const ShiftStatusPage({super.key, required this.token});

  @override
  State<ShiftStatusPage> createState() => _ShiftStatusPageState();
}

class _ShiftStatusPageState extends State<ShiftStatusPage> {
  bool isShiftOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Kasir'),
      ),
      body: Center(
        child: isShiftOpen
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'SHIFT: OPEN',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CloseShiftPage(token: widget.token),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          isShiftOpen = false;
                        });
                      }
                    },
                    child: const Text('Tutup Shift'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Shift Belum Dibuka',
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OpenShiftPage(token: widget.token),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          isShiftOpen = true;
                        });
                      }
                    },
                    child: const Text('Buka Shift'),
                  ),
                ],
              ),
      ),
    );
  }
}
