import 'package:flutter/material.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/services/income_service.dart';

class MoneyInfoView extends StatefulWidget {
  const MoneyInfoView({super.key});

  @override
  State<MoneyInfoView> createState() => _MoneyInfoViewState();
}

class _MoneyInfoViewState extends State<MoneyInfoView> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool isRecurring = false;
  String? frequency;
  DateTime? selectedDate;

  final Map<String, String> frequencies = {
    'Monthly': 'monthly',
    'Yearly': 'yearly',
  };

  bool get _isAmountValid {
    final text = amountController.text.trim();
    return text.isNotEmpty && double.tryParse(text) != null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _saveIncome() async {
    try {
      if (!_isAmountValid || selectedDate == null) {
        throw Exception('Please fill required fields');
      }

      if (isRecurring && frequency == null) {
        throw Exception('Please select frequency');
      }

      await IncomeService.insertIncome(
        source: sourceController.text.trim().isEmpty
            ? 'General'
            : sourceController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        date: selectedDate!,
        isRecurring: isRecurring,
        frequency: isRecurring ? frequency : null,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _input(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _box(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.menu, color: Colors.blue),
                  Text("Pocket Pilot",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  CircleAvatar(radius: 18)
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Welcome to POCKET PILOT",
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              const Text(
                "Let's get started by setting your primary income.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              // CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  children: [
                    // AMOUNT
                    _input(
                      "Primary Income Amount",
                      _box(
                        Row(
                          children: [
                            const Text("\$",
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "0.00",
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // TYPE
                    _input(
                      "Income Type",
                      _box(
                        DropdownButton<String>(
                          value: sourceController.text.isEmpty
                              ? "Salary"
                              : sourceController.text,
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: ["Salary", "Business", "Other"]
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              sourceController.text = val!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // DATE
                    _input(
                      "Received Date",
                      GestureDetector(
                        onTap: _pickDate,
                        child: _box(
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate == null
                                    ? "mm/dd/yyyy"
                                    : selectedDate!
                                        .toString()
                                        .split(" ")[0],
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // RECURRING
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F2F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.autorenew,
                                  color: Colors.orange),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text("Is Recurring Income?"),
                              ),
                              Switch(
                                value: isRecurring,
                                onChanged: (val) {
                                  setState(() {
                                    isRecurring = val;
                                    if (!val) frequency = null;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => frequency = "monthly"),
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: frequency == "monthly"
                                              ? Colors.blue
                                              : Colors.grey),
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                    child: const Center(
                                        child: Text("MONTHLY")),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => frequency = "yearly"),
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: frequency == "yearly"
                                              ? Colors.blue
                                              : Colors.grey),
                                      borderRadius:
                                          BorderRadius.circular(15),
                                    ),
                                    child: const Center(
                                        child: Text("YEARLY")),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // NOTES
                    _input(
                      "Navigator Notes",
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F2F6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                "e.g. Main job salary after tax...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveIncome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Complete Setup"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}