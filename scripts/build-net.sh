#!/bin/bash
set -e
: "${ANDROID_NDK_HOME:?Set ANDROID_NDK_HOME}"
API=24
ABIS="arm64-v8a armeabi-v7a x86 x86_64"
TOOLCHAIN="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$ROOT/build_workspace"
OUT="$ROOT/release"
mkdir -p "$WORK" "$OUT"
VER="2.2.0"
SRC="$WORK/SDL2_net-$VER"
if [ ! -d "$SRC" ]; then
    wget -q "https://github.com/libsdl-org/SDL_net/releases/download/release-$VER/SDL2_net-$VER.tar.gz" -O "$WORK/SDL2_net-$VER.tar.gz"
    tar xzf "$WORK/SDL2_net-$VER.tar.gz" -C "$WORK"
fi
for ABI in $ABIS; do
    cmake -S "$SRC" -B "$WORK/build_SDL2_net_$ABI" \
        -DANDROID_PLATFORM="android-$API" \
        -DANDROID_ABI="$ABI" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$OUT/SDL2_net/$ABI" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DSDL2NET_SAMPLES=OFF \
        -DSDL2NET_INSTALL=ON \
        -DSDL2_DIR="$OUT/SDL2/$ABI/lib/cmake/SDL2"
    cmake --build "$WORK/build_SDL2_net_$ABI" --target install -j"$(nproc)"
done
