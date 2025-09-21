const { BASE_MENU } = require('./menu_registry');
const { getModule } = require('./modules/registry');
const { checkScope } = require('./roles');

function buildMenu({ user, profile, overrides } = {}) {
  const items = [];
  for (const item of BASE_MENU) {
    if (!item.scope || checkScope(user, item.scope)) {
      items.push({ ...item, source: 'base' });
    }
  }

  if (profile?.modules) {
    for (const moduleKey of profile.modules) {
      const module = getModule(moduleKey);
      if (!module) continue;
      for (const route of module.routes) {
        if (!route.permission || checkScope(user, route.permission)) {
          items.push({
            key: `${moduleKey}:${route.path}`,
            label: route.menu,
            icon: route.icon,
            path: route.path,
            source: `module:${moduleKey}`,
          });
        }
      }
    }
  }

  if (Array.isArray(overrides?.extraItems)) {
    items.push(...overrides.extraItems);
  }

  const unique = new Map();
  for (const item of items) {
    if (!unique.has(item.path)) {
      unique.set(item.path, item);
    }
  }

  return Array.from(unique.values());
}

module.exports = {
  buildMenu,
};
