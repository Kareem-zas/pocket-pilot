import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';

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
            color: GlobalColors.textColor2,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your financial overview',
          style: TextStyle(
            color: GlobalColors.textColor,
            fontSize: 7,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: _box(
                'Current Balance',
                '\$${widget.currentBalance.toStringAsFixed(2)}',
                GlobalColors.buttonColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                'Expenses',
                '\$${widget.expenses.toStringAsFixed(2)}',
                GlobalColors.expensesColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _box(String title, String value, Color color) {
    return Container(
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
    );
  }
}