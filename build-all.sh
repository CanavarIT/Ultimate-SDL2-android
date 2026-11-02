#!/bin/bash
set -e

: "${ANDROID_NDK_HOME:?Set ANDROID_NDK_HOME}"

API=24
ABIS="arm64-v8a armeabi-v7a x86 x86_64"
TOOLCHAIN="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake"
ROOT="$(pwd)"
WORK="$ROOT/build_workspace"
OUT="$ROOT/release"
mkdir -p "$WORK" "$OUT"

LIBS=(
  "SDL2|2.30.11|SDL/releases/download/release-2.30.11/SDL2-2.30.11.tar.gz|-DSDL_SHARED=ON -DSDL_STATIC=ON"
  "SDL2_image|2.8.3|SDL_image/releases/download/release-2.8.3/SDL2_image-2.8.3.tar.gz|-DSDL2IMAGE_VENDORED=ON -DSDL2IMAGE_JXL=OFF -DSDL2IMAGE_AVIF=OFF -DSDL2IMAGE_SAMPLES=OFF -DSDL2IMAGE_INSTALL=ON"
  "SDL2_net|2.2.0|SDL_net/releases/download/release-2.2.0/SDL2_net-2.2.0.tar.gz|-DSDL2NET_SAMPLES=OFF -DSDL2NET_INSTALL=ON"
  "SDL2_mixer|2.8.1|SDL_mixer/releases/download/release-2.8.1/SDL2_mixer-2.8.1.tar.gz|-DSDL2MIXER_VENDORED=ON -DSDL2MIXER_MOD=OFF -DSDL2MIXER_MIDI=OFF -DSDL2MIXER_SAMPLES=OFF -DSDL2MIXER_INSTALL=ON -DWITH_ASM=OFF"
  "SDL2_ttf|2.24.0|SDL_ttf/releases/download/release-2.24.0/SDL2_ttf-2.24.0.tar.gz|-DSDL2TTF_VENDORED=ON -DSDL2TTF_HARFBUZZ=OFF -DSDL2TTF_SAMPLES=OFF -DSDL2TTF_INSTALL=ON"
)

for entry in "${LIBS[@]}"; do
    IFS='|' read -r NAME VER URL FLAGS <<< "$entry"
    SRC="$WORK/$NAME-$VER"
    if [ ! -d "$SRC" ]; then
        wget -q "https://github.com/libsdl-org/$URL" -O "$WORK/$NAME-$VER.tar.gz"
        tar xzf "$WORK/$NAME-$VER.tar.gz" -C "$WORK"
    fi
    if [ -f "$SRC/external/download.sh" ]; then
        (cd "$SRC" && bash external/download.sh || true)
    fi
    for ABI in $ABIS; do
        cmake -S "$SRC" -B "$WORK/build_${NAME}_$ABI" \
            -DANDROID_PLATFORM="android-$API" \
            -DANDROID_ABI="$ABI" \
            -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
            -DCMAKE_INSTALL_PREFIX="$OUT/$NAME/$ABI" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
            -DSDL2_DIR="$OUT/SDL2/$ABI/lib/cmake/SDL2" \
            $FLAGS
        cmake --build "$WORK/build_${NAME}_$ABI" --target install -j"$(nproc)"
    done
done

for NAME in SDL2 SDL2_image SDL2_net SDL2_mixer SDL2_ttf; do
    TMP=$(mktemp -d)
    for ABI in $ABIS; do
        mkdir -p "$TMP/$ABI"
        cp -r "$OUT/$NAME/$ABI/." "$TMP/$ABI/"
    done
    VER=$(ls "$WORK" | grep "^$NAME-" | head -1 | sed "s/^$NAME-//")
    tar czf "$OUT/$NAME-$VER-android-all.tar.gz" -C "$TMP" .
    rm -rf "$TMP"
done

ls -la "$OUT"/*.tar.gz
