Quake Mod
=========

QuakeC source for the SMB Quake 1 mod


Requirements
============
 
Required content packs:
 - http://dl.xonotic.fps.gratis/zzz-quake1_12.pk3

Optional mission packs:
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp1_07.pk3
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp2_04.pk3
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp3_01.pk3
 - http://dl.xonotic.fps.gratis/zzz-quake1-mp4_02.pk3


Usage
=====

On server launch, you'll need to set a few cvars to make everything work:

`coop 1`  
`deathmatch 0`  
`registered 1`  
`sv_playerphysicsqc 1`  
`sv_gameplayfix_droptofloorstartsolid 1`  
`sv_gameplayfix_q1bsptracelinereportstexture 0`  
`exec physicsq.cfg`  


Mission packs will be enabled automatically if you add their pk3 to the server
