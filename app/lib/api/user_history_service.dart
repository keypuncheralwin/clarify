import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class UserHistoryService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? ''; // Replace with your backend URL

  static Future<Map<String, dynamic>> fetchUserHistory(int pageSize,
      {String? pageToken, String searchKeyword = ''}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final idToken = await user.getIdToken();
    final response = await http.get(
      Uri.parse(
          '$baseUrl/user-history?pageSize=$pageSize&pageToken=$pageToken&searchKeyword=$searchKeyword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user history');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return data;
  }
}
