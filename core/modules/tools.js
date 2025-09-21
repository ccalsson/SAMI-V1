module.exports = {
  key: 'tools',
  name: 'Herramientas',
  routes: [
    { path: '/module/tools', menu: 'Herramientas', icon: 'build', permission: 'tools.approve' },
  ],
  permissions: ['tools.approve', 'tools.checkout'],
  widgets: ['tools.checkout', 'tools.return'],
};
