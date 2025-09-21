const EventEmitter = require('events');

class VideoManager extends EventEmitter {
  constructor({ cameras = [], visionClient }) {
    super();
    this.cameras = cameras;
    this.visionClient = visionClient;
    this.active = false;
    this.pollers = [];
  }

  async start() {
    if (this.active) return;
    this.active = true;
    for (const camera of this.cameras) {
      const poller = this.#startCameraLoop(camera);
      this.pollers.push(poller);
    }
  }

  async stop() {
    this.active = false;
    for (const poller of this.pollers) {
      clearInterval(poller);
    }
    this.pollers = [];
  }

  #startCameraLoop(camera) {
    const intervalMs = 5000;
    return setInterval(async () => {
      if (!this.active) return;
      try {
        const snapshot = await this.#captureFrame(camera);
        const findings = await this.#analyzeFrame(snapshot, camera);
        if (findings.length) {
          this.emit('detection', { camera, findings, snapshot, ts: Date.now() });
        }
      } catch (error) {
        this.emit('error', { camera, error });
      }
    }, intervalMs);
  }

  async #captureFrame(camera) {
    // Placeholder for RTSP/ONVIF frame capture; integrate with ffmpeg or similar.
    return { cameraId: camera.id, frame: Buffer.alloc(0) };
  }

  async #analyzeFrame(snapshot, camera) {
    if (!this.visionClient) return [];
    try {
      const result = await this.visionClient.analyze(snapshot.frame, { cameraId: camera.id });
      return Array.isArray(result?.findings) ? result.findings : [];
    } catch (error) {
      this.emit('error', { camera, error });
      return [];
    }
  }
}

function createVideoManager(options) {
  return new VideoManager(options);
}

module.exports = { createVideoManager };
