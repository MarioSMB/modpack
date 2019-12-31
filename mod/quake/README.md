Quake Mod
=========

QuakeC source for the SMB Quake 1 mod

[![Build Status](https://travis-ci.org/MarioSMB/modpack.svg?branch=quake)](https://travis-ci.org/MarioSMB/modpack)


Requirements
============
 
Required content packs:
 - http://dl.xonotic.co/zzz-quake1_10.pk3

Optional mission packs:
 - http://dl.xonotic.co/zzz-quake1-mp1_05.pk3
 - http://dl.xonotic.co/zzz-quake1-mp2_03.pk3


Usage
=====

On server launch, you'll need to set a few cvars to make everything work:

`coop 1`  
`deathmatch 0`  
`registered 1`  
`sv_playerphysicsqc 1`  
`sv_gameplayfix_droptofloorstartsolid 1`  


If you wish to use the Scourge of Armagon mission pack, you'll need the following as well:  
`set sv_missionpack_hipnotic 1`

If you wish to use the Dissolution of Eternity mission pack, you'll need the following instead:  
`set sv_missionpack_rogue 1`