import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class GamificationService {
  static const String baseUrl = 'http://localhost:8000/api/gamification';

  static Future<Map<String, String>> _headers() async {
    final token = await TokenService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final headers = await _headers();
      final response = await http.get(Uri.parse(baseUrl), headers: headers)
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to fetch gamification status');
      }

      return data['data'];
    } catch (e) {
      throw Exception("Connection offline: Unable to load gamification status.");
    }
  }

  static Future<Map<String, dynamic>> checkStatus() async {
    try {
      final headers = await _headers();
      final response = await http.post(Uri.parse('$baseUrl/check'), headers: headers)
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Failed to run gamification check');
      }

      return data['data'];
    } catch (e) {
      throw Exception("Connection offline: Unable to synchronize streaks.");
    }
  }
}
