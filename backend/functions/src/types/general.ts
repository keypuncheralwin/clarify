export type AIResponse = {
  title: string;
  isClickBait: boolean;
  explanation: string;
  summary: string;
  clarityScore: number;
  isVideo: boolean;
  answer: string;
};

export type ProcessedAIResponse = AIResponse & {
  url: string;
};

export interface AnalysedLinkResponse extends ProcessedAIResponse {
  hashedUrl: string;
  lastAnalysed: FirebaseFirestore.Timestamp | FirebaseFirestore.FieldValue;
}

export interface UserHistoryItem {
  historyId: string;
  analysedAt: FirebaseFirestore.Timestamp;
  hashedUrl: string;
  analysedLink: AnalysedLinkResponse;
}
