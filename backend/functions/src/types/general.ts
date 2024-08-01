export type AIResponse = {
  title: string;
  isClickBait: boolean;
  explanation: string;
  summary: string;
  clarityScore: number;
  isVideo: boolean;
  answer: string;
  error?: string;
};

export type ProcessedAIResponse = AIResponse & {
  url: string;
};

export interface AnalysedLinkResponse extends ProcessedAIResponse {
  hashedUrl: string;
  analysedAt: string;
  isAlreadyInHistory?: boolean;
}

export interface HistoryItem {
  historyId: string;
  analysedLink: AnalysedLinkResponse;
}

export interface HistoryResponse {
  userHistory: Array<HistoryItem>;
  nextPageToken: string | null;
}

export interface AnalysisResult {
  status: 'success' | 'error';
  data?: AnalysedLinkResponse;
  error?: {
    code: number;
    message: string;
  };
}
export interface FailedToAnalyseResponse {
  url: string;
  hashedUrl: string;
  visitCount: number;
  firstAttemptedAt: string;
  lastAttemptedAt: string;
  reason: string;
}
