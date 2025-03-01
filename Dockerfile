# Installing dependencies:
FROM node:22-alpine AS install-dependencies

WORKDIR /user/src/app

# Enable corepack for pnpm and copy lockfile
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm.lock ./

RUN pnpm install --frozen-lockfile --prod

COPY . .

# Creating a build:
FROM node:22-alpine  AS create-build

WORKDIR /user/src/app

# Enable corepack for pnpm again in this stage
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY --from=install-dependencies /user/src/app ./

RUN pnpm run build
USER node

# Running the application:
FROM node:22-alpine AS run

WORKDIR /user/src/app

# Enable corepack for pnpm in final stage
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY --from=install-dependencies /user/src/app/node_modules ./node_modules
COPY --from=create-build /user/src/app/dist ./dist
COPY package.json ./

CMD ["pnpm", "run", "start:prod"]