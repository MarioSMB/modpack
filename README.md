ESK modpack
===========

QuakeC source for the ESK server mods


Requirements
============

GMQCC (git://git.xonotic.org/xonotic/gmqcc.git)  
Xonotic (http://xonotic.org/download or git://git.xonotic.org/xonotic/xonotic.git)  
Content packs (https://dl.dropboxusercontent.com/u/18995126/maps/zzz-misc_019.pk3
 https://dl.dropboxusercontent.com/u/18995126/maps/zzz-monsters_007.pk3 https://dl.dropboxusercontent.com/u/18995126/maps/zzz-quickmenu_004.pk3)


Usage
=====

Compile GMQCC & copy the compiled binaries to client, menu & server folders inside esk-modpack/qcsrc  
Run this from a terminal in the qcsrc folder: make  
Copy the compiled .dat files from esk-modpack to Xonotic/data  
Copy the autoexec folder from esk-modpack to Xonotic/data  

Download the 2 server packages to your Xonotic/data folder & make sure they're available on your map download server  

To update, run this from a terminal in the esk-modpack folder: git pull  
Once this finishes, repeat previous usage steps