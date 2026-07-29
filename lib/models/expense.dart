class Expense {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });
}