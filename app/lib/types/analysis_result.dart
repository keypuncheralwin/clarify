import 'analysed_link_response.dart';

class AnalysisResult {
  final String status;
  final AnalysedLinkResponse? data;
  final AnalysisError? error;

  AnalysisResult({
    required this.status,
    this.data,
    this.error,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    print("Parsing AnalysisResult from JSON: $json");

    try {
      final status = json['status'] ?? 'unknown';
      final data = json['data'] != null
          ? AnalysedLinkResponse.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null;
      final error = json['error'] != null
          ? AnalysisError.fromJson(Map<String, dynamic>.from(json['error']))
          : null;

      print("Parsed status: $status");
      print("Parsed data: $data");
      print("Parsed error: $error");

      return AnalysisResult(
        status: status,
        data: data,
        error: error,
      );
    } catch (e) {
      print("Unexpected error during parsing: $e");
      return AnalysisResult(
        status: 'error',
        error: AnalysisError(
          errorCode: -1,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
      'error': error?.toJson(),
    };
  }
}

class AnalysisError {
  final int errorCode;
  final String errorMessage;

  AnalysisError({
    required this.errorCode,
    required this.errorMessage,
  });

  factory AnalysisError.fromJson(Map<String, dynamic> json) {
    print("Parsing AnalysisError from JSON: $json");

    final errorCode = json['errorCode'];
    final errorMessage = json['errorMessage'];

    print("Parsed errorCode: $errorCode");
    print("Parsed errorMessage: $errorMessage");

    return AnalysisError(
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'errorCode': errorCode,
      'errorMessage': errorMessage,
    };
  }
}
