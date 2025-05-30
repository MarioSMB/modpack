SMB modpack
===========

UPDATE
======
To ensure the future of this mod a tough decision was made to fork the Xonotic code repository.  
As a result you may encounter an error when updating, something along the lines of: `fatal: remote error: upload-pack: not our ref`  

To resolve this, you must delete the modpack directory and clone it again.  
Apologies for the inconvenience!


QuakeC source for the SMB server mods
<!---
[![Build Status](https://travis-ci.org/MarioSMB/modpack.svg?branch=master)](https://travis-ci.org/MarioSMB/modpack)
!-->
[![Build Status](https://img.shields.io/github/actions/workflow/status/MarioSMB/modpack/build.yml)](https://github.com/MarioSMB/modpack/actions)

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
 - https://dl.xonotic.fps.gratis/zzz-misc-v006-122-g0a722ad.pk3
 - https://dl.xonotic.fps.gratis/zzz-quickmenu_029.pk3
 - https://dl.xonotic.fps.gratis/zzz-minigames-v006-114-ga3a4a87.pk3


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
