#include "dummys.qh"

/*
+------+
|Dummys|
+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| This file contains delete(this); statements for entities not yet coded.    |
| This avoids Quake spewing out pages and pages of error messages when       |
| loading maps.                                                              |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

// General Junk
spawnfunc(event_lightning)           { delete(this); }
spawnfunc(misc_fireball)             { delete(this); }
spawnfunc(misc_explobox)             { delete(this); }
spawnfunc(misc_explobox2)            { delete(this); }
spawnfunc(trap_spikeshooter)         { delete(this); }
spawnfunc(trap_shooter)              { delete(this); }
spawnfunc(func_bossgate)             { delete(this); }
spawnfunc(func_episodegate)          { delete(this); }
spawnfunc(func_train)                { delete(this); }
spawnfunc(func_button)               { delete(this); }
spawnfunc(func_door)                 { delete(this); }
spawnfunc(func_door_secret)          { delete(this); }
spawnfunc(func_plat)                 { delete(this); }
spawnfunc(info_intermission)         { delete(this); }
spawnfunc(info_null)                 { delete(this); }
spawnfunc(info_teleport_destination) { delete(this); }

// Triggers
spawnfunc(trigger_relay)             { delete(this); }
spawnfunc(trigger_multiple)          { delete(this); }
spawnfunc(trigger_once)              { delete(this); }
spawnfunc(trigger_changelevel)       { delete(this); }
spawnfunc(trigger_counter)           { delete(this); }
spawnfunc(trigger_teleport)          { delete(this); }
spawnfunc(trigger_secret)            { delete(this); }
spawnfunc(trigger_setskill)          { delete(this); }
spawnfunc(trigger_monsterjump)       { delete(this); }
spawnfunc(trigger_onlyregistered)    { delete(this); }
spawnfunc(trigger_push)              { delete(this); }
spawnfunc(trigger_hurt)              { delete(this); }


spawnfunc(info_player_start2)        {}
spawnfunc(info_player_deathmatch)    {}
spawnfunc(info_player_coop)          {}

// Weapons
spawnfunc(weapon_supershotgun)       { delete(this); }
spawnfunc(weapon_nailgun)            { delete(this); }
spawnfunc(weapon_supernailgun)       { delete(this); }
spawnfunc(weapon_grenadelauncher)    { delete(this); }
spawnfunc(weapon_rocketlauncher)     { delete(this); }
spawnfunc(weapon_lightning)          { delete(this); }

// Monsters
spawnfunc(monster_enforcer)          { delete(this); }
spawnfunc(monster_ogre)              { delete(this); }
spawnfunc(monster_demon1)            { delete(this); }
spawnfunc(monster_shambler)          { delete(this); }
spawnfunc(monster_knight)            { delete(this); }
spawnfunc(monster_army)              { delete(this); }
spawnfunc(monster_wizard)            { delete(this); }
spawnfunc(monster_dog)               { delete(this); }
spawnfunc(monster_zombie)            { delete(this); }
spawnfunc(monster_boss)              { delete(this); }
spawnfunc(monster_tarbaby)           { delete(this); }
spawnfunc(monster_hell_knight)       { delete(this); }
spawnfunc(monster_fish)              { delete(this); }
spawnfunc(monster_shalrath)          { delete(this); }
spawnfunc(monster_oldone)            { delete(this); }

spawnfunc(item_health)               { delete(this); }
spawnfunc(item_megahealth_rot)       { delete(this); }
spawnfunc(item_armor1)               { delete(this); }
spawnfunc(item_armor2)               { delete(this); }
spawnfunc(item_armorInv)             { delete(this); }
spawnfunc(item_shells)               { delete(this); }
spawnfunc(item_spikes)               { delete(this); }
spawnfunc(item_rockets)              { delete(this); }
spawnfunc(item_cells)                { delete(this); }
spawnfunc(item_key1)                 { delete(this); }
spawnfunc(item_key2)                 { delete(this); }
spawnfunc(item_artifact_invulnerability)  { delete(this); }
spawnfunc(item_artifact_envirosuit)  { delete(this); }
spawnfunc(item_artifact_invisibility)  { delete(this); }
spawnfunc(item_artifact_super_damage)  { delete(this); }

spawnfunc(entity_rock)  { delete(this); }
spawnfunc(light_environment)  { delete(this); }
