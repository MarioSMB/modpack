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
 - http://dl.xonotic.fps.gratis/zzz-misc-v006-122-g0a722ad.pk3
 - http://dl.xonotic.fps.gratis/zzz-quickmenu_029.pk3
 - http://dl.xonotic.fps.gratis/zzz-minigames-v006-114-ga3a4a87.pk3

Optional content packs:
 - http://dl.xonotic.fps.gratis/zzz-mod-extra-v006-62-g9667a44.pk3
 - http://dl.xonotic.fps.gratis/zzz-mod-weapons-v006-107-g5176c47.pk3


Usage
=====

Note: PATH is one of the following depending on your system

|OS|Path|
|:--|:--|
|Windows|C:\Users\yourusername\Saved Games\xonotic|
|Linux|~/.xonotic|
|Mac|~/Library/Application Support/xonotic|
Nothing should *ever* be added to the main installation folder of Xonotic, use these paths!

1. Run this from a terminal in the modpack folder to complete setup: `./update.sh`
2. Run this from a terminal in the modpack folder to build the mod: `./build.sh` <br/>
For speed up compilation, if you want to execute without compression (without `csprogs-*.pk3` file): `ZIP=: ./build.sh`
3. Copy the compiled .dat files from modpack to `PATH/data`
4. Download the content packs to `PATH/data` and make sure they're available on your map download server

To update your server, repeat the above steps, but skip step 4 unless the packages available are newer than the ones you have


Localization
============

Translation work is done on Transifex: https://app.transifex.com/team-xonsmb/xonotic-smb-modpack/dashboard/

Also see Xonotic Wiki for translation guidelines and good practices: https://gitlab.com/xonotic/xonotic/-/wikis/Translating

Localization files dedicated to SMB are in the folder `lang`.

There are some scripts to help translaton work. To use them, please ensure `gettext` is installed, and complete setup with `./update.sh`.

1. `makepot.sh` will generate `common.pot` from SMB source code and *excludes vanilla Xonotic strings* from the same file in Xonotic data.
  - Run this after you have added new strings in the source code.
  - Transifex checks this file.
2. `merge.sh` will merge existing SMB translations and corresponding vanilla translations, when both exists, to `compiled/zzz-smb-l10n.pk3dir`
  - Run this if you are going to release your mod & translations.
  - To make translations available for your server players, use the `zzz-smb-l10n.xxxxxx.pk3` for your server (to skip creating it, use `ZIP=: ./merge.sh`)
  - This step is automatically done when executing `./build.sh` (to skip, use `L10N=0 ./build.sh`)
3. `updatepo.sh` will get new strings from the source code and put to your translated .po files.
  - Run this if you translate by directly editing `.po` files and new strings are available in the source code.
  - In most cases, you want to run `makepot.sh` before running this.

You can also integrate Transifex service to your own mod repository.

To avoid merge conflicts from upstream, be sure to develop & translate your own mod in a seperate branch.
