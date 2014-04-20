//***********************
//QUAKE 1 ENTITIES - So people can play quake1 maps with the xonotic weapons
//***********************
void spawnfunc_weapon_nailgun (void) {spawnfunc_weapon_electro();}
void spawnfunc_weapon_supernailgun (void) {spawnfunc_weapon_hagar();}
void spawnfunc_weapon_supershotgun (void) {spawnfunc_weapon_machinegun();}

void spawnfunc_item_spikes (void) {spawnfunc_item_bullets();}
//void spawnfunc_item_armor1 (void) {spawnfunc_item_armor_medium;}  // FIXME: in Quake this is green armor, in Xonotic maps it is an armor shard
void spawnfunc_item_armor2 (void) {spawnfunc_item_armor_large();}
void item_armorInv (void) {spawnfunc_item_armor_large();}
void spawnfunc_item_health (void) {if (self.spawnflags & 2) spawnfunc_item_health_mega();else spawnfunc_item_health_medium();}

//spawnfunc_item_spikes
//spawnfunc_item_health



