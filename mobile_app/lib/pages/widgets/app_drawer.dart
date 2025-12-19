import 'package:flutter/material.dart';
import 'package:mobile_app/pages/shift/shift_status_page.dart';
import 'package:mobile_app/pages/report/report_page.dart';

class AppDrawer extends StatelessWidget {
  final String token;

  const AppDrawer({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // HEADER DRAWER
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kasir Pintar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Menu Kasir',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // MENU: SHIFT
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text('Shift Kasir'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ShiftStatusPage(token: token),
                ),
              );
            },
          ),

          // MENU: LAPORAN
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Laporan Penjualan'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportPage(token: token),
                ),
              );
            },
          ),

          const Spacer(),

          const Divider(),

          // MENU: LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // sementara langsung keluar halaman
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
