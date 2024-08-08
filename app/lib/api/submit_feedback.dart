import 'package:clarify/api/get_deviceId.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class FeedbackService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<void> submitFeedback({
    String? email,
    int? rating,
    required String feedbackContent,
  }) async {
    final deviceId = await DeviceIdProvider.getDeviceId() ?? "NO_DEVICE_ID";
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();
    final userEmail = email ?? user?.email;

    final response = await http.post(
      Uri.parse('$baseUrl/feedback'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'deviceId': deviceId,
        'email': userEmail,
        'rating': rating,
        'feedbackContent': feedbackContent,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit feedback');
    }
  }
}
