const { writeFile } = require('fs/promises');
const { join } = require('path');

class ReportsManager {
  constructor({ outputDir = 'logs', profile } = {}) {
    this.outputDir = outputDir;
    this.events = [];
    this.profile = profile;
  }

  record(event) {
    this.events.push(event);
  }

  setProfile(profile) {
    this.profile = profile;
  }

  async generateSnapshot() {
    const snapshot = {
      generatedAt: new Date().toISOString(),
      events: this.events.slice(-100),
      totals: this.#countByType(),
      kpis: this.profile?.reports || [],
    };
    const file = join(this.outputDir, `report-${Date.now()}.json`);
    await writeFile(file, JSON.stringify(snapshot, null, 2));
    return { file, snapshot };
  }

  #countByType() {
    return this.events.reduce((acc, event) => {
      const key = event.type || 'unknown';
      acc[key] = (acc[key] || 0) + 1;
      return acc;
    }, {});
  }
}

function createReportsManager(options) {
  return new ReportsManager(options);
}

module.exports = { createReportsManager };
