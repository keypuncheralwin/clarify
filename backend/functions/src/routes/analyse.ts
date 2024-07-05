import { Router, Request, Response } from 'express';
import extractValidUrl from '../utils/extractValidUrl';
import processArticleLink from '../mainProcess/processArticleLink';
import processYouTubeLink from '../mainProcess/processYoutubeLink';
// import { verifyAuthToken } from '../middleware/authMiddleware';
import { containsValidYoutubeUrl } from '../utils/youtubeValidation';
import logger from '../logger/logger';
import { specialCasesCheck } from '../utils/specialCaseUrlChecks';

const router = Router();

const apiKey = process.env.GEMINI_API_TOKEN || '';

router.post('/analyse', async (req: Request, res: Response): Promise<void> => {
  if (!apiKey) {
    logger.error('Gemini API Key not loaded');
    res.status(400).send('Invalid API Key');
    return;
  }

  const { url } = req.body;
  const userEmail = req.user?.email; // Access user email
  logger.info(`Received URL: ${url} from user: ${userEmail}`);

  if (!url) {
    res.status(400).send('No URL provided');
    return;
  }

  try {
    const youTubeVideoLink = containsValidYoutubeUrl(url);
    if (youTubeVideoLink) {
      await processYouTubeLink(youTubeVideoLink, res, apiKey);
    } else {
      const validUrl = await extractValidUrl(url);
      if (!validUrl) {
        res.status(400).send('Invalid URL');
        return;
      }
      const finalUrl = specialCasesCheck(validUrl);
      await processArticleLink(finalUrl, res, apiKey);
    }
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    logger.error(`Error processing URL: ${error.message}`);
    res.status(500).send('An error occurred while processing the request');
  }
});

export default router;
