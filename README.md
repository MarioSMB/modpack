SMB modpack
===========

QuakeC source for the SMB server mods


NOTE:  
Since 0.8.1, the mod has been remade as a mutator.  
This greatly improves maintainability and allows us to provide updates quicker.  
In the process though, some cvars have changed, and a new system has been added to check the mod's cvars (no more autoexec, yay!)  
To see the available cvars, do the following from your server (or rcon) console: `dumpmodcvars`  
This will place a configuration file in the data/data folder, named mod_cvars.cfg. Do not execute or modify this on your server!  
Instead, copy the settings you wish to change into your main server.cfg file.


Requirements
============

Git
 - On Debian based systems, use `sudo apt-get install git-core`
 - Windows: https://git-scm.com/download/win
 - On other Linux systems, follow your standard package manager instructions to install Git
 - Mac: Install the command line tools package (Google is your friend)
 
Required content packs:
 - http://smb.djstrikes3.com/zzz-misc-v006-46-g1edff38.pk3
 - http://smb.djstrikes3.com/zzz-quickmenu_016.pk3
 - http://smb.djstrikes3.com/zzz-minigames-v006-47-g908aea1.pk3


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
