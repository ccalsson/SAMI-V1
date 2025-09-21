const BASE_MENU = [
  { key: 'dashboard', label: 'Dashboard', icon: 'dashboard', path: '/dashboard', scope: null },
  { key: 'cameras', label: 'Cámaras', icon: 'videocam', path: '/cameras', scope: 'cams.manage' },
  { key: 'devices', label: 'Dispositivos', icon: 'sensors', path: '/devices', scope: 'org.config' },
  { key: 'ai_rules', label: 'Reglas IA', icon: 'psychology', path: '/ai-rules', scope: 'ml.rules.manage' },
  { key: 'alerts', label: 'Alertas', icon: 'warning', path: '/alerts', scope: 'alerts.manage' },
  { key: 'reports', label: 'Reportes', icon: 'analytics', path: '/reports', scope: 'reports.generate' },
  { key: 'integrations', label: 'Integraciones', icon: 'hub', path: '/integrations', scope: 'integrations.approve' },
  { key: 'users', label: 'Usuarios', icon: 'group', path: '/users', scope: 'users.manage' },
];

module.exports = {
  BASE_MENU,
};
