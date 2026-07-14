import '../../../core/data/services/persistence_initializer.dart';
import 'expense_model.dart';

class ExpenseRepository {
  Future<List<Expense>> getExpenses({DateTime? start, DateTime? end}) async {
    final db = PersistenceInitializer.persistenceManager!.sqliteManager;
    final clauses = <String>[];
    final args = <Object?>[];
    if (start != null) {
      clauses.add('created_at >= ?');
      args.add(start.toIso8601String());
    }
    if (end != null) {
      clauses.add('created_at <= ?');
      args.add(end.toIso8601String());
    }
    final rows = await db.query('expenses',
        where: clauses.isEmpty ? null : clauses.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'created_at DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<double> total(DateTime start, DateTime end) async {
    final db = PersistenceInitializer.persistenceManager!.sqliteManager;
    final rows = await db.database.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE created_at BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<void> add(Expense expense) async {
    final db = PersistenceInitializer.persistenceManager!.sqliteManager;
    await db.insert('expenses', expense.toMap());
  }

  Future<void> delete(String id) async {
    final db = PersistenceInitializer.persistenceManager!.sqliteManager;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
