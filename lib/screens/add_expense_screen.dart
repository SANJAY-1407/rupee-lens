import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/expense_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String selectedCategory = "Food";

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Medical",
    "Entertainment",
    "Education",
    "Bills",
    "Others",
  ];
  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      amountController.text = widget.expense!.amount.toString();
      descriptionController.text = widget.expense!.description;
      selectedCategory = widget.expense!.category;
    }
  }
  Future<void> saveExpense() async {
    if (amountController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    final expense = Expense(
      id: widget.expense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(amountController.text),
      category: selectedCategory,
      description: descriptionController.text,
      date: DateTime.now(),
    );

    if (widget.expense == null) {
      ExpenseService.addExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense Added Successfully"),
        ),
      );
    } else {
      ExpenseService.updateExpense(expense);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Expense Updated Successfully"),
        ),
      );
    }

    amountController.clear();
    descriptionController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16),

      child: SingleChildScrollView(

        child: Column(

          children: [

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(

              value: selectedCategory,

              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),

              items: categories.map((category) {

                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedCategory = value!;
                });

              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveExpense,
                child: Text(
                  widget.expense == null
                      ? "Add Expense"
                      : "Update Expense",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}