void ok_DecreaseCharge(entity ent, float wep)
{
	if(!ent.ok_use_ammocharge) return;

	entity wepent = get_weaponinfo(wep);

	if(wepent.weapon == 0)
		return; // dummy

	ent.ammo_charge[wep] -= max(0, cvar(sprintf("g_overkill_ammo_decharge_%s", wepent.netname)));
}

void ok_IncreaseCharge(entity ent, float wep)
{
	entity wepent = get_weaponinfo(wep);

	if(wepent.weapon == 0)
		return; // dummy

	if(ent.ok_use_ammocharge)
	if(!ent.BUTTON_ATCK) // not while attacking?
		ent.ammo_charge[wep] = min(autocvar_g_overkill_ammo_charge_limit, ent.ammo_charge[wep] + cvar(sprintf("g_overkill_ammo_charge_rate_%s", wepent.netname)) * frametime / W_TICSPERFRAME);
}

float ok_CheckWeaponCharge(entity ent, float wep)
{
	if(!ent.ok_use_ammocharge) return TRUE;

	entity wepent = get_weaponinfo(wep);

	if(wepent.weapon == 0)
		return 0; // dummy

	return (ent.ammo_charge[wep] >= cvar(sprintf("g_overkill_ammo_decharge_%s", wepent.netname)));
}

void start_hmg()
{
	self.classname = "weapon_hmg";
	self.respawntime = autocvar_g_overkill_superguns_respawn_time;
	self.ok_item = TRUE;
	setmodel(self, "models/weapons/g_ok_hmg.md3");
	self.pickup_anyway = TRUE;
	spawnfunc_weapon_hmg();
}

void start_rpc()
{
	self.classname = "weapon_rpc";
	self.respawntime = autocvar_g_overkill_superguns_respawn_time;
	self.ok_item = TRUE;
	self.pickup_anyway = TRUE;
	setmodel(self, "models/weapons/g_ok_rl.md3");
	spawnfunc_weapon_rpc();
}

void start_mh_anyway()
{
	self.classname = "item_health_mega";
	self.ok_item = TRUE;
	self.pickup_anyway = TRUE;
	spawnfunc_item_health_mega();
}

void start_ma_anyway()
{
	self.pickup_anyway = TRUE;
	self.ok_item = TRUE;
	self.classname = "item_armor_large";
	spawnfunc_item_armor_large();
}

