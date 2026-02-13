import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost pointing to Flask
  // Use http://127.0.0.1:5000 for web/iOS simulator
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  Future<Map<String, dynamic>> screenStocks(String analystStyle) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/screen'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'analyst_style': analystStyle}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load screening data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
      // In a real app, handle this gracefully (e.g., return cached data or specific error types)
    }
  }

  Future<Map<String, dynamic>> getForecast(String stockCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forecast'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': stockCode}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error connecting to backend: $e');
    }
  }

  // Placeholder for News/Reverse Merger data if needed separate from screen
}
