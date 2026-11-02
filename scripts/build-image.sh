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
VER="2.8.3"
SRC="$WORK/SDL2_image-$VER"
if [ ! -d "$SRC" ]; then
    wget -q "https://github.com/libsdl-org/SDL_image/releases/download/release-$VER/SDL2_image-$VER.tar.gz" -O "$WORK/SDL2_image-$VER.tar.gz"
    tar xzf "$WORK/SDL2_image-$VER.tar.gz" -C "$WORK"
    (cd "$SRC" && bash external/download.sh || true)
fi
for ABI in $ABIS; do
    cmake -S "$SRC" -B "$WORK/build_SDL2_image_$ABI" \
        -DANDROID_PLATFORM="android-$API" \
        -DANDROID_ABI="$ABI" \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DCMAKE_INSTALL_PREFIX="$OUT/SDL2_image/$ABI" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DSDL2IMAGE_VENDORED=ON \
        -DSDL2IMAGE_JXL=OFF \
        -DSDL2IMAGE_AVIF=OFF \
        -DSDL2IMAGE_SAMPLES=OFF \
        -DSDL2IMAGE_INSTALL=ON \
        -DSDL2_DIR="$OUT/SDL2/$ABI/lib/cmake/SDL2"
    cmake --build "$WORK/build_SDL2_image_$ABI" --target install -j"$(nproc)"
done
