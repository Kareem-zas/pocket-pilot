import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/services/income_service.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  List<dynamic> incomes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadIncome();
  }

  Future<void> loadIncome() async {
    try {
      final data = await IncomeService.getIncome();
      setState(() {
        incomes = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.mainColor2,
      appBar: AppBar(
        backgroundColor: GlobalColors.mainColor2,
        elevation: 0,
        iconTheme: IconThemeData(
          color: GlobalColors.textColor3,
        ),
        title: Text(
          'Incomes',
          style: TextStyle(
            color: GlobalColors.textColor3,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : incomes.isEmpty
              ? Center(
                  child: Text(
                    'No incomes yet',
                    style: TextStyle(
                      color: GlobalColors.textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: incomes.length,
                  itemBuilder: (_, index) {
                    final income = incomes[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: GlobalColors.textFieldColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                        Icon(
  Icons.arrow_upward,
  color: Colors.green,
  size: 16,
),

                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  income['source'] ?? 'Income',
                                  style: TextStyle(
                                    color: GlobalColors.textColor3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  income['date']
                                      ?.toString()
                                      .split('T')
                                      .first ??
                                      '',
                                  style: TextStyle(
                                    color: GlobalColors.textColor,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${income['amount']}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
