import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class IncomeService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, dynamic>> insertIncome({
    required String source,
    required double amount,
    String? date,
    bool isRecurring = false,
    String? frequency,
    String? icon,
    String? notes,
  }) async {
    final token = await TokenService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/income'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'source': source,
        'amount': amount,
        'date': date,
        'isRecurring': isRecurring,
        'frequency': frequency,
        'icon': icon,
        'notes': notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Failed to add income');
    }

    return data;
  }

  static Future<List<dynamic>> getIncome() async {
    final token = await TokenService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/income'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to fetch income');
    }

    return data['incomes'];
  }

  static Future<Map<String, dynamic>> updateIncome({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    final token = await TokenService.getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/income/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updates),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to update income');
    }

    return data;
  }

  static Future<void> deleteIncome(String id) async {
    final token = await TokenService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/income/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to delete income');
    }
  }
}
