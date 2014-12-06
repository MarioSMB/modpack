SMB modpack
===========

MINSTAGIB SERVER OWNERS READ THIS: http://smbclan.net/wiki/Note_to_MinstaGib_server_owners
NOTE ABOUT UPDATES: Please read this before updating to latest mod: http://smbclan.net/wiki/Important_notice_to_server_owners_running_the_SMB_mod_pack

QuakeC source for the SMB server mods


Requirements
============

GMQCC - git://git.xonotic.org/xonotic/gmqcc.git  
Xonotic - http://xonotic.org/download or git://git.xonotic.org/xonotic/xonotic.git  
Required content packs - http://smb.djstrikes3.com/zzz-misc-v006-19-g43702ef.pk3 http://dl.smbclan.net/maps/zzz-quickmenu_010.pk3 http://dl.smbclan.net/maps/zzz-minigames-v006-18-gb6f5ebf.pk3
Optional content packs - http://smb.djstrikes3.com/zzz-monsters_009.pk3 http://smb.djstrikes3.com/zzz-vehicles_001.pk3


Usage
=====

Compile GMQCC & copy the compiled gmqcc binary from the gmqcc folder to modpack/qcsrc  
Run this from a terminal in the qcsrc folder: make QCC=../gmqcc  
Copy the compiled .dat files from modpack to Xonotic/data  
Copy the autoexec folder from modpack to Xonotic/data  

Download the content packs to Xonotic/data & make sure they're available on your map download server  


To update, run this from a terminal in the modpack folder: git pull  
Once this finishes, repeat previous usage steps