SMB modpack
===========

QuakeC source for the SMB server mods


NOTE:  
Since 0.8.1, the mod has been remade as a mutator.  
This greatly improves maintainability and allows us to provide updates quicker.  
In the process though, some cvars have changed, and a new system has been added to check the mod's cvars (no more autoexec, yay!)  
To see the available cvars, do the following from your server (or rcon) console: dumpmodcvars  
This will place a configuration file in the data/data folder, named mod_cvars.cfg. Do not execute or modify this on your server!  
Instead, copy the settings you wish to change into your main server.cfg file.


Requirements
============

GMQCC - git://git.xonotic.org/xonotic/gmqcc.git  
Xonotic - http://xonotic.org/download or git://git.xonotic.org/xonotic/xonotic.git  
Required content packs - http://smb.djstrikes3.com/zzz-misc-v006-41-gc670c3c.pk3 http://smb.djstrikes3.com/zzz-quickmenu_013.pk3 http://smb.djstrikes3.com/zzz-minigames-v006-43-g77558e8.pk3  


Usage
=====

Note: PATH is one of the following depending on your system:  
Windows: C:\Users\yourusername\Saved Games\xonotic  
Linux: ~/.xonotic  
Mac: ~/Library/Application Support/xonotic  
Nothing should *ever* be added to the main installation folder of Xonotic, use these paths!

Compile GMQCC & copy the compiled gmqcc binary from the gmqcc folder to modpack/qcsrc  
Run this from a terminal in the qcsrc folder: make QCC=../gmqcc  
Copy the compiled .dat files from modpack to PATH/data  
Copy the autoexec folder from modpack to PATH/data  

Download the content packs to PATH/data and make sure they're available on your map download server  


To update, run this from a terminal in the modpack folder: git pull  
Once this finishes, repeat previous usage steps