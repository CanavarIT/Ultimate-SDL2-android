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
VER="2.8.1"
SRC="$WORK/SDL2_mixer-$VER"
if [ ! -d "$SRC" ]; then
    wget -q "https://github.com/libsdl-org/SDL_mixer/releases/download/release-$VER/SDL2_mixer-$VER.tar.gz" -O "$WORK/SDL2_mixer-$VER.tar.gz"
    tar xzf "$WORK/SDL2_mixer-$VER.tar.gz" -C "$WORK"
    (cd "$SRC" && bash external/download.sh || true)
fi
for ABI in $ABIS; do
    cmake -S "$SRC" -B "$WORK/build_SDL2_mixer_$ABI" \
        -DANDROID_PLATFORM="android-$API" \
        -DANDROID_ABI="$ABI" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$OUT/SDL2_mixer/$ABI" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DSDL2MIXER_VENDORED=ON \
        -DSDL2MIXER_MOD=OFF \
        -DSDL2MIXER_MIDI=OFF \
        -DSDL2MIXER_SAMPLES=OFF \
        -DSDL2MIXER_INSTALL=ON \
        -DWITH_ASM=OFF \
        -DSDL2_DIR="$OUT/SDL2/$ABI/lib/cmake/SDL2"
    cmake --build "$WORK/build_SDL2_mixer_$ABI" --target install -j"$(nproc)"
done
