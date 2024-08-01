import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:clarify/utils/device_utils.dart'; // Import the utility function

class AuthService {
  static final String baseUrl = dotenv.env['BASE_URL'] ??
      ''; // Use environment variable; // Replace with your backend URL

  static Future<void> sendVerificationCode(String email) async {
    final deviceId = await getDeviceId(); // Get the device ID
    final response = await http.post(
      Uri.parse('$baseUrl/send-verification-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'deviceId': deviceId, // Include the device ID
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send verification code');
    }
  }

  static Future<Map<String, dynamic>> verifyCode(
      String email, String code) async {
    final deviceId = await getDeviceId(); // Get the device ID
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'code': code,
        'deviceId': deviceId, // Include the device ID
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
    final deviceId = await getDeviceId(); // Get the device ID
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'code': code,
        'name': name,
        'deviceId': deviceId, // Include the device ID
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create user');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['token'];
  }
}
