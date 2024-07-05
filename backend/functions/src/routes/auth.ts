import { Router, Request, Response } from 'express';
import admin from 'firebase-admin';
import crypto from 'crypto';
import { firestore } from 'firebase-admin';
import { sendMagicLink } from '../utils/emailService'; // Adjust your email service to handle sending magic links

const router = Router();

router.post(
  '/send-magic-link',
  async (req: Request, res: Response): Promise<void> => {
    const { email } = req.body;

    if (!email) {
      res.status(400).send('Email is required');
      return;
    }

    try {
      const token = crypto.randomBytes(20).toString('hex');
      const db = firestore();
      const docRef = db.collection('magicLinks').doc(email);
      await docRef.set({
        token,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const magicLink = `clarify://auth?token=${token}&email=${email}`;
      await sendMagicLink(email, magicLink); // Adjust your email service to send the magic link

      res.status(200).send('Magic link sent!');
    } catch (error) {
      console.error('Error sending magic link:', error);
      res.status(500).send('Failed to send magic link');
    }
  }
);

router.post(
  '/verify-magic-link',
  async (req: Request, res: Response): Promise<void> => {
    const { email, token } = req.body;

    if (!email || !token) {
      res.status(400).send('Email and token are required');
      return;
    }

    try {
      const db = firestore();
      const docRef = db.collection('magicLinks').doc(email);
      const doc = await docRef.get();

      if (!doc.exists) {
        res.status(400).send('Invalid token or email');
        return;
      }

      const data = doc.data();
      const { token: storedToken, createdAt } = data || {};

      const isValid =
        storedToken === token &&
        createdAt.toMillis() + 15 * 60 * 1000 > Date.now();

      if (!isValid) {
        res.status(400).send('Invalid or expired token');
        return;
      }

      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(email);
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
      } catch (error: any) {
        if (error.code === 'auth/user-not-found') {
          userRecord = await admin.auth().createUser({ email });
        } else {
          throw error;
        }
      }

      const firebaseToken = await admin
        .auth()
        .createCustomToken(userRecord.uid);
      res.status(200).json({ token: firebaseToken });
    } catch (error) {
      console.error('Error verifying token:', error);
      res.status(500).send('Failed to verify token');
    }
  }
);

export default router;
