Quake Mod
=========

QuakeC source for the SMB Quake 1 mod


Requirements
============
 
Required content packs:
 - http://dl.xonotic.fps.gratis/zzz-quake1-assets_01.pk3
 - http://dl.xonotic.fps.gratis/zzz-quake1-extras_08.pk3
 - http://dl.xonotic.fps.gratis/q1-campaign_01.pk3

Optional mission packs:
 - http://dl.xonotic.fps.gratis/q1-horde_01.pk3
 - http://dl.xonotic.fps.gratis/q1-hipnotic_02.pk3
 - http://dl.xonotic.fps.gratis/q1-rogue_01.pk3
 - http://dl.xonotic.fps.gratis/q1-impel_01.pk3
 - http://dl.xonotic.fps.gratis/q1-bbelief_01.pk3
 - http://dl.xonotic.fps.gratis/q1-cn_01.pk3
 - http://dl.xonotic.fps.gratis/q1-coldlight_01.pk3
 - http://dl.xonotic.fps.gratis/q1-contract_02.pk3
 - http://dl.xonotic.fps.gratis/q1-dopa_04.pk3
 - http://dl.xonotic.fps.gratis/q1-eod_01.pk3
 - http://dl.xonotic.fps.gratis/q1-sot_01.pk3
 - http://dl.xonotic.fps.gratis/q1-targetquake_01.pk3
 - http://dl.xonotic.fps.gratis/q1-terra_01.pk3


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
