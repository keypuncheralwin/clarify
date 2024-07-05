import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://ce2a-122-150-251-96.ngrok-free.app/clarify-c7c86/us-central1/api/auth'; // Replace with your backend URL

  static Future<void> sendMagicLink(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-magic-link'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send magic link');
    }
  }

  static Future<String> verifyMagicLink(String email, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-magic-link'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'token': token,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify magic link');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['token'];
  }
}
