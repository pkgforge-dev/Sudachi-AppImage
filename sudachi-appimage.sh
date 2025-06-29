#!/bin/bash

set -ex

export APPIMAGE_EXTRACT_AND_RUN=1
export ARCH="$(uname -m)"

pkgver="1.0.15"
HOME_DIR=$(realpath "./")
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
SUDACHI="https://github.com/emuplace/sudachi.emuplace.app/releases/download/v${pkgver}/latest.zip"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"

case "$1" in
    steamdeck)
        echo "Making Sudachi Optimized Build for Steam Deck"
        CMAKE_CXX_FLAGS="-march=znver2 -mtune=znver2 -O3 -pipe -flto=auto -Wno-error"
        CMAKE_C_FLAGS="-march=znver2 -mtune=znver2 -O3 -pipe -flto=auto -Wno-error"
        TARGET="Steamdeck"
        ;;
    modern)
        echo "Making Sudachi Optimized Build for Modern CPUs"
        CMAKE_CXX_FLAGS="-march=x86-64-v3 -O3 -pipe -flto=auto -Wno-error"
        CMAKE_C_FLAGS="-march=x86-64-v3 -O3 -pipe -flto=auto -Wno-error"
        ARCH="${ARCH}_v3"
        TARGET="Modern"
        ;;
    legacy)
        echo "Making Sudachi Optimized Build for Legacy CPUs"
        CMAKE_CXX_FLAGS="-march=x86-64 -mtune=generic -O2 -pipe -flto=auto -Wno-error"
        CMAKE_C_FLAGS="-march=x86-64 -mtune=generic -O2 -pipe -flto=auto -Wno-error"
        TARGET="Legacy"
        ;;
    aarch64)
        echo "Making Sudachi Optimized Build for AArch64"
        CMAKE_CXX_FLAGS="-march=armv8-a -mtune=generic -O3 -pipe -flto=auto -w"
        CMAKE_C_FLAGS="-march=armv8-a -mtune=generic -O3 -pipe -flto=auto -w"
        TARGET="Linux"
        ;;
esac

UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|latest|*$ARCH.AppImage.zsync"

echo "Getting sudachi source file"
if [ ! -d ./sudachi ]; then
    wget -q "$SUDACHI"
    mkdir ./sudachi
    unzip latest.zip -d ./sudachi
fi

cd ./sudachi
# List of submodule paths
submodule_paths=(
    "externals/enet"
    "externals/dynarmic"
    "externals/libusb/libusb"
    "externals/discord-rpc"
    "externals/vulkan-headers"
    "externals/sirit"
    "externals/mbedtls"
    "externals/xbyak"
    "externals/opus"
    "externals/cpp-httplib"
    "externals/ffmpeg/ffmpeg"
    "externals/cpp-jwt"
    "externals/libadrenotools"
    "externals/VulkanMemoryAllocator"
    "externals/breakpad"
    "externals/simpleini"
    "externals/oaknut"
    "externals/Vulkan-Utility-Libraries"
    "externals/vcpkg"
    "externals/nx_tzdb/tzdb_to_nx"
    "externals/cubeb"
    "externals/SDL3"
)

for path in "${submodule_paths[@]}"; do
    if [ -d "$path" ]; then
        echo "Deleting existing folder: $path"
        rm -rf "$path"
    fi
done

git init

