#!/usr/bin/env node
/*
 * SAMI seed script
 * Creates demo organizations, users, and devices in Firestore (or logs instructions in offline mode).
 */
const { setActiveProfile, setVoice, ensureFirebase } = require('../core/org_config');
const { getRoleScopes } = require('../core/roles');

const DEMO_DATA = {
  organizations: [
    {
      id: 'org-sawmill',
      name: 'Aserradero Demo',
      profile: 'industry.sawmill',
      voice: 'alloy',
    },
    {
      id: 'org-grocery',
      name: 'Verdulería Demo',
      profile: 'retail.grocery',
      voice: 'verse',
    },
  ],
  users: [
    { id: 'superuser', role: 'superuser', org: 'global', email: 'superuser@sami.local' },
    { id: 'owner-sawmill', role: 'owner', org: 'org-sawmill', email: 'owner.sawmill@sami.local' },
    { id: 'admin-sawmill', role: 'admin', org: 'org-sawmill', email: 'admin.sawmill@sami.local' },
    { id: 'supervisor-sawmill', role: 'supervisor', org: 'org-sawmill', email: 'supervisor.sawmill@sami.local' },
    { id: 'operario-sawmill', role: 'operario', org: 'org-sawmill', email: 'operario.sawmill@sami.local' },
    { id: 'owner-grocery', role: 'owner', org: 'org-grocery', email: 'owner.grocery@sami.local' },
  ],
  devices: {
    'org-sawmill': {
      cameras: [
        { id: 'sawmill-cam-1', rtsp: 'rtsp://demo-sawmill-cam-1' },
        { id: 'sawmill-cam-2', rtsp: 'rtsp://demo-sawmill-cam-2' },
      ],
      microphones: [{ id: 'sawmill-mic-1', device: '/dev/audio-sawmill' }],
    },
    'org-grocery': {
      cameras: [
        { id: 'grocery-cam-1', rtsp: 'rtsp://demo-grocery-cam-1' },
        { id: 'grocery-cam-2', rtsp: 'rtsp://demo-grocery-cam-2' },
      ],
      microphones: [{ id: 'grocery-mic-1', device: '/dev/audio-grocery' }],
    },
  },
};

async function main() {
  const firestore = await ensureFirebase();
  if (!firestore) {
    console.warn('Firestore no configurado. Mostraré los datos que deberías cargar:');
    console.log(JSON.stringify(DEMO_DATA, null, 2));
    return;
  }

  for (const org of DEMO_DATA.organizations) {
    const ref = firestore.doc(`organizations/${org.id}`);
    await ref.set({ name: org.name, created_at: Date.now() }, { merge: true });
    await setActiveProfile(org.id, org.profile, 'seed.script');
    await setVoice(org.id, org.voice, 'seed.script');
    const configRef = firestore.doc(`organizations/${org.id}/config/runtime`);
    await configRef.set(
      {
        cameras: DEMO_DATA.devices[org.id]?.cameras ?? [],
        microphones: DEMO_DATA.devices[org.id]?.microphones ?? [],
      },
      { merge: true },
    );
  }

  for (const user of DEMO_DATA.users) {
    const ref = firestore.doc(`users/${user.id}`);
    await ref.set({ role: user.role, email: user.email, org: user.org }, { merge: true });
    const membershipRef = firestore.collection('memberships').doc(`${user.id}-${user.org}`);
    await membershipRef.set(
      {
        userId: user.id,
        orgId: user.org,
        role: user.role,
        scopes: getRoleScopes(user.role),
      },
      { merge: true },
    );
  }

  console.log('Seed completado. Organizaciones y perfiles configurados.');
  console.log('\nAccesos demo:');
  console.log('  SuperUser  -> superuser@sami.local / contraseña: Demo1234');
  console.log('  Owner      -> owner.sawmill@sami.local / contraseña: Demo1234');
  console.log('  Admin      -> admin.sawmill@sami.local / contraseña: Demo1234');
  console.log('\nUI local:');
  console.log('  SuperUser Console -> http://localhost:3000/#/superuser/profiles');
  console.log('  Dashboard         -> http://localhost:3000/#/dashboard');
}

main().catch((error) => {
  console.error('Seed falló:', error);
  process.exit(1);
});
