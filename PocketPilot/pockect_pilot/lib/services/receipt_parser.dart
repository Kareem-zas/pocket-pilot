import '../models/receipt_data.dart';

class ReceiptParser {
  static ReceiptData parse(String text) {
    final lines = text
        .replaceAll(',', '.')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    double? total;
    DateTime? date;
    String itemName = 'Expense';

    for (final line in lines) {
      final lower = line.toLowerCase();

      if (total == null &&
          (lower.contains('total') ||
           lower.contains('amount'))) {
        final match = RegExp(r'(\d+\.\d{1,2})').firstMatch(line);
        if (match != null) {
          total = double.tryParse(match.group(1)!);
        }
      }

      if (date == null) {
        final match = RegExp(r'(\d{4}[-/]\d{2}[-/]\d{2})')
            .firstMatch(line);
        if (match != null) {
          date = DateTime.tryParse(
            match.group(1)!.replaceAll('/', '-'),
          );
        }
      }
    }

    for (final line in lines) {
      if (!RegExp(r'\d').hasMatch(line) && line.length > 3) {
        itemName = line;
        break;
      }
    }

    return ReceiptData(
      itemName: itemName,
      total: total,
      date: date,
      category: 'General',
    );
  }
}