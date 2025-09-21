class InteractionRouter {
  constructor({ routingRules, audioManager, chatHandler, promptBuilder }) {
    this.routingRules = routingRules || {};
    this.audioManager = audioManager;
    this.chatHandler = chatHandler;
    this.promptBuilder = promptBuilder;
    this.profile = null;
    this.orgContext = null;
  }

  setProfile(profile, context) {
    this.profile = profile;
    this.orgContext = context;
  }

  async handle({ role, input, meta }) {
    const mode = this.routingRules[role] || 'chat';
    if (mode === 'audio') {
      if (typeof input === 'string') {
        const speech = await this.audioManager.textToSpeech(input);
        return { mode, speech };
      }
      return { mode, message: 'Audio mode requires text response.' };
    }
    if (!this.chatHandler) throw new Error('Chat handler not configured');
    const prompt = this.promptBuilder ? this.promptBuilder(this.profile, this.orgContext) : null;
    const reply = await this.chatHandler(input, { role, profile: this.profile, prompt, meta });
    return { mode, reply };
  }
}

function createInteractionRouter(options) {
  return new InteractionRouter(options);
}

module.exports = { createInteractionRouter };
