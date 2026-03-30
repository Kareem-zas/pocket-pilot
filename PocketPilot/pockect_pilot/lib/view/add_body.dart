import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/services/variable_expenses_service.dart';
import 'package:pockect_pilot/services/gemini_receipt_service.dart';
import 'package:pockect_pilot/view/home_page.dart';

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

  /// ✅ READ AI RESULT (Gemini JSON)
  void _handleIncomingData() {
    final raw = AddBody.ocrTextCache;
    if (raw == null || raw.trim().isEmpty) return;

    _handledOnce = true;
    AddBody.ocrTextCache = null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        itemNameController.text =
            decoded['itemName']?.toString().trim() ?? '';
        priceController.text =
            decoded['total']?.toString().trim() ?? '';
        dateController.text =
            decoded['date']?.toString().trim() ?? '';
        categoryController.text =
            decoded['category']?.toString().trim() ?? 'Other';
      }
    } catch (e) {
      debugPrint('AI JSON PARSE ERROR: $e');
    }

    setState(() {});
  }

  /// 🔥 SAME LOGIC AS NAV BAR CAMERA (Gemini)
  Future<void> _openCameraWithAI() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analyzing receipt...')),
    );

    try {
      final jsonResult =
          await GeminiReceiptService.analyzeReceipt(File(image.path));

      if (!mounted) return;

      setState(() {
        AddBody.ocrTextCache = jsonResult;
        _handledOnce = false; // 🔁 force re-read
      });

      _handleIncomingData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gemini failed: $e')),
      );
    }
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
                onPressed: _openCameraWithAI, // ✅ FIXED
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

          /// ✅ ADD EXPENSE (AI + MANUAL)
          AppButton(
            text: 'Add Expense',
            onPressed: () async {
              final title = itemNameController.text.trim();
              final category = categoryController.text.trim();
              final dateText = dateController.text.trim();
              final notes = noteController.text.trim();
              final amount =
                  double.tryParse(priceController.text.trim());

              if (title.isEmpty ||
                  amount == null ||
                  amount <= 0 ||
                  category.isEmpty ||
                  dateText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid expense data'),
                  ),
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

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                  (_) => false,
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
