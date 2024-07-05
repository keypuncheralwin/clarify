import * as functions from 'firebase-functions';
import express from 'express';
import cors from 'cors';
import admin from 'firebase-admin';
import dotenv from 'dotenv';
import auth from './routes/auth';
import analyse from './routes/analyse';
import serviceAccount from './key.json';

dotenv.config();

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

const app = express();

app.use(cors());
app.use(express.json());

app.use('/auth', auth);
app.use('/clarify', analyse);

exports.api = functions.https.onRequest(app);
