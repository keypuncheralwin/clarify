import 'package:flutter/services.dart';
import '../types/analysis_result.dart';

class ApiService {
  static const platform = MethodChannel('com.clarify.app/api');

  static Future<AnalysisResult?> analyseLink(String url) async {
    try {
      print("Invoking platform method with URL: $url");
      final result = await platform
          .invokeMethod<Map<dynamic, dynamic>>('analyseLink', {'url': url});
      print("Raw result from platform method: $result");
      return result != null
          ? AnalysisResult.fromJson(Map<String, dynamic>.from(result))
          : null;
    } on PlatformException catch (e) {
      print("Failed to analyze link: '${e.message}'.");
      return AnalysisResult(
        status: 'error',
        error: AnalysisError(
          errorCode: -1,
          errorMessage: e.message ?? 'Unknown error',
        ),
      );
    } catch (e) {
      print("Unexpected error: $e");
      return AnalysisResult(
        status: 'error',
        error: AnalysisError(
          errorCode: -1,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
