import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  int selectedTab = 0;
  String selectedCategory = "Food & Drink";

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

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        itemNameController.text = decoded['itemName'] ?? '';
        priceController.text = decoded['total'] ?? '';
        dateController.text = decoded['date'] ?? '';
        categoryController.text = decoded['category'] ?? 'Other';
      }
    } catch (_) {}

    setState(() {});
  }

  Future<void> _openCameraWithAI() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await GeminiReceiptService.analyzeReceipt(File(image.path));
      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        AddBody.ocrTextCache = result;
        _handledOnce = false;
      });

      _handleIncomingData();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan failed: $e')),
      );
    }

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
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _openCameraWithAI,
                  ),
                ],
              ),

              const Text(
                "New Expense",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _tab("Manual Entry", 0),
                    _tab("Camera Scan", 1),
                    _tab("SMS Reader", 2),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _form(),

              const SizedBox(height: 20),

              _camera(),

              const SizedBox(height: 20),

              _sms(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, int index) {
    final selected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: selected ? Colors.blue : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _input(itemNameController, "Transaction Name"),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(child: _input(priceController, "Amount")),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(child: _input(dateController, "Date")),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _input(categoryController, "Category"),

          const SizedBox(height: 10),

          _input(noteController, "Notes"),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () async {
              final title = itemNameController.text.trim();
              final amount = double.tryParse(priceController.text.trim());
              final category = categoryController.text.trim();
              final dateText = dateController.text.trim();
              final notes = noteController.text.trim();

              if (title.isEmpty ||
                  amount == null ||
                  category.isEmpty ||
                  dateText.isEmpty) {
                return;
              }

              final parsedDate = DateTime.tryParse(dateText);
              if (parsedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid date format.")),
                );
                return;
              }

              try {
                await VariableExpensesService.addExpense(
                  title: title,
                  amount: amount,
                  category: category,
                  date: parsedDate,
                  notes: notes.isEmpty ? null : notes,
                );

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (_) => false,
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "Save Expense",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _camera() => GestureDetector(
    onTap: _openCameraWithAI,
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 40, color: Colors.blue),
            SizedBox(height: 10),
            Text("Tap to scan your receipt", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );

  Widget _sms() => Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
    ),
    child: const Center(child: Text("SMS Reader")),
  );

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F2F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
