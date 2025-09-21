const { readFile } = require('fs/promises');
const { join } = require('path');
let admin;
try {
  admin = require('firebase-admin');
} catch (_) {
  admin = null;
}

let firebaseApp;

async function ensureFirebase() {
  if (!admin) return null;
  if (!firebaseApp) {
    if (admin.apps.length) {
      firebaseApp = admin.apps[0];
    } else {
      const projectId = process.env.FIREBASE_PROJECT_ID;
      if (!projectId) {
        console.warn('[SAMI] FIREBASE_PROJECT_ID not set; running without Firestore');
        return null;
      }
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT;
      if (serviceAccountPath) {
        try {
          const serviceAccount = require(serviceAccountPath);
          firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: serviceAccount.project_id || projectId,
          });
        } catch (error) {
          console.warn('[SAMI] Failed to load service account', error.message);
          firebaseApp = admin.initializeApp({ projectId });
        }
      } else {
        try {
          firebaseApp = admin.initializeApp({
            projectId,
            credential: admin.credential.applicationDefault(),
          });
        } catch (error) {
          console.warn('[SAMI] applicationDefault credential not available, using projectId only');
          firebaseApp = admin.initializeApp({ projectId });
        }
      }
    }
  }
  return firebaseApp.firestore();
}

async function getOrgConfig(orgId) {
  if (!orgId) return null;
  const firestore = await ensureFirebase();
  if (!firestore) return null;
  const doc = await firestore.doc(`organizations/${orgId}/config/runtime`).get();
  return doc.exists ? doc.data() : null;
}

async function getAuditLogs(orgId, limit = 10) {
  const firestore = await ensureFirebase();
  if (!firestore) return [];
  const snapshot = await firestore
    .collection(`organizations/${orgId}/audit_logs`)
    .orderBy('ts', 'desc')
    .limit(limit)
    .get();
  return snapshot.docs.map((doc) => doc.data());
}

async function listOrganizations() {
  const firestore = await ensureFirebase();
  if (!firestore) return [];
  const snapshot = await firestore.collection('organizations').get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...(doc.data() || {}) }));
}

async function setActiveProfile(orgId, profileKey, actor) {
  const firestore = await ensureFirebase();
  if (!firestore) throw new Error('Firestore not available');
  const ref = firestore.doc(`organizations/${orgId}/config/runtime`);
  await ref.set({ active_profile: profileKey, updated_at: Date.now(), updated_by: actor }, { merge: true });
  await writeAuditLog(firestore, orgId, {
    actor,
    action: 'profile.update',
    resource: `organizations/${orgId}`,
    diff: { profileKey },
    ts: Date.now(),
  });
}

async function setVoice(orgId, voice, actor) {
  const firestore = await ensureFirebase();
  if (!firestore) throw new Error('Firestore not available');
  const ref = firestore.doc(`organizations/${orgId}/config/runtime`);
  await ref.set({ tts_voice: voice, updated_at: Date.now(), updated_by: actor }, { merge: true });
  await writeAuditLog(firestore, orgId, {
    actor,
    action: 'voice.update',
    resource: `organizations/${orgId}`,
    diff: { voice },
    ts: Date.now(),
  });
}

async function writeAuditLog(firestore, orgId, payload) {
  try {
    await firestore.collection(`organizations/${orgId}/audit_logs`).add(payload);
  } catch (error) {
    console.warn('[SAMI] Failed to write audit log', error.message);
  }
}

async function loadLocalConfig(path = join(process.cwd(), 'config', 'sami.json')) {
  const buffer = await readFile(path, 'utf8');
  return JSON.parse(buffer);
}

module.exports = {
  ensureFirebase,
  getOrgConfig,
  setActiveProfile,
  setVoice,
  loadLocalConfig,
  listOrganizations,
  getAuditLogs,
};
