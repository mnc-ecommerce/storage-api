FROM public.ecr.aws/docker/library/node:18-alpine
RUN apk add --no-cache g++ make python3
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production

FROM public.ecr.aws/docker/library/node:18-alpine
RUN apk add --no-cache g++ make python3
WORKDIR /app
COPY . .
RUN npm ci
RUN npm run build

FROM public.ecr.aws/docker/library/node:18-alpine
WORKDIR /app
RUN npm install -g npm@9.8.1
COPY migrations migrations
COPY ecosystem.config.js package.json ./
COPY --from=0 /app/node_modules node_modules
COPY --from=1 /app/dist dist
EXPOSE 5000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "dist/server.js"]
