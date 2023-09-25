FROM python:3.9-alpine as base
RUN mkdir /root/.local/

# amd64 stage
FROM base AS build-amd64
RUN pip3 install maildump

# arm64 stage
FROM base AS build-arm64
RUN apk update && apk add gcc libffi-dev py3-cffi alpine-sdk && pip3 install maildump && apk del alpine-sdk gcc libffi-dev py3-cffi

# build image
FROM build-${TARGETARCH}
COPY start.sh /root/.local/
WORKDIR /root/.local/
ENTRYPOINT /bin/sh /root/.local/start.sh
