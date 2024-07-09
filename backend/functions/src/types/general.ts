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
  analysedAt: string;
}

export interface UserHistoryItem {
  historyId: string;
  analysedAt: string;
  hashedUrl: string;
  analysedLink: AnalysedLinkResponse;
}
