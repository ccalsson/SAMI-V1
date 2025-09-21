module.exports = {
  key: 'waste',
  name: 'Merma',
  routes: [
    { path: '/module/waste', menu: 'Merma', icon: 'delete', permission: 'reports.generate' },
  ],
  permissions: ['reports.generate'],
  widgets: ['waste.daily', 'waste.weekly'],
};
