const { ensureFirebase } = require('../core/org_config');
const { getRoleScopes } = require('../core/roles');

async function authenticateRequest(req, fallbackUser) {
  const firestore = await ensureFirebase();
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

  if (!token) {
    return fallbackUser || { id: 'local-superuser', role: 'superuser', scopes: getRoleScopes('superuser') };
  }

  try {
    const decoded = await require('firebase-admin').auth().verifyIdToken(token);
    const userId = decoded.uid;
    const role = decoded.role || 'viewer';
    const scopes = decoded.scopes || getRoleScopes(role);
    const orgId = decoded.orgId;
    let membership = null;
    if (firestore && orgId) {
      const doc = await firestore.collection('memberships').doc(`${userId}-${orgId}`).get();
      membership = doc.exists ? doc.data() : null;
    }
    return {
      id: userId,
      role: membership?.role || role,
      scopes: membership?.scopes || scopes,
      orgId: membership?.orgId || orgId,
    };
  } catch (error) {
    console.warn('[SAMI API] Token inválido', error.message);
    return { id: 'anonymous', role: 'viewer', scopes: [] };
  }
}

module.exports = {
  authenticateRequest,
};