MUTATOR_HOOKFUNCTION(ok_PlayerDamage_Calculate)
{
	if(IS_PLAYER(frag_attacker) && IS_PLAYER(frag_target))
	if(DEATH_ISWEAPON(frag_deathtype, WEP_BLASTER))
	{
		frag_damage = 0;

		if(frag_attacker != frag_target)
		if(frag_target.health > 0)
		if(frag_target.frozen == 0)
		if(frag_target.deadflag == DEAD_NO)
		{
			Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_SECONDARY_NODAMAGE);
			frag_force = '0 0 0';
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerDamage_SplitHealthArmor)
{
	if(damage_take)
		self.ok_pauseregen_finished = max(self.ok_pauseregen_finished, time + 2);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerDies)
{
	entity oldself = self;

	if(IS_MONSTER(self))
	{
		remove(other); // remove default item
		other = world;
	}

	self.ok_lastwep = self.weapon;
	self.ok_deathloc = self.origin;
	self = spawn();
	self.ok_item = TRUE;
	self.noalign = TRUE;
	self.pickup_anyway = TRUE;
	spawnfunc_item_armor_small();
	self.movetype = MOVETYPE_TOSS;
	self.gravity = 1;
	self.reset = SUB_Remove;
	setorigin(self, frag_target.origin + '0 0 32');
	self.velocity = '0 0 200' + normalize(frag_attacker.origin - self.origin) * 500;
	self.classname = "droppedweapon"; // hax
	SUB_SetFade(self, time + 5, 1);
	self = oldself;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerRegen)
{
	// overkill's values are different, so use custom regen
	if(!self.frozen)
	{
		self.armorvalue = CalcRotRegen(self.armorvalue, autocvar_g_balance_armor_regenstable, autocvar_g_balance_armor_regen, autocvar_g_balance_armor_regenlinear, 1 * frametime * (time > self.ok_pauseregen_finished), 0, 0, 1, 1 * frametime * (time > self.pauserotarmor_finished), autocvar_g_balance_armor_limit);
		self.health = CalcRotRegen(self.health, autocvar_g_balance_health_regenstable, 0, 100, 1 * frametime * (time > self.ok_pauseregen_finished), 200, 0, autocvar_g_balance_health_rotlinear, 1 * frametime * (time > self.pauserothealth_finished), autocvar_g_balance_health_limit);
		
		float minf, maxf, limitf;

		maxf = autocvar_g_balance_fuel_rotstable;
		minf = autocvar_g_balance_fuel_regenstable;
		limitf = autocvar_g_balance_fuel_limit;

		self.ammo_fuel = CalcRotRegen(self.ammo_fuel, minf, autocvar_g_balance_fuel_regen, autocvar_g_balance_fuel_regenlinear, frametime * (time > self.pauseregen_finished) * ((self.items & IT_FUEL_REGEN) != 0), maxf, autocvar_g_balance_fuel_rot, autocvar_g_balance_fuel_rotlinear, frametime * (time > self.pauserotfuel_finished), limitf);
	}
	return TRUE; // return TRUE anyway, as frozen uses no regen
}

MUTATOR_HOOKFUNCTION(ok_ForbidThrowCurrentWeapon)
{
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerPreThink)
{
	if(intermission_running || gameover)
		return FALSE;

	if(self.deadflag != DEAD_NO || !IS_PLAYER(self) || self.frozen)
		return FALSE;

	ok_IncreaseCharge(self, self.weapon);
	
	float weaponuse_forbidden = forbidWeaponUse(self);

	if(self.BUTTON_ATCK2)
	if(!weaponuse_forbidden || (weaponuse_forbidden == 4 || weaponuse_forbidden == 2)) // allow if weapon is blocked
	if(time >= self.jump_interval)
	{
		self.jump_interval = time + WEP_CVAR_PRI(blaster, refire) * W_WeaponRateFactor();
		makevectors(self.v_angle);
		
		W_Blaster_Attack(
			WEP_BLASTER | HITTYPE_SECONDARY,
			WEP_CVAR_SEC(vaporizer, shotangle),
			WEP_CVAR_SEC(vaporizer, damage),
			WEP_CVAR_SEC(vaporizer, edgedamage),
			WEP_CVAR_SEC(vaporizer, radius),
			WEP_CVAR_SEC(vaporizer, force),
			WEP_CVAR_SEC(vaporizer, speed),
			WEP_CVAR_SEC(vaporizer, spread),
			WEP_CVAR_SEC(vaporizer, delay),
			WEP_CVAR_SEC(vaporizer, lifetime)
		);
	}

	self.weapon_blocked = FALSE;

	self.ok_ammo_charge = self.ammo_charge[self.weapon];

	if(self.ok_use_ammocharge)
	if(!ok_CheckWeaponCharge(self, self.weapon))
	{
		if(autocvar_g_overkill_ammo_charge_notice && time > self.ok_notice_time && self.BUTTON_ATCK && IS_REAL_CLIENT(self) && self.weapon == self.switchweapon)
		{
			//Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_OVERKILL_CHARGE);
			self.ok_notice_time = time + 2;
			play2(self, "weapons/dryfire.wav");
		}
		if(self.weaponentity.state != WS_CLEAR)
			w_ready();

		self.weapon_blocked = TRUE;
	}

	self.BUTTON_ATCK2 = 0;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerSpawn)
{
	if(autocvar_g_overkill_ammo_charge)
	{
		float i;

		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
			self.ammo_charge[i] = autocvar_g_overkill_ammo_charge_limit;

		self.ok_use_ammocharge = 1;
		self.ok_notice_time = time;
	}
	else
		self.ok_use_ammocharge = 0;
		
	self.ok_pauseregen_finished = time + 2;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_OnEntityPreSpawn)
{
	if(autocvar_g_powerups)
	if(autocvar_g_overkill_powerups_replace)
	if(self.classname == "item_strength")
	{
		entity wep = spawn();
		setorigin(wep, self.origin);
		wep.ok_item = TRUE;
		wep.think = start_hmg;
		wep.nextthink = time + 0.1;
		wep.noalign = self.noalign;
		return TRUE;
	}

	if(autocvar_g_powerups)
	if(autocvar_g_overkill_powerups_replace)
	if(self.classname == "item_invincible")
	{
		entity wep = spawn();
		setorigin(wep, self.origin);
		wep.ok_item = TRUE;
		wep.think = start_rpc;
		wep.nextthink = time + 0.1;
		wep.noalign = self.noalign;
		return TRUE;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_ItemRemove)
{
	if(self.ok_item)
		return FALSE;

	switch(self.items)
	{
		case IT_HEALTH: return !(autocvar_g_overkill_100h_anyway);
		case IT_ARMOR: return !(autocvar_g_overkill_100a_anyway);
	}

	return TRUE;
}

MUTATOR_HOOKFUNCTION(ok_SpectateCopy)
{
	self.ammo_charge[self.weapon] = other.ammo_charge[other.weapon];
	self.ok_use_ammocharge = other.ok_use_ammocharge;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_StartItems)
{
	start_items |= IT_UNLIMITED_WEAPON_AMMO;
	start_weapons = warmup_start_weapons = (WEPSET_MACHINEGUN | WEPSET_VORTEX | WEPSET_SHOTGUN);

	start_ammo_nails = start_ammo_cells = start_ammo_shells = start_ammo_rockets =
	warmup_start_ammo_nails = warmup_start_ammo_cells = warmup_start_ammo_shells = warmup_start_ammo_rockets = autocvar_g_overkill_ammo_start; // is this really needed? ammo isn't used anymore, but should default above 0

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":OK");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Overkill");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_SetModname)
{
	modname = "Overkill";
	return TRUE;
}

void ok_SetCvars()
{
	// TODO: kill this awful mess

	// playermodels
	cvar_settemp("sv_defaultcharacter", "1");
	cvar_settemp("sv_defaultplayermodel", "models/ok_player/okrobot1.dpm models/ok_player/okrobot2.dpm models/ok_player/okrobot3.dpm models/ok_player/okrobot4.dpm models/ok_player/okmale1.dpm models/ok_player/okmale2.dpm models/ok_player/okmale3.dpm models/ok_player/okmale4.dpm");
	cvar_settemp("sv_defaultplayermodel_red", "models/ok_player/okrobot1.dpm models/ok_player/okrobot2.dpm models/ok_player/okrobot3.dpm models/ok_player/okrobot4.dpm");
	cvar_settemp("sv_defaultplayermodel_blue", "models/ok_player/okmale1.dpm models/ok_player/okmale2.dpm models/ok_player/okmale3.dpm models/ok_player/okmale4.dpm");

	// shotgun
	cvar_settemp("g_balance_shotgun_primary_damage", "17");
	cvar_settemp("g_balance_shotgun_primary_bullets", "10");
	cvar_settemp("g_balance_shotgun_primary_force", "80");
	cvar_settemp("g_balance_shotgun_primary_spread", "0.07");
	cvar_settemp("g_balance_shotgun_primary_animtime", "0.65");
	cvar_settemp("g_balance_shotgun_primary_ammo", "6.25");
	cvar_settemp("g_balance_shotgun_reload_ammo", "50");
	cvar_settemp("g_balance_shotgun_reload_time", "2");
	cvar_settemp("g_balance_shotgun_primary_bulletconstant", "3000");

	// machinegun
	cvar_settemp("g_balance_machinegun_mode", "1");
	cvar_settemp("g_balance_machinegun_sustained_damage", "25");
	cvar_settemp("g_balance_machinegun_sustained_refire", "0.1");
	cvar_settemp("g_balance_machinegun_sustained_spread", "0.01");
	cvar_settemp("g_balance_machinegun_sustained_force", "5");
	cvar_settemp("g_balance_machinegun_reload_ammo", "30");
	cvar_settemp("g_balance_machinegun_reload_time", "1.5");
	cvar_settemp("g_balance_machinegun_primary_bulletconstant", "3000");

	// vortex
	cvar_settemp("g_balance_vortex_primary_damage", "100");
	cvar_settemp("g_balance_vortex_primary_force", "500");
	cvar_settemp("g_balance_vortex_primary_refire", "0.75");
	cvar_settemp("g_balance_vortex_primary_animtime", "0.75");
	cvar_settemp("g_balance_vortex_primary_ammo", "6");
	cvar_settemp("g_balance_vortex_primary_damagefalloff_mindist", "0");
	cvar_settemp("g_balance_vortex_primary_damagefalloff_maxdist", "0");
	cvar_settemp("g_balance_vortex_primary_damagefalloff_halflife", "0");
	cvar_settemp("g_balance_vortex_primary_damagefalloff_forcehalflife", "0");
	cvar_settemp("g_balance_vortex_secondary", "1");
	cvar_settemp("g_balance_vortex_charge", "0");
	cvar_settemp("g_balance_vortex_reload_ammo", "30");
	cvar_settemp("g_balance_vortex_reload_time", "2");

	// misc
	cvar_settemp("g_projectiles_newton_style_2_minfactor", "1");
	cvar_settemp("g_pickup_healthmega_anyway", "0");
	cvar_settemp("g_pickup_healthmega_max", "100");
	cvar_settemp("g_pickup_armorsmall_anyway", "0");
	cvar_settemp("g_pickup_armorsmall_max", "20");
}

void ok_Initialize()
{
	ok_SetCvars();

	precache_all_playermodels("models/ok_player/*.dpm");

	precache_model("models/weapons/h_ok_rl.iqm");
	precache_model("models/weapons/v_ok_rl.md3");
	precache_model("models/weapons/g_ok_rl.md3");
	precache_model("models/weapons/ok_rocket.md3");

	precache_model("models/weapons/h_ok_mg.iqm");
	precache_model("models/weapons/v_ok_mg.md3");
	precache_model("models/weapons/g_ok_mg.md3");

	precache_model("models/weapons/h_ok_hmg.iqm");
	precache_model("models/weapons/v_ok_hmg.md3");
	precache_model("models/weapons/g_ok_hmg.md3");

	precache_model("models/weapons/h_ok_shotgun.iqm");
	precache_model("models/weapons/v_ok_shotgun.md3");
	precache_model("models/weapons/g_ok_shotgun.md3");

	precache_model("models/weapons/h_ok_sniper.iqm");
	precache_model("models/weapons/v_ok_sniper.md3");
	precache_model("models/weapons/g_ok_sniper.md3");

	precache_sound("weapons/dryfire.wav");

	addstat(STAT_OK_AMMO_CHARGE, AS_FLOAT, ok_use_ammocharge);
	addstat(STAT_OK_AMMO_CHARGEPOOl, AS_FLOAT, ok_ammo_charge);

	WEP_ACTION(WEP_MACHINEGUN, WR_INIT);
	WEP_ACTION(WEP_VORTEX, WR_INIT);
	WEP_ACTION(WEP_SHOTGUN, WR_INIT);
	WEP_ACTION(WEP_BLASTER, WR_INIT);

	(get_weaponinfo(WEP_RPC)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
	(get_weaponinfo(WEP_HMG)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
	(get_weaponinfo(WEP_SHOTGUN)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;

	(get_weaponinfo(WEP_SHOTGUN)).mdl = "ok_shotgun";
	(get_weaponinfo(WEP_MACHINEGUN)).mdl = "ok_mg";
	(get_weaponinfo(WEP_VORTEX)).mdl = "ok_sniper";
}

MUTATOR_DEFINITION(mutator_overkill)
{
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, ok_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, ok_PlayerPreThink, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerSpawn, ok_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, ok_PlayerDamage_Calculate, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerDamage_SplitHealthArmor, ok_PlayerDamage_SplitHealthArmor, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, ok_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerRegen, ok_PlayerRegen, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, ok_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, ok_ItemRemove, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterDropItem, ok_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, ok_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, ok_StartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, ok_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, ok_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, ok_SetModname, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		ok_Initialize();
	}

	MUTATOR_ONREMOVE
	{
		(get_weaponinfo(WEP_RPC)).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
		(get_weaponinfo(WEP_HMG)).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
	}

	return FALSE;
}
