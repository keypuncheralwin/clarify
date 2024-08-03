import 'package:clarify/api/get_deviceId.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../types/user_history_response.dart';

class UserHistoryService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<UserHistoryResponse> fetchUserHistory(int pageSize,
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

    return UserHistoryResponse.fromJson(data);
  }

  static Future<UserHistoryResponse> fetchDeviceHistory(int pageSize,
      {String? pageToken, String searchKeyword = ''}) async {
    final deviceId = await DeviceIdProvider.getDeviceId() ?? "NO_DEVICE_ID";
    final Uri uri =
        Uri.parse('$baseUrl/device-history').replace(queryParameters: {
      'deviceId': deviceId,
      'pageSize': pageSize.toString(),
      'pageToken': pageToken,
      'searchKeyword': searchKeyword,
    });

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch device history');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    return UserHistoryResponse.fromJson(data);
  }

  static Future<void> clearUserHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final idToken = await user.getIdToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/user-history'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $idToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear user history');
    }
  }

  static Future<void> clearDeviceHistory() async {
    final deviceId = await DeviceIdProvider.getDeviceId() ?? "NO_DEVICE_ID";
    final Uri uri =
        Uri.parse('$baseUrl/device-history').replace(queryParameters: {
      'deviceId': deviceId,
    });

    final response = await http.delete(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear device history');
    }
  }
}
