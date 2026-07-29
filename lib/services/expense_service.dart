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
}
