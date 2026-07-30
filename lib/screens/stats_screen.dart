import 'package:flutter/material.dart';

import '../services/expense_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/pie_chart_widget.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ExpenseService.getCategoryTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCard(
              icon: Icons.account_balance_wallet,
              title: "Total Expense",
              value:
              "₹${ExpenseService.getTotalExpense().toStringAsFixed(2)}",
              iconColor: Colors.green,
            ),

            const SizedBox(height: 15),

            SummaryCard(
              icon: Icons.arrow_upward,
              title: "Highest Expense",
              value:
              "₹${ExpenseService.getHighestExpense().toStringAsFixed(2)}",
              iconColor: Colors.red,
            ),

            const SizedBox(height: 15),

            SummaryCard(
              icon: Icons.arrow_downward,
              title: "Lowest Expense",
              value:
              "₹${ExpenseService.getLowestExpense().toStringAsFixed(2)}",
              iconColor: Colors.blue,
            ),

            const SizedBox(height: 15),

            SummaryCard(
              icon: Icons.calculate,
              title: "Average Expense",
              value:
              "₹${ExpenseService.getAverageExpense().toStringAsFixed(2)}",
              iconColor: Colors.orange,
            ),

            const SizedBox(height: 30),

            const Text(
              "Category Wise",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            if (categories.isEmpty)
              const Column(
                children: [
                  SizedBox(height: 20),
                  Icon(
                    Icons.pie_chart_outline,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "No Expenses Added Yet",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Add some expenses to view statistics.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            else ...[
              PieChartWidget(data: categories),
              const SizedBox(height: 20),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(entry.key),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              ...categories.entries.map(
                    (entry) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.category,
                      color: Colors.green,
                    ),
                    title: Text(entry.key),
                    trailing: Text(
                      "₹${entry.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}