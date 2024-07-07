import { firestore } from 'firebase-admin';
import { ClickbaitResponse } from '../types/general';
import logger from '../logger/logger';

export async function getAnalysedLinkIfExists(
  hashedUrl: string,
  db: firestore.Firestore
): Promise<ClickbaitResponse | null> {
  const urlRef = db.collection('AnalysedLinks').doc(hashedUrl);

  try {
    const urlDoc = await urlRef.get();

    if (urlDoc.exists) {
      return urlDoc.data() as ClickbaitResponse;
    } else {
      return null;
    }
  } catch (error) {
    logger.error('Error checking URL existence:', error);
    throw new Error('Error checking URL existence');
  }
}
