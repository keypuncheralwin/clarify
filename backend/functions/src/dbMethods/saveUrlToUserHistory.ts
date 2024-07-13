import { firestore } from 'firebase-admin';
import logger from '../logger/logger';
import { AnalysedLinkResponse } from '../types/general';

export async function saveUrlToUserHistory(
  hashedUrl: string,
  db: firestore.Firestore,
  userUuid: string,
  analysedLinkResponse: AnalysedLinkResponse
): Promise<AnalysedLinkResponse> {
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
        analysedLinkResponse.isAlreadyInHistory = false;
        analysedLinkResponse.analysedAt = timeStamp;
        logger.info('URL added to user history successfully');
      } else {
        const existingDoc = historySnapshot.docs[0];
        const analysedAt = existingDoc.get('analysedAt');
        analysedLinkResponse.analysedAt = analysedAt;
        analysedLinkResponse.isAlreadyInHistory = true;
        logger.info('URL already exists in user history');
      }
    });
    return analysedLinkResponse;
  } catch (error) {
    logger.error('Error adding URL to user history:', error);
    throw new Error('Error adding URL to user history');
  }
}
