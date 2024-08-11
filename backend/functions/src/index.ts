import * as functions from 'firebase-functions';
import express from 'express';
import cors from 'cors';
import admin from 'firebase-admin';
import dotenv from 'dotenv';
import auth from './routes/auth';
import analyse from './routes/analyse';
import serviceAccount from './key.json';
import fetchUserHistory from './routes/fetchUserHistory';
import fetchDeviceHistory from './routes/fetchDeviceHistory';
import feedback from './routes/feedback';
import subscribe from './routes/subscibe';

dotenv.config();

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

const app = express();

app.use(cors());
app.use(express.json());

app.use(auth);
app.use(analyse);
app.use(fetchUserHistory);
app.use(fetchDeviceHistory);
app.use(feedback);
app.use(subscribe);

exports.api = functions.https.onRequest(app);
