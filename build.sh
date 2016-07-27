#!/bin/bash

error_handler () {
  errcode=$? # save the exit code as the first thing done in the trap function
  echo "error $errorcode"
  echo "The command executing at the time of the error was"
  echo "$BASH_COMMAND"
  echo "on line ${BASH_LINENO[0]}"
  exit $errcode  # or use some other value or do return instead
}
trap error_handler ERR

mkdir -p ${FFMPEG_SRC}
mkdir -p ${FFMPEG_BUILD}
mkdir -p ${FFMPEG_BIN}

apt-get update
apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev \
  libtheora-dev libtool libvorbis-dev pkg-config texinfo zlib1g-dev nasm

# yasm
cd ${FFMPEG_SRC}
wget http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz
tar xzvf yasm-${YASM_VERSION}.tar.gz
cd yasm-${YASM_VERSION}
./configure --prefix=${FFMPEG_BUILD} --bindir=${FFMPEG_BIN}
make
make install
make distclean

# libx264
cd ${FFMPEG_SRC}
wget http://download.videolan.org/pub/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2
tar xjvf x264-snapshot-${X264_VERSION}.tar.bz2
cd x264-snapshot-${X264_VERSION}
PATH="${FFMPEG_BIN}:${PATH}" ./configure --prefix=${FFMPEG_BUILD} --bindir=${FFMPEG_BIN} --enable-static --disable-opencl
PATH="${FFMPEG_BIN}:${PATH}" make
make install
make distclean

# libfdk-aac
cd ${FFMPEG_SRC}
wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/v${AAC_VERSION}
tar xzvf fdk-aac.tar.gz
cd mstorsjo-fdk-aac*
autoreconf -fiv
./configure --prefix=${FFMPEG_BUILD} --disable-shared
make
make install
make distclean 

# libmp3lame
cd ${FFMPEG_SRC}
wget http://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION%.*}/lame-${LAME_VERSION}.tar.gz
tar xzvf lame-${LAME_VERSION}.tar.gz
cd lame-${LAME_VERSION}
./configure --prefix=${FFMPEG_BUILD} --enable-nasm --disable-shared
make
make install
make distclean 

# libopus
cd ${FFMPEG_SRC}
wget http://downloads.xiph.org/releases/opus/opus-${OPUS_VERSION}.tar.gz
tar xzvf opus-${OPUS_VERSION}.tar.gz
cd opus-${OPUS_VERSION}
./configure --prefix=${FFMPEG_BUILD} --disable-shared
make
make install
make clean

# libvpx
cd ${FFMPEG_SRC}
wget http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${VPX_VERSION}.tar.bz2
tar xjvf libvpx-${VPX_VERSION}.tar.bz2
cd libvpx-${VPX_VERSION}
PATH="$FFMPEG_BIN:$PATH" ./configure --prefix=${FFMPEG_BUILD} --disable-examples --disable-unit-tests
PATH="$FFMPEG_BIN:$PATH" make
make install
make clean

# ffmpeg
cd ${FFMPEG_SRC}
wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz
tar xzvf ffmpeg-${FFMPEG_VERSION}.tar.gz
cd ffmpeg-${FFMPEG_VERSION}
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
      --enable-nonfree
PATH="$FFMPEG_BIN:$PATH" make
make install
make distclean
hash -r

mv ${FFMPEG_BIN}/ffmpeg /usr/local/bin
rm -rf /tmp/workdir
