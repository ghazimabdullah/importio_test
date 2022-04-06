# syntax=docker/dockerfile:1
FROM node:12-alpine
WORKDIR /app
COPY . .
RUN npm install -g ts-node
RUN npm install
CMD ["node", "--loader", "ts-node/esm", "index.ts"]
EXPOSE 3000