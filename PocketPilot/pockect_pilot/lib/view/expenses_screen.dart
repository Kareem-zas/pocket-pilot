import 'package:flutter/material.dart';
import 'package:pockect_pilot/utils/global_colors.dart';
import 'package:pockect_pilot/services/variable_expenses_service.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<dynamic> items = [];
  bool loading = true;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    /// 🔥 IMPORTANT:
    /// This gets called when coming back from another screen
    if (_loadedOnce && ModalRoute.of(context)?.isCurrent == true) {
      loadExpenses();
    }

    _loadedOnce = true;
  }

  Future<void> loadExpenses() async {
    setState(() => loading = true);

    try {
      final data = await VariableExpensesService.getVariableExpenses();
      if (!mounted) return;

      setState(() {
        items = data;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading expenses: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : GlobalColors.textColor3,
        ),
        title: Text(
          'Expenses',
          style: TextStyle(
            color: isDark ? Colors.white : GlobalColors.textColor3,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadExpenses,
        color: Theme.of(context).primaryColor,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                      Center(
                        child: Text(
                          'No Expenses',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : GlobalColors.textColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];

                      final title =
                          item['title']?.toString() ?? 'Unknown';
                      final category =
                          item['category']?.toString() ?? 'Other';
                      final amount =
                          item['amount']?.toString() ?? '0.00';

                      String date = 'No Date';
                      if (item['date'] != null) {
                        date =
                            item['date'].toString().split('T')[0];
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_downward,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.white : GlobalColors.textColor3,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$category • $date',
                                    style: TextStyle(
                                      color:
                                          isDark ? Colors.grey.shade400 : GlobalColors.textColor,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '-\$$amount',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
