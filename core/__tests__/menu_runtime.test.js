const test = require('node:test');
const assert = require('node:assert/strict');
const { buildMenu } = require('../menu_runtime');

test('buildMenu incluye base menu y módulos habilitados', () => {
  const menu = buildMenu({
    user: { role: 'admin', scopes: ['alerts.manage', 'reports.generate'] },
    profile: { modules: ['production', 'sales'] },
  });
  const paths = menu.map((item) => item.path);
  assert.ok(paths.includes('/dashboard'));
  assert.ok(paths.includes('/module/production'));
  assert.ok(paths.includes('/module/sales'));
});

