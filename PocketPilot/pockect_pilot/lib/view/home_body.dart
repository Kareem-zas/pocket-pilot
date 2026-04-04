import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/home_service.dart';
import 'package:pockect_pilot/services/income_service.dart';
import 'dart:io';
import 'package:pockect_pilot/view/add_income_body.dart';
import 'package:pockect_pilot/view/add_body.dart';
import 'package:pockect_pilot/services/variable_expenses_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pockect_pilot/services/gemini_receipt_service.dart';
import 'package:pockect_pilot/view/goals_page.dart';
import 'package:pockect_pilot/view/add_goal_page.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody>
    with SingleTickerProviderStateMixin {
  double balance = 0;
  double totalIncome = 0;
  double variableExpenses = 0;
  double totalFixed = 0;
  List incomes = [];
  List expenses = [];
  bool loading = true;

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    loadDashboard();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  Future<void> loadDashboard() async {
    try {
      final dashboard = await HomeService.fetchDashboard();
      final incomeList = await IncomeService.getIncome();
      final expenseList = await VariableExpensesService.getVariableExpenses();

      if (!mounted) return;

      setState(() {
        balance = dashboard['balance'] ?? 0;
        totalIncome = dashboard['totalIncome'] ?? 0;
        variableExpenses = dashboard['variableExpenses'] ?? 0;
        totalFixed = dashboard['totalFixed'] ?? 0;
        incomes = incomeList;
        expenses = expenseList;
        loading = false;
      });
    } catch (e) {
      loading = false;
    }
  }

  Future<void> _quickScan() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file == null) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final jsonResult = await GeminiReceiptService.analyzeReceipt(File(file.path));
      if (!mounted) return;
      Navigator.pop(context);
      
      AddBody.ocrTextCache = jsonResult;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBody()));
      loadDashboard();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed parsing: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: Colors.blue),
              const Text(
                "Pocket Pilot",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: _quickScan,
                  ),
                  const CircleAvatar(radius: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1F35), Color(0xFF1E5BD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circles
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Pocket Pilot Card", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Icon(Icons.wifi, color: Colors.white.withValues(alpha: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // EMV Chip
                      Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade300,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.orange.shade400),
                        ),
                        child: Center(
                          child: Container(
                            width: 25, height: 15,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.orange.shade600, width: 0.5),
                            )
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "****  ****  ****  7421",
                        style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 2),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("TOTAL BALANCE", style: TextStyle(color: Colors.white54, fontSize: 10)),
                              const SizedBox(height: 5),
                              Text(
                                "\$${balance.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(width: 25, height: 25, decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.8), shape: BoxShape.circle)),
                              Transform.translate(
                                offset: const Offset(-10, 0),
                                child: Container(width: 25, height: 25, decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.8), shape: BoxShape.circle)),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _button(
                  text: "Add Expense",
                  color: Colors.orange,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddBody(),
                      ),
                    );
                    loadDashboard();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _button(
                  text: "Add Income",
                  color: Colors.white,
                  textColor: Colors.blue,
                  border: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddIncomeBody(),
                      ),
                    );
                    loadDashboard();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Active Goals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  GestureDetector(
                    child: const Text("View All", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: Colors.blue, size: 16),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage())),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFEBEFF7), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.flight_takeoff, color: Color(0xFF0055D4), size: 18),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Dream Vacation", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Stack(
                          children: [
                            Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEFF7), borderRadius: BorderRadius.circular(2))),
                            FractionallySizedBox(
                              widthFactor: 0.45,
                              child: Container(height: 4, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(2))),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text("45%", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0055D4))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Income History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          incomes.isEmpty
              ? const Text("No income yet")
              : Column(
                  children:
                      incomes.map((e) => _historyItem(e)).toList(),
                ),
          const SizedBox(height: 25),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Regular Expense History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          expenses.isEmpty
              ? const Text("No expenses yet")
              : Column(
                  children:
                      expenses.map((e) => _expenseItem(e)).toList(),
                ),
        ],
      ),
    );
  }

  Widget _button({
    required String text,
    required Color color,
    Color textColor = Colors.white,
    bool border = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: border ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _historyItem(dynamic item) {
    final date = DateTime.tryParse(item['date'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.work, color: Colors.blue),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['source'] ?? 'Income'),
                  Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year}"
                        : "",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "+\$${item['amount']}",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseItem(dynamic item) {
    final date = DateTime.tryParse(item['date'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: Colors.orange),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? 'Expense'),
                  Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year}"
                        : "",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "-\$${item['amount']}",
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}