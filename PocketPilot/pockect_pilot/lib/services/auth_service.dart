import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:8000/api/auth';

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final body = jsonEncode({
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password.trim(),
      'phone': phone.trim(),
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: utf8.encode(body),
    );

   
    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      throw Exception(
        'Invalid response from server: ${response.body}',
      );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));

   
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Registration failed');
    }

    return data;
  }
}
