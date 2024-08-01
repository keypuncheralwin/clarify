import { Response } from 'express';
import { GoogleGenerativeAI } from '@google/generative-ai';
import {
  clickbaitArticleCriteria,
  generateClickbaitArticlePrompt,
} from '../constants/article';
import { safetySettings, generationConfig } from '../constants/gemini';
import logger from '../logger/logger';
import { getChatResponse, hashUrl, processResponse } from '../utils/general';
import { firestore } from 'firebase-admin';
import { saveAnalysedLink } from '../dbMethods/saveAnalysedLink';
import { getAnalysedLinkIfExists } from '../dbMethods/getAnalysedLinkIfExists';
import { saveUrlToUserHistory } from '../dbMethods/saveUrlToUserHistory';
import { saveFailedToAnalyseLink } from '../dbMethods/saveFailedToAnalyseLink';
import { AnalysisResult } from '../types/general';
import fetchArticle from '../utils/fetchArticle';

/**
 * Process the article link and handle the entire flow.
 * @param url - The validated URL of the article.
 * @param res - The Express response object.
 * @param apiKey - The gemini api key.
 * @param userUuid - Optional user UUID.
 */
async function processArticleLink(
  url: string,
  res: Response,
  apiKey: string,
  userUuid?: string
): Promise<void> {
  // Initialize firestore
  const db = firestore();
  const hashedUrl = hashUrl(url);

  let response = await getAnalysedLinkIfExists(hashedUrl, db);

  if (response) {
    if (userUuid) {
      response = await saveUrlToUserHistory(hashedUrl, db, userUuid, response);
    }
    const analysisResult: AnalysisResult = {
      status: 'success',
      data: response,
    };
    res.json(analysisResult);
    return;
  }
  const article = await fetchArticle(url);
  if (!article) {
    const analysisResult: AnalysisResult = {
      status: 'error',
      error: {
        code: 200,
        message: "Unfortunety, we're not able to clarify that right now.",
      },
    };
    res.status(200).json(analysisResult);
    return;
  }
  const { title, subtitle, content } = article;
  logger.info(`Fetched article: ${title}`);
  const prompt: string = generateClickbaitArticlePrompt(
    title,
    subtitle,
    content
  );
  logger.info('Generated prompt');
  logger.info(`Prompt: ${prompt}`);
  const genAI = new GoogleGenerativeAI(apiKey);

  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-flash',
    systemInstruction: clickbaitArticleCriteria,
  });

  const chatSession = model.startChat({
    safetySettings,
    generationConfig,
  });

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
      const analysisResult: AnalysisResult = {
        status: 'success',
        data: response,
      };
      res.json(analysisResult);
    } else {
      logger.error('No response received from the AI chat session');
      saveFailedToAnalyseLink(
        url,
        'No response received from the AI chat session'
      );
      const analysisResult: AnalysisResult = {
        status: 'error',
        error: {
          code: 500,
          message: 'Internal Server Error',
        },
      };
      res.status(500).json(analysisResult);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(`Error processing article: ${error?.message}`, error);
    saveFailedToAnalyseLink(url, `Error processing article: ${error?.message}`);
    const analysisResult: AnalysisResult = {
      status: 'error',
      error: {
        code: 500,
        message: 'Internal Server Error',
      },
    };
    res.status(500).json(analysisResult);
  }
}

export default processArticleLink;
