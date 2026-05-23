import 'package:flutter/material.dart';
import 'package:pockect_pilot/services/gamification_service.dart';
import 'package:pockect_pilot/utils/notification_helper.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  int _streakDays = 0;
  List<String> _unlockedBadges = [];
  double _dailyBudget = 0.0;
  double _expensesToday = 0.0;
  double _remainingBudget = 0.0;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final Map<String, Map<String, dynamic>> _badgeMetaData = {
    "Pocket Saver": {
      "desc": "Remained under budget 3 days in a row.",
      "icon": Icons.wallet,
      "color": Colors.amber,
    },
    "Budget Master": {
      "desc": "Remained under budget 7 days in a row.",
      "icon": Icons.workspace_premium,
      "color": Colors.blue,
    },
    "Financial Ninja": {
      "desc": "Remained under budget 30 days in a row.",
      "icon": Icons.security,
      "color": Colors.redAccent,
    },
    "No-Spend Hero": {
      "desc": "Had at least one day with zero variable expenses.",
      "icon": Icons.savings,
      "color": Colors.green,
    },
    "Smart Planner": {
      "desc": "Created at least one financial savings goal.",
      "icon": Icons.track_changes,
      "color": Colors.purple,
    },
    "Subscription Hunter": {
      "desc": "Identified and tracked active recurring subscriptions.",
      "icon": Icons.radar,
      "color": Colors.teal,
    },
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _loadStatus();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final data = await GamificationService.getStatus();
      setState(() {
        _streakDays = data['streakDays'] ?? 0;
        _unlockedBadges = List<String>.from(data['unlockedBadges'] ?? []);
        _dailyBudget = (data['dailyBudget'] as num?)?.toDouble() ?? 0.0;
        _expensesToday = (data['expensesToday'] as num?)?.toDouble() ?? 0.0;
        _remainingBudget = (data['remainingBudget'] as num?)?.toDouble() ?? 0.0;
        _isLoading = false;
      });
      _animController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStreak() async {
    try {
      setState(() => _isLoading = true);
      final data = await GamificationService.checkStatus();
      
      final newStreak = data['streakDays'] ?? 0;
      final List<String> newlyUnlocked = List<String>.from(data['newlyUnlocked'] ?? []);

      setState(() {
        _streakDays = newStreak;
        _unlockedBadges = List<String>.from(data['unlockedBadges'] ?? []);
        _dailyBudget = (data['dailyBudget'] as num?)?.toDouble() ?? 0.0;
        _expensesToday = (data['expensesToday'] as num?)?.toDouble() ?? 0.0;
        _remainingBudget = (data['remainingBudget'] as num?)?.toDouble() ?? 0.0;
        _isLoading = false;
      });

      _animController.forward(from: 0.0);

      // Handle newly unlocked badges celebration
      if (newlyUnlocked.isNotEmpty) {
        for (var badge in newlyUnlocked) {
          NotificationHelper.showNotification(
            id: badge.hashCode,
            title: "Achievement Unlocked! 🏆",
            body: "Congratulations! You earned the '$badge' badge.",
          );
          _showCelebrationDialog(badge);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Streak synced successfully!")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sync failed: ${e.toString()}")),
      );
    }
  }

  void _showCelebrationDialog(String badgeName) {
    final meta = _badgeMetaData[badgeName] ?? {
      "desc": "Custom badge",
      "icon": Icons.star,
      "color": Colors.amber,
    };

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E2937),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "Congratulations! 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (meta['color'] as Color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    meta['icon'] as IconData,
                    color: meta['color'] as Color,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badgeName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  meta['desc'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Awesome!",
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverBudget = _expensesToday > _dailyBudget;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Gamified Theme
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
            : _error != null
                ? _buildErrorWidget()
                : RefreshIndicator(
                    onRefresh: _loadStatus,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 25),
                          _buildStreakCard(),
                          const SizedBox(height: 25),
                          _buildBudgetGoalCard(isOverBudget),
                          const SizedBox(height: 30),
                          const Text(
                            "Your Financial Badges",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          const SizedBox(height: 15),
                          _buildBadgesGrid(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 70, color: Colors.grey),
            const SizedBox(height: 15),
            const Text(
              "Unable to load Streaks",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _error ?? "Check your backend connection status.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _loadStatus,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text("Retry Connection",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 5),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "POCKET SAVER LEVEL",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5),
                ),
                Text(
                  "Achievements",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.sync, color: Colors.blueAccent),
          onPressed: _checkStreak,
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Text(
                "🔥",
                style: TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$_streakDays DAY SPENDING STREAK",
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Keep saving to protect your streak!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetGoalCard(bool isOverBudget) {
    final progress = _dailyBudget > 0 ? (_expensesToday / _dailyBudget).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2937),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Dynamic Daily Target",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOverBudget ? "Over Budget" : "On Track",
                  style: TextStyle(
                      color: isOverBudget ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _subMetric("EXPENSES TODAY", "\$${_expensesToday.toStringAsFixed(2)}"),
              _subMetric("MAX BUDGET ALLOWED", "\$${_dailyBudget.toStringAsFixed(2)}"),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOverBudget ? Colors.redAccent : Colors.greenAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Remaining Month Budget: \$${_remainingBudget.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _subMetric(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBadgesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: _badgeMetaData.length,
      itemBuilder: (ctx, index) {
        final badgeName = _badgeMetaData.keys.elementAt(index);
        final meta = _badgeMetaData[badgeName]!;
        final bool isUnlocked = _unlockedBadges.contains(badgeName);

        final Color color = meta['color'] as Color;
        final IconData icon = meta['icon'] as IconData;
        final String desc = meta['desc'] as String;

        final cardChild = Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2937),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isUnlocked ? color.withValues(alpha: 0.3) : Colors.transparent,
                width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                badgeName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                desc,
                style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.3),
              ),
            ],
          ),
        );

        if (isUnlocked) {
          return cardChild;
        } else {
          return ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
            child: Opacity(
              opacity: 0.4,
              child: cardChild,
            ),
          );
        }
      },
    );
  }
}
