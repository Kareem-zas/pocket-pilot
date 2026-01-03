import 'dart:convert';
import 'package:http/http.dart' as http;

class ReceiptAIService {
  static const _apiKey = 'PUT_YOUR_OPENAI_KEY_HERE';

  static Future<Map<String, dynamic>?> parseReceipt(String ocrText) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a receipt analyzer. Extract structured data and return ONLY valid JSON."
          },
          {
            "role": "user",
            "content": """
Extract the following from this receipt text:
- store_name
- date (yyyy-mm-dd or null)
- total_amount (number)
- category (one word)
- items: [{name, price}]

Return JSON only.

Receipt text:
$ocrText
"""
          }
        ],
        "temperature": 0.1
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];

    return jsonDecode(content);
  }
}