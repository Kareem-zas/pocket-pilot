import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/services/fixed_expenses_service.dart';
import 'package:pockect_pilot/view/fixed_expenses_history.dart';

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();

  String frequency = 'monthly';
  bool loading = false;

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    dateController.dispose();
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

  Future<void> _addFixedExpense() async {
    if (loading) return;

    final title = titleController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    final dateText = dateController.text.trim();

    if (title.isEmpty || amount == null || dateText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FixedExpensesService.addFixedExpenseItem(
        title: title,
        amount: amount,
        frequency: frequency,
        startDate: DateTime.parse(dateText),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const FixedExpensesHistory(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 85),
                  Text(
                    'Add Fixed Expense',
                    style: TextStyle(
                      color: GlobalColors.textColor3,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              AppTextField(
                controller: titleController,
                hint: 'Expense Title',
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: amountController,
                hint: 'Amount',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              Container(
                width: 260,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: GlobalColors.textFieldColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: frequency,
                    isExpanded: true,
                    dropdownColor: GlobalColors.textFieldColor,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: GlobalColors.textColor3,
                    ),
                    style: TextStyle(
                      color: GlobalColors.textColor3,
                      fontSize: 11,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'yearly',
                        child: Text('Yearly'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          frequency = value;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: AppTextField(
                    controller: dateController,
                    hint: 'Start Date',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              AppButton(
                text: loading ? 'Saving...' : 'Add Fixed Expense',
                onPressed: loading ? () {} : _addFixedExpense,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
