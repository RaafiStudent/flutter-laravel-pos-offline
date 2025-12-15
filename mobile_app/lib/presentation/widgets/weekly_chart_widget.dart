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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _service.getWeeklyRevenue();
    if (mounted) {
      setState(() {
        _data = data.reversed.toList(); // Urutkan Senin -> Minggu
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
    if (_data.isEmpty) return const SizedBox(); 

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      height: 250,
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
          const Text("Pendapatan 7 Hari Terakhir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < _data.length) {
                          String dateStr = _data[index]['date'];
                          DateTime date = DateTime.parse(dateStr);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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