import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';

class ExpenseService {
  static final Box<Expense> expenseBox = Hive.box<Expense>('expenses');
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;
  static CollectionReference<Map<String, dynamic>>? get _userExpensesRef {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  static void initFirestoreListener() {
    final ref = _userExpensesRef;
    if (ref == null) return;

    ref.snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final expense = Expense.fromMap(doc.data(), doc.id);
        expenseBox.put(expense.id, expense);
      }
    });
  }

  static Future<void> addExpense(Expense expense) async {
    await expenseBox.put(expense.id, expense);
    final ref = _userExpensesRef;
    if (ref != null) {
      await ref.doc(expense.id).set(expense.toMap());
    }
  }

  static Future<void> updateExpense(Expense expense) async {
    await expenseBox.put(expense.id, expense);
    final ref = _userExpensesRef;
    if (ref != null) {
      await ref.doc(expense.id).update(expense.toMap());
    }
  }

  static Future<void> deleteExpense(String id) async {
    await expenseBox.delete(id);
    final ref = _userExpensesRef;
    if (ref != null) {
      await ref.doc(id).delete();
    }
  }

  static Future<void> syncLocalToCloud() async {
    final ref = _userExpensesRef;
    if (ref == null) return;

    for (var expense in expenseBox.values) {
      await ref.doc(expense.id).set(expense.toMap(), SetOptions(merge: true));
    }
  }

  static Future<void> fetchFromCloud() async {
    final ref = _userExpensesRef;
    if (ref == null) return;

    final snapshot = await ref.get();
    for (var doc in snapshot.docs) {
      final expense = Expense.fromMap(doc.data(), doc.id);
      expenseBox.put(expense.id, expense);
    }
  }

  static List<Expense> getExpenses() {
    return expenseBox.values.toList();
  }

  static List<Expense> getRecentExpenses() {
    return expenseBox.values
        .toList()
        .reversed
        .toList();
  }

  static double getTotalExpense() {
    double total = 0;
    for (var expense in expenseBox.values) {
      total += expense.amount;
    }
    return total;
  }

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

  static int getExpenseCount() {
    return expenseBox.length;
  }

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

  static double getAverageExpense() {
    if (expenseBox.isEmpty) return 0;

    return getTotalExpense() / expenseBox.length;
  }

  static double getCashTotal() {
    double total = 0;

    for (var expense in expenseBox.values) {
      if (expense.paymentMethod == "Cash") {
        total += expense.amount;
      }
    }

    return total;
  }

  static double getUpiTotal() {
    double total = 0;

    for (var expense in expenseBox.values) {
      if (expense.paymentMethod == "UPI") {
        total += expense.amount;
      }
    }

    return total;
  }

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

  static List<double> getWeeklyExpenses() {
    final List<double> weekly = List.filled(7, 0);

    final now = DateTime.now();

    for (final expense in expenseBox.values) {
      final difference = now.difference(expense.date).inDays;

      if (difference >= 0 && difference < 7) {
        int index = expense.date.weekday - 1;
        weekly[index] += expense.amount;
      }
    }

    return weekly;
  }
}