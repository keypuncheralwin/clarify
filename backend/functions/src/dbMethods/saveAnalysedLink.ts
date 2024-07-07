import admin from 'firebase-admin';
import { firestore } from 'firebase-admin';
import { ClickbaitResponse } from '../types/general';
import logger from '../logger/logger';

export async function saveAnalysedLink(
  hashedUrl: string,
  db: firestore.Firestore,
  url: string,
  analysedLink: ClickbaitResponse
): Promise<void> {
  const urlData = {
    ...analysedLink,
    originalUrl: url,
    lastanalysed: admin.firestore.FieldValue.serverTimestamp(),
  };

  const urlRef = db.collection('AnalysedLinks').doc(hashedUrl);

  try {
    await db.runTransaction(async (transaction) => {
      const urlDoc = await transaction.get(urlRef);

      if (!urlDoc.exists) {
        transaction.set(urlRef, urlData);
      }
    });

    logger.info('URL details saved successfully');
  } catch (error) {
    logger.error('Error saving URL details:', error);
    throw new Error('Error saving URL details');
  }
}
