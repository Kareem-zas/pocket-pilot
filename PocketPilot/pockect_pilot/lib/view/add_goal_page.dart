import 'package:flutter/material.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  String selectedCategory = "Travel";
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      setState(() {
        _dateController.text = "$month/$day/${date.year}";
      });
    }
  }

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
              const SizedBox(height: 25),
              _buildBriefingCard(),
              const SizedBox(height: 25),
              _buildLabel("Goal Name"),
              _buildTextField(hint: "e.g., Dream Vacation"),
              const SizedBox(height: 20),
              _buildLabel("Target Amount"),
              _buildTextField(hint: "\$  0.00"),
              const SizedBox(height: 20),
              _buildLabel("Target Date"),
              _buildTextField(
                hint: "mm/dd/yyyy", 
                trailingIcon: Icons.calendar_today,
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
              ),
              const SizedBox(height: 25),
              _buildLabel("Mission Category"),
              _buildCategories(),
              const SizedBox(height: 25),
              _buildBoostCard(),
              const SizedBox(height: 30),
              _buildSubmit(context),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
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
          "New Savings Goal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.rocket_launch, color: Colors.blue.shade800, size: 16),
        ),
      ],
    );
  }

  Widget _buildBriefingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade100, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFF0055D4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 15),
          const Text("MISSION BRIEFING", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black54)),
          const SizedBox(height: 5),
          const Text("Chart Your Course", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0055D4))),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField({required String hint, IconData? trailingIcon, TextEditingController? controller, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEFF7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          suffixIcon: trailingIcon != null ? Icon(trailingIcon, color: Colors.black87, size: 20) : null,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _categoryChip("Travel", Icons.flight_takeoff)),
            const SizedBox(width: 10),
            Expanded(child: _categoryChip("Housing", Icons.home)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _categoryChip("Education", Icons.school)),
            const SizedBox(width: 10),
            Expanded(child: _categoryChip("General", Icons.savings)),
          ],
        ),
      ],
    );
  }

  Widget _categoryChip(String label, IconData icon) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0055D4) : const Color(0xFFEBEFF7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black87, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoostCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.orange.shade800, size: 20),
              const SizedBox(width: 10),
              Text("Boost Your Start", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 20),
          Text("INITIAL DEPOSIT (OPTIONAL)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter amount to start today",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Adding an initial deposit helps reach your goal 15% faster.",
            style: TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmit(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Goal created structurally!")));
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0055D4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.adjust, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text("Create Goal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
