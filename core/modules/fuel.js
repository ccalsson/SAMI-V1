module.exports = {
  key: 'fuel',
  name: 'Combustible',
  routes: [
    { path: '/module/fuel', menu: 'Combustible', icon: 'local_gas_station', permission: 'fuel.approve' },
  ],
  permissions: ['fuel.approve', 'fuel.request'],
  widgets: ['fuel.dispense', 'fuel.overtime'],
};
