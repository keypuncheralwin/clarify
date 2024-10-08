import { Router, Request, Response } from 'express';
import admin from 'firebase-admin';
import { firestore } from 'firebase-admin';
import { sendVerificationCode } from '../utils/emailService';

const router = Router();

router.post(
  '/send-verification-code',
  async (req: Request, res: Response): Promise<void> => {
    const { email } = req.body;

    if (!email) {
      res.status(400).send('Email is required');
      return;
    }

    try {
      const code = Math.floor(1000 + Math.random() * 9000).toString();
      const db = firestore();
      const docRef = db.collection('VerificationCodes').doc(email);
      await docRef.set({
        code,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      await sendVerificationCode(email, code);

      res.status(200).send('Verification code sent!');
    } catch (error) {
      console.error('Error sending verification code:', error);
      res.status(500).send('Failed to send verification code');
    }
  }
);

router.post(
  '/verify-code',
  async (req: Request, res: Response): Promise<void> => {
    const { email, code, name, deviceId } = req.body;

    if (!email || !code) {
      res.status(400).send('Email and code are required');
      return;
    }

    try {
      const db = firestore();
      const docRef = db.collection('VerificationCodes').doc(email);
      const doc = await docRef.get();

      if (!doc.exists) {
        res.status(400).send('Invalid code or email');
        return;
      }

      const data = doc.data();
      const { code: storedCode, createdAt } = data || {};

      const isValid =
        storedCode === code &&
        createdAt.toMillis() + 15 * 60 * 1000 > Date.now();

      if (!isValid) {
        res.status(400).send('Invalid or expired code');
        return;
      }

      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(email);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        if (error.code === 'auth/user-not-found') {
          if (!name) {
            res.status(200).json({ nameRequired: true });
            return;
          }
          userRecord = await admin
            .auth()
            .createUser({ email, displayName: name });
        } else {
          throw error;
        }
      }

      const firebaseToken = await admin
        .auth()
        .createCustomToken(userRecord.uid);

      // Link the device ID to the user ID
      if (deviceId) {
        const deviceRef = db.collection('DeviceRequests').doc(deviceId);

        // Move DeviceHistory to UserHistory
        const deviceHistoryRef = deviceRef.collection('DeviceHistory');
        const deviceHistorySnapshot = await deviceHistoryRef.get();

        const userHistoryRef = db
          .collection('Users')
          .doc(userRecord.uid)
          .collection('UserHistory');

        const batch = db.batch();

        deviceHistorySnapshot.forEach((doc) => {
          const userHistoryDocRef = userHistoryRef.doc(doc.id);
          batch.set(userHistoryDocRef, doc.data());
        });

        await batch.commit();

        // Delete DeviceHistory
        deviceHistorySnapshot.forEach(async (doc) => {
          await deviceHistoryRef.doc(doc.id).delete();
        });
      }

      res.status(200).json({ token: firebaseToken });
    } catch (error) {
      console.error('Error verifying code:', error);
      res.status(500).send('Failed to verify code');
    }
  }
);

export default router;
