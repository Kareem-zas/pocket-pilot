import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/goals_service.dart';
import 'package:pockect_pilot/view/add_goal_page.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  List<dynamic> goals = [];
  Map<String, dynamic> summary = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });
      final data = await GoalsService.getGoals();
      if (!mounted) return;
      setState(() {
        goals = data['goals'] ?? [];
        summary = data['summary'] ?? {};
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  IconData _iconFromCategory(String? category) {
    switch (category) {
      case 'Travel':
        return Icons.flight_takeoff;
      case 'Housing':
        return Icons.home;
      case 'Education':
        return Icons.school;
      default:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadGoals,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadGoals,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 30),
                          _buildTotalSavingsRow(context),
                          const SizedBox(height: 20),
                          _buildMomentumCard(),
                          const SizedBox(height: 30),
                          _buildActiveGoalsHeader(),
                          const SizedBox(height: 15),
                          if (goals.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Column(
                                  children: [
                                    Icon(Icons.flag_outlined,
                                        size: 60, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No goals yet.\nTap "New Goal" to create your first!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...goals.map((goal) => _buildGoalCard(
                                  title: goal['title'] ?? '',
                                  subtitle: goal['category'] ?? 'General',
                                  icon: _iconFromCategory(goal['category']),
                                  progressValue:
                                      ((goal['progress'] ?? 0) / 100)
                                          .clamp(0.0, 1.0),
                                  progressText:
                                      '${(goal['progress'] ?? 0).toStringAsFixed(0)}%',
                                  savedAmount:
                                      '\$${(goal['savedAmount'] ?? 0).toStringAsFixed(2)}',
                                  targetAmount:
                                      '\$${(goal['targetAmount'] ?? 0).toStringAsFixed(2)}',
                                  goalId: goal['_id'],
                                )),
                          const SizedBox(height: 10),
                          _buildInsightsRow(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
        const Text(
          "Pocket Pilot",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTotalSavingsRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSaved = summary['totalSaved'] ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("TOTAL SAVINGS",
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 5),
            Text(
              '\$${(totalSaved as num).toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddGoalPage()),
            );
            _loadGoals(); // Refresh after adding
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0055D4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("New Goal",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMomentumCard() {
    final overallProgress = (summary['overallProgress'] ?? 0) / 100.0;
    final goalsCount = summary['goalsCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E5BD8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Active Goals",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(
                    "$goalsCount ${goalsCount == 1 ? 'Goal' : 'Goals'}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.trending_up, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Overall Progress",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text(
                "${(overallProgress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: overallProgress.clamp(0.0, 1.0),
                child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4))),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActiveGoalsHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Active Goals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("All Goals",
            style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double progressValue,
    required String progressText,
    required String savedAmount,
    required String targetAmount,
    required String goalId,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEFF7),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: isDark ? Colors.blue[300] : const Color(0xFF0055D4), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Text(progressText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              // Delete button
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Goal'),
                      content:
                          Text('Are you sure you want to delete "$title"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await GoalsService.deleteGoal(goalId);
                    _loadGoals();
                  }
                },
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEFF7),
                      borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: progressValue,
                child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4))),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SAVED",
                      style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  Text(savedAmount,
                      style: TextStyle(
                          color: isDark ? Colors.blue[300] : const Color(0xFF0055D4),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("TARGET",
                      style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  Text(targetAmount,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInsightsRow() {
    if (goals.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Find fastest growing goal (highest progress)
    final sorted = List.from(goals)
      ..sort((a, b) =>
          (b['progress'] ?? 0).compareTo(a['progress'] ?? 0));

    final fastest = sorted.isNotEmpty ? sorted.first : null;
    final closest = goals.reduce((a, b) {
      final aRemaining =
          (a['targetAmount'] ?? 0) - (a['savedAmount'] ?? 0);
      final bRemaining =
          (b['targetAmount'] ?? 0) - (b['savedAmount'] ?? 0);
      return aRemaining < bRemaining ? a : b;
    });

    final closestRemaining = ((closest['targetAmount'] ?? 0) -
            (closest['savedAmount'] ?? 0))
        .toStringAsFixed(0);

    return Row(
      children: [
        if (fastest != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEFF7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt, color: Colors.brown, size: 16),
                  const SizedBox(height: 15),
                  const Text("Highest Progress",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(
                    '${fastest['title']} - ${(fastest['progress'] ?? 0).toStringAsFixed(0)}%',
                    style:
                        TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEBEFF7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.star,
                    color: isDark ? Colors.blue[300] : const Color(0xFF0055D4), size: 16),
                const SizedBox(height: 15),
                const Text("Next Milestone",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 5),
                Text(
                  '${closest['title']} is \$$closestRemaining from target',
                  style:
                      TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
