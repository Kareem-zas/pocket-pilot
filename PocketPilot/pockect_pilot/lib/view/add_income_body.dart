import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/services/income_service.dart';
import 'package:pockect_pilot/view/home_page.dart';

class AddIncomeBody extends StatefulWidget {
  const AddIncomeBody({super.key});

  @override
  State<AddIncomeBody> createState() => _AddIncomeBodyState();
}

class _AddIncomeBodyState extends State<AddIncomeBody> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isRecurring = false;
  String? frequency;
  DateTime? selectedDate;

  final Map<String, String> frequencies = {
    'Monthly': 'monthly',
    'Yearly': 'yearly',
  };

  @override
  void dispose() {
    amountController.dispose();
    sourceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  bool get _isAmountValid {
    final text = amountController.text.trim();
    return text.isNotEmpty && double.tryParse(text) != null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _addIncome() async {
    if (!_isAmountValid || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    if (isRecurring && frequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select frequency')),
      );
      return;
    }

    try {
      await IncomeService.insertIncome(
        source: sourceController.text.trim().isEmpty
            ? 'General'
            : sourceController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        date: selectedDate!,
        isRecurring: isRecurring,
        frequency: isRecurring ? frequency : null,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      if (!mounted) return;

      // ✅ redirect to HomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Add Income',
            style: TextStyle(
              color: GlobalColors.textColor3,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          AppTextField(
            controller: amountController,
            hint: "Income Amount",
            keyboardType: TextInputType.number,
            suffix: SizedBox(
              width: 40,
              child: Center(
                child: Text(
                  "\$",
                  style: TextStyle(
                    color: GlobalColors.textColor3,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          Opacity(
            opacity: _isAmountValid ? 1 : 0.4,
            child: AppTextField(
              controller: sourceController,
              hint: "Income Source (e.g. Salary)",
              enabled: _isAmountValid,
            ),
          ),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recurring Income',
                  style: TextStyle(
                    fontSize: 11,
                    color: GlobalColors.textColor3,
                  ),
                ),
                Switch(
                  value: isRecurring,
                  onChanged: (val) {
                    setState(() {
                      isRecurring = val;
                      if (!val) frequency = null;
                    });
                  },
                ),
              ],
            ),
          ),

          if (isRecurring)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 70, vertical: 8),
              child: DropdownButtonFormField<String>(
                value: frequency,
                hint: const Text("Select Frequency"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: GlobalColors.textFieldColor,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: frequencies.entries
                    .map(
                      (e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(e.key),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => frequency = val),
              ),
            ),

          const SizedBox(height: 12),

          AppButton(
            text: selectedDate == null
                ? "Pick Date"
                : selectedDate!
                    .toLocal()
                    .toString()
                    .split(' ')[0],
            onPressed: _pickDate,
          ),

          const SizedBox(height: 12),

          AppTextField(
            controller: notesController,
            hint: "Notes (optional)",
          ),

          const SizedBox(height: 30),

          AppButton(
            text: "Add Income",
            onPressed: _addIncome,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
