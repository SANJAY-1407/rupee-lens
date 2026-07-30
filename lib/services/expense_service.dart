import '../models/expense.dart';

class ExpenseService {
  static final List<Expense> expenses = [];

  static void addExpense(Expense expense) {
    expenses.add(expense);

  }
  static List<Expense> getExpenses() {
    return expenses;
  }

  static List<Expense> getRecentExpenses() {
    return expenses.reversed.toList();
  }

  static double getTotalExpense() {
    double total = 0;

    for (var expense in expenses) {
      total += expense.amount;
    }

    return total;
  }

  static double getTodayExpense() {
    double total = 0;

    final today = DateTime.now();

    for (var expense in expenses) {
      if (expense.date.day == today.day &&
          expense.date.month == today.month &&
          expense.date.year == today.year) {
        total += expense.amount;
      }
    }

    return total;
  }

  static double getMonthlyExpense() {
    double total = 0;

    final today = DateTime.now();

    for (var expense in expenses) {
      if (expense.date.month == today.month &&
          expense.date.year == today.year) {
        total += expense.amount;
      }
    }

    return total;
  }
  static int getExpenseCount() {
    return expenses.length;
  }
  static Map<String, double> getCategoryTotals() {
    Map<String, double> totals = {};

    for (var expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }
  // Highest Expense
  static double getHighestExpense() {
    if (expenses.isEmpty) return 0;

    double highest = expenses.first.amount;

    for (var expense in expenses) {
      if (expense.amount > highest) {
        highest = expense.amount;
      }
    }

    return highest;
  }

// Lowest Expense
  static double getLowestExpense() {
    if (expenses.isEmpty) return 0;

    double lowest = expenses.first.amount;

    for (var expense in expenses) {
      if (expense.amount < lowest) {
        lowest = expense.amount;
      }
    }

    return lowest;
  }

// Average Expense
  static double getAverageExpense() {
    if (expenses.isEmpty) return 0;

    return getTotalExpense() / expenses.length;
  }


}
