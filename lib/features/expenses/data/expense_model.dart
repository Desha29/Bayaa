class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String? notes;
  final DateTime date;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  factory Expense.fromMap(Map<String, Object?> map) => Expense(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        category: map['category'] as String? ?? 'General',
        notes: map['notes'] as String?,
        date: DateTime.parse(map['created_at'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'notes': notes,
        'created_at': date.toIso8601String(),
      };
}
