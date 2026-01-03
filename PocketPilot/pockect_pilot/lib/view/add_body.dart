import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';

class AddBody extends StatefulWidget {
  static String? ocrTextCache;

  const AddBody({super.key});

  @override
  State<AddBody> createState() => _AddBodyState();
}

class _AddBodyState extends State<AddBody> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool _ocrHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_ocrHandled &&
        AddBody.ocrTextCache != null &&
        AddBody.ocrTextCache!.trim().isNotEmpty) {
      _fillFromOCR(AddBody.ocrTextCache!);
      AddBody.ocrTextCache = null;
      _ocrHandled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt data filled automatically'),
            ),
          );
        }
      });
    }
  }

  void _fillFromOCR(String text) {
    final lines = text
        .replaceAll(',', '.')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    for (final line in lines) {
      final lower = line.toLowerCase();

      if (priceController.text.isEmpty &&
          (lower.contains('total') ||
              lower.contains('amount') ||
              RegExp(r'\d+\.\d{2}').hasMatch(line))) {
        final match = RegExp(r'(\d+\.\d{1,2})').firstMatch(line);
        if (match != null) {
          priceController.text = match.group(1)!;
        }
      }

      if (dateController.text.isEmpty) {
        final dateMatch =
            RegExp(r'(\d{4}[-/]\d{2}[-/]\d{2})').firstMatch(line);
        if (dateMatch != null) {
          dateController.text =
              dateMatch.group(1)!.replaceAll('/', '-');
        }
      }
    }

    for (final line in lines) {
      if (!RegExp(r'\d').hasMatch(line) && line.length > 3) {
        itemNameController.text = line;
        break;
      }
    }

    if (categoryController.text.isEmpty) {
      categoryController.text = 'General';
    }

    setState(() {});
  }

  @override
  void dispose() {
    itemNameController.dispose();
    priceController.dispose();
    categoryController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Text(
              'Add Expense',
              style: TextStyle(
                color: GlobalColors.textColor2,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            AppTextField(
              controller: itemNameController,
              hint: 'Item Name',
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: priceController,
              hint: 'Price',
              keyboardType: TextInputType.number,
              suffix: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 20,
                ),
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: GlobalColors.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: categoryController,
              hint: 'Category',
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: AppTextField(
                  controller: dateController,
                  hint: 'Date',
                  suffix: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 20,
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: GlobalColors.textColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: noteController,
              hint: 'Note (optional)',
            ),

            const SizedBox(height: 30),

            AppButton(
              text: 'Add Expense',
              onPressed: () {
                debugPrint('Item: ${itemNameController.text}');
                debugPrint('Price: ${priceController.text}');
                debugPrint('Category: ${categoryController.text}');
                debugPrint('Date: ${dateController.text}');
                debugPrint('Note: ${noteController.text}');
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}