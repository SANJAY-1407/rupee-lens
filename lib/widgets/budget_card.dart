import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final double budget;
  final double spent;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget - spent;

    double progress = 0;
    if (budget > 0) {
      progress = spent / budget;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Budget",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "₹${spent.toStringAsFixed(2)} / ₹${budget.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: budget == 0
                ? 0
                : (spent / budget).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(
              spent > budget ? Colors.red : Colors.green,
            ),
          ),
        ),


            const SizedBox(height: 10),

            Text(
              "Remaining ₹${remaining.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}