import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class SubscriptionService {
  static const String baseUrl = 'http://192.168.0.109:8000/api/subscriptions';

  static Future<List<dynamic>> getSubscriptions() async {
    final token = await TokenService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load subscriptions');
    }

    final data = jsonDecode(response.body);
    return data['data']['subscriptions'] ?? [];
  }

  static Future<void> triggerRescan() async {
    final token = await TokenService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/rescan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to trigger rescan');
    }
  }

  static Future<void> cancelSubscription(String id) async {
    final token = await TokenService.getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel subscription');
    }
  }
}
