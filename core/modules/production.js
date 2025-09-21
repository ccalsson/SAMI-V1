module.exports = {
  key: 'production',
  name: 'Producción',
  routes: [
    { path: '/module/production', menu: 'Producción', icon: 'factory', permission: 'reports.generate' },
  ],
  permissions: ['reports.generate'],
  widgets: ['production.oee', 'production.output'],
};
