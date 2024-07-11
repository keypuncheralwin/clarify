import 'package:flutter/services.dart';
import '../types/analysed_link_response.dart';

class ApiService {
  static const platform = MethodChannel('com.clarify.app/api');

  static Future<AnalysedLinkResponse?> analyzeLink(String url) async {
    try {
      final result = await platform
          .invokeMethod<Map<dynamic, dynamic>>('analyzeLink', {'url': url});
      return result != null
          ? AnalysedLinkResponse.fromJson(Map<String, dynamic>.from(result))
          : null;
    } on PlatformException catch (e) {
      print("Failed to analyze link: '${e.message}'.");
      return null;
    }
  }
}
