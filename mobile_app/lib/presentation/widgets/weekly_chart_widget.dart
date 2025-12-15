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
  bool _isLoading = true;
  
  // State untuk Filter
  String _selectedFilter = '7H'; // Default 7 Hari

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Logic ganti data berdasarkan tombol
  void _loadData() async {
    setState(() => _isLoading = true);

    int days = 7;
    bool isMonthly = false;

    switch (_selectedFilter) {
      case '7H':
        days = 7;
        isMonthly = false;
        break;
      case '1B':
        days = 30;
        isMonthly = false;
        break;
      case '3B':
        days = 90;
        isMonthly = true; // Mulai grouping bulan
        break;
      case '6B':
        days = 180;
        isMonthly = true;
        break;
      case '1T':
        days = 365;
        isMonthly = true;
        break;
    }

    final data = await _service.getRevenueReport(days: days, isMonthly: isMonthly);
    
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  // Widget Tombol Filter Kecil
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

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      height: 320, 
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
          // HEADER
          const Text("Grafik Pendapatan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          // FILTER TOMBOL
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

          // CHART
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _data.isEmpty 
                ? Center(child: Text("Tidak ada data di periode ini", style: TextStyle(color: Colors.grey.shade400)))
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
                                  DateTime date = DateTime.parse(rawDate);
                                  label = DateFormat('dd/MM').format(date);
                                } else {
                                  DateTime date = DateFormat('yyyy-MM').parse(rawDate);
                                  label = DateFormat('MMM').format(date);
                                }

                                if (_data.length > 10 && index % 2 != 0) return const SizedBox(); 

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
                              width: _data.length > 20 ? 8 : 16,
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