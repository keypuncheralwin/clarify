import { Response } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { geminiArticleContext, generateClickbaitArticlePrompt } from '../constants/article';
import { safetySettings, generationConfig } from '../constants/gemini';
import logger from '../logger/logger';
import fetchArticle from '../utils/fetchArticle';
import { addClarityScoreDefinition, getChatResponse } from '../utils/general';

/**
 * Process the article link and handle the entire flow.
 * @param validUrl - The validated URL of the article.
 * @param model - The Google Generative AI model.
 * @param res - The Express response object.
 * @param apiKey - The gemini api key.
 */
async function processArticleLink(
  validUrl: string,
  res: Response,
  apiKey: string
): Promise<void> {
  const article = await fetchArticle(validUrl);
  if (!article) {
    res.status(400).send('Invalid URL');
    return;
  }
  const genAI = new GoogleGenerativeAI(apiKey);

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
  });

  const { title, subtitle, content } = article;
  logger.info(`Fetched article: ${title}`);
  
  // Start the chat session with the preloaded history
  const chatSession = model.startChat({
    safetySettings,
    generationConfig,
    history: geminiArticleContext 
  });

  const prompt: string = generateClickbaitArticlePrompt(
    title,
    subtitle,
    content
  );
  logger.info('Generated prompt');
  logger.info(`Prompt: ${prompt}`);

  try {
    let response = await getChatResponse(prompt, chatSession);

    if (response) {
      response = addClarityScoreDefinition(response, 'article');
      logger.info(`Received response: ${JSON.stringify(response)}`);
      res.json({ response });
    } else {
      logger.error('No response received from the chat session');
      res.status(500).send('Internal Server Error');
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(`Error processing article: ${error?.message}`, error);
    res.status(500).send('Internal Server Error');
  }
}

export default processArticleLink;
