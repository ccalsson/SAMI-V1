const modules = [
  require('./production'),
  require('./safety'),
  require('./tools'),
  require('./fuel'),
  require('./sales'),
  require('./inventory'),
  require('./prices'),
  require('./waste'),
  require('./gps'),
  require('./attendance'),
  require('./projects'),
];

const registry = new Map(modules.map((module) => [module.key, module]));

function getModule(key) {
  return registry.get(key);
}

function listModules() {
  return Array.from(registry.values());
}

module.exports = {
  registry,
  getModule,
  listModules,
};
