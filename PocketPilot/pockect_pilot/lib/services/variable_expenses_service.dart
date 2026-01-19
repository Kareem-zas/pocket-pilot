import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class VariableExpensesService {
  static const String baseUrl =
      'http://localhost:8000/api/variable-expenses';

  static Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String? notes,
  }) async {
    final token = await TokenService.getToken();

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'notes': notes,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add expense');
    }
  }
}