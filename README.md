<h1 align="left">
  <br>
  <b>Sudachi Unofficial Appimage</b>
  <br>
</h1>

[![GitHub Release](https://img.shields.io/github/v/release/pflyly/Sudachi-AppImage?label=Current%20Release)](https://github.com/pflyly/Sudachi-AppImage/releases/latest)
[![GitHub Downloads](https://img.shields.io/github/downloads/pflyly/Sudachi-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pflyly/Sudachi-AppImage/releases/latest)
[![CI Build Status](https://github.com//pflyly/Sudachi-AppImage/actions/workflows/build.yml/badge.svg)](https://github.com/pflyly/Sudachi-AppImage/releases/latest)

### 🐧

These builds for Linux are built with several CPU-specific compliler optimization flags targeting:

- **Steam Deck** — optimized for `znver2` (Zen 2)
- **Modern x86_64 CPUs** — optimized for `x86-64-v3` (via the Modern Build)
- **Legacy x86_64 CPUs** — compatible with baseline `x86-64` (via the Legacy Build)
- **AArch64 devices** — compatible with `aarch64` architecture

All of the Appimages are built using [**Sharun**](https://github.com/VHSgunzo/sharun) and are bundled with **Mesa drivers** to ensure maximum compatibility.
---------------------------------------------------------------

* [**Latest Nightly Release Here**](https://github.com/pflyly/Sudachi-AppImage/releases/latest)

---------------------------------------------------------------

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i sudachi` or `appman -i sudachi`

* [dbin](https://github.com/xplshn/dbin) `dbin install sudachi.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install sudachi`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)
