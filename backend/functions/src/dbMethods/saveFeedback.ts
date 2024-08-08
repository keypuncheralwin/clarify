import { firestore } from 'firebase-admin';
import logger from '../logger/logger';

interface FeedbackData {
  deviceId: string;
  feedbackContent: string;
  email?: string;
  rating?: number;
}

export async function saveFeedback(
  feedbackData: FeedbackData
): Promise<boolean> {
  const timeStamp = new Date().toISOString(); // Store in ISO format (UTC)

  const feedback = {
    ...feedbackData,
    submittedAt: timeStamp,
  };

  const feedbackRef = firestore().collection('Feedback').doc();

  try {
    await feedbackRef.set(feedback);
    logger.info('Feedback saved successfully');
    return true;
  } catch (error) {
    logger.error('Error saving feedback:', error);
    return false;
  }
}
