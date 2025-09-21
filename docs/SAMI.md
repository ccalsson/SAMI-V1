# Módulo SAMI (IA Central)

El módulo SAMI coordina cámaras, micrófonos y sensores para generar alertas inteligentes en tiempo real.

## Estructura

```
config/sami.json          # Configuración principal
core/brain.js             # Punto de entrada y orquestación
core/video.js             # Ingesta y análisis de video
core/audio.js             # Audio, STT y TTS
core/interaction.js       # Enrutamiento por rol (chat/audio)
core/reports.js           # Persistencia de eventos y reportes
logs/                     # Salida de reportes y bitácoras
```

## Uso rápido

```js
const { startBrain, askSAMI, broadcastMessage } = require('./core/brain');

(async () => {
  await startBrain();
  const adminReply = await askSAMI('admin', 'Genera un resumen del turno nocturno.');
  console.log(adminReply.reply);
  await broadcastMessage('Atención, se inicia simulacro de evacuación.', 'sage');
})();
```

- `startBrain()` lee `config/sami.json`, conecta cámaras RTSP, micrófonos y sensores.
- `askSAMI(rol, input)` enrutará la consulta a chat o respuesta por audio según `routing_rules`.
- `broadcastMessage(texto, voz)` sintetiza y emite un mensaje de voz en todos los parlantes.

El módulo puede operar en modo offline si no se define `OPENAI_API_KEY`; en ese caso se generan respuestas de texto simuladas y buffers de audio placeholder.
