import { ClickbaitResponse } from '../types/general';
import logger from '../logger/logger';
import { ChatSession, Part } from '@google/generative-ai';
import { clarityScoreDefinitionArticle } from '../constants/article';
import { clarityScoreDefinitionYoutube } from '../constants/youtube';
import * as crypto from 'crypto';

export function hashUrl(url: string): string {
  return crypto.createHash('sha256').update(url).digest('hex');
}

export const extractJson = (str: string): ClickbaitResponse | null => {
  try {
    // Remove backticks and 'json' string from the beginning and end
    let cleanStr = str.replace(/```json\s*|```/g, '');

    // Strip unwanted control characters
    // eslint-disable-next-line no-control-regex
    cleanStr = cleanStr.replace(/[\u0000-\u001F]/g, '');

    // Attempt to match the JSON object within the cleaned string
    const jsonMatch = cleanStr.match(/(\{.*\})/s);

    if (jsonMatch) {
      const jsonStr = jsonMatch[1];

      // Attempt to parse the JSON
      const jsonResponse = JSON.parse(jsonStr);
      logger.info('JSON successfully extracted', { jsonResponse });
      return jsonResponse;
    } else {
      logger.warn('No JSON found in the string');
      return null;
    }
  } catch (error) {
    logger.error('Error extracting JSON', error);
    return null;
  }
};

export const getChatResponse = async (
  prompt: string | Array<string | Part>,
  chatSession: ChatSession
): Promise<ClickbaitResponse | null> => {
  try {
    const result = await chatSession.sendMessage(prompt);
    const responseText = result.response.text();
    logger.info('Response text received', { responseText });
    return extractJson(responseText);
  } catch (error) {
    logger.error('Error processing prompt', error);
    return null;
  }
};

export const processResponse = (
  response: ClickbaitResponse,
  type: 'youtube' | 'article',
  url: string
): ClickbaitResponse => {
  const clarityScoreDefinition =
    type === 'youtube'
      ? clarityScoreDefinitionYoutube
      : clarityScoreDefinitionArticle;

  const isVideo = type === 'youtube';

  return {
    ...response,
    explanation: clarityScoreDefinition + response.explanation,
    url: url,
    isVideo: isVideo,
  };
};
