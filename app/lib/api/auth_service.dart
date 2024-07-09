import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'https://8743-122-150-251-249.ngrok-free.app/clarify-c7c86/us-central1/api'; // Replace with your backend URL

  static Future<void> sendVerificationCode(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-verification-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send verification code');
    }
  }

  static Future<Map<String, dynamic>> verifyCode(
      String email, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'code': code,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify code');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  static Future<String> createUser(
      String email, String code, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'code': code,
        'name': name,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create user');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['token'];
  }
}
