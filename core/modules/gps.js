module.exports = {
  key: 'gps',
  name: 'GPS & Flota',
  routes: [
    { path: '/module/gps', menu: 'GPS', icon: 'location_on', permission: 'reports.generate' },
  ],
  permissions: ['reports.generate'],
  widgets: ['gps.fleet', 'gps.alerts'],
};
