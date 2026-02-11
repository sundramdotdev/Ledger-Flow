import 'package:hive_ce/hive.dart';
import '../models/transaction.dart';

/// Centralizes all Hive database operations for [Transaction] objects.
class HiveService {
  static const String _boxName = 'transactions';

  /// Opens the transactions box. Call once at app startup.
  static Future<Box<Transaction>> openBox() async {
    return await Hive.openBox<Transaction>(_boxName);
  }

  /// Returns the already-opened box (use after [openBox]).
  static Box<Transaction> getBox() => Hive.box<Transaction>(_boxName);

  /// Adds a new transaction and returns its Hive key.
  static Future<int> addTransaction(Transaction txn) async {
    final box = getBox();
    return await box.add(txn);
  }

  /// Updates a transaction at its current Hive key.
  static Future<void> updateTransaction(Transaction txn) async {
    await txn.save();
  }

  /// Deletes a transaction by its Hive key.
  static Future<void> deleteTransaction(Transaction txn) async {
    await txn.delete();
  }

  /// Returns all stored transactions as a list.
  static List<Transaction> getAllTransactions() {
    return getBox().values.toList();
  }
}
