import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:portfolio/core/config/app_config.dart';

void main() async {
  await AppConfig.initialize();
  final url = AppConfig.tursoUrl;
  final token = AppConfig.tursoToken;

  final sql = "ALTER TABLE services ADD COLUMN icon_url TEXT;";
  
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "requests": [
        { "type": "execute", "stmt": { "sql": sql, "args": [] } },
        { "type": "close" }
      ]
    })
  );
  
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
