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
 - Windows: ??? (alternatively, use MSYS2, guide pending)
 - Mac systems should already come with the required building tools once Git is installed
 
Required content packs:
 - http://dl.xonotic.co/zzz-misc-v006-75-g26267bf.pk3
 - http://dl.xonotic.co/zzz-quickmenu_021.pk3
 - http://dl.xonotic.co/zzz-minigames-v006-64-g09ed1c0.pk3

Optional content packs:
 - http://dl.xonotic.co/zzz-mod-extra-v006-62-g9667a44.pk3
 - http://dl.xonotic.co/zzz-mod-weapons-v006-70-g7e65c20


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
2. Run this from a terminal in the modpack folder: `./build.sh`
3. Copy the compiled .dat files from modpack to `PATH/data`
4. Download the content packs to `PATH/data` and make sure they're available on your map download server

To update your server, repeat the above steps, but skip step 4 unless the packages available are newer than the ones you have
