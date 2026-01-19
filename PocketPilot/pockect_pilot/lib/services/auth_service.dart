import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api/auth';

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
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login failed');
    }

    if (data['token'] != null) {
      await TokenService.saveToken(data['token']);
    }

    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Register failed');
    }

    if (data['token'] != null) {
      await TokenService.saveToken(data['token']);
    }

    return data;
  }
}
