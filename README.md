ESK modpack
===========

NOTE ABOUT UPDATES: Please read this before updating to latest mod: https://github.com/MarioSMB/esk-modpack/wiki/(GUIDE)-Important-note-about-recent-updates

QuakeC source for the ESK server mods


Requirements
============

GMQCC - git://git.xonotic.org/xonotic/gmqcc.git  
Xonotic - http://xonotic.org/download or git://git.xonotic.org/xonotic/xonotic.git  
Required content packs - zzz-misc-v006-18-gb6f5ebf.pk3 http://dl.smbclan.net/maps/zzz-quickmenu_010.pk3 http://dl.smbclan.net/maps/zzz-minigames-v006-18-gb6f5ebf.pk3
Optional content packs - http://dl.smbclan.net/maps/zzz-monsters_009.pk3 http://dl.smbclan.net/maps/zzz-vehicles_001.pk3


Usage
=====

Compile GMQCC & copy the compiled gmqcc binary from the gmqcc folder to esk-modpack/qcsrc  
Run this from a terminal in the qcsrc folder: make QCC=../gmqcc  
Copy the compiled .dat files from esk-modpack to Xonotic/data  
Copy the autoexec folder from esk-modpack to Xonotic/data  

Download the content packs to Xonotic/data & make sure they're available on your map download server  


To update, run this from a terminal in the esk-modpack folder: git pull  
Once this finishes, repeat previous usage steps