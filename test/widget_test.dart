import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ledger_flow/models/transaction.dart';
import 'package:ledger_flow/providers/transaction_provider.dart';
import 'package:ledger_flow/screens/dashboard_screen.dart';

// Mock TransactionProvider to avoid Hive dependency
class MockTransactionProvider extends TransactionProvider {
  final List<Transaction> _mockTransactions = [
    Transaction(
      id: '1',
      title: 'Salary',
      amount: 5000.0,
      date: DateTime.now(),
      category: 'Salary',
      isIncome: true,
    ),
    Transaction(
      id: '2',
      title: 'Groceries',
      amount: 150.0,
      date: DateTime.now(),
      category: 'Food',
      isIncome: false,
    ),
    Transaction(
      id: '3',
      title: 'Rent',
      amount: 1200.0,
      date: DateTime.now(),
      category: 'Housing',
      isIncome: false,
    ),
  ];

  @override
  List<Transaction> get transactions => _mockTransactions;

  @override
  void loadTransactions() {
    // Do nothing to avoid Hive calls
  }

  @override
  Map<String, List<double>> yearlyIncomeVsExpense(int year) {
    // Return dummy data for the chart
    final income = List<double>.filled(12, 0);
    final expense = List<double>.filled(12, 0);

    // Populate stats based on mock transactions (assuming they are current year)
    // For simplicity in test, just hardcode expected values if needed,
    // or simulate logic. Here we simulate logic for the current month.
    final currentMonth = DateTime.now().month - 1;
    income[currentMonth] = 5000.0;
    expense[currentMonth] = 1350.0; // 150 + 1200

    return {'income': income, 'expense': expense};
  }
}

void main() {
  testWidgets('DashboardScreen displays summary cards and charts', (
    WidgetTester tester,
  ) async {
    // Build the widget tree with the MockProvider
    await tester.pumpWidget(
      ChangeNotifierProvider<TransactionProvider>(
        create: (_) => MockTransactionProvider(),
        child: MaterialApp(home: const DashboardScreen()),
      ),
    );

    // Allow animations/futures to settle
    await tester.pumpAndSettle();

    // Verify Summary Cards
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);

    // Verify values in cards (Current Month)
    // Income: 5000.0, Expense: 1350.0 (150+1200), Balance: 3650.0
    expect(find.text('\$5000.0'), findsOneWidget);
    expect(find.text('\$1350.0'), findsOneWidget);
    expect(find.text('\$3650.0'), findsOneWidget);

    // Verify Charts Headers
    expect(find.text('Monthly Expenses'), findsOneWidget);
    expect(find.text('Yearly Overview'), findsOneWidget);

    // Verify Charts exist
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
  });
}
