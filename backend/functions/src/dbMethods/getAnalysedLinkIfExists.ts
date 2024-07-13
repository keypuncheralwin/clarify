import { firestore } from 'firebase-admin';
import { AnalysedLinkResponse } from '../types/general';
import logger from '../logger/logger';

export async function getAnalysedLinkIfExists(
  hashedUrl: string,
  db: firestore.Firestore
): Promise<AnalysedLinkResponse | null> {
  const urlRef = db.collection('AnalysedLinks').doc(hashedUrl);

  try {
    const urlDoc = await urlRef.get();

    if (!urlDoc.exists) {
      return null;
    }

    const analysedLinkResponse = urlDoc.data() as AnalysedLinkResponse;
    analysedLinkResponse.isAlreadyInHistory = false;
    return analysedLinkResponse;
  } catch (error) {
    logger.error('Error checking URL existence:', error);
    throw new Error('Error checking URL existence');
  }
}
