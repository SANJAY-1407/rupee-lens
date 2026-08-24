import 'package:hive/hive.dart';
import '../models/expense.dart';

class ExpenseService {
  static final Box<Expense> expenseBox =
  Hive.box<Expense>('expenses');

  // Add Expense
  static void addExpense(Expense expense) {
    expenseBox.put(expense.id, expense);
  }

  // Get All Expenses
  static List<Expense> getExpenses() {
    return expenseBox.values.toList();
  }

  // Recent Expenses
  static List<Expense> getRecentExpenses() {
    return expenseBox.values
        .toList()
        .reversed
        .toList();
  }

  // Total Expense
  static double getTotalExpense() {
    double total = 0;

    for (var expense in expenseBox.values) {
      total += expense.amount;
    }

    return total;
  }

  // Today's Expense
  static double getTodayExpense() {
    double total = 0;
    final today = DateTime.now();

    for (var expense in expenseBox.values) {
      if (expense.date.day == today.day &&
          expense.date.month == today.month &&
          expense.date.year == today.year) {
        total += expense.amount;
      }
    }

    return total;
  }

  // Monthly Expense
  static double getMonthlyExpense() {
    double total = 0;
    final today = DateTime.now();

    for (var expense in expenseBox.values) {
      if (expense.date.month == today.month &&
          expense.date.year == today.year) {
        total += expense.amount;
      }
    }

    return total;
  }

  // Expense Count
  static int getExpenseCount() {
    return expenseBox.length;
  }

  // Category Totals
  static Map<String, double> getCategoryTotals() {
    Map<String, double> totals = {};

    for (var expense in expenseBox.values) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  static double getHighestExpense() {
    if (expenseBox.values.isEmpty) return 0;

    double highest = 0;

    for (final expense in expenseBox.values) {
      if (expense.amount > highest) {
        highest = expense.amount;
      }
    }

    return highest;
  }

  // Lowest Expense
  static double getLowestExpense() {
    if (expenseBox.isEmpty) return 0;

    double lowest = expenseBox.values.first.amount;

    for (var expense in expenseBox.values) {
      if (expense.amount < lowest) {
        lowest = expense.amount;
      }
    }

    return lowest;
  }

  // Average Expense
  static double getAverageExpense() {
    if (expenseBox.isEmpty) return 0;

    return getTotalExpense() / expenseBox.length;
  }

  // Delete Expense
  static void deleteExpense(String id) {
    expenseBox.delete(id);
  }

  // Update Expense
  static void updateExpense(Expense expense) {
    expenseBox.put(expense.id, expense);
  }

  // Cash Total
  static double getCashTotal() {
    double total = 0;

    for (var expense in expenseBox.values) {
      if (expense.paymentMethod == "Cash") {
        total += expense.amount;
      }
    }

    return total;
  }

// UPI Total
  static double getUpiTotal() {
    double total = 0;

    for (var expense in expenseBox.values) {
      if (expense.paymentMethod == "UPI") {
        total += expense.amount;
      }
    }

    return total;
  }

  // Monthly Category Report
  static Map<String, double> getMonthlyCategoryTotals() {
    final Map<String, double> totals = {};
    final now = DateTime.now();

    for (var expense in expenseBox.values) {
      if (expense.date.month == now.month &&
          expense.date.year == now.year) {
        totals[expense.category] =
            (totals[expense.category] ?? 0) + expense.amount;
      }
    }

    return totals;
  }

  static String getMostUsedPaymentMethod() {
    int cashCount = 0;
    int upiCount = 0;

    for (final expense in expenseBox.values) {
      if (expense.paymentMethod == "Cash") {
        cashCount++;
      } else if (expense.paymentMethod == "UPI") {
        upiCount++;
      }
    }

    if (cashCount == 0 && upiCount == 0) {
      return "No Data";
    }

    if (cashCount > upiCount) {
      return "💵 Cash";
    }

    if (upiCount > cashCount) {
      return "📱 UPI";
    }

    return "🤝 Equal Usage";
  }

  static String getMostSpentCategory() {
    if (expenseBox.values.isEmpty) {
      return "No Data";
    }
    final Map<String, double> totals = {};

    for (final expense in expenseBox.values) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    String topCategory = "";
    double highestAmount = 0;

    totals.forEach((category, amount) {
      if (amount > highestAmount) {
        highestAmount = amount;
        topCategory = category;
      }
    });

    return "$topCategory (₹${highestAmount.toStringAsFixed(0)})";
  }

  static int getMonthlyExpenseCount() {
    final now = DateTime.now();
    int count = 0;

    for (final expense in expenseBox.values) {
      if (expense.date.month == now.month &&
          expense.date.year == now.year) {
        count++;
      }
    }

    return count;
  }

  static double getAverageExpensePerDay() {
    final now = DateTime.now();

    double total = 0;
    int today = now.day;

    for (final expense in expenseBox.values) {
      if (expense.date.month == now.month &&
          expense.date.year == now.year) {
        total += expense.amount;
      }
    }

    if (today == 0) return 0;

    return total / today;
  }

  // Weekly Expense Data
  static List<double> getWeeklyExpenses() {
    final List<double> weekly = List.filled(7, 0);

    final now = DateTime.now();

    for (final expense in expenseBox.values) {
      final difference = now.difference(expense.date).inDays;

      if (difference >= 0 && difference < 7) {
        // Monday = 1 ... Sunday = 7
        int index = expense.date.weekday - 1;
        weekly[index] += expense.amount;
      }
    }

    return weekly;
  }

}