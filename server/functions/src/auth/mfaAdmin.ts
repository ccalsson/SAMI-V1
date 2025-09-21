import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const mfaAdmin = functions.auth.user().afterCreate(async (user) => {
  const role = user.customClaims?.role;
  if (role === 'admin' || role === 'pro') {
    // TODO: notify user to enroll MFA
    console.log(`User ${user.uid} requires MFA enrollment`);
  }
});
