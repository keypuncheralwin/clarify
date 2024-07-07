import { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import logger from '../logger/logger';

const MAX_REQUESTS = 10;

export const verifyUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const token = req.headers.authorization?.split('Bearer ')[1];

  if (!token) {
    res.status(403).send('Unauthorized');
    return;
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    logger.error('Error verifying auth token', error);
    res.status(403).send('Unauthorized');
  }
};

export const verifyUserOrDevice = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  const { device_id } = req.body;

  if (!device_id) {
    res.status(400).send('Device ID is required');
    return;
  }

  const db = admin.firestore();
  const deviceRef = db.collection('DeviceRequests').doc(device_id);

  try {
    if (token) {
      await verifyUser(req, res, next);

      // Link device to user if user verification passes
      if (req.user) {
        await deviceRef.set(
          {
            userId: req.user.uid,
            requestCount: 0,
          },
          { merge: true }
        );
      }
    } else {
      const deviceDoc = await deviceRef.get();
      let requestCount = 0;

      if (deviceDoc.exists) {
        const deviceData = deviceDoc.data();
        requestCount = deviceData?.requestCount || 0;

        if (requestCount >= MAX_REQUESTS) {
          res.status(429).send('Request limit reached. Please sign in.');
          return;
        }
      }

      await deviceRef.set(
        {
          requestCount: admin.firestore.FieldValue.increment(1),
          lastRequestAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      next();
    }
  } catch (error) {
    logger.error(
      'Error verifying auth token or tracking device requests',
      error
    );
    res.status(500).send('Internal Server Error');
  }
};
