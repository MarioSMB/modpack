# SMB modpack

QuakeC source for the SMB server mods
<!---
[![Build Status](https://travis-ci.org/MarioSMB/modpack.svg?branch=master)](https://travis-ci.org/MarioSMB/modpack)
!-->
[![Build Status](https://img.shields.io/github/actions/workflow/status/MarioSMB/modpack/build.yml)](https://github.com/MarioSMB/modpack/actions)

## Prerequisites

Ensure your system has following programs installed:

- git
- gcc
- make
- 7zip or zip (required for pk3)
- bash

This mod also depends on following additional resources, download and place
them in [userdir](#userdir-reference)/data.

- <https://dl.xonotic.fps.gratis/zzz-misc-v006-123-gc8a7c01.pk3>
- <https://dl.xonotic.fps.gratis/zzz-quickmenu_029.pk3>
- <https://dl.xonotic.fps.gratis/zzz-minigames-v006-114-ga3a4a87.pk3>

## Building

First, clone this repository and enter the project directory:

```bash
git clone https://github.com/MarioSMB/modpack
cd modpack
```

The `build.sh` script handles the compilation process. Output files are generated in `build/<branch>/`

| Build Type | Command | Build Output |
|:--- |:---|:---|
| **Standard Build** | `./build.sh` | Compiles `.dat` files only. |
| **Full Build** | `./build.sh -a` | Compiles `.dat` and `.pk3` files. |

> [!NOTE]
> To rebuild you'll have to remove the previously compiled `.dat` and `.pk3` files. Add `-c` flag to the build script for a clean build.

> [!TIP]
> Run `./build.sh -h` to see full usage of the build script.

## Usage

To play the mod locally, copy the `.dat` files into the userdir/data.

## Userdir Reference

Depending on your operating system, your userdir is located at:

|OS|Path|
|:--|:--|
|Windows|C:\Users\yourusername\Saved Games\xonotic|
|Linux|~/.xonotic|
|Mac|~/Library/Application Support/xonotic|

> [!IMPORTANT]
> Nothing should *ever* be added to the gamedir (where the main game lives), use userdir.
