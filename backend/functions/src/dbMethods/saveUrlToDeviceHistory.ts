import { firestore } from 'firebase-admin';
import logger from '../logger/logger';
import { AnalysedLinkResponse } from '../types/general';

export async function saveUrlToDeviceHistory(
  hashedUrl: string,
  db: firestore.Firestore,
  deviceId: string,
  analysedLinkResponse: AnalysedLinkResponse
): Promise<AnalysedLinkResponse> {
  const timeStamp = new Date().toISOString(); // Store in ISO format (UTC)
  const deviceRef = db.collection('DeviceRequests').doc(deviceId);
  const historyRef = deviceRef
    .collection('DeviceHistory')
    .where('hashedUrl', '==', hashedUrl);

  try {
    await db.runTransaction(async (transaction) => {
      const historySnapshot = await transaction.get(historyRef);

      if (historySnapshot.empty) {
        const newHistoryRef = deviceRef.collection('DeviceHistory').doc();
        transaction.set(newHistoryRef, {
          hashedUrl: hashedUrl,
          analysedAt: timeStamp,
        });
        analysedLinkResponse.isAlreadyInHistory = false;
        analysedLinkResponse.analysedAt = timeStamp;
        logger.info('URL added to device history successfully');
      } else {
        const existingDoc = historySnapshot.docs[0];
        const analysedAt = existingDoc.get('analysedAt');
        analysedLinkResponse.analysedAt = analysedAt;
        analysedLinkResponse.isAlreadyInHistory = true;
        logger.info('URL already exists in device history');
      }
    });
    return analysedLinkResponse;
  } catch (error) {
    logger.error('Error adding URL to device history:', error);
    throw new Error('Error adding URL to device history');
  }
}
