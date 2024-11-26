# Base image with pre-installed build tools
FROM node:18-bullseye AS base
WORKDIR /app
COPY package.json ./
EXPOSE 3000

# Builder image for compiling the application
FROM base AS builder
WORKDIR /app
COPY . .
RUN npm install --legacy-peer-deps
RUN npm run build

# Production image
FROM node:18-slim AS production
WORKDIR /app
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
ENV NODE_ENV=production

RUN addgroup --gid 1001 nodejs
RUN adduser --uid 1001 --ingroup nodejs --disabled-password nextjs
USER nextjs

CMD ["npm", "start"]

# Development image
# FROM base AS dev
# WORKDIR /app
# ENV NODE_ENV=development
# RUN npm install --legacy-peer-deps
# COPY . .
# CMD ["npm", "run", "dev"]
