FROM node:22-alpine as builder

RUN apk add --no-cache git \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --target wasm32-unknown-unknown \
	&& git clone --depth 1 --branch photos-v1.2.28 https://github.com/ente-io/ente.git /app

ENV PATH="/root/.cargo/bin:${PATH}"

ARG NEXT_PUBLIC_ENTE_ENDPOINT=ente.doesnot.exist.example.com
ARG NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT=albums.doesnot.exist.example.com

WORKDIR /app/web
RUN yarn install \
    && yarn build:photos

FROM alpine:3.22

WORKDIR /app
COPY --from=builder /app/web/apps/photos/out .
COPY --chmod=755 entrypoint.sh /entrypoint.sh

RUN apk --no-cache upgrade \
	&& apk --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing add gatling brotli

ENV PORT=3000
EXPOSE ${PORT}

CMD /entrypoint.sh
