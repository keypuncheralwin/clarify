import { firestore } from 'firebase-admin';

export async function clearDeviceHistory(
  db: firestore.Firestore,
  deviceId: string
): Promise<void> {
  const deviceHistoryRef = db
    .collection('DeviceRequests')
    .doc(deviceId)
    .collection('DeviceHistory');

  const deviceHistorySnapshot = await deviceHistoryRef.get();

  const batch = db.batch();

  deviceHistorySnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
}

export default clearDeviceHistory;
