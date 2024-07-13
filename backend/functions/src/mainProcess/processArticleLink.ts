import { Response } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import {
  clickbaitArticleCriteria,
  generateClickbaitArticlePrompt,
} from '../constants/article';
import { safetySettings, generationConfig } from '../constants/gemini';
import logger from '../logger/logger';
import fetchArticle from '../utils/fetchArticle';
import { getChatResponse, hashUrl, processResponse } from '../utils/general';
import { firestore } from 'firebase-admin';
import { saveAnalysedLink } from '../dbMethods/saveAnalysedLink';
import { getAnalysedLinkIfExists } from '../dbMethods/getAnalysedLinkIfExists';
import { saveUrlToUserHistory } from '../dbMethods/saveUrlToUserHistory';
import { saveFailedToAnalyseLink } from '../dbMethods/saveFailedToAnalyseLink';

/**
 * Process the article link and handle the entire flow.
 * @param validUrl - The validated URL of the article.
 * @param model - The Google Generative AI model.
 * @param res - The Express response object.
 * @param apiKey - The gemini api key.
 */
async function processArticleLink(
  url: string,
  res: Response,
  apiKey: string,
  userUuid?: string
): Promise<void> {
  //Initialise firestore
  const db = firestore();
  const hashedUrl = hashUrl(url);

  let response = await getAnalysedLinkIfExists(hashedUrl, db);

  if (response) {
    if (userUuid) {
      response = await saveUrlToUserHistory(hashedUrl, db, userUuid, response);
    }
    res.json({ response });
    return;
  }

  const genAI = new GoogleGenerativeAI(apiKey);

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
    systemInstruction: clickbaitArticleCriteria,
  });

  const article = await fetchArticle(url);
  if (!article) {
    saveFailedToAnalyseLink(url, 'Not able to find article');
    res.status(400).send('Invalid URL');
    return;
  }

  const { title, subtitle, content } = article;
  logger.info(`Fetched article: ${title}`);

  const chatSession = model.startChat({
    safetySettings,
    generationConfig,
  });

  const prompt: string = generateClickbaitArticlePrompt(
    title,
    subtitle,
    content
  );
  logger.info('Generated prompt');
  logger.info(`Prompt: ${prompt}`);

  try {
    const aiResponse = await getChatResponse(prompt, chatSession);

    if (aiResponse) {
      const processedAIResponse = processResponse(aiResponse, 'article', url);
      response = await saveAnalysedLink(hashedUrl, db, processedAIResponse);
      if (userUuid) {
        response = await saveUrlToUserHistory(
          hashedUrl,
          db,
          userUuid,
          response
        );
      }
      logger.info(`Received response: ${JSON.stringify(response)}`);
      res.json({ response });
    } else {
      logger.error('No response received from the AI chat sesssion');
      saveFailedToAnalyseLink(
        url,
        'No response received from the AI chat sesssion'
      );
      res.status(500).send('Internal Server Error');
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(`Error processing article: ${error?.message}`, error);
    saveFailedToAnalyseLink(url, `Error processing article: ${error?.message}`);
    res.status(500).send('Internal Server Error');
  }
}

export default processArticleLink;
