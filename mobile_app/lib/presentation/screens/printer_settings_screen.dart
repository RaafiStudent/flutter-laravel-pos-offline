import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/data/services/printer_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrinterService _printerService = PrinterService();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initPrinter();
  }

  void _initPrinter() async {
    // Minta Izin Dulu
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    // Load Devices
    setState(() => _isLoading = true);
    List<BluetoothDevice> devices = await _printerService.getBondedDevices();
    
    bool status = await _printerService.isConnected;

    setState(() {
      _devices = devices;
      _isConnected = status;
      _isLoading = false;
    });
  }

  void _connect(BluetoothDevice device) async {
    setState(() => _isLoading = true);
    try {
      await _printerService.connect(device);
      setState(() {
        _selectedDevice = device;
        _isConnected = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Printer Terhubung!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
    setState(() => _isLoading = false);
  }

  void _disconnect() async {
    await _printerService.disconnect();
    setState(() => _isConnected = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Printer")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.print, color: _isConnected ? Colors.green : Colors.grey, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Status Printer:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _isConnected 
                            ? "Terhubung: ${_selectedDevice?.name ?? 'Unknown'}" 
                            : "Tidak Terhubung",
                          style: TextStyle(color: _isConnected ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Perangkat Paired (Sambungkan Bluetooth di Pengaturan HP dulu):", 
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      title: Text(device.name ?? "Unknown Device"),
                      subtitle: Text(device.address ?? "-"),
                      trailing: ElevatedButton(
                        onPressed: _isConnected ? null : () => _connect(device),
                        child: const Text("Connect"),
                      ),
                    );
                  },
                ),
              ),
              if (_isConnected)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: _disconnect,
                      child: const Text("Putus Koneksi Printer"),
                    ),
                  ),
                )
            ],
          ),
    );
  }
}