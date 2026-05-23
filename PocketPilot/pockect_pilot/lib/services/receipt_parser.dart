import '../models/receipt_data.dart';

class ReceiptParser {
  static ReceiptData parse(String text) {
    final lines = text
        .replaceAll(',', '.')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.length > 2 && !_ignoreLine(e))
        .toList();

    double? total;
    DateTime? date;
    String? itemName;

    for (final line in lines) {
      final lower = line.toLowerCase();

      if (total == null &&
          _looksLikeTotalLine(lower)) {
        final match =
            RegExp(r'(\d{1,6}\.\d{2})').firstMatch(line);
        if (match != null) {
          total = double.tryParse(match.group(1)!);
        }
      }

      if (date == null) {
        final match = RegExp(
          r'(\d{2}[/-]\d{2}[/-]\d{4}|\d{4}[/-]\d{2}[/-]\d{2})',
        ).firstMatch(line);

        if (match != null) {
          date = DateTime.tryParse(
            match.group(1)!.replaceAll('/', '-'),
          );
        }
      }
    }

    for (final line in lines) {
      if (_isGoodItemName(line)) {
        itemName = line;
        break;
      }
    }

    return ReceiptData(
      itemName: itemName ?? 'Expense',
      total: total,
      date: date,
      category: 'General',
    );
  }

  static bool _looksLikeTotalLine(String lower) {
    return lower.contains('total') ||
        lower.contains('amount') ||
        lower.contains('grand') ||
        lower.contains('balance');
  }

  static bool _isGoodItemName(String line) {
    if (RegExp(r'\d').hasMatch(line)) return false;
    if (_looksLikeStoreName(line)) return false;
    if (_ignoreLine(line)) return false;
    return line.length > 4;
  }

  static bool _ignoreLine(String line) {
    final lower = line.toLowerCase();
    return lower.contains('thank') ||
        lower.contains('vat') ||
        lower.contains('tax') ||
        lower.contains('cash') ||
        lower.contains('change') ||
        lower.contains('receipt') ||
        lower.contains('invoice') ||
        lower.contains('tel') ||
        lower.contains('phone');
  }

  static bool _looksLikeStoreName(String line) {
    return line == line.toUpperCase() && line.length <= 30;
  }
}
