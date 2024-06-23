export type ClickbaitResponse = {
  title: string;
  isClickBait: boolean;
  explanation: string;
  summary: string;
  clarityScore: number;
  answer?: string | null;
};
