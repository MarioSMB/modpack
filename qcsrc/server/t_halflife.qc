
.float  roomtype;
.float  radius;
.float  pitch;
.float  renderamt;
.float  rendermode;
.vector rendercolor;

void spawnfunc_weapon_crossbow() {}
void spawnfunc_weapon_handgrenade() {}
void spawnfunc_ammo_crossbow() {}
void spawnfunc_ammo_9mmclip() {}
void spawnfunc_ammo_gaussclip() {}
void spawnfunc_weapon_rpg() {}
void spawnfunc_weapon_357() {}
void ammo_ARgrenades() {}
void spawnfunc_item_battery() {}
void spawnfunc_ammo_rpgclip() {}
void weapon_9mmAR() {}
void spawnfunc_weapon_tripmine() {}
void spawnfunc_weapon_snark() {}
void spawnfunc_ammo_buckshot() {}
void ammo_9mmAR() {}
void spawnfunc_ammo_357() {}
void spawnfunc_weapon_gauss() {}
void spawnfunc_weapon_hornetgun() {}
//void spawnfunc_weapon_shotgun() {}
void spawnfunc_item_healthkit() {}
void spawnfunc_item_longjump() {}
void spawnfunc_item_antidote() {}
void spawnfunc_func_recharge() {}
void spawnfunc_info_node() {}
void spawnfunc_env_sound() {}
void spawnfunc_light_spot() {}
void spawnfunc_func_healthcharger() {}


void func_ladder_touch()
{
	if not(other.iscreature)
		return;
	if (other.vehicle_flags & VHF_ISVEHICLE)
		return;

	EXACTTRIGGER_TOUCH;

	other.ladder_time = time + 0.1;
	other.ladder_entity = self;
}

void spawnfunc_func_ladder()
{
	EXACTTRIGGER_INIT;
	self.touch = func_ladder_touch;
}

void spawnfunc_func_water()
{
	EXACTTRIGGER_INIT;
	self.touch = func_ladder_touch;
}

