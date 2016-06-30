FROM golang:1.6.2

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

RUN mkdir -p ${FFMPEG_SRC} && \
    mkdir -p ${FFMPEG_BUILD} && \
    mkdir -p ${FFMPEG_BIN}

RUN apt-get update && \
    apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
        libtheora-dev libtool libvorbis-dev pkg-config texinfo zlib1g-dev nasm

# yasm
RUN cd ${FFMPEG_SRC} && \
    wget http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz && \
    tar xzvf yasm-${YASM_VERSION}.tar.gz && \
    cd yasm-${YASM_VERSION} && \
    ./configure --prefix=${FFMPEG_BUILD} --bindir=${FFMPEG_BIN} && \
    make && \
    make install && \
    make distclean

# libx264
RUN cd ${FFMPEG_SRC} && \
    wget http://download.videolan.org/pub/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 && \
    tar xjvf x264-snapshot-${X264_VERSION}.tar.bz2 && \
    cd x264-snapshot-${X264_VERSION} && \
    PATH="${FFMPEG_BIN}:${PATH}" ./configure --prefix=${FFMPEG_BUILD} --bindir=${FFMPEG_BIN} --enable-static --disable-opencl && \
    PATH="${FFMPEG_BIN}:${PATH}" make && \
    make install && \
    make distclean

# libfdk-aac
RUN cd ${FFMPEG_SRC} && \
    wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/v${AAC_VERSION} && \
    tar xzvf fdk-aac.tar.gz && \
    cd mstorsjo-fdk-aac* && \
    autoreconf -fiv && \
    ./configure --prefix=${FFMPEG_BUILD} --disable-shared && \
    make && \
    make install && \
    make distclean 

# libmp3lame
RUN cd ${FFMPEG_SRC} && \
    wget http://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.*}/lame-${LAME_VERSION}.tar.gz && \
    tar xzvf lame-${LAME_VERSION}.tar.gz && \
    cd lame-${LAME_VERSION} && \
    ./configure --prefix=${FFMPEG_BUILD} --enable-nasm --disable-shared && \
    make && \
    make install && \
    make distclean 

# libopus
RUN cd ${FFMPEG_SRC} && \
    wget http://downloads.xiph.org/releases/opus/opus-${OPUS_VERSION}.tar.gz && \
    tar xzvf opus-${OPUS_VERSION}.tar.gz && \
    cd opus-${OPUS_VERSION} && \
    ./configure --prefix=${FFMPEG_BUILD} --disable-shared && \
    make && \
    make install && \
    make clean

# libvpx
RUN cd ${FFMPEG_SRC} && \
    wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${VPX_VERSION}.tar.bz2 && \
    tar xjvf libvpx-${VPX_VERSION}.tar.bz2 && \
    cd libvpx-${VPX_VERSION} && \
    PATH="$FFMPEG_BIN:$PATH" ./configure --prefix=${FFMPEG_BUILD} --disable-examples --disable-unit-tests && \
    PATH="$FFMPEG_BIN:$PATH" make && \
    make install && \
    make clean

# ffmpeg
RUN cd ${FFMPEG_SRC} && \
    wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    tar xzvf ffmpeg-${FFMPEG_VERSION}.tar.gz && \
    cd ffmpeg-${FFMPEG_VERSION} && \
    PATH="$FFMPEG_BIN:$PATH" PKG_CONFIG_PATH="${FFMPEG_BUILD}/lib/pkgconfig" ./configure \
      --prefix="${FFMPEG_BUILD}" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I${FFMPEG_BUILD}/include" \
      --extra-ldflags="-L${FFMPEG_BUILD}/lib" \
      --bindir="$FFMPEG_BIN" \
      --enable-gpl \
      --enable-libass \
      --enable-libfdk-aac \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-nonfree && \
    PATH="$FFMPEG_BIN:$PATH" make && \
    make install && \
    make distclean && \
    hash -r

RUN mv ${FFMPEG_BIN}/ffmpeg /usr/local/bin
RUN rm -rf /tmp/workdir

WORKDIR /go
