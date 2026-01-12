import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/expenses_screen.dart';
import 'package:pockect_pilot/view/fixed_expenses_screen.dart';
import 'package:pockect_pilot/view/income_screen.dart';

class HomeBody extends StatefulWidget {
  final double currentBalance;
  final double expenses;

  const HomeBody({
    super.key,
    required this.currentBalance,
    required this.expenses,
  });

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Home',
          style: TextStyle(
            color: GlobalColors.textColor3,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your financial overview',
          style: TextStyle(
            color: GlobalColors.buttonColor,
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 40),

        Row(
          children: [
            Expanded(
              child: _box(
                title: 'Current Balance',
                value: '\$${widget.currentBalance.toStringAsFixed(2)}',
                color: GlobalColors.buttonColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                title: 'Expenses',
                value: '\$${widget.expenses.toStringAsFixed(2)}',
                color: GlobalColors.expensesColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpensesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _box(
                title: 'Income',
                value: '\$0.00',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomeScreen(),
                    ),
                  );
                }
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                title: 'Fixed Expenses',
                value: '\$0.00',
                color: GlobalColors.expensesColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FixedExpensesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _box({
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: GlobalColors.textColor2,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: GlobalColors.textColor2,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}