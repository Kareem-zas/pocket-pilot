import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/services/fixed_expenses_service.dart';

class FixedExpensesHistory extends StatefulWidget {
  const FixedExpensesHistory({super.key});

  @override
  State<FixedExpensesHistory> createState() => _FixedExpensesHistoryState();
}

class _FixedExpensesHistoryState extends State<FixedExpensesHistory> {
  List<dynamic> items = [];
  bool loading = true;
  final Set<String> updatingItems = {};

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final data = await FixedExpensesService.getFixedExpenseItems();
      setState(() {
        items = data;
        loading = false;
      });
    } catch (_) {
      loading = false;
    }
  }

  Future<void> toggleActive(int index) async {
    final item = items[index];
    final String itemId = item['_id'];
    final bool oldValue = item['isActive'] ?? true;
    final bool newValue = !oldValue;

    if (updatingItems.contains(itemId)) return;

    setState(() {
      updatingItems.add(itemId);
      items[index]['isActive'] = newValue;
    });

    try {
      await FixedExpensesService.updateFixedExpenseActivity(
        itemId: itemId,
        isActive: newValue,
      );
    } catch (e) {
      setState(() {
        items[index]['isActive'] = oldValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update expense status'),
        ),
      );
    } finally {
      setState(() {
        updatingItems.remove(itemId);
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
          'Fixed Expenses',
          style: TextStyle(
            color: GlobalColors.textColor3,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Text(
                    'No Fixed Expenses',
                    style: TextStyle(
                      color: GlobalColors.textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final item = items[index];

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    color: GlobalColors.textColor3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item['frequency']} • \$${item['amount']}',
                                  style: TextStyle(
                                    color: GlobalColors.textColor,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: item['isActive'] ?? true,
                            activeColor: GlobalColors.buttonColor,
                            onChanged: (_) => toggleActive(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
