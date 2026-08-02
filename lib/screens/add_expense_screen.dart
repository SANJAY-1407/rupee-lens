import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/denomination_service.dart';
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
  String selectedPaymentMethod = "Cash";

  String selectedDenomination = "₹100";

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

    // 👇 ADD THESE TWO LINES HERE
    final amount = double.parse(amountController.text);
    final description = descriptionController.text.trim();

    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      category: selectedCategory,
      description: description,
      date: DateTime.now(),
      paymentMethod: selectedPaymentMethod,
      denomination: selectedPaymentMethod == "Cash"
          ? DenominationService.calculate(
        int.parse(amountController.text),
      ).join("\n")
          : "UPI",
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

            const Text(
              "THIS IS MY NEW SCREEN",
              style: TextStyle(
                fontSize: 25,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
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
            const SizedBox(height: 15),

            const Text(
              "Payment Method",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            RadioListTile<String>(
              title: const Text("Cash"),
              value: "Cash",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text("UPI"),
              value: "UPI",
              groupValue: selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
            if (selectedPaymentMethod == "Cash") ...[
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedDenomination,
                decoration: const InputDecoration(
                  labelText: "Denomination",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "₹10", child: Text("₹10")),
                  DropdownMenuItem(value: "₹20", child: Text("₹20")),
                  DropdownMenuItem(value: "₹50", child: Text("₹50")),
                  DropdownMenuItem(value: "₹100", child: Text("₹100")),
                  DropdownMenuItem(value: "₹200", child: Text("₹200")),
                  DropdownMenuItem(value: "₹500", child: Text("₹500")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDenomination = value!;
                  });
                },
              ),
            ],
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