import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

// Salt should be provided via Secret Manager as ANON_SALT
const salt = process.env.ANON_SALT || functions.config().analytics?.salt || 'dev_salt';

export const anonymize = functions.firestore
  .document('metrics/{docId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const hash = crypto.createHmac('sha256', salt).update(data.uid).digest('hex');
    await admin.firestore().collection('analytics').add({
      ...data,
      uid: hash,
    });
  });
