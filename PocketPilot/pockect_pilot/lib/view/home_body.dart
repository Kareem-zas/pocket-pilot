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
import 'package:pockect_pilot/services/pocket_service.dart';
import 'package:pockect_pilot/services/bank_sms_service.dart';
import 'package:pockect_pilot/services/token_service.dart';
import 'package:pockect_pilot/view/login_view.dart';
import 'package:pockect_pilot/view/receipt_confirmation_page.dart';
import 'package:pockect_pilot/services/gamification_service.dart';
import 'package:pockect_pilot/view/gamification_screen.dart';
import 'package:pockect_pilot/services/goals_service.dart';
import 'package:pockect_pilot/view/shared_goals_page.dart';

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
  double pocketCash = 0;
  List incomes = [];
  List expenses = [];
  int streak = 0;
  Map<String, dynamic>? latestGoal;
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
      final cashLocal = await PocketService.getPocketBalance();

      int currentStreak = 0;
      try {
        final gamification = await GamificationService.getStatus();
        currentStreak = gamification['streak'] ?? 0;
      } catch (e) {
        print("Error loading gamification streak: $e");
      }

      Map<String, dynamic>? activeGoal;
      try {
        final goalsData = await GoalsService.getGoals();
        final List goalsList = goalsData['goals'] ?? [];
        if (goalsList.isNotEmpty) {
          activeGoal = goalsList.first;
        }
      } catch (e) {
        print("Error loading goals: $e");
      }

      if (!mounted) return;

      setState(() {
        pocketCash = cashLocal;
        balance = dashboard['balance'] ?? 0;
        totalIncome = dashboard['totalIncome'] ?? 0;
        variableExpenses = dashboard['variableExpenses'] ?? 0;
        totalFixed = dashboard['totalFixed'] ?? 0;
        incomes = incomeList;
        expenses = expenseList;
        streak = currentStreak;
        latestGoal = activeGoal;
        loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => loading = false);
      
      final err = e.toString().toLowerCase();
      if (err.contains("token") || err.contains("jwt") || err.contains("unauthorized")) {
        await TokenService.clearToken();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _syncSMS() async {
    try {
      final msgs = await BankSmsService.fetchRecentBankMessages();
      if (msgs.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Bank Messages Found"),
            content: Text("Detected ${msgs.length} recent transactions. Process any ATM withdrawals into your Pocket Money?"),
            actions: [
               TextButton(onPressed:() => Navigator.pop(ctx), child: const Text("Cancel")),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                 onPressed: () async {
                   double totalCashAdded = 0;
                   for(var msg in msgs) {
                      if(msg['type'] == 'withdrawal') {
                          totalCashAdded += msg['amount'];
                      }
                   }
                   
                   // Sync to backend APIs (they filter internally by type: purchase and deposit)
                   int syncedExpCount = await VariableExpensesService.syncSmsExpenses(msgs);
                   int syncedIncCount = await IncomeService.syncSmsIncome(msgs);
                   
                   await PocketService.addPocketCash(totalCashAdded);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                   loadDashboard();
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Synced: $syncedExpCount Expenses, $syncedIncCount Income, \$${totalCashAdded.toStringAsFixed(2)} Cash")));
                 }, 
                 child: const Text("Sync to Pocket", style: TextStyle(color: Colors.white))
               )
            ]
          )
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No new bank messages.")));
      }
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
      
      await Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => ReceiptConfirmationPage(rawJson: jsonResult))
      );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    icon: const Icon(Icons.sync_outlined, color: Colors.blue),
                    onPressed: _syncSMS,
                  ),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("POCKET MONEY 💵", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 5),
                              Text(
                                "\$${pocketCash.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 18, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                              ),
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
          _buildStreakBanner(),
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
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  textColor: isDark ? Colors.blue.shade300 : Colors.blue,
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
              Text(
                "Active Goals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    child: Text(
                      "Shared Vaults 👥",
                      style: TextStyle(
                        color: isDark ? Colors.green.shade300 : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SharedGoalsPage())).then((_) => loadDashboard()),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    child: Text(
                      "View All",
                      style: TextStyle(
                        color: isDark ? Colors.blue.shade300 : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())).then((_) => loadDashboard()),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: isDark ? Colors.blue.shade300 : Colors.blue, size: 16),
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage())).then((_) => loadDashboard()),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          _buildActiveGoalCard(),
          const SizedBox(height: 25),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Income History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Regular Expense History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: border ? Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300) : null,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: isDark ? Colors.blue.shade300 : Colors.blue),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['source'] ?? 'Income',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year}"
                        : "",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            "+\$${item['amount']}",
            style: TextStyle(
              color: isDark ? Colors.blue.shade300 : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseItem(dynamic item) {
    final date = DateTime.tryParse(item['date'] ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F2F6),
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
                  Text(
                    item['title'] ?? 'Expense',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date != null
                        ? "${date.day}/${date.month}/${date.year}"
                        : "",
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.grey,
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

  Widget _buildStreakBanner() {
    if (streak <= 0) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamificationScreen()),
        ).then((_) => loadDashboard());
      },
      child: Container(
        margin: const EdgeInsets.only(top: 15, bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2C1605), const Color(0xFF4C270A)]
                : [const Color(0xFFFFF7ED), const Color(0xFFFFEDD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF7C2D12) : Colors.orange.shade200, width: 1),
        ),
        child: Row(
          children: [
            const Text("🔥", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You're on a $streak-Day Streak!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.orange.shade300 : Colors.orange.shade900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tap to see your badges and daily budget check.",
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: isDark ? Colors.orange.shade300 : Colors.orange, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGoalCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (latestGoal == null) {
      return GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage())).then((_) => loadDashboard()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.flag_outlined, color: Colors.grey),
              SizedBox(width: 10),
              Text(
                "Create a savings goal to start tracking",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final goal = latestGoal!;
    final String title = goal['title'] ?? 'Goal';
    final double target = (goal['targetAmount'] as num?)?.toDouble() ?? 0.0;
    final double saved = (goal['savedAmount'] as num?)?.toDouble() ?? 0.0;
    final double progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    final bool isShared = goal['shared'] ?? false;

    return GestureDetector(
      onTap: () {
        if (isShared) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SharedGoalsPage())).then((_) => loadDashboard());
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsPage())).then((_) => loadDashboard());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isShared
                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9))
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEFF7)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isShared ? Icons.group : Icons.flag,
                color: isShared ? Colors.green : (isDark ? Colors.blue.shade300 : const Color(0xFF0055D4)),
                size: 18,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isShared) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Shared 👥",
                            style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEFF7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isShared ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 15),
            Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isShared ? Colors.green : (isDark ? Colors.blue.shade300 : const Color(0xFF0055D4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}