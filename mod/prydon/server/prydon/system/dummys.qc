/*
+------+
|Dummys|
+------+-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| Scratch                                      Http://www.admdev.com/scratch |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
| This file contains remove(self); statements for entities not yet coded.    |
| This avoids Quake spewing out pages and pages of error messages when       |
| loading maps.                                                              |
+=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-+
*/

// General Junk
void() event_lightning          = {remove(self);};
void() misc_fireball            = {remove(self);};
void() misc_explobox            = {remove(self);};
void() misc_explobox2           = {remove(self);};
void() trap_spikeshooter        = {remove(self);};
void() trap_shooter             = {remove(self);};
void() func_bossgate            = {remove(self);};
void() func_episodegate         = {remove(self);};
void() func_train               = {remove(self);};
void() func_button              = {remove(self);};
void() func_door                = {remove(self);};
void() func_door_secret         = {remove(self);};
void() func_plat                = {remove(self);};
void() info_intermission        = {remove(self);};
void() info_null                = {remove(self);};
void() info_teleport_destination= {remove(self);};

// Triggers
void() trigger_relay            = {remove(self);};
void() trigger_multiple         = {remove(self);};
void() trigger_once             = {remove(self);};
void() trigger_changelevel      = {remove(self);};
void() trigger_counter          = {remove(self);};
void() trigger_teleport         = {remove(self);};
void() trigger_secret           = {remove(self);};
void() trigger_setskill         = {remove(self);};
void() trigger_monsterjump      = {remove(self);};
void() trigger_onlyregistered   = {remove(self);};
void() trigger_push             = {remove(self);};
void() trigger_hurt             = {remove(self);};


void() info_player_start2       = {};
void() info_player_deathmatch   = {};
void() info_player_coop         = {};

// Weapons
void() weapon_supershotgun      = {remove(self);};
void() weapon_nailgun           = {remove(self);};
void() weapon_supernailgun      = {remove(self);};
void() weapon_grenadelauncher   = {remove(self);};
void() weapon_rocketlauncher    = {remove(self);};
void() weapon_lightning         = {remove(self);};

// Monsters
void() monster_enforcer         = {remove(self);};
void() monster_ogre             = {remove(self);};
void() monster_demon1           = {remove(self);};
void() monster_shambler         = {remove(self);};
void() monster_knight           = {remove(self);};
void() monster_army             = {remove(self);};
void() monster_wizard           = {remove(self);};
void() monster_dog              = {remove(self);};
void() monster_zombie           = {remove(self);};
void() monster_boss             = {remove(self);};
void() monster_tarbaby          = {remove(self);};
void() monster_hell_knight      = {remove(self);};
void() monster_fish             = {remove(self);};
void() monster_shalrath         = {remove(self);};
void() monster_oldone           = {remove(self);};

void() item_health              = {remove(self);};
void() item_megahealth_rot      = {remove(self);};
void() item_armor1              = {remove(self);};
void() item_armor2              = {remove(self);};
void() item_armorInv            = {remove(self);};
void() item_shells              = {remove(self);};
void() item_spikes              = {remove(self);};
void() item_rockets             = {remove(self);};
void() item_cells               = {remove(self);};
void() item_key1                = {remove(self);};
void() item_key2                = {remove(self);};
void() item_artifact_invulnerability = {remove(self);};
void() item_artifact_envirosuit = {remove(self);};
void() item_artifact_invisibility = {remove(self);};
void() item_artifact_super_damage = {remove(self);};

void() entity_rock = {remove(self); };
void() light_environment = {remove(self);};
