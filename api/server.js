const express = require('express');
const cors = require('cors');
const { createApiRouter } = require('./index');
const { startBrain } = require('../core/brain');

async function start() {
  await startBrain({});
  const app = express();
  app.use(cors());
  app.use('/api', await createApiRouter());
  const port = process.env.PORT || 3333;
  app.listen(port, () => console.log(`SAMI API listening on http://localhost:${port}/api`));
}

start().catch((error) => {
  console.error('Failed to start API', error);
  process.exit(1);
});
