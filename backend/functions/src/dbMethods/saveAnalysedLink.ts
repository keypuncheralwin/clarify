import { firestore } from 'firebase-admin';
import logger from '../logger/logger';
import { AnalysedLinkResponse, ProcessedAIResponse } from '../types/general';

export async function saveAnalysedLink(
  hashedUrl: string,
  db: firestore.Firestore,
  processedAIResponse: ProcessedAIResponse
): Promise<AnalysedLinkResponse> {
  const timeStamp = new Date().toISOString(); // Store in ISO format (UTC)

  const analysedLink: AnalysedLinkResponse = {
    ...processedAIResponse,
    hashedUrl,
    analysedAt: timeStamp,
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
