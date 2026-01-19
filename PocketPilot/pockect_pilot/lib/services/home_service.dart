import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class HomeService {
  static const String baseUrl = 'http://localhost:8000/api/summary';

  static Future<Map<String, double>> fetchHomeData() async {
    final token = await TokenService.getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception('Failed to load home data');
    }

    return {
      'currentBalance': (data['balance'] as num).toDouble(),
      'totalIncome': (data['totalIncome'] as num).toDouble(),
      'totalExpenses': (data['totalExpenses'] as num).toDouble(),
      'totalFixedExpenses':
          (data['totalFixedExpenses'] as num).toDouble(),
    };
  }
}