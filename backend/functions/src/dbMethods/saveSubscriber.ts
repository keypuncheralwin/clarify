import { firestore } from 'firebase-admin';
import logger from '../logger/logger';

interface SubscriberData {
  name?: string;
  email: string;
}

export async function saveSubscriber(
  subscriberData: SubscriberData
): Promise<{ success: boolean; message: string }> {
  try {
    const subscribersRef = firestore().collection('Subscribers');
    const querySnapshot = await subscribersRef
      .where('email', '==', subscriberData.email)
      .get();

    if (!querySnapshot.empty) {
      logger.warn('Email is already subscribed');
      return { success: false, message: 'Email is already subscribed' };
    }

    const timeStamp = new Date().toISOString(); // Store in ISO format (UTC)
    const subscriber = {
      ...subscriberData,
      subscribedAt: timeStamp,
    };

    await subscribersRef.add(subscriber);
    logger.info('Subscriber saved successfully');
    return { success: true, message: 'Subscriber saved successfully' };
  } catch (error) {
    logger.error('Error saving subscriber:', error);
    return { success: false, message: 'Failed to save subscriber' };
  }
}
