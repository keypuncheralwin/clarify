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
  validUrl: string,
  res: Response,
  apiKey: string,
  userUuid?: string
): Promise<void> {
  //Initialise firestore
  const db = firestore();
  const hashedUrl = hashUrl(validUrl);

  const alreadyAnalysed = await getAnalysedLinkIfExists(
    hashedUrl,
    db,
    userUuid
  );

  if (alreadyAnalysed) {
    if (userUuid) {
      const isAlreadyInHistory = await saveUrlToUserHistory(
        hashedUrl,
        db,
        userUuid
      );
      alreadyAnalysed.isAlreadyInHistory = isAlreadyInHistory;
    }
    res.json({ response: alreadyAnalysed });
    return;
  }

  const genAI = new GoogleGenerativeAI(apiKey);

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
    systemInstruction: clickbaitArticleCriteria,
  });

  const article = await fetchArticle(validUrl);
  if (!article) {
    saveFailedToAnalyseLink(validUrl, hashedUrl, db);
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
      const processedAIResponse = processResponse(
        aiResponse,
        'article',
        validUrl
      );
      const analysedLink = await saveAnalysedLink(
        hashedUrl,
        db,
        processedAIResponse
      );
      if (userUuid) {
        await saveUrlToUserHistory(hashedUrl, db, userUuid);
      }
      logger.info(`Received response: ${JSON.stringify(analysedLink)}`);
      res.json({ response: analysedLink });
    } else {
      logger.error('No response received from the AI chat sesssion');
      saveFailedToAnalyseLink(validUrl, hashedUrl, db);
      res.status(500).send('Internal Server Error');
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(`Error processing article: ${error?.message}`, error);
    saveFailedToAnalyseLink(validUrl, hashedUrl, db);
    res.status(500).send('Internal Server Error');
  }
}

export default processArticleLink;
