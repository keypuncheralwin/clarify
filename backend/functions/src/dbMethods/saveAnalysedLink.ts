import admin from 'firebase-admin';
import { firestore } from 'firebase-admin';
import logger from '../logger/logger';
import { AnalysedLinkResponse, ProcessedAIResponse } from '../types/general';

export async function saveAnalysedLink(
  hashedUrl: string,
  db: firestore.Firestore,
  processedAIResponse: ProcessedAIResponse
): Promise<AnalysedLinkResponse> {
  const analysedLink: AnalysedLinkResponse = {
    ...processedAIResponse,
    hashedUrl,
    lastAnalysed: admin.firestore.FieldValue.serverTimestamp(),
  };

  const urlRef = db.collection('AnalysedLinks').doc(hashedUrl);

  try {
    await db.runTransaction(async (transaction) => {
      const urlDoc = await transaction.get(urlRef);

      if (!urlDoc.exists) {
        transaction.set(urlRef, analysedLink);
      }
    });

    logger.info('Analysed link details saved successfully');
    return analysedLink;
  } catch (error) {
    logger.error('Error saving Analysed link details:', error);
    throw new Error('Error saving Analysed link details');
  }
}
