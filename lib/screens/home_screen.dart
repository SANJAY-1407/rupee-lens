import 'package:flutter/material.dart';

import '../services/expense_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/recent_title.dart';

import 'add_expense_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import '../models/expense.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  void showEditDialog(Expense expense) {

    final amountController =
    TextEditingController(text: expense.amount.toString());

    final descriptionController =
    TextEditingController(text: expense.description);

    String selectedCategory = expense.category;

    final categories = [
      "Food",
      "Transport",
      "Shopping",
      "Medical",
      "Entertainment",
      "Education",
      "Bills",
      "Others",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Expense"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,

                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () {

                    final updatedExpense =Expense(
                      id: expense.id,
                      amount: double.parse(amountController.text),
                      category: selectedCategory,
                      description: descriptionController.text,
                      date: expense.date,
                      paymentMethod: expense.paymentMethod,
                      denomination: expense.denomination,
                    );

                    ExpenseService.updateExpense(updatedExpense);

                    setState(() {});

                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final filteredExpenses = ExpenseService.getRecentExpenses().where((expense) {
      return expense.category
          .toLowerCase()
          .contains(searchText) ||
          expense.description
              .toLowerCase()
              .contains(searchText);
    }).toList();
    final homePage = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome 👋",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            "Track every rupee wisely.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 25),

          SummaryCard(
            icon: Icons.account_balance_wallet,
            title: "Total Expense",
            value:
            "₹${ExpenseService.getTotalExpense().toStringAsFixed(2)}",
            iconColor: Colors.green,
          ),

          const SizedBox(height: 15),

          SummaryCard(
            icon: Icons.today,
            title: "Today's Expense",
            value:
            "₹${ExpenseService.getTodayExpense().toStringAsFixed(2)}",
            iconColor: Colors.orange,
          ),

          const SizedBox(height: 15),

          SummaryCard(
            icon: Icons.calendar_month,
            title: "This Month",
            value:
            "₹${ExpenseService.getMonthlyExpense().toStringAsFixed(2)}",
            iconColor: Colors.blue,
          ),

          const SizedBox(height: 15),

          SummaryCard(
            icon: Icons.receipt_long,
            title: "Number of Expenses",
            value: ExpenseService.getExpenseCount().toString(),
            iconColor: Colors.purple,
          ),

          const SizedBox(height: 30),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "Search Expense...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
          ),

          const SizedBox(height: 20),
          const Text(
            "Recent Expenses",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          filteredExpenses.isEmpty
          ? const Center(
        child: Text(
          "No expenses yet.",
          style: TextStyle(fontSize: 18),
        ),
      )
          : Column(
            children: filteredExpenses.map((expense) {
          return RecentTile(
            icon: Icons.currency_rupee,
            iconColor: Colors.green,
            title: expense.category,
            subtitle: expense.paymentMethod == "Cash"
                ? "${expense.description} • Cash • ${expense.denomination} notes"
                : "${expense.description} • UPI",
            amount: "₹${expense.amount.toStringAsFixed(2)}",
            onEdit: () {
              showEditDialog(expense);
            },
            onDelete: () {
              setState(() {
                ExpenseService.deleteExpense(expense.id);
              });
            },
          );
        }).toList(),
      ),

        ],
      ),
    );


    final pages = [
      homePage,
      const AddExpenseScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("RupeeLens"),
        centerTitle: true,
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}