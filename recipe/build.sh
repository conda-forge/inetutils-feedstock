#!/bin/sh
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./build-aux
set -ex

./configure \
    --prefix="$PREFIX" \
    --disable-silent-rules \
    --disable-dependency-tracking \
    --enable-ncurses \
    --disable-logger \
    --enable-year2038 \
    --with-wrap \
    --with-pam \
    --with-idn \
    --enable-threads=posix
make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install