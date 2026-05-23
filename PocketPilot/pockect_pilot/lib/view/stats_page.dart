import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pockect_pilot/services/home_service.dart';
import 'package:pockect_pilot/view/ai_pilot_page.dart';
import 'package:pockect_pilot/view/forecast_screen.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String _activeChartFilter = 'EXPENSES';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              _buildForecastBanner(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          text: TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            children: const [
              TextSpan(text: "Statistics "),
              TextSpan(text: "&", style: TextStyle(color: Color(0xFF0055D4))),
              TextSpan(text: " Insights"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Your spending momentum has increased by 4.2% compared to last month. Here's how you're navigating your budget.",
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEFF7),
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
                Text(
                  "${months[now.month-1]} ${now.year}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    double income = 0;
    double expenses = 0;
    
    if (dashboardData != null && dashboardData!['summary'] != null) {
      final summary = dashboardData!['summary'];
      income = (summary['income']['total'] as num).toDouble();
      expenses = (summary['expenses']['total'] as num).toDouble();
    }

    double savings = income - expenses;
    double targetValue = expenses;
    Color lineColor = Colors.orange;

    if (_activeChartFilter == 'INCOME') {
      targetValue = income;
      lineColor = Colors.blue;
    } else if (_activeChartFilter == 'SAVINGS') {
      targetValue = savings > 0 ? savings : 0;
      lineColor = Colors.green;
    }

    double globalMax = 100;
    if (income > globalMax) globalMax = income;
    if (expenses > globalMax) globalMax = expenses;
    if (savings > globalMax) globalMax = savings;
    List<FlSpot> spots = [
      const FlSpot(0, 0),
      const FlSpot(1, 0),
      const FlSpot(2, 0),
      const FlSpot(3, 0),
      const FlSpot(4, 0),
      FlSpot(5, targetValue),
    ];

    String floatText;
    Color floatColor;

    if (_activeChartFilter == 'INCOME') {
      floatText = "+\$${income.toStringAsFixed(0)}";
      floatColor = Colors.blue;
    } else if (_activeChartFilter == 'EXPENSES') {
      floatText = "-\$${expenses.toStringAsFixed(0)}";
      floatColor = Colors.orange;
    } else {
      floatText = savings >= 0 ? "+\$${savings.toStringAsFixed(0)}" : "-\$${savings.abs().toStringAsFixed(0)}";
      floatColor = savings >= 0 ? Colors.green : Colors.red.shade800;
    }

    // Dynamically calculate the last 6 months including the current active month
    final now = DateTime.now();
    const globalMonths = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    List<String> timelineMonths = [];
    for (int i = 5; i >= 0; i--) {
      int idx = (now.month - 1 - i) % 12;
      if (idx < 0) idx += 12;
      timelineMonths.add(globalMonths[idx]);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cash Flow", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                  Text("Momentum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 5),
                  const Text("Income vs Expenses", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const Text("• Last 6 Months", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  _statChip("INCOME", Colors.blue),
                  _statChip("EXPENSES", Colors.orange),
                  _statChip("SAVINGS", Colors.green),
                ],
              )
            ],
          ),
          const SizedBox(height: 35),
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < timelineMonths.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  timelineMonths[value.toInt()],
                                  style: TextStyle(
                                    color: value.toInt() == 5 ? (isDark ? Colors.blue.shade300 : Colors.blue) : (isDark ? Colors.white60 : Colors.grey),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 5,
                    minY: 0,
                    maxY: (globalMax * 1.2), // Global headroom so the curves relate to each other visually
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: lineColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true), // Show dots so the zeros are visible
                        belowBarData: BarAreaData(
                          show: true,
                          color: lineColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  top: -25,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: floatColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(floatText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    bool isActive = _activeChartFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        setState(() => _activeChartFilter = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F2F6)),
          border: Border.all(color: isActive ? color : Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 8, color: isActive ? color : (isDark ? Colors.white70 : Colors.blue.shade900), fontWeight: FontWeight.bold)),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Spending Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
            Text("VIEW ALL", style: TextStyle(color: isDark ? Colors.blue.shade300 : Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isDark ? Colors.blue.shade300 : iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 10, letterSpacing: 0.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 2),
              Text(change, style: TextStyle(color: changeColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPilotInsights(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEFF7),
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
              Text(
                "Pilot Insights",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
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
              String prompt = "Based on my dashboard, how can I optimize my budget to dramatically increase my savings rate?";
              if (_activeChartFilter == 'EXPENSES') {
                prompt = "Based on my dashboard, how can I creatively reduce my expenses this month?";
              } else if (_activeChartFilter == 'INCOME') {
                prompt = "Based on my dashboard, what are some effective strategies to increase my monthly income?";
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => AiPilotPage(initialPrompt: prompt)));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForecastScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_graph, color: Colors.greenAccent, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "AI Financial Time-Travel 🔮",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Project income, expenses, and balance trajectory for the next 6 months.",
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
