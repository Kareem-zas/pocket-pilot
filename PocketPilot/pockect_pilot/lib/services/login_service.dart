import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class LoginService {
  static const String baseUrl = 'http://192.168.0.109:8000/api/auth';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login failed');
    }

    final token = data['token'];
    if (token == null) {
      throw Exception('Token not found');
    }

    await TokenService.saveToken(token);

    return data;
  }
}
