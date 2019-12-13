# 1: Build
FROM node:10-alpine as builder

# Install bash dependency
RUN apk add --no-cache bash

ENV NODE_PATH=/node_modules
ENV PATH=$PATH:/node_modules/.bin

WORKDIR /app

# Add config files
ADD package.json ./package.json
ADD lerna.json ./lerna.json

# Add monorepo utilities
ADD bin ./bin

# Add source code
ADD packages/ufo ./packages/ufo

# Install dev and project dependencies
RUN yarn
RUN yarn run init

# Build
RUN yarn build

# 2: NGINX
FROM nginx:alpine

# Install bash dependency
RUN apk add --no-cache bash

EXPOSE 80

# Copy NGINX config
RUN rm -rf /etc/nginx/conf.d
COPY ./conf/nginx.conf /etc/nginx/

WORKDIR /usr/share/nginx/html

# Copy web bundle to public directory
COPY --from=builder /app/packages/ufo/build .
# Copy env file
COPY packages/ufo/.env.example .env
# Copy env build file
COPY ./bin/build_env_config.sh .

RUN chmod +x ./build_env_config.sh

# Generate env config file and start NGINX service on container start
CMD ["/bin/bash", "-c", "/usr/share/nginx/html/build_env_config.sh && nginx -g \"daemon off;\""]
