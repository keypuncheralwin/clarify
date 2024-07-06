import { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin';
import logger from '../logger/logger';

export const verifyAuthToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  const token = req.headers.authorization?.split('Bearer ')[1];
  logger.info(`Received something: ${req.headers.authorization}`);
  if (!token) {
    logger.error('NO TOKEN');
    res.status(403).send('Unauthorized');
    return;
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    res.status(403).send('Unauthorized');
  }
};
