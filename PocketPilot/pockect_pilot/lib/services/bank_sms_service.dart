import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class BankSmsService {
  static final SmsQuery _query = SmsQuery();

  static Future<bool> requestPermission() async {
    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      return true;
    } else {
      var result = await Permission.sms.request();
      return result.isGranted;
    }
  }

  /// Scans the 50 most recent SMS messages to find potential bank transactions
  static Future<List<Map<String, dynamic>>> fetchRecentBankMessages() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception("SMS permission denied. We need this to read bank messages.");
    }

    try {
      List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50,
      );

      List<Map<String, dynamic>> parsedTransactions = [];

      for (var msg in messages) {
        String body = msg.body?.toLowerCase() ?? '';
        
        // Define trigger keywords for expenses/withdrawals
        bool isExpense = body.contains('purchase') || 
                         body.contains('deducted') || 
                         body.contains('withdrawn') ||
                         body.contains('payment');
                         
        // Trigger keywords for deposits
        bool isDeposit = body.contains('deposited') || 
                         body.contains('credited') || 
                         body.contains('refunded');

        // Only process financial SMS messages
        if (isExpense || isDeposit) {
          // Attempt to extract the amount using a basic currency Regex
          // Matches formatted numbers like 150.00, 150, 1,500.50
          RegExp amountRegex = RegExp(r'(?:sar|usd|\$|aed|egp|rs|amount:?)?\s?((?:\d{1,3}(?:,\d{3})*|\d+)(?:\.\d{1,2})?)', caseSensitive: false);
          
          final match = amountRegex.firstMatch(body);
          if (match != null) {
            String extractedAmountStr = match.group(1)?.replaceAll(',', '') ?? '0';
            double amount = double.tryParse(extractedAmountStr) ?? 0.0;
            
            if (amount > 0) {
              parsedTransactions.add({
                'id': msg.id.toString(),
                'sender': msg.address,
                'amount': amount,
                'type': isExpense ? 'expense' : 'income',
                'date': msg.date,
                'body': msg.body,
              });
            }
          }
        }
      }

      return parsedTransactions;
    } catch (e) {
      throw Exception("Failed to fetch SMS: $e");
    }
  }
}
