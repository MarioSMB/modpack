ESK modpack
===========

QuakeC source for the ESK server mods


Requirements
============

GMQCC (git://git.xonotic.org/xonotic/gmqcc.git)  
Xonotic (http://xonotic.org/download or git://git.xonotic.org/xonotic/xonotic.git)  
Required content packs (https://dl.dropboxusercontent.com/u/18995126/maps/zzz-misc_029.pk3 https://dl.dropboxusercontent.com/u/18995126/maps/zzz-quickmenu_008.pk3)
Optional content packs (https://dl.dropboxusercontent.com/u/18995126/maps/zzz-monsters_008.pk3 https://dl.dropboxusercontent.com/u/18995126/maps/zzz-vehicles_001.pk3)


Usage
=====

Compile GMQCC & copy the compiled binaries to the client and server folders inside esk-modpack/qcsrc  
Run this from a terminal in the qcsrc folder: make  
Copy the compiled .dat files from esk-modpack to Xonotic/data  
Copy the autoexec folder from esk-modpack to Xonotic/data  

Download the content packs to Xonotic/data & make sure they're available on your map download server  


To update, run this from a terminal in the esk-modpack folder: git pull  
Once this finishes, repeat previous usage steps