import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/home_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await HomeService.fetchFullDashboard();
      if (mounted) {
        setState(() {
          dashboardData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildDateSelector(),
              const SizedBox(height: 25),
              _buildChartCard(),
              const SizedBox(height: 25),
              _buildSavingsRateCard(),
              const SizedBox(height: 25),
              _buildSpendingBreakdown(),
              const SizedBox(height: 25),
              _buildPilotInsights(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "FINANCIAL ANALYSIS",
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            children: [
              TextSpan(text: "Statistics "),
              TextSpan(text: "&", style: TextStyle(color: Color(0xFF0055D4))),
              TextSpan(text: " Insights"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Your spending momentum has increased by 4.2% compared to last month. Here's how you're navigating your budget.",
          style: TextStyle(
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEFF7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0055D4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ACTIVE PERIOD", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("${months[now.month-1]} ${now.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cash Flow", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Momentum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Income vs Expenses", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("• Last 6 Months", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  _statChip("INCOME", Colors.blue),
                  const SizedBox(width: 5),
                  _statChip("EXPENSES", Colors.orange),
                ],
              )
            ],
          ),
          const SizedBox(height: 60), // Placeholder graph curves
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: 0,
                bottom: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text("+\$1.2k", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("MAY", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("JUN", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("JUL", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("AUG", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("SEP", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("OCT", style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 8, color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSavingsRateCard() {
    double income = 0;
    double expenses = 0;
    
    if (dashboardData != null && dashboardData!['summary'] != null) {
      final summary = dashboardData!['summary'];
      income = (summary['income']['total'] as num).toDouble();
      expenses = (summary['expenses']['total'] as num).toDouble();
    }

    double efficiency = income > 0 ? ((income - expenses) / income) * 100 : 0;
    if (efficiency < 0) efficiency = 0;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0055D4), Color(0xFF0044B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Savings Rate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Efficiency Index", style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          Text("${efficiency.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36)),
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.white, size: 14),
              SizedBox(width: 5),
              Text("+2.1% FROM LAST MONTH", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Monthly Savings Progress", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text("${efficiency.toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(height: 6, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(3))),
              FractionallySizedBox(
                widthFactor: (efficiency / 100).clamp(0.0, 1.0),
                child: Container(height: 6, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(3))),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSpendingBreakdown() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Spending Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("VIEW ALL", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 15),
        ..._buildDynamicCategories(),
      ],
    );
  }

  List<Widget> _buildDynamicCategories() {
    if (dashboardData == null || dashboardData!['summary'] == null) return [];
    
    final details = dashboardData!['summary']['expenses']['variable']['details'] as List;
    if (details.isEmpty) return [const Center(child: Text("No expenses recorded yet."))];
    
    Map<String, double> grouped = {};
    Map<String, int> counts = {};

    for (var item in details) {
      final cat = item['category'] ?? 'other';
      final amt = (item['amount'] as num).toDouble();
      grouped[cat] = (grouped[cat] ?? 0) + amt;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    final sortedKeys = grouped.keys.toList()..sort((a,b) => grouped[b]!.compareTo(grouped[a]!));

    return sortedKeys.take(3).map((cat) {
      return _breakdownItem(
          icon: Icons.category,
          iconColor: Colors.blue.shade900,
          bgColor: Colors.blue.shade50,
          title: cat.toUpperCase(),
          subtitle: "${counts[cat]} TRANSACTIONS",
          amount: "\$${grouped[cat]!.toStringAsFixed(2)}",
          change: "...",
          changeColor: Colors.grey,
      );
    }).toList();
  }

  Widget _breakdownItem({required IconData icon, required Color iconColor, required Color bgColor, required String title, required String subtitle, required String amount, required String change, required Color changeColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 0.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(change, style: TextStyle(color: changeColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPilotInsights(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFF7),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFF0055D4), shape: BoxShape.circle),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text("Pilot Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          _insightCard(
            title: "Over-budget Warning",
            text: "You've spent a large portion of your monthly budget. Consider reviewing your top categories.",
            borderColor: Colors.orange.shade700,
          ),
          const SizedBox(height: 10),
          _insightCard(
            title: "Savings Opportunity",
            text: "Try asking the AI Pilot how to optimize your fixed expenses to increase your savings rate.",
            borderColor: const Color(0xFF0055D4),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Routing to AI Pilot...")));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF0055D4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ask AI Pilot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _insightCard({required String title, required String text, required Color borderColor}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 5),
          Text(text, style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }
}
