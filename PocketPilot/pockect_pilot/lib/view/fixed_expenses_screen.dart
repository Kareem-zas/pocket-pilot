import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor,
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: GlobalColors.textColor2,
        ),
        title: Text(
          'Fixed Expenses',
          style: TextStyle(
            color: GlobalColors.textColor2,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'All Fixed Expenses Will Appear Here',
          style: TextStyle(
            color: GlobalColors.textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}