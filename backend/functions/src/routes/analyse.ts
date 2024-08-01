import { Router, Request, Response } from 'express';
import processArticleLink from '../mainProcess/processArticleLink';
import processYouTubeLink from '../mainProcess/processYoutubeLink';
import { containsValidYoutubeUrl } from '../utils/youtubeValidation';
import logger from '../logger/logger';
import extractValidUrl from '../utils/extractValidUrl';
import { verifyUserOrDevice } from '../middleware/authMiddleware';

const router = Router();

const apiKey = process.env.GEMINI_API_TOKEN || '';

router.post(
  '/analyse',
  verifyUserOrDevice,
  async (req: Request, res: Response): Promise<void> => {
    if (!apiKey) {
      logger.error('Gemini API Key not loaded');
      res.status(400).send('Invalid API Key');
      return;
    }

    const { url } = req.body;
    const userUuid = req.user?.uid;

    if (!url) {
      res.status(400).send('No URL provided');
      return;
    }

    try {
      const youTubeVideoLink = containsValidYoutubeUrl(url);
      if (youTubeVideoLink) {
        await processYouTubeLink(youTubeVideoLink, res, apiKey, userUuid);
      } else {
        const validUrl = await extractValidUrl(url);
        console.log('validURL:', validUrl);
        if (!validUrl) {
          res.status(400).send('Invalid URL');
          return;
        }
        await processArticleLink(validUrl, res, apiKey, userUuid);
      }
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    } catch (error: any) {
      logger.error(`Error processing URL: ${error.message}`);
      res.status(500).send('An error occurred while processing the request');
    }
  }
);

export default router;
