# Base image with pre-installed build tools
FROM node:18-bullseye AS base
WORKDIR /app
COPY package.json yarn.lock ./
# Copy only package.json and yarn.lock
EXPOSE 3000

# Builder image for compiling the application
FROM base AS builder
WORKDIR /app
COPY . .
# Copy the rest of the project files
RUN yarn install --prefer-offline
RUN yarn build

# Debug: Check if yarn install worked
RUN ls -al /app/node_modules  

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

# Debug: Check the /app directory in the production image
RUN ls -al /app

CMD ["yarn", "start"]
