const test = require('node:test');
const assert = require('node:assert/strict');
const { checkScope } = require('../roles');

test('checkScope true for user scope', () => {
  const user = { role: 'admin', scopes: ['alerts.manage'] };
  assert.equal(checkScope(user, 'alerts.manage'), true);
});

test('checkScope true for role scope', () => {
  const user = { role: 'admin', scopes: [] };
  assert.equal(checkScope(user, 'reports.generate'), true);
});

test('checkScope false when not granted', () => {
  const user = { role: 'operario', scopes: [] };
  assert.equal(checkScope(user, 'reports.generate'), false);
});
