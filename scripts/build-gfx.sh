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
    wget -q "https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-1.0.4.tar.gz" -O "$WORK/SDL2_gfx-1.0.4.tar.gz"
    tar xzf "$WORK/SDL2_gfx-1.0.4.tar.gz" -C "$WORK"
fi

cat > "$SRC/Android.mk" << 'MK'
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := SDL2_gfx
LOCAL_SRC_FILES := SDL2_gfxPrimitives.c SDL2_rotozoom.c SDL2_framerate.c SDL2_imageFilter.c

LOCAL_C_INCLUDES := $(LOCAL_PATH) $(SDL2_INCLUDE_DIR)

LOCAL_CFLAGS := -O2 -fPIC -DDECLSPEC=
LOCAL_LDLIBS := -llog

LOCAL_SHARED_LIBRARIES := SDL2

include $(BUILD_SHARED_LIBRARY)

$(call import-module,SDL2)
MK

cat > "$SRC/Application.mk" << 'MK'
APP_ABI := arm64-v8a
APP_PLATFORM := android-24
APP_STL := c++_shared
MK

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
