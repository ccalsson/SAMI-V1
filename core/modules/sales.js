module.exports = {
  key: 'sales',
  name: 'Ventas',
  routes: [
    { path: '/module/sales', menu: 'Ventas', icon: 'point_of_sale', permission: 'reports.generate' },
  ],
  permissions: ['reports.generate'],
  widgets: ['sales.hourly', 'sales.ticketAverage'],
};
