import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class VariableExpensesService {
  static const String baseUrl =
      'http://localhost:8000/api/variable-expenses';

  // ✅ ADD EXPENSE (هذا اللي كان ناقص)
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
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to add expense');
    }
  }

  // ✅ FETCH VARIABLE EXPENSES (Dashboard)
  static Future<List<dynamic>> getVariableExpenses({
    int? year,
    int? month,
  }) async {
    final token = await TokenService.getToken();

    final query = <String, String>{};
    if (year != null) query['year'] = year.toString();
    if (month != null) query['month'] = month.toString();

    final uri = Uri.parse('http://localhost:8000/api/dashboard')
        .replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load variable expenses');
    }

    final data = jsonDecode(response.body);
    return data['data']['summary']['expenses']['variable']['details'] ?? [];
  }
}
