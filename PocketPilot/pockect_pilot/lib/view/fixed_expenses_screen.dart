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
      backgroundColor: GlobalColors.mainColor2,
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor2,
        elevation: 0,
        iconTheme: IconThemeData(
          color: GlobalColors.textColor3,
        ),
        title: Text(
          'Fixed Expenses',
          style: TextStyle(
            color: GlobalColors.textColor3,
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