import { firestore } from 'firebase-admin';

export async function clearUserHistory(
  db: firestore.Firestore,
  userUuid: string
): Promise<void> {
  const userHistoryRef = db
    .collection('Users')
    .doc(userUuid)
    .collection('UserHistory');

  const userHistorySnapshot = await userHistoryRef.get();

  const batch = db.batch();

  userHistorySnapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
}

export default clearUserHistory;
