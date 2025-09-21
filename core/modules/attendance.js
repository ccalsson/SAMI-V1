module.exports = {
  key: 'attendance',
  name: 'Asistencia',
  routes: [
    { path: '/module/attendance', menu: 'Asistencia', icon: 'badge', permission: 'shifts.manage' },
  ],
  permissions: ['shifts.manage'],
  widgets: ['attendance.present', 'attendance.absences'],
};
