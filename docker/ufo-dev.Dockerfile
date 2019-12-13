FROM timbru31/java-node:11-alpine-slim

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

# Build app dependencies
RUN yarn build:ufo

# Run development app
CMD yarn ufo

