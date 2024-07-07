import { firestore } from 'firebase-admin';

interface AnalysedLink {
  title: string;
  isClickBait: boolean;
  clarityScore: number;
  explanation: string;
  answer: string;
  summary: string;
  isVideo: boolean;
  originalUrl: string;
  lastAnalysed: FirebaseFirestore.Timestamp;
}

interface UserHistoryItem {
  historyId: string;
  analysedAt: FirebaseFirestore.Timestamp;
  hashedUrl: string;
  analysedLink: AnalysedLink;
}

interface UserHistoryResponse {
  userHistory: Array<UserHistoryItem>;
  nextPageToken: string | null;
}

export async function fetchUserHistory(
  db: firestore.Firestore,
  userUuid: string,
  pageSize: number,
  pageToken?: string,
  searchKeyword: string = ''
): Promise<UserHistoryResponse> {
  let userHistoryRef = db
    .collection('Users')
    .doc(userUuid)
    .collection('UserHistory')
    .orderBy('analysedAt', 'desc')
    .limit(pageSize);

  if (pageToken) {
    const lastDoc = await db
      .collection('Users')
      .doc(userUuid)
      .collection('UserHistory')
      .doc(pageToken)
      .get();

    if (lastDoc.exists) {
      userHistoryRef = userHistoryRef.startAfter(lastDoc);
    }
  }

  const userHistorySnapshot = await userHistoryRef.get();
  const userHistoryData: UserHistoryItem[] = [];

  for (const doc of userHistorySnapshot.docs) {
    const historyData = doc.data();
    const hashedUrl = historyData.hashedUrl;
    const analysedLinkDoc = await db
      .collection('AnalysedLinks')
      .doc(hashedUrl)
      .get();

    if (analysedLinkDoc.exists) {
      const analysedLinkData = analysedLinkDoc.data() as AnalysedLink;

      if (analysedLinkData.title.includes(searchKeyword)) {
        userHistoryData.push({
          historyId: doc.id,
          analysedAt: historyData.analysedAt,
          hashedUrl: historyData.hashedUrl,
          analysedLink: analysedLinkData,
        });
      }
    }
  }

  const nextPageToken =
    userHistorySnapshot.docs.length === pageSize
      ? userHistorySnapshot.docs[userHistorySnapshot.docs.length - 1].id
      : null;

  return {
    userHistory: userHistoryData,
    nextPageToken,
  };
}

export default fetchUserHistory;
