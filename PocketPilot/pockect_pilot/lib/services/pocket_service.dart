import 'package:shared_preferences/shared_preferences.dart';

class PocketService {
  static const String _cashKey = 'pocket_cash_balance';

  /// Fetch the current pocket cash balance
  static Future<double> getPocketBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_cashKey) ?? 0.0;
  }

  /// Update the pocket cash balance directly
  static Future<void> updatePocketBalance(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_cashKey, amount);
  }

  /// Add cash (e.g. ATM withdrawal detected via SMS)
  static Future<void> addPocketCash(double amount) async {
    double current = await getPocketBalance();
    await updatePocketBalance(current + amount);
  }

  /// Subtract cash (e.g. manually spending cash)
  static Future<void> subtractPocketCash(double amount) async {
    double current = await getPocketBalance();
    double newBalance = current - amount;
    // Don't let it go below 0 for safety in tracking
    if (newBalance < 0) newBalance = 0;
    await updatePocketBalance(newBalance);
  }
}
