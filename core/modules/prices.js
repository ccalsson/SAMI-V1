module.exports = {
  key: 'prices',
  name: 'Precios',
  routes: [
    { path: '/module/prices', menu: 'Precios', icon: 'attach_money', permission: 'reports.generate' },
  ],
  permissions: ['reports.generate'],
  widgets: ['prices.margins'],
};
