import { Router, Request, Response } from 'express';
import logger from '../logger/logger';
import { saveFeedback } from '../dbMethods/saveFeedback';

const router = Router();

router.post('/feedback', async (req: Request, res: Response): Promise<void> => {
  const { deviceId, email, rating, feedbackContent } = req.body;

  if (!deviceId || !feedbackContent) {
    res.status(400).send('deviceId and feedbackContent are required');
    return;
  }

  try {
    const isSaved = await saveFeedback({
      deviceId,
      feedbackContent,
      email,
      rating,
    });
    if (isSaved) {
      logger.info('Feedback saved successfully');
      res.status(200).send('Feedback received successfully');
    } else {
      logger.error('Failed to save feedback');
      res.status(500).send('Failed to save feedback');
    }
  } catch (error) {
    logger.error('Error saving feedback:', error);
    res.status(500).send('An error occurred while saving the feedback');
  }
});

export default router;
