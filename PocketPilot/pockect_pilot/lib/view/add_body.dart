import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/services/receipt_ocr_service.dart';
import 'package:pockect_pilot/services/variable_expenses_service.dart';

class AddBody extends StatefulWidget {
  static String? ocrTextCache;

  const AddBody({super.key});

  @override
  State<AddBody> createState() => _AddBodyState();
}

class _AddBodyState extends State<AddBody> {
  final itemNameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final dateController = TextEditingController();
  final noteController = TextEditingController();

  bool _handledOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_handledOnce) {
      _handleIncomingData();
    }
  }

  void _handleIncomingData() {
    final raw = AddBody.ocrTextCache;
    if (raw == null || raw.trim().isEmpty) return;

    _handledOnce = true;
    AddBody.ocrTextCache = null;

    bool success = false;

    /// 1️⃣ حاول JSON (Gemini)
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _applyParsedData(
          itemName: decoded['itemName'],
          total: decoded['total'],
          date: decoded['date'],
          category: decoded['category'],
        );
        success = true;
      }
    } catch (_) {}

    /// 2️⃣ Fallback OCR
    if (!success) {
      _applyFallbackOCR(raw);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt data filled automatically'),
        ),
      );
    });

    setState(() {});
  }

  void _applyParsedData({
    dynamic itemName,
    dynamic total,
    dynamic date,
    dynamic category,
  }) {
    itemNameController.text = itemName?.toString() ?? '';
    priceController.text = total?.toString() ?? '';
    dateController.text = date?.toString() ?? '';
    categoryController.text = category?.toString() ?? 'Other';
  }

  Future<void> _scanReceiptFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanning receipt...')),
    );

    final text = await ReceiptOCRService.extractText(
      File(image.path),
    );

    _applyFallbackOCR(text);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt scanned successfully')),
    );
  }

  void _applyFallbackOCR(String text) {
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
        final match =
            RegExp(r'(\d+\.\d{1,2})').firstMatch(line);
        if (match != null) {
          priceController.text = match.group(1)!;
        }
      }

      if (dateController.text.isEmpty) {
        final match = RegExp(
          r'(\d{4}[-/]\d{2}[-/]\d{2})',
        ).firstMatch(line);
        if (match != null) {
          dateController.text =
              match.group(1)!.replaceAll('/', '-');
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
      categoryController.text = 'Other';
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
    final picked = await showDatePicker(
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
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 85),
              Text(
                'Add Expense',
                style: TextStyle(
                  color: GlobalColors.textColor3,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: GlobalColors.textColor3,
                  size: 18,
                ),
                onPressed: _scanReceiptFromCamera,
              ),
            ],
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
           onPressed: () async {
  final title = itemNameController.text.trim();
  final amount = double.tryParse(priceController.text.trim());
  final category = categoryController.text.trim();
  final dateText = dateController.text.trim();
  final notes = noteController.text.trim();

  if (title.isEmpty || amount == null || category.isEmpty || dateText.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields')),
    );
    return;
  }

  try {
    await VariableExpensesService.addExpense(
      title: title,
      amount: amount,
      category: category,
      date: DateTime.parse(dateText),
      notes: notes.isEmpty ? null : notes,
    );

    itemNameController.clear();
    priceController.clear();
    categoryController.clear();
    dateController.clear();
    noteController.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
},

          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}