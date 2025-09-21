const test = require('node:test');
const assert = require('node:assert/strict');
const { buildSystemPrompt } = require('../prompts');

test('buildSystemPrompt compone persona y reglas generales', () => {
  const profile = {
    persona_prompt: 'Perfil demo',
    focus: ['seguridad', 'producción'],
  };
  const prompt = buildSystemPrompt(profile, { orgName: 'Org Demo', shift: 'Noche' });
  assert.match(prompt, /Perfil demo/);
  assert.match(prompt, /Sos SAMI/);
  assert.match(prompt, /Organización: Org Demo/);
  assert.match(prompt, /Enfoques prioritarios: seguridad, producción/);
});
