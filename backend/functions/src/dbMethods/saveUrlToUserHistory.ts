import { firestore } from 'firebase-admin';
import logger from '../logger/logger';

export async function saveUrlToUserHistory(
  hashedUrl: string,
  db: firestore.Firestore,
  userUuid?: string
): Promise<void> {
  if (!userUuid) {
    logger.info('User UUID is not provided, skipping history update.');
    return;
  }
  const timeStamp = new Date().toISOString(); // Store in ISO format (UTC)
  const userRef = db.collection('Users').doc(userUuid);
  const historyRef = userRef
    .collection('UserHistory')
    .where('hashedUrl', '==', hashedUrl);

  try {
    await db.runTransaction(async (transaction) => {
      const historySnapshot = await transaction.get(historyRef);

      if (historySnapshot.empty) {
        const newHistoryRef = userRef.collection('UserHistory').doc();
        transaction.set(newHistoryRef, {
          hashedUrl: hashedUrl,
          analysedAt: timeStamp,
        });
      }
    });

    logger.info('URL added to user history successfully');
  } catch (error) {
    logger.error('Error adding URL to user history:', error);
    throw new Error('Error adding URL to user history');
  }
}
