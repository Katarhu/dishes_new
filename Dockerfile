FROM node:20.1-alpine AS builder

RUN apk add --update --no-cache openssl1.1-compat

#
ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}

# Create app directory
WORKDIR /app

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./
COPY prisma ./prisma/

# Install app dependencies
RUN npm install


COPY . .

RUN npx prisma generate --schema=/app/prisma/schema.prisma

RUN npx prisma migrate deploy

RUN npm run build

FROM node:20.1-alpine

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist

EXPOSE 8080
CMD [ "npm", "run", "start:prod" ]