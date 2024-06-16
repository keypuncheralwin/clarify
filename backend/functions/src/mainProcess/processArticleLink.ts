import { Response } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { generateClickbaitArticlePrompt } from '../constants/article';
import { safetySettings, generationConfig } from '../constants/gemini';
import logger from '../logger/logger';
import fetchArticle from '../utils/fetchArticle';
import { getChatResponse } from '../utils/general';
import dotenv from 'dotenv';
dotenv.config();

/**
 * Process the article link and handle the entire flow.
 * @param validUrl - The validated URL of the article.
 * @param model - The Google Generative AI model.
 * @param res - The Express response object.
 */
async function processArticleLink(
  validUrl: string,
  res: Response
): Promise<void> {
  const article = await fetchArticle(validUrl);
  if (!article) {
    res.status(400).send('Invalid URL');
    return;
  }

  const apiKey = process.env.GEMINI_API_TOKEN || '';
  const genAI = new GoogleGenerativeAI(apiKey);

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
  });

  const { title, subtitle, content } = article;
  logger.info(`Fetched article: ${title}`);

  const chatSession = model.startChat({
    safetySettings,
    generationConfig,
    history: [],
  });

  const prompt: string = generateClickbaitArticlePrompt(
    title,
    subtitle,
    content
  );
  logger.info('Generated prompt');

  try {
    const response = await getChatResponse(prompt, chatSession);

    if (response) {
      logger.info(`Received response: ${JSON.stringify(response)}`);
      res.json({ response });
    } else {
      logger.error('No response received from the chat session');
      res.status(500).send('Internal Server Error');
    }
  } catch (error: any) {
    logger.error(`Error processing article: ${error?.message}`, error);
    res.status(500).send('Internal Server Error');
  }
}

export default processArticleLink;
