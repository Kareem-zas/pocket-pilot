import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/view/expenses_screen.dart';
import 'package:pockect_pilot/view/fixed_expenses_history.dart';
import 'package:pockect_pilot/view/income_screen.dart';
import 'package:pockect_pilot/services/home_service.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  double currentBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  double totalFixedExpenses = 0.0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      final data = await HomeService.fetchHomeData();

      setState(() {
        currentBalance = data['currentBalance'] ?? 0.0;
        totalIncome = data['totalIncome'] ?? 0.0;
        totalExpenses = data['totalExpenses'] ?? 0.0;
        totalFixedExpenses = data['totalFixedExpenses'] ?? 0.0;
        loading = false;
      });
    } catch (e) {
      debugPrint('HOME ERROR: $e');
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
        const SizedBox(height: 40),

        Row(
          children: [
            Expanded(
              child: _box(
                title: 'Current Balance',
                value: '\$${currentBalance.toStringAsFixed(2)}',
                color: GlobalColors.buttonColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                title: 'Expenses',
                value: '\$${totalExpenses.toStringAsFixed(2)}',
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
                value: '\$${totalIncome.toStringAsFixed(2)}',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomeScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                title: 'Fixed Expenses',
                value: '\$${totalFixedExpenses.toStringAsFixed(2)}',
                color: GlobalColors.expensesColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FixedExpensesHistory(),
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