const ROLE_SCOPES = {
  superuser: [
    'profiles.manage',
    'org.manage',
    'modules.publish',
    'audit.read_all',
    'billing.manage',
    'voice.manage',
  ],
  owner: [
    'org.config',
    'users.manage',
    'integrations.approve',
    'exports.all',
  ],
  admin: [
    'cams.manage',
    'ml.rules.manage',
    'alerts.manage',
    'inventory.manage',
    'reports.generate',
  ],
  supervisor: [
    'alerts.close',
    'shifts.manage',
    'tools.approve',
    'fuel.approve',
  ],
  operario: [
    'tasks.view',
    'tools.checkout',
    'fuel.request',
  ],
};

function getRoleScopes(role) {
  return ROLE_SCOPES[role] || [];
}

function checkScope(user, scope) {
  if (!user) return false;
  if (Array.isArray(user.scopes) && user.scopes.includes(scope)) return true;
  if (user.role && getRoleScopes(user.role).includes(scope)) return true;
  return false;
}

module.exports = {
  ROLE_SCOPES,
  getRoleScopes,
  checkScope,
};
