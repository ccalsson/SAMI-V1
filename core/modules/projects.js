module.exports = {
  key: 'projects',
  name: 'Proyectos',
  routes: [
    { path: '/module/projects', menu: 'Proyectos', icon: 'business_center', permission: 'reports.generate' },
  ],
  permissions: ['reports.generate'],
  widgets: ['projects.progress', 'projects.costs'],
};
