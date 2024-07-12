import 'analysed_link_response.dart';

class UserHistoryItem {
  final String historyId;
  final AnalysedLinkResponse analysedLink;

  UserHistoryItem({
    required this.historyId,
    required this.analysedLink,
  });

  factory UserHistoryItem.fromJson(Map<String, dynamic> json) {
    if (json['analysedLink'] == null) {
      throw Exception("Missing analysedLink in JSON data");
    }
    return UserHistoryItem(
      historyId:
          json['historyId'] ?? 'unknown', // Default to 'unknown' if missing
      analysedLink: AnalysedLinkResponse.fromJson(
          json['analysedLink'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historyId': historyId,
      'analysedLink': analysedLink.toJson(),
    };
  }
}

class UserHistoryResponse {
  final List<UserHistoryItem> userHistory;
  final String? nextPageToken;

  UserHistoryResponse({
    required this.userHistory,
    this.nextPageToken,
  });

  factory UserHistoryResponse.fromJson(Map<String, dynamic> json) {
    return UserHistoryResponse(
      userHistory: (json['userHistory'] as List)
          .map((item) => UserHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextPageToken: json['nextPageToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userHistory': userHistory.map((item) => item.toJson()).toList(),
      'nextPageToken': nextPageToken,
    };
  }
}
