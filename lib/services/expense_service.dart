import '../models/expense.dart';

class ExpenseService {
  static final List<Expense> expenses = [];

  // Add Expense
  static void addExpense(Expense expense) {
    expenses.add(expense);
  }

  // Get All Expenses
  static List<Expense> getExpenses() {
    return expenses;
  }

  // Total Expense
  static double getTotalExpense() {
    double total = 0;

    for (var expense in expenses) {
      total += expense.amount;
    }

    return total;
  }

  // Update Expense
  static void updateExpense(Expense updatedExpense) {
    final index = expenses.indexWhere(
          (expense) => expense.id == updatedExpense.id,
    );

    if (index != -1) {
      expenses[index] = updatedExpense;
    }
  }

  // Delete Expense
  static void deleteExpense(String id) {
    expenses.removeWhere((expense) => expense.id == id);
  }

  // Number of Expenses
  static int getExpenseCount() {
    return expenses.length;
  }

  // Clear All Expenses (Optional)
  static void clearExpenses() {
    expenses.clear();
  }
}