import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/hive_service.dart';

/// Manages application state for transactions via [ChangeNotifier].
/// All screens listen to this provider for real-time data updates.
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  // ── Computed totals ────────────────────────────────────────────

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  // ── CRUD operations ────────────────────────────────────────────

  /// Loads all transactions from Hive into memory.
  void loadTransactions() {
    _transactions = HiveService.getAllTransactions();
    notifyListeners();
  }

  /// Adds a transaction to Hive and refreshes the list.
  Future<void> addTransaction(Transaction txn) async {
    await HiveService.addTransaction(txn);
    loadTransactions();
  }

  /// Deletes a transaction from Hive and refreshes the list.
  Future<void> deleteTransaction(Transaction txn) async {
    await HiveService.deleteTransaction(txn);
    loadTransactions();
  }

  /// Updates a transaction in Hive and refreshes the list.
  Future<void> updateTransaction(Transaction txn) async {
    await HiveService.updateTransaction(txn);
    loadTransactions();
  }

  // ── Filtering helpers (used by Search screen) ──────────────────

  List<Transaction> searchByTitle(String query) {
    if (query.isEmpty) return _transactions;
    return _transactions
        .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Transaction> filterByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return !t.date.isBefore(start) && !t.date.isAfter(end);
    }).toList();
  }

  List<Transaction> searchAndFilter(
      String query, DateTime? start, DateTime? end) {
    var results = searchByTitle(query);
    if (start != null && end != null) {
      results = results.where((t) {
        return !t.date.isBefore(start) && !t.date.isAfter(end);
      }).toList();
    }
    return results;
  }

  // ── Monthly / Yearly aggregations (used by Dashboard charts) ───

  /// Returns expense totals grouped by category for the given month.
  Map<String, double> monthlyExpensesByCategory(int year, int month) {
    final map = <String, double>{};
    for (final t in _transactions) {
      if (!t.isIncome && t.date.year == year && t.date.month == month) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    return map;
  }

  /// Returns monthly income & expense totals for a full year (index 0–11).
  Map<String, List<double>> yearlyIncomeVsExpense(int year) {
    final income = List<double>.filled(12, 0);
    final expense = List<double>.filled(12, 0);
    for (final t in _transactions) {
      if (t.date.year == year) {
        final m = t.date.month - 1;
        if (t.isIncome) {
          income[m] += t.amount;
        } else {
          expense[m] += t.amount;
        }
      }
    }
    return {'income': income, 'expense': expense};
  }
}
