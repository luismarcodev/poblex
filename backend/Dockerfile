FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY prisma ./prisma
COPY tsconfig.json tsconfig.build.json nest-cli.json ./
COPY src ./src
RUN npx prisma generate
RUN npm run build

FROM node:22-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app ./

EXPOSE 3000
CMD ["sh", "-c", "npm run db:migrate && node dist/main.js"]
