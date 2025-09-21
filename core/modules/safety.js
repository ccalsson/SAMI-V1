module.exports = {
  key: 'safety',
  name: 'Seguridad',
  routes: [
    { path: '/module/safety', menu: 'Seguridad', icon: 'shield', permission: 'alerts.manage' },
  ],
  permissions: ['alerts.manage'],
  widgets: ['safety.incidents', 'safety.ppe'],
};
