FROM golang:1.7.3

ENV FFMPEG_SRC=/tmp/workdir/src \
    FFMPEG_BUILD=/tmp/workdir/src \
    FFMPEG_BIN=/tmp/workdir/bin

ENV YASM_VERSION=1.3.0 \
    X264_VERSION=20160629-2245-stable \
    AAC_VERSION=0.1.4 \
    LAME_VERSION=3.99.5 \
    OPUS_VERSION=1.1.2 \
    VPX_VERSION=1.5.0 \
    FFMPEG_VERSION=3.1

COPY build.sh .
RUN ./build.sh

WORKDIR /go
