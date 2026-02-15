import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'entry_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EntryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final now = DateTime.now();
          final currentMonthTransactions = _filterCurrentMonth(
            provider.transactions,
            now,
          );

          final income = _calculateTotal(currentMonthTransactions, true);
          final expense = _calculateTotal(currentMonthTransactions, false);
          final balance = income - expense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Income',
                        amount: income,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Expense',
                        amount: expense,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Balance',
                        amount: balance,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Monthly Expenses Pie Chart
                Text(
                  'Monthly Expenses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _MonthlyPieChart(
                    transactions: currentMonthTransactions,
                  ),
                ),
                const SizedBox(height: 24),

                // Yearly Income vs Expense Line Chart
                Text(
                  'Yearly Overview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: _YearlyLineChart(provider: provider, year: now.year),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Transaction> _filterCurrentMonth(
    List<Transaction> transactions,
    DateTime now,
  ) {
    return transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();
  }

  // ignore: unused_element
  List<Transaction> _filterCurrentYear(
    List<Transaction> transactions,
    DateTime now,
  ) {
    return transactions.where((t) => t.date.year == now.year).toList();
  }

  double _calculateTotal(List<Transaction> transactions, bool isIncome) {
    return transactions
        .where((t) => t.isIncome == isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyPieChart extends StatelessWidget {
  final List<Transaction> transactions;

  const _MonthlyPieChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};
    for (var t in transactions) {
      if (!t.isIncome) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No expenses this month'));
    }

    final List<Color> colors = [
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.yellow,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: categoryTotals.entries.map((e) {
          final index = categoryTotals.keys.toList().indexOf(e.key);
          final color = colors[index % colors.length];
          return PieChartSectionData(
            color: color,
            value: e.value,
            title: '${e.key}\n${e.value.toStringAsFixed(0)}',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _YearlyLineChart extends StatelessWidget {
  final TransactionProvider provider;
  final int year;

  const _YearlyLineChart({required this.provider, required this.year});

  @override
  Widget build(BuildContext context) {
    final validData = provider.yearlyIncomeVsExpense(year);
    final income = validData['income']!;
    final expense = validData['expense']!;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'J',
                  'F',
                  'M',
                  'A',
                  'M',
                  'J',
                  'J',
                  'A',
                  'S',
                  'O',
                  'N',
                  'D',
                ];
                if (value.toInt() >= 0 && value.toInt() < 12) {
                  return Text(
                    months[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const SizedBox();
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ), // Hide left Y-axis labels for cleaner look
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              12,
              (index) => FlSpot(index.toDouble(), income[index]),
            ),
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: List.generate(
              12,
              (index) => FlSpot(index.toDouble(), expense[index]),
            ),
            isCurved: true,
            color: Colors.redAccent,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
