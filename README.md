# Ultimate SDL2 for Android (prebuilt)

Prebuilt SDL2 2.30.11 and its satellite libraries for Android,
compiled from source with the official Android NDK.

## Included libraries

| Library | Version | Upstream |
|---------|---------|----------|
| SDL2 | 2.30.11 | libsdl-org/SDL |
| SDL2_image | 2.8.3 | libsdl-org/SDL_image |
| SDL2_mixer | 2.8.1 | libsdl-org/SDL_mixer |
| SDL2_net | 2.2.0 | libsdl-org/SDL_net |
| SDL2_ttf | 2.24.0 | libsdl-org/SDL_ttf |

## Supported ABIs

arm64-v8a, armeabi-v7a, x86, x86_64.
API 24 (Android 7.0), NDK r29 (29.0.14206865).

## Download

See the Releases page:
https://github.com/CanavarIT/Ultimate-SDL2-android/releases

Each archive contains one folder per ABI (arm64-v8a/, armeabi-v7a/, x86/, x86_64/).

## Usage

### CMake

set(SDL2_DIR "${CMAKE_SOURCE_DIR}/third_party/SDL2/arm64-v8a/lib/cmake/SDL2")
find_package(SDL2 REQUIRED)
target_link_libraries(myapp PRIVATE SDL2::SDL2)

### jniLibs

Copy .so files from the ABI folder into app/src/main/jniLibs/<abi>/.

For SDL2_image and SDL2_mixer you must also copy vendored .so files:
- SDL2_image: libpng16.so, libjpeg.so, libwebp.so, libwebpdemux.so, libtiff.so
- SDL2_mixer: libogg.so, libopus.so, libopusfile.so, libwavpack.so

SDL2_ttf statically links FreeType, no extra .so needed.

## Notes

Binaries are unstripped (debug info included) for easier debugging.
AGP strips them automatically when building a release APK.

## Building from source

Requirements: NDK r29, CMake 3.5+, Bash.
Run ./build-all.sh with ANDROID_NDK_HOME set.

## License

zlib license. See LICENSE.
