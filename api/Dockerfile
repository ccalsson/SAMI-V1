FROM node:20-alpine
WORKDIR /app
COPY api/package*.json ./
RUN npm install --omit=dev
COPY core ./core
COPY config ./config
COPY api ./api
ENV PORT=3333
CMD ["node", "api/server.js"]
