ARG NODE_VERSION

##########################
# builder
##########################
FROM node:${NODE_VERSION}-alpine AS builder

WORKDIR /web

COPY /web ./

RUN npm install

RUN npm run build

##########################
# runner
##########################
FROM node:${NODE_VERSION}-alpine AS runner

RUN apk update && \
    apk upgrade

WORKDIR /web

USER node

COPY --from=builder /web/.next ./.next
COPY --from=builder /web/public ./public
COPY --from=builder /web/node_modules ./node_modules
COPY --from=builder /web/package.json ./

CMD npm run start

##########################
# development
##########################
FROM node:${NODE_VERSION}-alpine AS development

WORKDIR /web

RUN apk update && \
    apk upgrade && \
    apk add --no-cache make gcc g++ python3 curl

# install and cache web dependencies
COPY package*.json .

RUN npm install npm

CMD npm run dev