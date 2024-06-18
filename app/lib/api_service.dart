import 'package:flutter/services.dart';

class ApiService {
  static const platform = MethodChannel('com.example.clarify/api');

  Future<Map<String, dynamic>> analyzeLink(String url) async {
    try {
      final result = await platform.invokeMethod('analyzeLink', {'url': url});
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      rethrow;
    }
  }
}
