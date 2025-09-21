const EventEmitter = require('events');
const { createReadStream } = require('fs');

class AudioManager extends EventEmitter {
  constructor({ microphones = [], openai }) {
    super();
    this.microphones = microphones;
    this.openai = openai;
    this.recorders = [];
    this.voiceOverride = null;
  }

  async start() {
    for (const mic of this.microphones) {
      const recorder = this.#createRecorder(mic);
      this.recorders.push(recorder);
    }
  }

  async stop() {
    for (const dispose of this.recorders) {
      if (typeof dispose === 'function') dispose();
    }
    this.recorders = [];
  }

  async textToSpeech(text, voice) {
    const selectedVoice = voice || this.voiceOverride || this.openai?.voice || 'alloy';
    if (!this.openai) {
      const fallback = Buffer.from(text, 'utf8');
      this.emit('tts', { text, voice: selectedVoice, audio: fallback, offline: true });
      return fallback;
    }
    const response = await this.openai.audio.speech.create({
      model: this.openai.ttsModel,
      voice: selectedVoice,
      input: text,
      format: 'mp3',
    });
    this.emit('tts', { text, voice: selectedVoice, audio: response.data });
    return response.data;
  }

  async speechToText(filePath) {
    if (!this.openai) {
      const text = `Audio recibido (${filePath})`;
      this.emit('stt', { filePath, text, offline: true });
      return text;
    }
    const response = await this.openai.audio.transcriptions.create({
      file: createReadStream(filePath),
      model: 'gpt-4o-mini-transcribe',
    });
    this.emit('stt', { filePath, text: response.text });
    return response.text;
  }

  #createRecorder(mic) {
    // Placeholder for streaming audio capture
    const interval = setInterval(async () => {
      this.emit('audio', { mic, buffer: Buffer.alloc(0), ts: Date.now() });
    }, 7000);
    return () => clearInterval(interval);
  }

  setVoice(voice) {
    this.voiceOverride = voice;
    this.emit('voice', { voice });
  }
}

function createAudioManager(options) {
  return new AudioManager(options);
}

module.exports = { createAudioManager };
