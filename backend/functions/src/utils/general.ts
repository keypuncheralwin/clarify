import { clickbaitResponse } from '../types/general';
import logger from '../logger/logger';
import { ChatSession } from '@google/generative-ai';

export const extractJson = (str: string): clickbaitResponse | null => {
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
  prompt: string,
  chatSession: ChatSession
): Promise<clickbaitResponse | null> => {
  try {
    const result = await chatSession.sendMessage(prompt);
    const responseText = await result.response.text();
    logger.info('Response text received', { responseText });
    return extractJson(responseText);
  } catch (error) {
    logger.error('Error processing article', error);
    return null;
  }
};
