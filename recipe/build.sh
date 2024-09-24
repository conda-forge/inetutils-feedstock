#!/bin/sh
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
make check
make install