# build stage
FROM node:24-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# EXPOSE 5000
# CMD ["npm", "start"]

# production stage
FROM node:24-alpine
WORKDIR /app
COPY --from=builder /app /app
EXPOSE 5000
ENV PORT=5000
CMD ["node", "index.js"]