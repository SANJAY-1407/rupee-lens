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
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _InsightMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InsightMiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.60),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 17,
              color: color,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  double monthlyBudget = 0;
  int currentIndex = 0;

  final TextEditingController searchController =
  TextEditingController();

  String searchText = "";
  String sortOption = "Latest";
  String selectedFilter = "All";
  DateTime? selectedDate;
  String selectedCategory = "All";
  String selectedPaymentMethod = "All";

  @override
  void initState() {
    super.initState();
    loadBudget();
  }

  Future<void> loadBudget() async {
    monthlyBudget = await BudgetService.getBudget();

    final monthlyExpense =
    ExpenseService.getMonthlyExpense();

    final exceeded =
    await BudgetService.isBudgetExceeded(monthlyExpense);

    if (exceeded) {
      await NotificationService.showNotification(
        title: "⚠️ Budget Alert",
        body: "You have exceeded your monthly budget!",
      );
    }

    setState(() {});
  }

  void showEditDialog(Expense expense) {
    final amountController =
    TextEditingController(
      text: expense.amount.toString(),
    );

    final descriptionController =
    TextEditingController(
      text: expense.description,
    );

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
                    final updatedExpense = Expense(
                      id: expense.id,
                      amount:
                      double.parse(amountController.text),
                      category: selectedCategory,
                      description:
                      descriptionController.text,
                      date: expense.date,
                      paymentMethod:
                      expense.paymentMethod,
                      denomination:
                      expense.denomination,
                    );

                    ExpenseService.updateExpense(
                      updatedExpense,
                    );

                    setState(() {});

                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context)
                        .showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.blue,
                        content: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Expense Updated Successfully",
                            ),
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
    List<Expense> recentExpenses =
    ExpenseService.getRecentExpenses();

    final now = DateTime.now();

    if (selectedFilter == "Today") {
      recentExpenses = recentExpenses.where((e) {
        return e.date.day == now.day &&
            e.date.month == now.month &&
            e.date.year == now.year;
      }).toList();
    }

    if (selectedFilter == "This Week") {
      recentExpenses = recentExpenses.where((e) {
        return now.difference(e.date).inDays <= 7;
      }).toList();
    }

    if (selectedFilter == "This Month") {
      recentExpenses = recentExpenses.where((e) {
        return e.date.month == now.month &&
            e.date.year == now.year;
      }).toList();
    }

    if (selectedDate != null) {
      recentExpenses = recentExpenses.where((expense) {
        return expense.date.day == selectedDate!.day &&
            expense.date.month == selectedDate!.month &&
            expense.date.year == selectedDate!.year;
      }).toList();
    }

    if (selectedCategory != "All") {
      recentExpenses = recentExpenses.where((expense) {
        return expense.category == selectedCategory;
      }).toList();
    }

    if (selectedPaymentMethod != "All") {
      recentExpenses =
          recentExpenses.where((expense) {
            return expense.paymentMethod ==
                selectedPaymentMethod;
          }).toList();
    }

    final filteredExpenses =
    recentExpenses.where((expense) {
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
        filteredExpenses.sort(
              (a, b) => b.date.compareTo(a.date),
        );
        break;

      case "Oldest":
        filteredExpenses.sort(
              (a, b) => a.date.compareTo(b.date),
        );
        break;

      case "Highest":
        filteredExpenses.sort(
              (a, b) => b.amount.compareTo(a.amount),
        );
        break;

      case "Lowest":
        filteredExpenses.sort(
              (a, b) => a.amount.compareTo(b.amount),
        );
        break;

      case "A-Z":
        filteredExpenses.sort(
              (a, b) =>
              a.category.compareTo(b.category),
        );
        break;

      case "Z-A":
        filteredExpenses.sort(
              (a, b) =>
              b.category.compareTo(a.category),
        );
        break;
    }

    final allExpenses = ExpenseService.getExpenses();

    final double monthlySpent =
    ExpenseService.getMonthlyExpense();

    final remainingBudget =
        monthlyBudget - monthlySpent;

    final budgetProgress = monthlyBudget <= 0
        ? 0.0
        : (monthlySpent / monthlyBudget)
        .clamp(0.0, 1.0);

    final totalDays =
        DateTime(now.year, now.month + 1, 0).day;

    final dailyGoal =
        monthlyBudget / totalDays;

    final todayExpense =
    ExpenseService.getTodayExpense();

    final monthlyExpenseCount =
    ExpenseService.getMonthlyExpenseCount();

    String highestCategory = "No Expenses";

    if (allExpenses.isNotEmpty) {
      final Map<String, double> categoryTotals = {};

      for (var expense in allExpenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) +
                expense.amount;
      }

      highestCategory = categoryTotals.entries
          .reduce(
            (a, b) =>
        a.value > b.value ? a : b,
      )
          .key;
    }

    final homePage = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
            value:
            ExpenseService.getExpenseCount().toString(),
            iconColor: Colors.purple,
          ),

          const SizedBox(height: 30),

          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search Expense...",
              prefixIcon:
              const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                icon:
                const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    searchText = "";
                  });
                },
              )
                  : null,
              border:
              const OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchText =
                    value.toLowerCase();
              });
            },
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: sortOption,
            decoration: const InputDecoration(
              prefixIcon:
              Icon(Icons.sort),
              labelText: "Sort By",
              border:
              OutlineInputBorder(),
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
                child:
                Text("Highest Amount"),
              ),
              DropdownMenuItem(
                value: "Lowest",
                child:
                Text("Lowest Amount"),
              ),
              DropdownMenuItem(
                value: "A-Z",
                child:
                Text("Category A-Z"),
              ),
              DropdownMenuItem(
                value: "Z-A",
                child:
                Text("Category Z-A"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                sortOption = value!;
              });
            },
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────────────
          // DAILY SPENDING GOAL
          // ─────────────────────────────────────

          Card(
            elevation: 0,
            child: Padding(
              padding:
              const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration:
                        BoxDecoration(
                          color: Colors.orange
                              .withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .track_changes_rounded,
                          color:
                          Colors.orange,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              "Daily Spending Goal",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Keep today's spending within your goal",
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Text(
                            "Today's Spending",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Colors.grey,
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          Text(
                            "₹${todayExpense.toStringAsFixed(2)}",
                            style:
                            const TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .end,
                        children: [
                          const Text(
                            "Daily Goal",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                              Colors.grey,
                            ),
                          ),

                          const SizedBox(
                              height: 4),

                          Text(
                            "₹${dailyGoal.toStringAsFixed(2)}",
                            style:
                            const TextStyle(
                              fontSize: 22,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                    child:
                    LinearProgressIndicator(
                      minHeight: 10,
                      value: dailyGoal <= 0
                          ? 0
                          : (todayExpense /
                          dailyGoal)
                          .clamp(
                        0.0,
                        1.0,
                      ),
                      backgroundColor:
                      Colors.grey
                          .withValues(
                        alpha: 0.12,
                      ),
                      valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                        todayExpense >
                            dailyGoal
                            ? Colors.red
                            : todayExpense >=
                            dailyGoal *
                                0.75
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        todayExpense >
                            dailyGoal
                            ? Icons
                            .warning_rounded
                            : todayExpense >=
                            dailyGoal *
                                0.75
                            ? Icons
                            .info_outline_rounded
                            : Icons
                            .check_circle_rounded,
                        size: 19,
                        color: todayExpense >
                            dailyGoal
                            ? Colors.red
                            : todayExpense >=
                            dailyGoal *
                                0.75
                            ? Colors.orange
                            : Colors.green,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          todayExpense >
                              dailyGoal
                              ? "🚨 Daily spending goal exceeded!"
                              : todayExpense >=
                              dailyGoal *
                                  0.75
                              ? "⚠️ You are getting close to today's goal."
                              : "✅ You're within today's spending goal.",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w600,
                            color: todayExpense >
                                dailyGoal
                                ? Colors.red
                                : todayExpense >=
                                dailyGoal *
                                    0.75
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    dailyGoal <= 0
                        ? "Set a monthly budget to calculate your daily spending goal."
                        : "Daily goal is calculated from your monthly budget.",
                    style:
                    const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─────────────────────────────────────
          // SMART INSIGHTS
          // ─────────────────────────────────────

          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Smart Insights",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "🏆 Highest Category : $highestCategory",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "💸 Total Spent This Month : ₹${monthlySpent.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "💰 Remaining Budget : ₹${remainingBudget.toStringAsFixed(2)}",
                    style: TextStyle(
                      color:
                      remainingBudget < 0
                          ? Colors.red
                          : Colors.green,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "📊 Budget Used : ${monthlyBudget > 0
                        ? ((monthlySpent / monthlyBudget) * 100)
                        .toStringAsFixed(1)
                        : "0"}%",
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "📦 Total Expenses : ${ExpenseService.getExpenseCount()}",
                  ),

                  const SizedBox(height: 8),

                  // Expenses This Month
                  Text(
                    "🗓️ Expenses This Month : $monthlyExpenseCount Expenses",
                  ),

                  const SizedBox(height: 10),

                  Builder(
                    builder: (context) {
                      final isDark =
                          Theme.of(context)
                              .brightness ==
                              Brightness.dark;

                      final double percentage =
                      monthlyBudget <= 0
                          ? 0
                          : (monthlySpent /
                          monthlyBudget)
                          .clamp(
                        0.0,
                        1.0,
                      );

                      final String status =
                      BudgetService
                          .getBudgetStatus(
                        monthlySpent,
                        monthlyBudget,
                      );

                      final bool exceeded =
                          monthlyBudget > 0 &&
                              monthlySpent >=
                                  monthlyBudget;

                      final bool warning =
                          monthlyBudget > 0 &&
                              monthlySpent >=
                                  monthlyBudget *
                                      0.75 &&
                              monthlySpent <
                                  monthlyBudget;

                      final Color statusColor =
                      monthlyBudget <= 0
                          ? Colors.blue
                          : exceeded
                          ? Colors.red
                          : warning
                          ? Colors.orange
                          : Colors.green;

                      final IconData statusIcon =
                      monthlyBudget <= 0
                          ? Icons
                          .account_balance_wallet_rounded
                          : exceeded
                          ? Icons
                          .warning_rounded
                          : warning
                          ? Icons
                          .remove_circle_outline_rounded
                          : Icons
                          .check_circle_rounded;

                      final String statusTitle =
                      monthlyBudget <= 0
                          ? "Set a Budget"
                          : exceeded
                          ? "Budget Exceeded"
                          : warning
                          ? "Budget Needs Attention"
                          : "Budget is Healthy";

                      final String statusMessage =
                      monthlyBudget <= 0
                          ? "Set your monthly budget to start tracking your spending."
                          : exceeded
                          ? "You have crossed your monthly spending limit."
                          : warning
                          ? "Your spending is getting close to the monthly limit."
                          : "You're comfortably within your monthly spending limit.";

                      return Container(
                        width:
                        double.infinity,
                        padding:
                        const EdgeInsets.all(
                          18,
                        ),
                        decoration:
                        BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(
                            24,
                          ),
                          gradient:
                          LinearGradient(
                            begin:
                            Alignment.topLeft,
                            end:
                            Alignment.bottomRight,
                            colors: isDark
                                ? [
                              statusColor
                                  .withValues(
                                alpha: 0.18,
                              ),
                              Theme.of(
                                  context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(
                                alpha: 0.45,
                              ),
                            ]
                                : [
                              statusColor
                                  .withValues(
                                alpha: 0.10,
                              ),
                              Theme.of(
                                  context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(
                                alpha: 0.45,
                              ),
                            ],
                          ),
                          border:
                          Border.all(
                            color: statusColor
                                .withValues(
                              alpha: 0.28,
                            ),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor
                                  .withValues(
                                alpha: isDark
                                    ? 0.16
                                    : 0.08,
                              ),
                              blurRadius: 24,
                              offset:
                              const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration:
                                  BoxDecoration(
                                    shape:
                                    BoxShape
                                        .circle,
                                    color: statusColor
                                        .withValues(
                                      alpha:
                                      0.14,
                                    ),
                                  ),
                                  child: Icon(
                                    statusIcon,
                                    color:
                                    statusColor,
                                    size: 25,
                                  ),
                                ),

                                const SizedBox(
                                  width: 13,
                                ),

                                Expanded(
                                  child:
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        "Smart Budget Insight",
                                        style:
                                        TextStyle(
                                          fontSize:
                                          13,
                                          fontWeight:
                                          FontWeight
                                              .w600,
                                          color: Theme.of(
                                              context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 3),

                                      Text(
                                        statusTitle,
                                        style:
                                        TextStyle(
                                          fontSize:
                                          18,
                                          fontWeight:
                                          FontWeight
                                              .w900,
                                          color:
                                          statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    statusColor
                                        .withValues(
                                      alpha:
                                      0.12,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      30,
                                    ),
                                  ),
                                  child: Text(
                                    "${(percentage * 100).toStringAsFixed(0)}%",
                                    style:
                                    TextStyle(
                                      color:
                                      statusColor,
                                      fontSize:
                                      12,
                                      fontWeight:
                                      FontWeight
                                          .w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 18),

                            Container(
                              width:
                              double.infinity,
                              padding:
                              const EdgeInsets
                                  .all(14),
                              decoration:
                              BoxDecoration(
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  16,
                                ),
                                color: isDark
                                    ? Colors.black
                                    .withValues(
                                  alpha:
                                  0.12,
                                )
                                    : Colors.white
                                    .withValues(
                                  alpha:
                                  0.65,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Icon(
                                    Icons
                                        .auto_awesome_rounded,
                                    color:
                                    statusColor,
                                    size: 20,
                                  ),

                                  const SizedBox(
                                      width: 10),

                                  Expanded(
                                    child: Text(
                                      statusMessage,
                                      style:
                                      TextStyle(
                                        fontSize:
                                        13,
                                        height:
                                        1.45,
                                        fontWeight:
                                        FontWeight
                                            .w500,
                                        color: Theme.of(
                                            context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                                height: 18),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(
                                  "Budget usage",
                                  style:
                                  TextStyle(
                                    fontSize:
                                    12,
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                    color: Theme.of(
                                        context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),

                                Text(
                                  monthlyBudget <=
                                      0
                                      ? "No budget"
                                      : "₹${monthlySpent.toStringAsFixed(0)} / "
                                      "₹${monthlyBudget.toStringAsFixed(0)}",
                                  style:
                                  const TextStyle(
                                    fontSize:
                                    12,
                                    fontWeight:
                                    FontWeight
                                        .w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 9),

                            ClipRRect(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                20,
                              ),
                              child:
                              LinearProgressIndicator(
                                value:
                                percentage,
                                minHeight: 9,
                                backgroundColor:
                                statusColor
                                    .withValues(
                                  alpha:
                                  0.10,
                                ),
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(
                                  statusColor,
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 15),

                            Row(
                              children: [
                                Expanded(
                                  child:
                                  _InsightMiniStat(
                                    icon: Icons
                                        .account_balance_wallet_rounded,
                                    label:
                                    "Remaining",
                                    value:
                                    monthlyBudget <=
                                        0
                                        ? "—"
                                        : "₹${remainingBudget.toStringAsFixed(0)}",
                                    color:
                                    remainingBudget <
                                        0
                                        ? Colors
                                        .red
                                        : Colors
                                        .green,
                                  ),
                                ),

                                const SizedBox(
                                    width: 10),

                                Expanded(
                                  child:
                                  _InsightMiniStat(
                                    icon: Icons
                                        .receipt_long_rounded,
                                    label:
                                    "Expenses",
                                    value: ExpenseService
                                        .getExpenseCount()
                                        .toString(),
                                    color:
                                    Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Divider(),

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
                selected:
                selectedFilter == filter,
                onSelected: (_) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () async {
              final pickedDate =
              await showDatePicker(
                context: context,
                initialDate:
                selectedDate ??
                    DateTime.now(),
                firstDate:
                DateTime(2020),
                lastDate:
                DateTime.now(),
              );

              if (pickedDate != null) {
                setState(() {
                  selectedDate =
                      pickedDate;
                  selectedFilter = "All";
                });
              }
            },
            icon: const Icon(
              Icons.calendar_month,
            ),
            label: Text(
              selectedDate == null
                  ? "Select Date"
                  : "${selectedDate!.day.toString().padLeft(2, '0')}-"
                  "${selectedDate!.month.toString().padLeft(2, '0')}-"
                  "${selectedDate!.year}",
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue:
            selectedCategory,
            decoration:
            const InputDecoration(
              labelText: "Category",
              prefixIcon:
              Icon(Icons.category),
              border:
              OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: "All",
                child:
                Text("All Categories"),
              ),
              DropdownMenuItem(
                value: "Food",
                child: Text("🍔 Food"),
              ),
              DropdownMenuItem(
                value: "Travel",
                child:
                Text("✈️ Travel"),
              ),
              DropdownMenuItem(
                value: "Shopping",
                child:
                Text("🛍 Shopping"),
              ),
              DropdownMenuItem(
                value: "Bills",
                child:
                Text("💡 Bills"),
              ),
              DropdownMenuItem(
                value: "Entertainment",
                child:
                Text("🎬 Entertainment"),
              ),
              DropdownMenuItem(
                value: "Medical",
                child:
                Text("💊 Medical"),
              ),
              DropdownMenuItem(
                value: "Other",
                child:
                Text("💰 Other"),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedCategory =
                    value;
              });
            },
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue:
            selectedPaymentMethod,
            decoration:
            const InputDecoration(
              labelText:
              "Payment Method",
              prefixIcon:
              Icon(Icons.payment),
              border:
              OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: "All",
                child:
                Text("All Payments"),
              ),
              DropdownMenuItem(
                value: "Cash",
                child:
                Text("💵 Cash"),
              ),
              DropdownMenuItem(
                value: "UPI",
                child:
                Text("📱 UPI"),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                selectedPaymentMethod =
                    value;
              });
            },
          ),

          const SizedBox(height: 10),

          if (selectedDate != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedDate = null;
                });
              },
              icon:
              const Icon(Icons.clear),
              label:
              const Text("Clear Date"),
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
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (filteredExpenses.isEmpty)
            Padding(
              padding:
              const EdgeInsets.symmetric(
                vertical: 30,
              ),
              child: Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "No expenses found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Try another filter.",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 350,
              ),
              transitionBuilder:
                  (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    child: child,
                  ),
                );
              },
              child: Column(
                key: ValueKey(
                  filteredExpenses
                      .map((e) => e.id)
                      .join(','),
                ),
                children:
                filteredExpenses
                    .map((expense) {
                  return RecentTile(
                    icon:
                    Icons.currency_rupee,
                    iconColor:
                    Colors.green,
                    title:
                    expense.category,
                    subtitle:
                    expense.paymentMethod ==
                        'Cash'
                        ? '${expense.description} • Cash • ${expense.denomination}'
                        : '${expense.description} • UPI',
                    amount:
                    '₹${expense.amount.toStringAsFixed(2)}',
                    onEdit: () {
                      showEditDialog(
                          expense);
                    },
                    onDelete: () async {
                      final shouldDelete =
                      await showDialog<
                          bool>(
                        context: context,
                        builder:
                            (context) {
                          return AlertDialog(
                            title:
                            const Text(
                              "Delete Expense",
                            ),
                            content:
                            const Text(
                              "Are you sure you want to delete this expense?",
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    context,
                                    false,
                                  );
                                },
                                child:
                                const Text(
                                  "Cancel",
                                ),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () {
                                  Navigator.pop(
                                    context,
                                    true,
                                  );
                                },
                                child:
                                const Text(
                                  "Delete",
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete ==
                          true) {
                        setState(() {
                          ExpenseService
                              .deleteExpense(
                            expense.id,
                          );
                        });

                        ScaffoldMessenger.of(
                            context)
                            .showSnackBar(
                          const SnackBar(
                            backgroundColor:
                            Colors.red,
                            content: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors
                                      .white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Expense Deleted Successfully",
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
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
        title:
        const Text("RupeeLens"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
            ),
            onPressed: () async {
              await NotificationService
                  .showNotification(
                title:
                "🎉 Notification Test",
                body:
                "Congratulations! Notifications are working.",
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: currentIndex,
        type:
        BottomNavigationBarType.fixed,
        selectedItemColor:
        Colors.green,
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
            icon:
            Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon:
            Icon(Icons.add),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon:
            Icon(Icons.bar_chart),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon:
            Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}