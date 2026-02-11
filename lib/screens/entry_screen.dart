import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/category_picker.dart';

/// The main transaction entry screen with Income/Expense toggle,
/// amount via calculator keypad, category picker, and title input.
class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen>
    with SingleTickerProviderStateMixin {
  bool _isIncome = false;
  double _amount = 0;
  String _category = '';
  DateTime _date = DateTime.now();
  final _titleCtrl = TextEditingController();
  late AnimationController _toggleAnim;

  @override
  void initState() {
    super.initState();
    _toggleAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _toggleAnim.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────

  Future<void> _openCalculator() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CalculatorKeypad(),
    );
    if (result != null) setState(() => _amount = result);
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CategoryPicker(),
    );
    if (result != null) setState(() => _category = result);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  surface: const Color(0xFF1A1A2E),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _saveTransaction() {
    if (_amount <= 0) {
      _showSnackBar('Tap the amount to enter a value');
      return;
    }
    if (_category.isEmpty) {
      _showSnackBar('Please select a category');
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnackBar('Please enter a title');
      return;
    }

    final txn = Transaction(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: _amount,
      date: _date,
      category: _category,
      isIncome: _isIncome,
    );

    context.read<TransactionProvider>().addTransaction(txn);

    // Reset form
    setState(() {
      _amount = 0;
      _category = '';
      _titleCtrl.clear();
      _date = DateTime.now();
    });

    _showSnackBar('Transaction saved!', isSuccess: true);
  }

  void _showSnackBar(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green[700] : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final incomeColor = const Color(0xFF00E676);
    final expenseColor = const Color(0xFFFF5252);
    final activeColor = _isIncome ? incomeColor : expenseColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // ── Income / Expense Toggle ────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildToggle('Expense', !_isIncome, expenseColor, () {
                    setState(() => _isIncome = false);
                  }),
                  _buildToggle('Income', _isIncome, incomeColor, () {
                    setState(() => _isIncome = true);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Amount display (tappable) ──────────────────────
            GestureDetector(
              onTap: _openCalculator,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeColor.withValues(alpha: 0.12),
                      activeColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: activeColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Tap to enter amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_amount == _amount.roundToDouble() ? _amount.toInt().toString() : _amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Category ───────────────────────────────────────
            _buildFieldTile(
              icon: Icons.category_rounded,
              label: _category.isEmpty ? 'Select Category' : _category,
              isEmpty: _category.isEmpty,
              onTap: _pickCategory,
            ),
            const SizedBox(height: 12),

            // ── Title ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.edit_note_rounded,
                      color: cs.primary.withValues(alpha: 0.7)),
                  hintText: 'Transaction title',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Date ───────────────────────────────────────────
            _buildFieldTile(
              icon: Icons.calendar_today_rounded,
              label: DateFormat('EEE, dd MMM yyyy').format(_date),
              isEmpty: false,
              onTap: _pickDate,
            ),
            const SizedBox(height: 32),

            // ── Save Button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _saveTransaction,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save Transaction',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
      String label, bool active, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(color: color.withValues(alpha: 0.4))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? color : Colors.white38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldTile({
    required IconData icon,
    required String label,
    required bool isEmpty,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon,
                  color: isEmpty
                      ? cs.primary.withValues(alpha: 0.5)
                      : cs.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isEmpty
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.2)),
            ],
          ),
        ),
      ),
    );
  }
}
