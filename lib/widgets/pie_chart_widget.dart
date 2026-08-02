import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const PieChartWidget({
    super.key,
    required this.data,
  });
  String getEmoji(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return "🍔";
      case "shopping":
        return "🛍️";
      case "travel":
        return "✈️";
      case "entertainment":
        return "🎬";
      case "medical":
        return "💊";
      case "bills":
        return "💡";
      default:
        return "💰";
    }
  }

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
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: data.entries.map((entry) {
            final percentage = (entry.value / total) * 100;
            final section = PieChartSectionData(
              color: colors[colorIndex % colors.length],
              value: entry.value,
              radius: 100,
              title:
              "${getEmoji(entry.key)} ${entry.key}\n${percentage.toStringAsFixed(0)}%",
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
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