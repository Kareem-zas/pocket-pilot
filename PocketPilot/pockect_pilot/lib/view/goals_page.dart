import 'package:flutter/material.dart';
import 'package:pockect_pilot/view/add_goal_page.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildGoalCard(
                title: "Dream Vacation",
                subtitle: "Tokyo & Kyoto Expedition",
                icon: Icons.flight_takeoff,
                progressValue: 0.45,
                progressText: "45%",
                savedAmount: "\$3,600",
                targetAmount: "\$8,000",
              ),
              _buildGoalCard(
                title: "Emergency Fund",
                subtitle: "6 Months Runway",
                icon: Icons.shield,
                progressValue: 0.82,
                progressText: "82%",
                savedAmount: "\$12,300",
                targetAmount: "\$15,000",
              ),
              _buildGoalCard(
                title: "Down Payment",
                subtitle: "Suburban Villa Project",
                icon: Icons.home,
                progressValue: 0.15,
                progressText: "15%",
                savedAmount: "\$8,950",
                targetAmount: "\$60,000",
              ),
              const SizedBox(height: 10),
              _buildInsightsRow(),
              const SizedBox(height: 30),
            ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("TOTAL SAVINGS", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            SizedBox(height: 5),
            Text("\$24,850.00", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage()));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0055D4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text("New Goal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMomentumCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E5BD8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
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
                children: const [
                  Text("Monthly Momentum", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  SizedBox(height: 5),
                  Text("+\$1,240.00", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.trending_up, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Overall Progress", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              Text("68%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: Colors.blue.shade300, borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: 0.68,
                child: Container(height: 8, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4))),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActiveGoalsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Active Goals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text("View All", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEBEFF7), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF0055D4), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Text(progressText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFEBEFF7), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: progressValue,
                child: Container(height: 8, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4))),
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
                  const Text("SAVED", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text(savedAmount, style: const TextStyle(color: Color(0xFF0055D4), fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("TARGET", style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text(targetAmount, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInsightsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEFF7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.bolt, color: Colors.brown, size: 16),
                SizedBox(height: 15),
                Text("Fastest Growth", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 5),
                Text("Vacation Fund grew 12% this week", style: TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEFF7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.star, color: Color(0xFF0055D4), size: 16),
                SizedBox(height: 15),
                Text("Next Milestone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 5),
                Text("Emergency Fund is \$2.7k from target", style: TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
