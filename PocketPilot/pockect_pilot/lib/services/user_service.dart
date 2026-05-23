import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class UserService {
  static const String baseUrl = 'http://192.168.0.109:8000/api';

  static Future<Map<String, dynamic>> getUserInfo() async {
    final token = await TokenService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/auth/getUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }
}
