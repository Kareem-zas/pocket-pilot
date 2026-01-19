// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'token_service.dart';

// class SummaryService {
//   static const String _baseUrl = 'http://localhost:8000/api/summary';

//   static Future<Map<String, double>> getDashboardSummary() async {
//     final token = await TokenService.getToken();

//     final response = await http.get(
//       Uri.parse(_baseUrl),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     final data = jsonDecode(response.body);

//     if (response.statusCode != 200) {
//       throw Exception(data['message'] ?? 'Failed to load summary');
//     }

//     return {
//       'currentBalance': (data['currentBalance'] as num).toDouble(),
//       'totalIncome': (data['totalIncome'] as num).toDouble(),
//       'totalExpenses': (data['totalExpenses'] as num).toDouble(),
//       'totalFixedExpenses':
//           (data['totalFixedExpenses'] as num).toDouble(),
//       'totalVariableExpenses':
//           (data['totalVariableExpenses'] as num).toDouble(),
//     };
//   }
// }
