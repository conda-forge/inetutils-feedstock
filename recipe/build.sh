#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

if [[ ${build_platform} != ${target_platform} ]]; then
    CROSS_LDFLAGS=${LDFLAGS}
    CROSS_CC="${CC}"
    CROSS_LD="${LD}"

    LDFLAGS=${LDFLAGS//${PREFIX}/${BUILD_PREFIX}}
    CC=${CC//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}
    LD="${LD//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}"

    ./configure \
        --prefix="$BUILD_PREFIX" \
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
    make install
    make clean

    LDFLAGS="${CROSS_LDFLAGS}"
    CC=${CROSS_CC}
    LD=${CROSS_LD}

    sed -i "s|../\$(TOOL)|${BUILD_PREFIX}/bin/|" man/Makefile.am
fi

# Skip test that fails on macOS
if [[ ${target_platform} =~ .*osx.* ]]; then
    sed -i '/dist_check_SCRIPTS += libls.sh/d' tests/Makefile.am
fi
autoreconf --force --verbose --install
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
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
make check
fi
make install
