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
  analysedLink: AnalysedLinkResponse;
}

export interface FailedToAnalyseResponse {
  url: string;
  hashedUrl: string;
  visitCount: number;
  firstAttemptedAt: string;
  lastAttemptedAt: string;
}
