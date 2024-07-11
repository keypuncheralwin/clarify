class AnalysedLinkResponse {
  final String title;
  final bool isClickBait;
  final String explanation;
  final String summary;
  final int clarityScore;
  final String url;
  final bool isVideo;
  final String answer;
  final String hashedUrl;
  final String analysedAt;

  AnalysedLinkResponse({
    required this.title,
    required this.isClickBait,
    required this.explanation,
    required this.summary,
    required this.clarityScore,
    required this.url,
    required this.isVideo,
    required this.answer,
    required this.hashedUrl,
    required this.analysedAt,
  });

  factory AnalysedLinkResponse.fromJson(Map<String, dynamic> json) {
    return AnalysedLinkResponse(
      title: json['title'],
      isClickBait: json['isClickBait'],
      explanation: json['explanation'],
      summary: json['summary'],
      clarityScore: json['clarityScore'],
      url: json['url'],
      isVideo: json['isVideo'],
      answer: json['answer'],
      hashedUrl: json['hashedUrl'],
      analysedAt: json['analysedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isClickBait': isClickBait,
      'explanation': explanation,
      'summary': summary,
      'clarityScore': clarityScore,
      'url': url,
      'isVideo': isVideo,
      'answer': answer,
      'hashedUrl': hashedUrl,
      'analysedAt': analysedAt,
    };
  }
}
