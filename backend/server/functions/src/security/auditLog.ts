import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// Logs writes on emotions entries to a private collection. In production this
// could instead stream to BigQuery for centralized analytics.
export const auditLog = functions.firestore
  .document('emotions/{uid}/entries/{entryId}')
  .onWrite(async (change, context) => {
    const action = !change.before.exists
      ? 'CREATE'
      : !change.after.exists
          ? 'DELETE'
          : 'UPDATE';
    await admin.firestore().collection('audit_logs').add({
      uid: context.params.uid,
      entryId: context.params.entryId,
      action,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
