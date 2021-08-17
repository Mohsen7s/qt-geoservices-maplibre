#!/bin/bash -l

source scl_source enable devtoolset-8

set -e
set -x

export CCACHE_DIR="$GITHUB_WORKSPACE/.ccache"
export PATH=$Qt5_Dir/bin:$PATH
qmake --version

if [[ "$1" = "library" ]]; then
  mkdir build && cd build
  cmake3 ../source/dependencies/maplibre-gl-native/ \
    -G Ninja \
    -DMBGL_WITH_QT=ON \
    -DMBGL_QT_LIBRARY_ONLY=ON \
    -DMBGL_QT_STATIC=ON \
    -DMBGL_QT_WITH_INTERNAL_ICU=OFF \
    -DMBGL_QT_WITH_INTERNAL_SQLITE=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=../install-gl \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache
  ninja
  ninja install
elif [[ "$1" = "plugin" ]]; then
  mkdir build && cd build
  qmake ../source/ MBGL_PATH=../install-gl
  make -j2
  INSTALL_ROOT=../install make install
else
  exit 1
fi
