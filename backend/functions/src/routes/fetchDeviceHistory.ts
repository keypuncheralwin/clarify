import { Router, Request, Response } from 'express';
import admin from 'firebase-admin';
import logger from '../logger/logger';
import fetchDeviceHistory from '../dbMethods/fetchDeviceHistory';
import clearDeviceHistory from '../dbMethods/clearDeviceHistory';

const router = Router();

router.get(
  '/device-history',
  async (req: Request, res: Response): Promise<void> => {
    const {
      pageSize = 10,
      pageToken,
      searchKeyword = '',
      deviceId,
    } = req.query;

    if (!deviceId) {
      res.status(400).send('Device ID is required');
      return;
    }
    try {
      const db = admin.firestore();
      const response = await fetchDeviceHistory(
        db,
        deviceId as string,
        Number(pageSize),
        pageToken as string,
        searchKeyword as string
      );
      res.status(200).json(response);
    } catch (error) {
      logger.error('Error fetching device history:', error);
      res
        .status(500)
        .send('An error occurred while fetching the device history');
    }
  }
);

router.delete(
  '/device-history',
  async (req: Request, res: Response): Promise<void> => {
    const { deviceId } = req.query;

    if (!deviceId) {
      res.status(400).send('Device ID is required');
      return;
    }

    try {
      const db = admin.firestore();
      await clearDeviceHistory(db, deviceId as string);
      res.status(200).send('Device history cleared successfully');
    } catch (error) {
      logger.error('Error clearing device history:', error);
      res
        .status(500)
        .send('An error occurred while clearing the device history');
    }
  }
);

export default router;
