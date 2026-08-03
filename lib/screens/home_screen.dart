import 'package:flutter/material.dart';

import '../services/expense_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/recent_title.dart';

import 'add_expense_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import '../models/expense.dart';
import '../services/budget_service.dart';
import '../widgets/budget_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}
final highestExpense = ExpenseService.getHighestExpense();
class _HomeScreenState extends State<HomeScreen> {
  double monthlyBudget = 0;
  int currentIndex = 0;
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadBudget();
  }
  Future<void> loadBudget() async {
    monthlyBudget = await BudgetService.getBudget();



    setState(() {});
  }
  String searchText = "";
  String sortOption = "Latest";
  String selectedFilter = "All";
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
      "House Rent",
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
                      initialValue: selectedCategory,

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

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.blue,
                        content: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Expense Updated Successfully"),
                          ],
                        ),
                      ),
                    );


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
    List<Expense> recentExpenses = ExpenseService.getRecentExpenses();

    final now = DateTime.now();

    if (selectedFilter == "Today") {
      recentExpenses = recentExpenses.where((e) =>
      e.date.day == now.day &&
          e.date.month == now.month &&
          e.date.year == now.year).toList();
    }

    if (selectedFilter == "This Week") {
      recentExpenses = recentExpenses.where((e) =>
      now.difference(e.date).inDays <= 7).toList();
    }

    if (selectedFilter == "This Month") {
      recentExpenses = recentExpenses.where((e) =>
      e.date.month == now.month &&
          e.date.year == now.year).toList();
    }
    final filteredExpenses = recentExpenses.where((expense) {
      return expense.category
          .toLowerCase()
          .contains(searchText) ||

          expense.description
              .toLowerCase()
              .contains(searchText) ||

          expense.amount
              .toString()
              .contains(searchText) ||

          expense.paymentMethod
              .toLowerCase()
              .contains(searchText);
    }).toList();

    switch (sortOption) {
      case "Latest":
        filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
        break;

      case "Oldest":
        filteredExpenses.sort((a, b) => a.date.compareTo(b.date));
        break;

      case "Highest":
        filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;

      case "Lowest":
        filteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;

      case "A-Z":
        filteredExpenses.sort((a, b) => a.category.compareTo(b.category));
        break;

      case "Z-A":
        filteredExpenses.sort((a, b) => b.category.compareTo(a.category));
        break;
    }

    final allExpenses = ExpenseService.getExpenses();

    double totalSpent = ExpenseService.getTotalExpense();

    final remainingBudget = monthlyBudget - totalSpent;
    final budgetProgress = monthlyBudget <= 0
        ? 0.0
        : (totalSpent / monthlyBudget).clamp(0.0, 1.0);

    final totalDays =
        DateTime(now.year, now.month + 1, 0).day;

    final dailyGoal = monthlyBudget / totalDays;

    final todayExpense = ExpenseService.getTodayExpense();
    final mostUsedPayment = ExpenseService.getMostUsedPaymentMethod();
    final mostSpentCategory = ExpenseService.getMostSpentCategory();
    final monthlyExpenseCount =
    ExpenseService.getMonthlyExpenseCount();
    final averagePerDay = ExpenseService.getAverageExpensePerDay();


    String highestCategory = "No Expenses";

    if (allExpenses.isNotEmpty) {
      final Map<String, double> categoryTotals = {};

      for (var expense in allExpenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      highestCategory = categoryTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }
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
            decoration: InputDecoration(
              hintText: "Search Expense...",
              prefixIcon: const Icon(Icons.search),

              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchText = "";
                  });
                },
              )
                  : null,

              border: const OutlineInputBorder(),
            ),

            onChanged: (value) {
              setState(() {
                searchText = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: sortOption,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.sort),
              labelText: "Sort By",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: "Latest",
                child: Text("Latest"),
              ),
              DropdownMenuItem(
                value: "Oldest",
                child: Text("Oldest"),
              ),
              DropdownMenuItem(
                value: "Highest",
                child: Text("Highest Amount"),
              ),
              DropdownMenuItem(
                value: "Lowest",
                child: Text("Lowest Amount"),
              ),
              DropdownMenuItem(
                value: "A-Z",
                child: Text("Category A-Z"),
              ),
              DropdownMenuItem(
                value: "Z-A",
                child: Text("Category Z-A"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                sortOption = value!;
              });
            },
          ),

          const SizedBox(height: 20),

          BudgetCard(
            budget: monthlyBudget,
            spent: ExpenseService.getTotalExpense(),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📊 Monthly Budget Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: budgetProgress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetProgress >= 1
                          ? Colors.red
                          : budgetProgress >= 0.9
                          ? Colors.orange
                          : budgetProgress >= 0.75
                          ? Colors.amber
                          : Colors.green,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(budgetProgress * 100).toStringAsFixed(1)}% of monthly budget used",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🎯 Daily Spending Goal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Daily Goal : ₹${dailyGoal.toStringAsFixed(2)}",
                  ),

                  Text(
                    "Today's Expense : ₹${todayExpense.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: dailyGoal <= 0
                        ? 0
                        : (todayExpense / dailyGoal).clamp(0.0, 1.0),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      todayExpense > dailyGoal
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),

                  const SizedBox(height: 8),


                  const SizedBox(height: 10),

                  Text(
                    todayExpense > dailyGoal
                        ? "🚨 Daily Limit Exceeded!"
                        : "✅ You're within today's limit.",
                    style: TextStyle(
                      color: todayExpense > dailyGoal
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.payments, color: Colors.blue),
                    title: const Text("Most Used Payment : "),
                    subtitle: Text(mostUsedPayment),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                    title: const Text("Most Spent Category : "),
                    subtitle: Text(mostSpentCategory),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month,
                      color: Colors.teal,
                    ),
                    title: const Text("Expenses This Month : "),
                    subtitle: Text("$monthlyExpenseCount Expenses"),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                    ),
                    title: const Text("Average Per Day : "),
                    subtitle: Text("₹${averagePerDay.toStringAsFixed(2)}"),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.workspace_premium,
                      color: Colors.red,
                    ),
                    title: const Text("Highest Expense : "),
                    subtitle: Text("₹${highestExpense.toStringAsFixed(2)}"),
                  ),

                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        "Smart Insights",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text("🏆 Highest Category : $highestCategory"),

                  const SizedBox(height: 8),

                  Text("💸 Total Spent : ₹${totalSpent.toStringAsFixed(2)}"),

                  const SizedBox(height: 8),

                  Text(
                    "💰 Remaining Budget : ₹${remainingBudget.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: remainingBudget < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "📊 Budget Used : ${monthlyBudget > 0 ? ((totalSpent / monthlyBudget) * 100).toStringAsFixed(1) : "0"}%",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "📦 Total Expenses : ${ExpenseService.getExpenseCount()}",
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(

                      color: monthlyBudget <= 0
                          ? Colors.grey.shade200
                          : totalSpent >= monthlyBudget
                          ? Colors.red.shade100
                          : totalSpent >= monthlyBudget * 0.9
                          ? Colors.red.shade50
                          : totalSpent >= monthlyBudget * 0.75
                          ? Colors.orange.shade100
                          : totalSpent >= monthlyBudget * 0.5
                          ? Colors.yellow.shade100
                          : Colors.green.shade100,


                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      BudgetService.getBudgetStatus(
                        totalSpent,
                        monthlyBudget,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),



                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),


          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              "Today",
              "This Week",
              "This Month",
              "All",
            ].map((filter) {
              return ChoiceChip(
                label: Text(filter),
                selected: selectedFilter == filter,
                onSelected: (_) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                "Recent Expenses",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

        if (filteredExpenses.isEmpty)
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: const [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 15),
            Text(
              "No expenses found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Try another filter.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    )
    else
    Column(
    children: filteredExpenses.map((expense) {
    return RecentTile(
    icon: Icons.currency_rupee,
    iconColor: Colors.green,
    title: expense.category,
    subtitle: expense.paymentMethod == "Cash"
    ? "${expense.description} • Cash • ${expense.denomination} "
        : "${expense.description} • UPI",
    amount: "₹${expense.amount.toStringAsFixed(2)}",
    onEdit: () {
    showEditDialog(expense);
    },

      onDelete: () async {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete Expense"),
              content: const Text(
                "Are you sure you want to delete this expense?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );

        if (shouldDelete == true) {
          setState(() {
            ExpenseService.deleteExpense(expense.id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Row(
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Expense Deleted Successfully"),
                ],
              ),
            ),
          );
        }
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
        onTap: (index) async {
          if (index == 0) {
            await loadBudget();
          }

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