git submodule add https://github.com/lsalzman/enet externals/enet
git submodule add https://github.com/sudachi-emu/dynarmic externals/dynarmic
git submodule add https://github.com/libusb/libusb externals/libusb/libusb
git submodule add https://github.com/sudachi-emu/discord-rpc externals/discord-rpc
git submodule add https://github.com/KhronosGroup/Vulkan-Headers externals/vulkan-headers
git submodule add https://github.com/sudachi-emu/sirit externals/sirit
git submodule add https://github.com/sudachi-emu/mbedtls externals/mbedtls
git submodule add https://github.com/herumi/xbyak externals/xbyak
git submodule add https://github.com/xiph/opus externals/opus
git submodule add https://github.com/yhirose/cpp-httplib externals/cpp-httplib
git submodule add https://github.com/FFmpeg/FFmpeg externals/ffmpeg/ffmpeg
git submodule add https://github.com/arun11299/cpp-jwt externals/cpp-jwt
git submodule add https://github.com/bylaws/libadrenotools externals/libadrenotools
git submodule add https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator externals/VulkanMemoryAllocator
git submodule add https://github.com/sudachi-emu/breakpad externals/breakpad
git submodule add https://github.com/brofield/simpleini externals/simpleini
git submodule add https://github.com/sudachi-emu/oaknut externals/oaknut
git submodule add https://github.com/KhronosGroup/Vulkan-Utility-Libraries externals/Vulkan-Utility-Libraries
git submodule add https://github.com/microsoft/vcpkg externals/vcpkg
git submodule add https://github.com/lat9nq/tzdb_to_nx externals/nx_tzdb/tzdb_to_nx
git submodule add https://github.com/mozilla/cubeb externals/cubeb
git submodule add https://github.com/libsdl-org/sdl externals/SDL3

git submodule update --init --recursive

cd externals/cpp-httplib && git checkout 65ce51aed7f15e40e8fb6d2c0a8efb10bcb40126
cd "${HOME_DIR}"/sudachi/externals/xbyak && git checkout v6.68

cd "${HOME_DIR}"/sudachi

# workaround for ffmpeg build
sed -i '/--disable-postproc/d' externals/ffmpeg/CMakeLists.txt

mkdir build
cd build
cmake .. -GNinja \
    -DENABLE_QT6=ON \
    -DSUDACHI_USE_BUNDLED_FFMPEG=ON \
    -DSUDACHI_TESTS=OFF \
    -DSUDACHI_CHECK_SUBMODULES=OFF \
    -DSUDACHI_ENABLE_LTO=ON \
    -DENABLE_QT_TRANSLATION=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_SYSTEM_PROCESSOR="$(uname -m)" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--as-needed" \
    ${CMAKE_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS"} \
    ${CMAKE_C_FLAGS:+-DCMAKE_C_FLAGS="$CMAKE_C_FLAGS"}
ninja

VERSION="${pkgver}"
echo "$VERSION" > ~/version
echo "$(cat ~/version)"

# Create base Appdir files
sudo ninja install
mkdir -p Appdir
cd Appdir

cp -v /usr/share/applications/org.sudachi_emu.sudachi.desktop ./sudachi.desktop
dos2unix ./sudachi.desktop
cp -v ../../dist/sudachi.ico .
ln -sfv ./sudachi.ico ./.DirIcon

wget --retry-connrefused --tries=30 "$LIB4BN" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -a -- ./lib4bin -p -v -e -s -k \
    /usr/bin/sudachi \
    /usr/lib/libSDL* \
    /usr/lib/libXss.so* \
    /usr/lib/libgamemode.so* \
    /usr/lib/qt6/plugins/imageformats/* \
    /usr/lib/qt6/plugins/iconengines/* \
    /usr/lib/qt6/plugins/platforms/* \
    /usr/lib/qt6/plugins/platformthemes/* \
    /usr/lib/qt6/plugins/platforminputcontexts/* \
    /usr/lib/qt6/plugins/styles/* \
    /usr/lib/qt6/plugins/xcbglintegrations/* \
    /usr/lib/qt6/plugins/wayland-*/* \
    /usr/lib/pulseaudio/* \
    /usr/lib/spa-0.2/*/* \
    /usr/lib/alsa-lib/* \
    /usr/lib/lib*GL*.so* \
    /usr/lib/dri/* \
    /usr/lib/vdpau/* \
    /usr/lib/libvulkan* \
    /usr/lib/libdecor-0.so*

ln -fv ./sharun ./AppRun
./sharun -g

cd ..
# Prepare uruntime
wget -q "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime --appimage-addupdinfo "$UPINFO"

# Turn AppDir into appimage
echo "Generating AppImage"
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 \
--header uruntime -i ./AppDir  -o sudachi-v"${pkgver}"-"${TARGET}"-"${ARCH}".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

mkdir -p artifacts
mv -v *.AppImage* artifacts/

echo "All Done!"
