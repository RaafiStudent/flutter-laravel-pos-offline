import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/data/services/order_service.dart';

class WeeklyChartWidget extends StatefulWidget {
  const WeeklyChartWidget({super.key});

  @override
  State<WeeklyChartWidget> createState() => _WeeklyChartWidgetState();
}

class _WeeklyChartWidgetState extends State<WeeklyChartWidget> {
  final OrderService _service = OrderService();
  
  List<Map<String, dynamic>> _data = [];
  double _todayRevenue = 0; // Variabel khusus Hari Ini
  bool _isLoading = true;
  
  // State untuk Filter
  String _selectedFilter = '7H'; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Logic load data (Grafik + Hari Ini)
  void _loadData() async {
    setState(() => _isLoading = true);

    int limit = 7;
    bool isMonthly = false;

    switch (_selectedFilter) {
      case '7H':
        limit = 7; 
        isMonthly = false;
        break;
      case '1B':
        limit = 30; 
        isMonthly = false;
        break;
      case '3B':
        limit = 3; 
        isMonthly = true; 
        break;
      case '6B':
        limit = 6; 
        isMonthly = true;
        break;
      case '1T':
        limit = 12; 
        isMonthly = true;
        break;
    }

    // Ambil Data Grafik
    final data = await _service.getRevenueReport(limit: limit, isMonthly: isMonthly);
    // Ambil Data Hari Ini Terpisah
    final today = await _service.getTodayRevenue();
    
    if (mounted) {
      setState(() {
        _data = data.reversed.toList();
        _todayRevenue = today; // Simpan data hari ini
        _isLoading = false;
      });
    }
  }

  // Widget Tombol Filter
  Widget _buildFilterButton(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2962FF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300)
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactSimpleCurrency(locale: 'id_ID');
    final fullCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      height: 360, // Tinggi disesuaikan biar muat teks besar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: Pendapatan Hari Ini (Besar)
          const Text("Pendapatan Hari Ini", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            fullCurrency.format(_todayRevenue), 
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF2962FF)
            )
          ),
          
          const Divider(height: 24),

          // 2. FILTER BUTTONS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('7H'),
                const SizedBox(width: 8),
                _buildFilterButton('1B'),
                const SizedBox(width: 8),
                _buildFilterButton('3B'),
                const SizedBox(width: 8),
                _buildFilterButton('6B'),
                const SizedBox(width: 8),
                _buildFilterButton('1T'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. CHART BODY
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _data.isEmpty 
                ? Center(child: Text("Tidak ada data periode ini", style: TextStyle(color: Colors.grey.shade400)))
                : BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.blueGrey,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String period = _data[group.x.toInt()]['period'];
                            return BarTooltipItem(
                              '$period\n',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: currency.format(rod.toY),
                                  style: const TextStyle(color: Colors.yellowAccent),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < _data.length) {
                                String rawDate = _data[index]['period'];
                                
                                String label = "";
                                if (rawDate.length == 10) {
                                  // Harian: Tgl/Bln
                                  DateTime date = DateTime.parse(rawDate);
                                  label = DateFormat('dd/MM').format(date);
                                } else {
                                  // Bulanan: Nama Bulan
                                  DateTime date = DateFormat('yyyy-MM').parse(rawDate);
                                  label = DateFormat('MMM').format(date);
                                }

                                // Logic agar label tidak bertumpuk jika data banyak
                                if (_data.length > 15 && index % 3 != 0) return const SizedBox(); 
                                if (_data.length > 7 && _data.length <= 15 && index % 2 != 0) return const SizedBox();

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    label,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      barGroups: _data.asMap().entries.map((entry) {
                        int index = entry.key;
                        double total = double.parse(entry.value['total'].toString());
                        
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: total,
                              color: const Color(0xFF2962FF),
                              width: _data.length > 20 ? 6 : 12, // Batang mengecil otomatis
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}