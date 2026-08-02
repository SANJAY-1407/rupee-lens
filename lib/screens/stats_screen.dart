import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../widgets/pie_chart_widget.dart';
import '../services/pdf_service.dart';
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String getEmoji(String category) {
    switch (category.toLowerCase()) {
      case "food":
        return "🍔";
      case "shopping":
        return "🛍";
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
    final categoryTotals = ExpenseService.getCategoryTotals();
    final monthlyTotals = ExpenseService.getMonthlyCategoryTotals();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          const Text(
            "Statistics",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await PdfService.generateExpenseReport();
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Export Expense Report"),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet,
                  color: Colors.green),
              title: const Text("Total Expense"),
              trailing: Text(
                "₹${ExpenseService.getTotalExpense().toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_upward,
                  color: Colors.red),
              title: const Text("Highest Expense"),
              trailing: Text(
                "₹${ExpenseService.getHighestExpense().toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.arrow_downward,
                  color: Colors.blue),
              title: const Text("Lowest Expense"),
              trailing: Text(
                "₹${ExpenseService.getLowestExpense().toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.calculate,
                  color: Colors.orange),
              title: const Text("Average Expense"),
              trailing: Text(
                "₹${ExpenseService.getAverageExpense().toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long,
                  color: Colors.purple),
              title: const Text("Number of Expenses"),
              trailing: Text(
                ExpenseService.getExpenseCount().toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 25),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Category Wise Expense",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          PieChartWidget(
            data: categoryTotals,
          ),

          ...categoryTotals.entries.map(
                (entry) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.category,
                  color: Colors.green,
                ),
                title: Text(
                  "${getEmoji(entry.key)} ${entry.key}",
                ), 
                trailing: Text(
                  "₹${entry.value.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ).toList(),

          const SizedBox(height: 30),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "This Month Report",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          ...monthlyTotals.entries.map(
                (entry) => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Colors.blue,
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
      ),
    );
  }
}