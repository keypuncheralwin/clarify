export type ClickbaitResponse = {
  title: string;
  isClickBait: boolean;
  explanation: string;
  summary: string;
  clarityScore: number;
  url: string;
  isVideo: boolean;
  answer: string | null;
};
