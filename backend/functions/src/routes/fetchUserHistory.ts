import { Router, Request, Response } from 'express';
import admin from 'firebase-admin';
import logger from '../logger/logger';
import { verifyUser } from '../middleware/authMiddleware';
import fetchUserHistory from '../dbMethods/fetchUserHistory';

const router = Router();

router.get(
  '/user-history',
  verifyUser,
  async (req: Request, res: Response): Promise<void> => {
    const userUuid = req.user?.uid;
    const { pageSize = 10, pageToken, searchKeyword = '' } = req.query;

    if (!userUuid) {
      res.status(400).send('User UUID is required');
      return;
    }

    try {
      const db = admin.firestore();
      const response = await fetchUserHistory(
        db,
        userUuid,
        Number(pageSize),
        pageToken as string,
        searchKeyword as string
      );
      res.status(200).json(response);
    } catch (error) {
      logger.error('Error fetching user history:', error);
      res.status(500).send('An error occurred while fetching the user history');
    }
  }
);

export default router;
