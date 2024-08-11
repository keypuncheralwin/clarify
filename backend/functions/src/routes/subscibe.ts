import { Router, Request, Response } from 'express';
import logger from '../logger/logger';
import { saveSubscriber } from '../dbMethods/saveSubscriber';

const router = Router();

router.post(
  '/subscribe',
  async (req: Request, res: Response): Promise<void> => {
    const { name, email } = req.body;
    if (!email) {
      res.status(400).json({ success: false, message: 'Email is required' });
      return;
    }

    try {
      const result = await saveSubscriber({ name, email });
      if (result.success) {
        logger.info(result.message);
        res.status(200).json({
          success: true,
          message: result.message,
        });
      } else {
        logger.warn(result.message);
        res.status(400).json({ success: false, message: result.message });
      }
    } catch (error) {
      logger.error('Error saving subscriber:', error);
      res.status(500).json({
        success: false,
        message: 'An error occurred while saving the subscriber',
      });
    }
  }
);

export default router;
