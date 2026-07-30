import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const PieChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No Data Available",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
    ];

    int colorIndex = 0;

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((entry) {
            final section = PieChartSectionData(
              color: colors[colorIndex % colors.length],
              value: entry.value,
              radius: 90,
              title:
              "${entry.key}\n₹${entry.value.toStringAsFixed(0)}",
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );

            colorIndex++;
            return section;
          }).toList(),
        ),
      ),
    );
  }
}