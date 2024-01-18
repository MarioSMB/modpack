SMB modpack
===========

QuakeC source for the SMB server mods

[![Build Status](https://travis-ci.org/MarioSMB/modpack.svg?branch=master)](https://travis-ci.org/MarioSMB/modpack)


Requirements
============

Git
 - On Debian based systems, use `sudo apt-get install git-core`
 - Windows: https://git-scm.com/download/win
 - On other Linux systems, follow your standard package manager instructions to install Git
 - Mac: Install the command line tools package (Google is your friend)

Building tools
 - On Debian based systems, use `sudo apt-get install build-essential`
 - Windows: MSYS2 (full guide pending)
 - Mac systems should already come with the required building tools once Git is installed
 
Required content packs:
 - http://dl.xonotic.fps.gratis/zzz-misc-v006-110-ge06fbb8.pk3
 - http://dl.xonotic.fps.gratis/zzz-quickmenu_029.pk3
 - http://dl.xonotic.fps.gratis/zzz-minigames-v006-114-ga3a4a87.pk3

Optional content packs:
 - http://dl.xonotic.fps.gratis/zzz-mod-extra-v006-62-g9667a44.pk3
 - http://dl.xonotic.fps.gratis/zzz-mod-weapons-v006-70-g7e65c20.pk3


Usage
=====

Note: PATH is one of the following depending on your system

|OS|Path|
|:--|:--|
|Windows|C:\Users\yourusername\Saved Games\xonotic|
|Linux|~/.xonotic|
|Mac|~/Library/Application Support/xonotic|
Nothing should *ever* be added to the main installation folder of Xonotic, use these paths!

1. Run this from a terminal in the modpack folder: `./update.sh`
2. Run this from a terminal in the modpack folder: `./build.sh` <br/>
For speed up compilation, if you want to execute without compression (without `csprogs-*.pk3` file): `ZIP=: ./build.sh`
3. Copy the compiled .dat files from modpack to `PATH/data`
4. Download the content packs to `PATH/data` and make sure they're available on your map download server

To update your server, repeat the above steps, but skip step 4 unless the packages available are newer than the ones you have


Localization
============

(url to transifex to be done)

Localization files dedicated to SMB are in the folder `lang`.

There are some scripts inside, introduced below. Complete setup with `./update.sh` before use.

1. `makepot.sh` generates `common.pot` from SMB source code and *excludes vanilla Xonotic strings* from the same file in Xonotic data.
2. `merge.sh` will merge existing SMB translations and corresponding vanilla translations, when both exists, to `compiled/zzz-smb-l10n.pk3dir`
  - To make translations available for your server players, use the `zzz-smb-l10n.xxxxxx.pk3` for your server (to skip creating pk3, use `ZIP=: ./merge.sh`)
  - This step is automatically done when executing `./build.sh` (to skip, use `L10N=0 ./build.sh`)

If you want to have translations from your own code and avoid merge conflicts, be sure to develop & translate in a seperate branch.
