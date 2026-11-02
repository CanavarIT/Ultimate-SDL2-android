#!/bin/bash
set -e
: "${ANDROID_NDK_HOME:?Set ANDROID_NDK_HOME}"
API=24
ABIS="arm64-v8a armeabi-v7a x86 x86_64"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$ROOT/build_workspace"
OUT="$ROOT/release"
SRC="$WORK/SDL2_gfx-1.0.4"
mkdir -p "$OUT/SDL2_gfx"

if [ ! -d "$SRC" ]; then
    echo "Error: SDL2_gfx source not found in $SRC"
    echo "Run: wget http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-1.0.4.tar.gz && tar xzf SDL2_gfx-1.0.4.tar.gz"
    exit 1
fi

for ABI in $ABIS; do
    echo "=== SDL2_gfx 1.0.4 / $ABI ==="
    SDL2_INC="$OUT/SDL2/$ABI/include"
    SDL2_LIB="$OUT/SDL2/$ABI/lib"
    BUILD_DIR="$WORK/build_SDL2_gfx_$ABI"
    INSTALL_DIR="$OUT/SDL2_gfx/$ABI"
    mkdir -p "$BUILD_DIR" "$INSTALL_DIR/lib" "$INSTALL_DIR/include/SDL2"
    
    cd "$BUILD_DIR"
    "$ANDROID_NDK_HOME/ndk-build" \
        NDK_PROJECT_PATH="$SRC" \
        APP_BUILD_SCRIPT="$SRC/Android.mk" \
        NDK_APPLICATION_MK="$SRC/Application.mk" \
        APP_ABI="$ABI" \
        APP_PLATFORM="android-$API" \
        SDL2_INCLUDE_DIR="$SDL2_INC" \
        SDL2_LIBRARY_DIR="$SDL2_LIB" \
        NDK_MODULE_PATH="$OUT/SDL2/$ABI/share/ndk-modules" \
        -j"$(nproc)"
    
    cp "$SRC/libs/$ABI/libSDL2_gfx.so" "$INSTALL_DIR/lib/" 2>/dev/null || \
    cp "$SRC/obj/local/$ABI/libSDL2_gfx.so" "$INSTALL_DIR/lib/" 2>/dev/null || \
    echo "Warning: libSDL2_gfx.so not found for $ABI"
    
    cp "$SRC/SDL2_gfxPrimitives.h" "$SRC/SDL2_rotozoom.h" "$SRC/SDL2_framerate.h" "$SRC/SDL2_imageFilter.h" "$INSTALL_DIR/include/SDL2/" 2>/dev/null
    cd "$ROOT"
done
ls -la "$OUT/SDL2_gfx"/*/lib/
