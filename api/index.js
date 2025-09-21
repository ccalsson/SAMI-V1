const express = require('express');
const multer = require('multer');
const fs = require('fs');
const os = require('os');
const path = require('path');
const upload = multer({ storage: multer.memoryStorage() });

const { state, applyProfile, askSAMI } = require('../core/brain');
const { getOrgConfig, setActiveProfile, setVoice, loadLocalConfig, listOrganizations, getAuditLogs } = require('../core/org_config');
const { checkScope } = require('../core/roles');
const { buildMenu } = require('../core/menu_runtime');
const { authenticateRequest } = require('./auth');

async function createApiRouter(options = {}) {
  const router = express.Router();
  const config = state.config || (await loadLocalConfig());

  router.use(async (req, res, next) => {
    if (typeof options.authMiddleware === 'function') {
      return options.authMiddleware(req, res, next);
    }
    req.user = await authenticateRequest(req, options.mockUser);
    return next();
  });

  router.get('/orgs/:id/profile', async (req, res) => {
    const orgId = req.params.id;
    const runtime = await getOrgConfig(orgId);
    const activeKey = runtime?.active_profile || Object.keys(config.profiles)[0];
    const profile = config.profiles[activeKey];
    const audit = await getAuditLogs(orgId);
    res.json({
      orgId,
      active_profile: activeKey,
      profile,
      tts_voice: runtime?.tts_voice || profile.tts_voice,
      updated_at: runtime?.updated_at,
      updated_by: runtime?.updated_by,
      audit,
    });
  });

  router.get('/orgs', async (req, res) => {
    const items = await listOrganizations();
    const enriched = await Promise.all(
      items.map(async (org) => {
        const runtime = await getOrgConfig(org.id);
        const profileKey = runtime?.active_profile || Object.keys(config.profiles)[0];
        const profile = config.profiles[profileKey];
        return {
          id: org.id,
          name: org.name,
          active_profile: profileKey,
          tts_voice: runtime?.tts_voice || profile.tts_voice,
          audit: [],
        };
      }),
    );
    res.json(enriched);
  });

  router.put('/orgs/:id/profile', express.json(), async (req, res) => {
    const orgId = req.params.id;
    const { profileKey } = req.body || {};
    if (!checkScope(req.user, 'profiles.manage')) {
      return res.status(403).json({ error: 'forbidden' });
    }
    if (!config.profiles[profileKey]) {
      return res.status(400).json({ error: 'invalid_profile' });
    }
    await setActiveProfile(orgId, profileKey, req.user.id);
    await applyProfile({ orgId, profileKey, user: req.user });
    res.json({ ok: true, profileKey });
  });

  router.put('/orgs/:id/voice', express.json(), async (req, res) => {
    const orgId = req.params.id;
    const { voice } = req.body || {};
    if (!checkScope(req.user, 'voice.manage')) {
      return res.status(403).json({ error: 'forbidden' });
    }
    if (!config.voices.includes(voice)) {
      return res.status(400).json({ error: 'invalid_voice' });
    }
    await setVoice(orgId, voice, req.user.id);
    await applyProfile({ orgId, user: req.user });
    res.json({ ok: true, voice });
  });

  router.get('/orgs/:id/menu', async (req, res) => {
    const orgId = req.params.id;
    const runtime = await getOrgConfig(orgId);
    const profileKey = runtime?.active_profile || Object.keys(config.profiles)[0];
    const profile = config.profiles[profileKey];
    const menu = buildMenu({ user: req.user, profile });
    res.json({ orgId, menu });
  });

  router.post('/chat', express.json(), async (req, res) => {
    const { orgId, text } = req.body || {};
    const role = req.body?.role || req.user?.role;
    if (!role) return res.status(400).json({ error: 'role_required' });
    if (orgId) await applyProfile({ orgId, user: req.user });
    const reply = await askSAMI(role, text, { orgId, userId: req.user.id });
    res.json({ reply });
  });

  router.post('/audio/in', upload.single('audio'), async (req, res) => {
    const { orgId } = req.body || {};
    const role = req.body?.role || req.user?.role;
    if (!role) return res.status(400).json({ error: 'role_required' });
    if (!req.file) return res.status(400).json({ error: 'audio_required' });
    if (orgId) await applyProfile({ orgId, user: req.user });
    let transcript = req.file.originalname || 'audio';
    let tempPath;
    try {
      if (state.audio?.speechToText) {
        tempPath = path.join(os.tmpdir(), `${Date.now()}-${req.file.originalname || 'audio.wav'}`);
        fs.writeFileSync(tempPath, req.file.buffer);
        transcript = await state.audio.speechToText(tempPath);
      }
    } catch (error) {
      console.warn('[SAMI API] STT falló', error.message);
    } finally {
      if (tempPath && fs.existsSync(tempPath)) {
        fs.unlinkSync(tempPath);
      }
    }

    const response = await askSAMI(role, transcript, { orgId, audio: true, userId: req.user.id });
    let audioBase64;
    if (response && response.speech) {
      audioBase64 = Buffer.isBuffer(response.speech)
        ? response.speech.toString('base64')
        : Buffer.from(response.speech).toString('base64');
    }
    res.json({ transcript, response, audio: audioBase64 });
  });

  return router;
}

module.exports = {
  createApiRouter,
};
