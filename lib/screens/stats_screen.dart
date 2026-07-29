import 'package:flutter/material.dart';
import '../services/expense_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseService.getExpenses();
    final totalExpense = ExpenseService.getTotalExpense();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: expenses.isEmpty
            ? const Center(
          child: Text(
            "No Expenses Added Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              child: ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                  size: 35,
                ),
                title: const Text(
                  "Total Expense",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "₹ ${totalExpense.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 5,
              child: ListTile(
                leading: const Icon(
                  Icons.receipt_long,
                  color: Colors.blue,
                  size: 35,
                ),
                title: const Text(
                  "Number of Expenses",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  expenses.length.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Expense History",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          "₹",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(expense.category),
                      subtitle: Text(expense.description),
                      trailing: Text(
                        "₹${expense.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}