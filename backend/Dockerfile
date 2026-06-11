# Backend-Image für lokale Entwicklung / docker-compose.
# Multi-Stage: schlanke Runtime, Build-Artefakte aus der Build-Stage.

# ── Build-Stage ──────────────────────────────────────────────────────────────
FROM node:20-slim AS build
WORKDIR /app
# OpenSSL wird von Prisma benötigt.
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

COPY prisma ./prisma
RUN npx prisma generate

COPY tsconfig*.json ./
COPY src ./src
COPY assets ./assets
RUN npm run build

# ── Runtime-Stage ────────────────────────────────────────────────────────────
FROM node:20-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
# prisma (CLI) bleibt dabei, damit `migrate deploy` zur Laufzeit läuft.
RUN npm ci --omit=dev && npm install prisma@5.22.0 --no-save

COPY prisma ./prisma
RUN npx prisma generate

COPY --from=build /app/dist ./dist
COPY assets ./assets

EXPOSE 3000

# Liveness-Probe ohne zusätzliche Tools (node ist im Image vorhanden).
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://127.0.0.1:'+(process.env.PORT||3000)+'/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

# Bei Start: ausstehende Migrationen anwenden, dann API starten.
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main.js"]
