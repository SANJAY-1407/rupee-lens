import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/expense_service.dart';
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context) {

    final weekly = ExpenseService.getWeeklyExpenses();

    double maxY = weekly.reduce((a, b) => a > b ? a : b);

    if (maxY == 0) {
      maxY = 100;
    } else {
      maxY += 100;
    }


    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxY / 500).ceil() * 500,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),

          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 500,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      "₹${value.toInt()}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = [
                    "M",
                    "T",
                    "W",
                    "T",
                    "F",
                    "S",
                    "S",
                  ];

                  return Text(days[value.toInt()]);
                },
              ),
            ),
          ),

          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: weekly[0],
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                )
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: weekly[1],
                  width: 18,
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: weekly[2],
                  width: 18,
                ),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: weekly[3],
                  width: 18,
                ),
              ],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: weekly[4],
                  width: 18,
                ),
              ],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(
                  toY: weekly[5],
                  width: 18,
                ),
              ],
            ),
            BarChartGroupData(
              x: 6,
              barRods: [
                BarChartRodData(
                  toY: weekly[6],
                  width: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}