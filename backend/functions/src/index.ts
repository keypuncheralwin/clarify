import * as functions from 'firebase-functions';
import express, { Request, Response } from 'express';
import cors from 'cors';
import extractValidUrl from './utils/extractValidUrl';
import logger from './logger/logger';
import processArticleLink from './mainProcess/processArticleLink';
import { containsValidYoutubeUrl } from './utils/youtubeValidation';
import processYouTubeLink from './mainProcess/processYoutubeLink';
import dotenv from 'dotenv';
import { specialCasesCheck } from './utils/specialCaseUrlChecks';
dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const apiKey = process.env.GEMINI_API_TOKEN || '';

app.post('/check-clickbait', async (req: Request, res: Response) => {
  if (!apiKey) {
    logger.error('Gemini API Key not loaded');
    return res.status(400).send('Invalid API Key');
  }

  const { url } = req.body;
  logger.info(`Received URL: ${url}`);

  if (!url) {
    return res.status(400).send('No URL provided');
  }

  try {
    const youTubeVideoLink = containsValidYoutubeUrl(url);
    if (youTubeVideoLink) {
      await processYouTubeLink(youTubeVideoLink, res, apiKey);
    } else {
      const validUrl = await extractValidUrl(url);
      if (!validUrl) {
        return res.status(400).send('Invalid URL');
      }
      const finalUrl = specialCasesCheck(validUrl);
      await processArticleLink(finalUrl, res, apiKey);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(`Error processing URL: ${error.message}`);
    return res
      .status(500)
      .send('An error occurred while processing the request');
  }
  return;
});

exports.api = functions.https.onRequest(app);
