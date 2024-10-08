Quake Mod
=========

QuakeC source for the SMB Quake 1 mod


Requirements
============
 
Required content packs:
 - https://dl.xonotic.fps.gratis/zzz-quake1-assets_05.pk3
 - https://dl.xonotic.fps.gratis/zzz-quake1-champions_01.pk3
 - https://dl.xonotic.fps.gratis/zzz-quake1-items_01.pk3
 - https://dl.xonotic.fps.gratis/zzz-quake1-monsters_01.pk3

Some optional mission packs:
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
 - http://dl.xonotic.fps.gratis/q1-tiddles_01.pk3
 - http://dl.xonotic.fps.gratis/q1-insomnia_01.pk3
 - http://dl.xonotic.fps.gratis/q1-dmd_01.pk3


Usage
=====

On server launch, you'll need to set a few cvars to make everything work:

`coop 1`  
`deathmatch 0`  
`sv_playerphysicsqc 1`  
`mod_q1bsp_polygoncollisions 0`  
`sv_gameplayfix_droptofloorstartsolid_nudgetocorrect 0`  
`sv_legacy_bbox_expand 1`  
`sv_areagrid_link_SOLID_NOT 1`  
`exec physicsq.cfg`    


Mission packs will be enabled automatically if you add their pk3 to the server
