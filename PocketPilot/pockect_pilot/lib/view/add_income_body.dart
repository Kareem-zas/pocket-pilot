import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';

class AddIncomeBody extends StatefulWidget {
  const AddIncomeBody({super.key});

  @override
  State<AddIncomeBody> createState() => _AddIncomeBodyState();
}

class _AddIncomeBodyState extends State<AddIncomeBody> {
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    sourceController.dispose();
    amountController.dispose();
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
      setState(() {
        dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Text(
              'Add Income',
              style: TextStyle(
                color: GlobalColors.textColor2,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            AppTextField(
              controller: sourceController,
              hint: 'Source Name',
            ),

            const SizedBox(height: 12),

            AppTextField(
              controller: amountController,
              hint: 'Amount',
              keyboardType: TextInputType.number,
              suffix: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
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
              hint: 'Income Category',
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: AppTextField(
                  controller: dateController,
                  hint: 'Date',
                  suffix: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
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
              text: 'Add Income',
              onPressed: () {
                print(sourceController.text);
                print(amountController.text);
                print(categoryController.text);
                print(dateController.text);
                print(noteController.text);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
