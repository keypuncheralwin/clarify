import { firestore } from 'firebase-admin';
import logger from '../logger/logger';
import { FailedToAnalyseResponse } from '../types/general';
import { hashUrl } from '../utils/general';

export async function saveFailedToAnalyseLink(
  url: string,
  reason: string
): Promise<void> {
  const db = firestore();
  const hashedUrl = hashUrl(url);

  const timeStamp = new Date().toISOString(); // Store in ISO format (UTC)

  const urlRef = db.collection('FailedToAnalyse').doc(hashedUrl);

  try {
    await db.runTransaction(async (transaction) => {
      const urlDoc = await transaction.get(urlRef);

      if (urlDoc.exists) {
        const currentData = urlDoc.data() as FailedToAnalyseResponse;
        transaction.update(urlRef, {
          visitCount: (currentData.visitCount || 0) + 1,
          lastAttemptedAt: timeStamp,
        });
      } else {
        const failedToAnalyse: FailedToAnalyseResponse = {
          url,
          hashedUrl,
          visitCount: 1,
          firstAttemptedAt: timeStamp,
          lastAttemptedAt: timeStamp,
          reason,
        };
        transaction.set(urlRef, failedToAnalyse);
      }
    });

    logger.info('Failed to analyse link details saved/updated successfully');
  } catch (error) {
    logger.error(
      'Error saving/updating failed to analyse link details:',
      error
    );
    throw new Error('Error saving/updating failed to analyse link details');
  }
}
