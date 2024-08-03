import { firestore } from 'firebase-admin';
import {
  AnalysedLinkResponse,
  UserHistoryItem,
  UserHistoryResponse,
} from '../types/general';

export async function fetchDeviceHistory(
  db: firestore.Firestore,
  deviceId: string,
  pageSize: number,
  pageToken?: string,
  searchKeyword: string = ''
): Promise<UserHistoryResponse> {
  let deviceHistoryRef = db
    .collection('DeviceRequests')
    .doc(deviceId)
    .collection('DeviceHistory')
    .orderBy('analysedAt', 'desc')
    .limit(pageSize);

  if (pageToken) {
    const lastDoc = await db
      .collection('DeviceRequests')
      .doc(deviceId)
      .collection('DeviceHistory')
      .doc(pageToken)
      .get();

    if (lastDoc.exists) {
      deviceHistoryRef = deviceHistoryRef.startAfter(lastDoc);
    }
  }

  const deviceHistorySnapshot = await deviceHistoryRef.get();
  const deviceHistoryData: UserHistoryItem[] = [];

  for (const doc of deviceHistorySnapshot.docs) {
    const historyData = doc.data();
    const hashedUrl = historyData.hashedUrl;
    const analysedLinkDoc = await db
      .collection('AnalysedLinks')
      .doc(hashedUrl)
      .get();

    if (analysedLinkDoc.exists) {
      const analysedLinkData = analysedLinkDoc.data() as AnalysedLinkResponse;

      if (analysedLinkData.title.includes(searchKeyword)) {
        // Updating the lastAnalysed time to be when the device analysed it and not when the link was first
        // analysed
        analysedLinkData.analysedAt = historyData.analysedAt;
        deviceHistoryData.push({
          historyId: doc.id,
          analysedLink: analysedLinkData,
        });
      }
    }
  }

  const nextPageToken =
    deviceHistorySnapshot.docs.length === pageSize
      ? deviceHistorySnapshot.docs[deviceHistorySnapshot.docs.length - 1].id
      : null;

  return {
    userHistory: deviceHistoryData,
    nextPageToken,
  };
}

export default fetchDeviceHistory;
