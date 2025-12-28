# Base image with pnpm pre-installed
FROM node:20-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
WORKDIR /app
# Install pnpm 9 (required for lockfileVersion 6.0)
RUN npm install -g pnpm@9
# Configure npm registry to use taobao mirror (for better network in China)
RUN pnpm config set registry https://registry.npmmirror.com

# Production dependencies stage
FROM base AS prod-deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
# Increase timeout and retry settings for network issues
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm config set fetch-timeout 600000 && \
    pnpm config set fetch-retries 5 && \
    pnpm install --prod --frozen-lockfile --ignore-scripts

# Build stage
FROM base AS build
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
# Increase timeout and retry settings for network issues
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm config set fetch-timeout 600000 && \
    pnpm config set fetch-retries 5 && \
    pnpm install --frozen-lockfile
COPY . . 
# Skip Cloudflare dev mode initialization during Docker build
ENV SKIP_CLOUDFLARE_DEV=1
ENV NODE_ENV=production
RUN pnpm run build

# Final image (minimal size)
FROM base AS final
WORKDIR /app

# Copy only the necessary files from previous stages
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/.next ./.next
COPY package.json pnpm-lock.yaml ./
COPY public ./public
# Copy next.config.mjs (required for basePath and other runtime configs)
COPY --from=build /app/next.config.mjs ./next.config.mjs

EXPOSE 3000

# Set the entry point for production
CMD [ "pnpm", "start" ]
