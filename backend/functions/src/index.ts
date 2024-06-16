import * as functions from 'firebase-functions';
import express, { Request, Response } from 'express';
import cors from 'cors';
import extractValidUrl from './utils/extractValidUrl';
import logger from './logger/logger';
import processArticleLink from './mainProcess/processArticleLink';
import { isYouTubeVideoLink } from './utils/youtubeValidation';
import processYouTubeLink from './mainProcess/processYoutubeLink';

const app = express();

app.use(cors());
app.use(express.json());

app.post('/check-clickbait', async (req: Request, res: Response) => {
  const { url } = req.body;
  logger.info(`Received URL: ${url}`);

  const validUrl = await extractValidUrl(url);

  if (!validUrl) {
    res.status(400).send('Invalid URL');
    return;
  }

  if (isYouTubeVideoLink(validUrl)) {
    await processYouTubeLink(validUrl, res);
  } else {
    await processArticleLink(validUrl, res);
  }
});

exports.api = functions.https.onRequest(app);
