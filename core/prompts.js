function buildSystemPrompt(profile, context = {}) {
  if (!profile) {
    throw new Error('Profile metadata is required to build SAMI prompt.');
  }

  const lines = [];
  if (profile.persona_prompt) {
    lines.push(profile.persona_prompt.trim());
  }

  lines.push(
    'Sos SAMI, cerebro central. Priorizá seguridad, cumplimiento y eficiencia. Dirigite con el tono del perfil. Sé preciso y breve. Si faltan datos, pedilos.',
  );

  const contextParts = [];
  if (context.orgName) contextParts.push(`Organización: ${context.orgName}`);
  if (context.site) contextParts.push(`Sitio: ${context.site}`);
  if (context.shift) contextParts.push(`Turno: ${context.shift}`);
  if (contextParts.length) {
    lines.push(`Contexto dinámico: ${contextParts.join(' | ')}`);
  }

  if (Array.isArray(profile.focus) && profile.focus.length) {
    lines.push(`Enfoques prioritarios: ${profile.focus.join(', ')}`);
  }

  return lines.join('\n');
}

module.exports = {
  buildSystemPrompt,
};
