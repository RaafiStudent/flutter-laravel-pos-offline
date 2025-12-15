import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

class PrinterService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // Cek Status Bluetooth
  Future<bool> get isConnected async => (await bluetooth.isConnected) ?? false;

  // Ambil Daftar Perangkat yang sudah Pairing
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await bluetooth.getBondedDevices();
  }

  // Connect ke Printer
  Future<void> connect(BluetoothDevice device) async {
    await bluetooth.connect(device);
  }

  // Disconnect
  Future<void> disconnect() async {
    await bluetooth.disconnect();
  }

  // Fungsi CETAK STRUK
  Future<void> printStruk(Map<String, dynamic> order, List<Map<String, dynamic>> items) async {
    if ((await bluetooth.isConnected) != true) return;

    // Format Uang
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    // --- MULAI CETAK ---
    bluetooth.printNewLine();
    
    // 1. Header
    bluetooth.printCustom("KASIR PINTAR", 3, 1); // Size 3, Center
    bluetooth.printCustom("Jl. Raya Programmer No. 1", 1, 1);
    bluetooth.printNewLine();
    
    bluetooth.printLeftRight("No:", order['transaction_code'], 0);
    bluetooth.printLeftRight("Tgl:", dateFormat.format(DateTime.parse(order['transaction_date'])), 0);
    bluetooth.printCustom("--------------------------------", 1, 1);

    // 2. Item List
    for (var item in items) {
      String name = item['name'] ?? 'Produk'; // Pastikan join di query history nanti benar
      int qty = item['quantity'];
      double price = double.parse(item['price'].toString());
      double total = qty * price;

      bluetooth.printLeftRight(name, "", 0); // Nama Produk
      bluetooth.printLeftRight("$qty x ${currency.format(price)}", currency.format(total), 0);
    }

    bluetooth.printCustom("--------------------------------", 1, 1);

    // 3. Total & Pembayaran
    bluetooth.printLeftRight("Total:", "Rp ${currency.format(order['total_amount'])}", 1);
    bluetooth.printLeftRight("Bayar:", "Rp ${currency.format(order['payment_amount'])}", 0);
    bluetooth.printLeftRight("Kembali:", "Rp ${currency.format(order['change_amount'])}", 0);

    // 4. Footer
    bluetooth.printNewLine();
    bluetooth.printCustom("Terima Kasih", 1, 1);
    bluetooth.printCustom("Barang yang dibeli", 0, 1);
    bluetooth.printCustom("tidak dapat dikembalikan", 0, 1);
    
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.paperCut(); // Potong kertas (jika printer support)
  }
}