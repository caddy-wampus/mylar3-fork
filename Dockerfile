
FROM ghcr.io/linuxserver/unrar:latest as unrar
FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
LABEL version eric-local-1

RUN \
  echo "**** install build dependencies ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    jpeg-dev \
    libffi-dev \
    libwebp-dev \
    python3-dev \
    zlib-dev && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    jpeg \
    libwebp-tools \
    nodejs \
    python3 \
    zlib

COPY ./ /app/mylar3/

RUN \ 
  echo "**** initialize mylar3 ****" && \
  cd /app/mylar3 && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.19/ -r requirements.txt && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
COPY init-scripts/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
VOLUME /config
EXPOSE 8090