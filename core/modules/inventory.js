module.exports = {
  key: 'inventory',
  name: 'Inventario',
  routes: [
    { path: '/module/inventory', menu: 'Inventario', icon: 'inventory', permission: 'inventory.manage' },
  ],
  permissions: ['inventory.manage'],
  widgets: ['inventory.turnover', 'inventory.stockouts'],
};
