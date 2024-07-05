import 'package:flutter/services.dart';

class ApiService {
  static const platform = MethodChannel('com.clarify.app/api');

  static Future<Map<String, dynamic>?> analyzeLink(String url) async {
    try {
      final result = await platform.invokeMethod<Map<dynamic, dynamic>>('analyzeLink', {'url': url});
      return result != null ? Map<String, dynamic>.from(result) : null;
    } on PlatformException catch (e) {
      print("Failed to analyze link: '${e.message}'.");
      return null;
    }
  }
}
