import { ClickbaitResponse } from '../types/general';
import logger from '../logger/logger';
import { ChatSession, Part } from '@google/generative-ai';
import { clarityScoreDefinitionArticle } from '../constants/article';
import { clarityScoreDefinitionYoutube } from '../constants/youtube';

export const extractJson = (str: string): ClickbaitResponse | null => {
  try {
    const jsonMatch = str.match(/{.*}/s);
    if (jsonMatch) {
      const jsonResponse = JSON.parse(jsonMatch[0]);
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

export const addClarityScoreDefinition = (
  response: ClickbaitResponse,
  type: 'youtube' | 'article'
): ClickbaitResponse => {
  const clarityScoreDefinition =
    type === 'youtube'
      ? clarityScoreDefinitionYoutube
      : clarityScoreDefinitionArticle;
  return {
    ...response,
    explanation: clarityScoreDefinition + response.explanation,
  };
};
