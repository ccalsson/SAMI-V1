const test = require('node:test');
const assert = require('node:assert/strict');
const { createAudioManager } = require('../audio');

test('textToSpeech fallback when openai missing', async () => {
  const audio = createAudioManager({ microphones: [], openai: null });
  const buffer = await audio.textToSpeech('Hola', 'alloy');
  assert.ok(Buffer.isBuffer(buffer));
  assert.equal(buffer.toString(), 'Hola');
});
