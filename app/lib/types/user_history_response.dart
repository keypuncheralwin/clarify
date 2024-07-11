import 'analysed_link_response.dart';

class UserHistoryItem {
  final String historyId;
  final AnalysedLinkResponse analysedLink;

  UserHistoryItem({
    required this.historyId,
    required this.analysedLink,
  });

  factory UserHistoryItem.fromJson(Map<String, dynamic> json) {
    return UserHistoryItem(
      historyId: json['historyId'],
      analysedLink: AnalysedLinkResponse.fromJson(json['analysedLink']),
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

  UserHistoryResponse({required this.userHistory});

  factory UserHistoryResponse.fromJson(Map<String, dynamic> json) {
    return UserHistoryResponse(
      userHistory: (json['userHistory'] as List)
          .map((item) => UserHistoryItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userHistory': userHistory.map((item) => item.toJson()).toList(),
    };
  }
}
