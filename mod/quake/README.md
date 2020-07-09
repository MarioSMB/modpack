Quake Mod
=========

QuakeC source for the SMB Quake 1 mod

[![Build Status](https://travis-ci.org/MarioSMB/modpack.svg?branch=quake)](https://travis-ci.org/MarioSMB/modpack)


Requirements
============
 
Required content packs:
 - http://dl.xonotic.fps.gratis/zzz-quake1_12.pk3

Optional mission packs:
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp1_07.pk3
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp2_04.pk3
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp3_01.pk3


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

If you wish to use the experimental Abyss of Pandemonium mission pack, you'll need the following instead:  
`set sv_missionpack_impel 1`
