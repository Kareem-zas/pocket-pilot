import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/widgets/app_widgets.dart';
import 'package:pockect_pilot/view/home_page.dart';

class MoneyInfoView extends StatefulWidget {
  const MoneyInfoView({super.key});

  @override
  State<MoneyInfoView> createState() => _MoneyInfoViewState();
}

class _MoneyInfoViewState extends State<MoneyInfoView> {
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController incomeCategoryController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  @override
  void dispose() {
    incomeController.dispose();
    incomeCategoryController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  bool get _isIncomeEntered {
    final text = incomeController.text.trim();
    return text.isNotEmpty && double.tryParse(text) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
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
                    color: GlobalColors.textColor2,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please fill the form in your income info',
                  style: TextStyle(
                    color: GlobalColors.textColor,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                AppTextField(
                  controller: incomeController,
                  hint: "Income (optional)",
                  keyboardType: TextInputType.number,
                  suffix: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                    child: Text(
                      "\$",
                      style: TextStyle(
                        color: GlobalColors.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Opacity(
                  opacity: _isIncomeEntered ? 1.0 : 0.4,
                  child: AppTextField(
                    controller: incomeCategoryController,
                    hint: "Income Category",
                    enabled: _isIncomeEntered,
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: balanceController,
                  hint: "Current Balance",
                  keyboardType: TextInputType.number,
                  suffix: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                    child: Text(
                      "\$",
                      style: TextStyle(
                        color: GlobalColors.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
AppButton(
  text: "Save",
  onPressed: () {
    final balance =
        double.tryParse(balanceController.text.trim()) ?? 0;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomePage(currentBalance: balance),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  },
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