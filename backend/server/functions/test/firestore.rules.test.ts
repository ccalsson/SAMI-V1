import { readFileSync } from 'fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
  RulesTestEnvironment,
} from '@firebase/rules-unit-testing';

const projectId = 'mindcare-test';
let testEnv: RulesTestEnvironment;

function getDb(auth?: { uid: string; token: any }) {
  if (!auth) {
    return testEnv.unauthenticatedContext().firestore();
  }
  return testEnv
    .authenticatedContext(auth.uid, auth.token)
    .firestore();
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync('../../firestore.rules', 'utf8'),
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

describe('Firestore security', () => {
  it('allows owner to read own emotion', async () => {
    const db = getDb({ uid: 'u1', token: { role: 'user' } });
    const ref = db.collection('emotions').doc('u1').collection('entries').doc('e1');
    await assertSucceeds(ref.get());
  });

  it('denies other users', async () => {
    const db = getDb({ uid: 'u1', token: { role: 'user' } });
    const ref = db.collection('emotions').doc('u2').collection('entries').doc('e1');
    await assertFails(ref.get());
  });

  it('allows owner billing access', async () => {
    const db = getDb({ uid: 'u1', token: { role: 'user' } });
    const ref = db.collection('billing').doc('u1').collection('subscriptions').doc('s1');
    await assertSucceeds(ref.get());
  });

  it('denies non-owner billing access', async () => {
    const db = getDb({ uid: 'u2', token: { role: 'user' } });
    const ref = db.collection('billing').doc('u1').collection('subscriptions').doc('s1');
    await assertFails(ref.get());
  });

  it('allows public read of professionals', async () => {
    const db = getDb();
    const ref = db.collection('professionals').doc('p1');
    await assertSucceeds(ref.get());
  });

  it('denies non-admin write to professionals', async () => {
    const db = getDb({ uid: 'u1', token: { role: 'user' } });
    const ref = db.collection('professionals').doc('p1');
    await assertFails(ref.set({ foo: 'bar' }));
  });

  it('allows admin write to professionals', async () => {
    const db = getDb({ uid: 'a1', token: { role: 'admin' } });
    const ref = db.collection('professionals').doc('p1');
    await assertSucceeds(ref.set({ foo: 'bar' }));
  });
});
