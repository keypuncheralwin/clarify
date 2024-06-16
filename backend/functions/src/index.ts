import * as functions from 'firebase-functions';
import express, { Request, Response } from 'express';
import cors from 'cors';
import extractValidUrl from './utils/extractValidUrl';
import logger from './logger/logger';
import processArticleLink from './mainProcess/processArticleLink';
import { isYouTubeVideoLink } from './utils/youtubeValidation';
import processYouTubeLink from './mainProcess/processYoutubeLink';
import dotenv from 'dotenv';
dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

const apiKey = process.env.GEMINI_API_TOKEN || '';

app.post('/check-clickbait', async (req: Request, res: Response) => {
  if (!apiKey) {
    logger.error('Gemini API Key not loaded');
    res.status(400).send('Invalid API Key');
    return;
  }

  const { url } = req.body;
  logger.info(`Received URL: ${url}`);

  const validUrl = await extractValidUrl(url);

  if (!validUrl) {
    res.status(400).send('Invalid URL');
    return;
  }

  if (isYouTubeVideoLink(validUrl)) {
    await processYouTubeLink(validUrl, res, apiKey);
  } else {
    await processArticleLink(validUrl, res, apiKey);
  }
});

exports.api = functions.https.onRequest(app);
