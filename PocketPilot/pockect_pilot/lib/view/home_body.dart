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

class _HomeBodyState extends State<HomeBody>
    with WidgetsBindingObserver {
  double balance = 0;
  double totalIncome = 0;
  double variableExpenses = 0;
  double totalFixed = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadDashboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadDashboard();
    }
  }

  Future<void> loadDashboard() async {
    try {
      final data = await HomeService.fetchDashboard();

      if (!mounted) return;

      setState(() {
        balance = data['balance']!;
        totalIncome = data['totalIncome']!;
        variableExpenses = data['variableExpenses']!;
        totalFixed = data['totalFixed']!;
        loading = false;
      });
    } catch (e) {
      debugPrint('HOME ERROR: $e');
      if (!mounted) return;
      setState(() => loading = false);
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
                value: '\$${balance.toStringAsFixed(2)}',
                color: GlobalColors.buttonColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                title: 'Expenses',
                value: '\$${variableExpenses.toStringAsFixed(2)}',
                color: GlobalColors.expensesColor,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpensesScreen(),
                    ),
                  );
                  loadDashboard();
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
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomeScreen(),
                    ),
                  );
                  loadDashboard();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _box(
                title: 'Fixed Expenses',
                value: '\$${totalFixed.toStringAsFixed(2)}',
                color: GlobalColors.expensesColor,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FixedExpensesHistory(),
                    ),
                  );
                  loadDashboard();
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
