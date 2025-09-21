const { join } = require('path');
const EventEmitter = require('events');
let OpenAI;
try {
  OpenAI = require('openai');
} catch (_) {
  OpenAI = null;
}

const { createVideoManager } = require('./video');
const { createAudioManager } = require('./audio');
const { createInteractionRouter } = require('./interaction');
const { createReportsManager } = require('./reports');
const { buildSystemPrompt } = require('./prompts');
const { buildMenu } = require('./menu_runtime');
const { loadLocalConfig, getOrgConfig } = require('./org_config');

const DEFAULT_CONFIG = join(process.cwd(), 'config', 'sami.json');
const state = {
  started: false,
  config: null,
  video: null,
  audio: null,
  interaction: null,
  reports: null,
  emitter: new EventEmitter(),
  profile: null,
  profileKey: null,
  menu: [],
};

async function loadConfig(configPath = DEFAULT_CONFIG) {
  return loadLocalConfig(configPath);
}

function buildOpenAIClient(config) {
  if (!OpenAI) return null;
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    console.warn('[SAMI] OPENAI_API_KEY not set; running in offline mode');
    return null;
  }
  const client = new OpenAI({ apiKey });
  client.ttsModel = config.tts_model;
  client.voice = config.voice;
  client.analyze = async (input, meta) => {
    const response = await client.responses.create({
      model: config.model,
      input: [
        { role: 'system', content: 'Analiza la escena y reporta hallazgos relevantes para seguridad industrial.' },
        { role: 'user', content: `Escena desde ${meta?.cameraId ?? 'cámara'}: ${input.length} bytes capturados.` },
      ],
    });
    const findings = response.output_text ? [{ type: 'summary', detail: response.output_text }] : [];
    return { findings };
  };
  return client;
}

async function startBrain(options = {}) {
  if (state.started) return state;
  state.config = await loadConfig(options.configPath);
  const openai = buildOpenAIClient(state.config);

  const defaults = state.config.defaults || {};
  const microphones = state.config.microphones || defaults.microphones || [];
  const cameras = state.config.cameras || defaults.cameras || [];

  state.audio = createAudioManager({ microphones, openai });
  state.video = createVideoManager({ cameras, visionClient: openai });
  state.reports = createReportsManager({ outputDir: 'logs' });
  state.interaction = createInteractionRouter({
    routingRules: state.config.routing_rules,
    audioManager: state.audio,
    chatHandler: (input, ctx) => handleChat(input, ctx, openai),
    promptBuilder: (profile, context) => buildSystemPrompt(profile, context),
  });

  attachSensors(state.config.sensors || []);

  await applyProfile({ orgId: options.orgId, profileKey: options.profileKey, user: options.user });

  state.video.on('detection', (event) => handleDetection(event));
  state.video.on('error', (payload) => logEvent('video_error', payload));
  state.audio.on('audio', (payload) => handleAudio(payload));
  state.audio.on('stt', (payload) => logEvent('transcription', payload));
  state.audio.on('tts', (payload) => logEvent('tts', payload));

  await state.audio.start();
  await state.video.start();
  state.started = true;
  logEvent('sami_started', { ts: Date.now() });
  return state;
}

async function askSAMI(userRole, input, meta = {}) {
  if (!state.started) throw new Error('SAMI is not running. Call startBrain() first.');
  const response = await state.interaction.handle({ role: userRole, input, meta });
  logEvent('interaction', { role: userRole, input, response });
  return response;
}

async function broadcastMessage(message, voice) {
  if (!state.started) throw new Error('SAMI is not running.');
  const selectedVoice = voice || state.audio.voiceOverride || state.profile?.tts_voice || state.config.voice;
  const audio = await state.audio.textToSpeech(message, selectedVoice);
  logEvent('broadcast', { message, voice: selectedVoice });
  state.emitter.emit('broadcast', { message, audio });
  return audio;
}

async function handleChat(input, ctx, openai) {
  const prompt = ctx?.prompt || 'Sos SAMI, cerebro central.';
  const userContent = typeof input === 'string' ? input : JSON.stringify(input);
  if (!openai) {
    return `SAMI (offline): ${userContent}`;
  }
  const response = await openai.responses.create({
    model: state.config.model,
    input: [
      { role: 'system', content: prompt },
      { role: 'user', content: userContent },
    ],
  });
  return response.output_text;
}

function handleDetection(event) {
  logEvent('detection', event);
  const alert = {
    type: 'vision_alert',
    camera: event.camera.id,
    detail: event.findings,
    ts: event.ts,
  };
  state.reports.record(alert);
  state.emitter.emit('alert', alert);
}

function handleAudio(payload) {
  logEvent('audio_capture', payload);
  // Placeholder: integrate voice activity detection and STT triggers.
}

function logEvent(type, payload) {
  const entry = { type, payload, timestamp: new Date().toISOString() };
  state.reports.record(entry);
  state.emitter.emit('event', entry);
}

function attachSensors(sensors) {
  if (!Array.isArray(sensors) || !sensors.length) return;
  for (const sensor of sensors) {
    logEvent('sensor_attached', sensor);
  }
}

async function applyProfile({ orgId, profileKey, user }) {
  if (!state.config) throw new Error('Config not loaded');
  const runtimeConfig = orgId ? await getOrgConfig(orgId) : null;
  const selectedKey = runtimeConfig?.active_profile || profileKey || Object.keys(state.config.profiles)[0];
  const profile = state.config.profiles[selectedKey];
  if (!profile) {
    throw new Error(`Profile ${selectedKey} not defined`);
  }
  const context = {
    orgId,
    orgName: runtimeConfig?.orgName,
    site: runtimeConfig?.site,
    shift: runtimeConfig?.shift,
  };
  state.profile = profile;
  state.profileKey = selectedKey;
  state.interaction.setProfile(profile, context);
  state.reports.setProfile(profile);
  const voice = runtimeConfig?.tts_voice || profile.tts_voice;
  state.audio.setVoice(voice);
  const menuUser = user || runtimeConfig?.user || { role: 'superuser', scopes: [] };
  state.menu = buildMenu({ user: menuUser, profile });
  logEvent('profile_applied', { orgId, profileKey: selectedKey, voice, actor: menuUser.id });
  return { profile, voice, context };
}

module.exports = {
  startBrain,
  askSAMI,
  broadcastMessage,
  loadConfig,
  applyProfile,
  state,
};
