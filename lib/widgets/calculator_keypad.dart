import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

/// A premium custom numeric keypad with a built-in arithmetic calculator.
/// Supports +, -, *, / operations with live expression evaluation.
///
/// Usage:
/// ```dart
/// final amount = await showModalBottomSheet<double>(
///   context: context,
///   builder: (_) => const CalculatorKeypad(),
/// );
/// ```
class CalculatorKeypad extends StatefulWidget {
  const CalculatorKeypad({super.key});

  @override
  State<CalculatorKeypad> createState() => _CalculatorKeypadState();
}

class _CalculatorKeypadState extends State<CalculatorKeypad>
    with SingleTickerProviderStateMixin {
  String _expression = '';
  String _result = '0';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _pulseAnimation =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Expression logic ───────────────────────────────────────────

  void _onKeyTap(String key) {
    _pulseController.forward(from: 0.95);
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
          _result = '0';
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
            _evaluate();
          }
          break;
        case '=':
          _evaluate();
          _expression = _result;
          break;
        case '✓':
          final value = double.tryParse(_result) ?? 0;
          Navigator.of(context).pop(value.abs());
          break;
        default:
          // Prevent consecutive operators
          if (_isOperator(key) && _expression.isNotEmpty) {
            final last = _expression[_expression.length - 1];
            if (_isOperator(last)) {
              _expression =
                  _expression.substring(0, _expression.length - 1) + key;
              return;
            }
          }
          // Prevent leading operators except minus
          if (_expression.isEmpty && _isOperator(key) && key != '-') return;
          _expression += key;
          _evaluate();
      }
    });
  }

  bool _isOperator(String c) => ['+', '-', '×', '÷'].contains(c);

  void _evaluate() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    try {
      // Replace display symbols with math symbols
      String exp = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      // Strip trailing operator for evaluation
      if (exp.isNotEmpty && '+-*/'.contains(exp[exp.length - 1])) {
        exp = exp.substring(0, exp.length - 1);
      }
      if (exp.isEmpty) {
        _result = '0';
        return;
      }
      // ignore: deprecated_member_use
      final parser = Parser();
      // ignore: deprecated_member_use
      final expression = parser.parse(exp);
      final cm = ContextModel();
      // ignore: deprecated_member_use
      final eval = expression.evaluate(EvaluationType.REAL, cm) as double;
      // Show integer if whole number
      _result = eval == eval.roundToDouble() && !eval.isInfinite
          ? eval.toInt().toString()
          : eval.toStringAsFixed(2);
    } catch (_) {
      // Don't update result on parse error — keep last valid result
    }
  }

  // ── UI ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Display
            _buildDisplay(cs),
            const Divider(color: Colors.white10, height: 1),
            // Keypad
            _buildKeypad(cs),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression
          Text(
            _expression.isEmpty ? '0' : _expression,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Result
          ScaleTransition(
            scale: _pulseAnimation,
            child: Text(
              '₹$_result',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(ColorScheme cs) {
    final rows = [
      ['C', '⌫', '÷', '×'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.', '✓'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: rows.map((row) {
          return Row(
            children: row.map((key) {
              final isOperator = ['÷', '×', '-', '+', '='].contains(key);
              final isAction = ['C', '⌫'].contains(key);
              final isDone = key == '✓';
              final isZero = key == '0';

              Color bgColor;
              Color textColor;
              if (isDone) {
                bgColor = cs.primary;
                textColor = cs.onPrimary;
              } else if (isOperator) {
                bgColor = cs.primary.withValues(alpha: 0.15);
                textColor = cs.primary;
              } else if (isAction) {
                bgColor = Colors.white.withValues(alpha: 0.08);
                textColor = Colors.redAccent;
              } else {
                bgColor = Colors.white.withValues(alpha: 0.06);
                textColor = Colors.white;
              }

              return Expanded(
                flex: isZero ? 2 : (isDone ? 2 : 1),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Material(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _onKeyTap(key),
                      splashColor: cs.primary.withValues(alpha: 0.2),
                      child: Container(
                        height: 64,
                        alignment: Alignment.center,
                        child: isDone
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline,
                                      color: textColor, size: 22),
                                  const SizedBox(width: 6),
                                  Text('Done',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      )),
                                ],
                              )
                            : Text(
                                key,
                                style: TextStyle(
                                  fontSize: isAction ? 20 : 24,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
