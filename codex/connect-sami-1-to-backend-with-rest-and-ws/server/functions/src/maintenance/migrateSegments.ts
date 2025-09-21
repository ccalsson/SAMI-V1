import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const migrateSegments = functions.pubsub
  .topic('migrate-segments')
  .onPublish(async () => {
    const users = await admin.firestore().collection('users').get();
    for (const doc of users.docs) {
      // TODO: migrate user documents to new structure
      console.log('Migrating', doc.id);
    }
  });
