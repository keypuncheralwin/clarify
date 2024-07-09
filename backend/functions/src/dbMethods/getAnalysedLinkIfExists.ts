import { firestore } from 'firebase-admin';
import { AnalysedLinkResponse } from '../types/general';
import logger from '../logger/logger';

export async function getAnalysedLinkIfExists(
  hashedUrl: string,
  db: firestore.Firestore,
  userUuid?: string
): Promise<AnalysedLinkResponse | null> {
  const urlRef = db.collection('AnalysedLinks').doc(hashedUrl);

  try {
    const urlDoc = await urlRef.get();

    if (!urlDoc.exists) {
      return null;
    }

    const analysedLinkResponse = urlDoc.data() as AnalysedLinkResponse;

    if (userUuid) {
      const userRef = db.collection('Users').doc(userUuid);
      const historyRef = userRef
        .collection('UserHistory')
        .where('hashedUrl', '==', hashedUrl);

      const historySnapshot = await historyRef.get();

      if (!historySnapshot.empty) {
        const userHistoryDoc = historySnapshot.docs[0];
        const lastAnalysed = userHistoryDoc.get('analysedAt');
        analysedLinkResponse.lastAnalysed = lastAnalysed;
      }
    }

    return analysedLinkResponse;
  } catch (error) {
    logger.error('Error checking URL existence:', error);
    throw new Error('Error checking URL existence');
  }
}
