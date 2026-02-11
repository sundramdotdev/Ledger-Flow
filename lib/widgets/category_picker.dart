import 'package:flutter/material.dart';

/// A pre-defined category with an emoji and label.
class Category {
  final String emoji;
  final String label;

  const Category({required this.emoji, required this.label});

  /// Combined display string stored in the Transaction.
  String get display => '$emoji $label';
}

/// Default categories shipped with the app.
const List<Category> defaultCategories = [
  Category(emoji: '🛒', label: 'Grocery'),
  Category(emoji: '🧾', label: 'Bills'),
  Category(emoji: '🏋️', label: 'Gym'),
  Category(emoji: '💰', label: 'Salary'),
  Category(emoji: '🍔', label: 'Food'),
  Category(emoji: '🚗', label: 'Transport'),
  Category(emoji: '🎬', label: 'Entertainment'),
  Category(emoji: '💊', label: 'Health'),
];

/// A bottom-sheet picker for selecting or creating a transaction category.
class CategoryPicker extends StatefulWidget {
  final List<Category> extraCategories;

  const CategoryPicker({super.key, this.extraCategories = const []});

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  late List<Category> _all;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _all = [...defaultCategories, ...widget.extraCategories];
  }

  void _showAddDialog() {
    final emojiCtrl = TextEditingController();
    final labelCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Category',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emojiCtrl,
              style: const TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '😀',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Category name',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          FilledButton(
            onPressed: () {
              if (emojiCtrl.text.isNotEmpty && labelCtrl.text.isNotEmpty) {
                setState(() {
                  _all.add(Category(
                      emoji: emojiCtrl.text.trim(),
                      label: labelCtrl.text.trim()));
                  _selectedIndex = _all.length - 1;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  Text('Pick Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      )),
                  const Spacer(),
                  IconButton(
                    onPressed: _showAddDialog,
                    icon: Icon(Icons.add_circle_outline, color: cs.primary),
                    tooltip: 'Add custom',
                  ),
                ],
              ),
            ),
            // Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_all.length, (i) {
                  final cat = _all[i];
                  final selected = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? cs.primary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                            ? Border.all(color: cs.primary, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        cat.display,
                        style: TextStyle(
                          fontSize: 15,
                          color: selected ? cs.primary : Colors.white70,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            // Confirm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _selectedIndex != null
                      ? () =>
                          Navigator.pop(context, _all[_selectedIndex!].display)
                      : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
