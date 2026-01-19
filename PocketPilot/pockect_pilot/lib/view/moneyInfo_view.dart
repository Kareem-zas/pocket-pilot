import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/services/income_service.dart';

class MoneyInfoView extends StatefulWidget {
  const MoneyInfoView({super.key});

  @override
  State<MoneyInfoView> createState() => _MoneyInfoViewState();
}

class _MoneyInfoViewState extends State<MoneyInfoView> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

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
    balanceController.dispose();
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

  Future<void> _saveIncome() async {
    try {
      if (_isAmountValid) {
        await IncomeService.insertIncome(
          source: sourceController.text.trim().isEmpty
              ? 'General'
              : sourceController.text.trim(),
          amount: double.parse(amountController.text.trim()),
          date: selectedDate?.toIso8601String(),
          isRecurring: isRecurring,
          frequency: isRecurring ? frequency : null,
          notes: notesController.text.trim().isEmpty
              ? null
              : notesController.text.trim(),
        );
      }

  

     Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const HomePage(),
  ),
);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Text(
                  'Income Info',
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
                  suffix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("\$"),
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

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text(
                    'Recurring Income',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: isRecurring,
                  onChanged: (val) {
                    setState(() {
                      isRecurring = val;
                      if (!val) frequency = null;
                    });
                  },
                ),

                if (isRecurring)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: DropdownButtonFormField<String>(
  value: frequency,
  hint: const Text("Select Frequency"),
  items: frequencies.entries
      .map(
        (e) => DropdownMenuItem(
          value: e.value,
          child: Text(e.key),
        ),
      )
      .toList(),
  onChanged: (val) => setState(() => frequency = val),
)
,
                  ),

                const SizedBox(height: 12),

                
AppButton(
  text: selectedDate == null
      ? "Pick Date"
      : selectedDate!.toLocal().toString().split(' ')[0],
  onPressed: _pickDate,
),



                const SizedBox(height: 12),

                AppTextField(
                  controller: notesController,
                  hint: "Notes (optional)",
                ),

                const SizedBox(height: 12),

                AppTextField(
                  controller: balanceController,
                  hint: "Current Balance",
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 30),

                AppButton(
                  text: "Save",
                  onPressed: _saveIncome,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
