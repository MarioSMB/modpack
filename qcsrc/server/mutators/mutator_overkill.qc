void ok_DecreaseCharge(entity ent, float wep)
{
	if not(autocvar_g_overkill_ammo_charge) return;
	
	entity wepent = get_weaponinfo(wep);
	
	if(wepent.netname == "")
		return; // dummy
	
	ent.ammo_charge[wep] -= cvar(sprintf("g_overkill_ammo_decharge_%s", wepent.netname));
}

void ok_IncreaseCharge(entity ent, float wep)
{
	entity wepent = get_weaponinfo(wep);
	
	if(wepent.netname == "")
		return; // dummy

	if(autocvar_g_overkill_ammo_charge)
	if not(ent.BUTTON_ATCK)
	if(ent.ammo_charge[wep] <= autocvar_g_overkill_ammo_charge_limit)
		ent.ammo_charge[wep] = min(autocvar_g_overkill_ammo_charge_limit, ent.ammo_charge[wep] + cvar(sprintf("g_overkill_ammo_charge_rate_%s", wepent.netname)) * frametime / W_TICSPERFRAME);
}

float ok_CheckWeaponCharge(entity ent, float wep, float swep)
{
	if not(autocvar_g_overkill_ammo_charge) return TRUE;
	if(wep != swep) return TRUE; // switching, don't even bother checking
	
	entity wepent = get_weaponinfo(wep);
	
	if(wepent.netname == "")
		return 0; // dummy
	
	return !(ent.ammo_charge[wep] < cvar(sprintf("g_overkill_ammo_decharge_%s", wepent.netname)));
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
	if(DEATH_ISWEAPON(frag_deathtype, WEP_LASER) && frag_target == frag_attacker)
		frag_damage = 0;
	
	if(!IS_PLAYER(frag_target) || frag_target == frag_attacker)
		return 0;
	
	if not (DEATH_ISWEAPON(frag_deathtype, WEP_LASER))
		return 0;
	
	frag_damage = 0;

	if(frag_target.health >= 1 && IS_PLAYER(frag_target) && !frag_target.frozen)
		Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_MINSTA_SECONDARY);

	frag_force = '0 0 0';
	frag_attacker = frag_target;
	
	return 0;
}

MUTATOR_HOOKFUNCTION(ok_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":OK");
	return 0;
}

MUTATOR_HOOKFUNCTION(ok_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Overkill");
	return 0;
}

void ok_Item_Touch()
{
	if(IS_PLAYER(other))
	if(other.deadflag == DEAD_NO)
	if(!other.frozen)
	{
		Item_Touch();
		remove(self);
	}
}

MUTATOR_HOOKFUNCTION(ok_PlayerDies)
{
	entity oldself = self;
	
	self.ok_lastwep = self.weapon;
	self.ok_deathloc = self.origin;
	self = spawn();
	self.ok_item = TRUE;
	self.noalign = TRUE;
	self.pickup_anyway = TRUE;
	spawnfunc_item_armor_small();
	self.movetype = MOVETYPE_TOSS;
	self.gravity = 1;
	setorigin(self, frag_target.origin + '0 0 32');
	self.velocity = '0 0 200' + normalize(frag_attacker.origin - self.origin) * 500;
	self.touch = ok_Item_Touch;
	SUB_SetFade(self, time + 5, 1);
	self = oldself;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_MonsterDrop)
{
	other.monster_loot = func_null;
	
	entity oldself;
	oldself = self;
	self = spawn();
	self.ok_item = TRUE;
	self.noalign = TRUE;
	self.pickup_anyway = TRUE;
	spawnfunc_item_armor_small();
	self.movetype = MOVETYPE_TOSS;
	self.gravity = 1;
	setorigin(self, oldself.origin + '0 0 32');
	self.velocity = randomvec() * 175 + '0 0 325';
	self.touch = ok_Item_Touch;
	SUB_SetFade(self, time + 5, 1);
	self = oldself;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_ForbidThrowCurrentWeapon)
{
	nades_CheckThrow();

	return TRUE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerPreThink)
{
	if(intermission_running || gameover)
		return FALSE;

	if(self.deadflag != DEAD_NO || !IS_PLAYER(self))
		return FALSE;

	if(self.frozen)
		return FALSE;
	
	if(self.ok_lastwep != 0)
	{
		if(self.ok_lastwep == WEP_HMG)
			W_SwitchWeapon(WEP_UZI);
		else if(self.ok_lastwep == WEP_RPC)
			W_SwitchWeapon(WEP_NEX);
		else
			W_SwitchWeapon(self.ok_lastwep);

		self.ok_lastwep = 0;
	}
	
	ok_IncreaseCharge(self, self.weapon);

	if(self.BUTTON_ATCK2)
	if(self.jump_interval <= time)
	{
		self.jump_interval = time + autocvar_g_balance_laser_primary_refire * W_WeaponRateFactor();
		makevectors(self.v_angle);
		W_Laser_Attack(3, WEP_LASER, WEP_LASER);
	}
	
	self.weapon_blocked = FALSE;
	
	self.ok_ammo_charge = self.ammo_charge[self.switchweapon];
	
	if(autocvar_g_overkill_ammo_charge)
	if(!ok_CheckWeaponCharge(self, self.weapon, self.switchweapon))
	{
		if(autocvar_g_overkill_ammo_charge_notice && time > self.ok_notice_time && self.BUTTON_ATCK)
		{
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_OVERKILL_CHARGE);
			self.ok_notice_time = time + 2;
			if(IS_REAL_CLIENT(self))
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
	
	self.ammo_nails = autocvar_g_overkill_ammo_start;
	self.ammo_cells = autocvar_g_overkill_ammo_start;
	self.ammo_shells = autocvar_g_overkill_ammo_start;
	self.ammo_rockets = autocvar_g_overkill_ammo_start;

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
		return TRUE;
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_ItemRemove)
{
	if(self.ok_item == TRUE)
		return FALSE;
		
	switch(self.items)
	{
		case IT_HEALTH: if(autocvar_g_overkill_100h_anyway) return FALSE;
		case IT_ARMOR: if(autocvar_g_overkill_100a_anyway) return FALSE;
		default: return TRUE;
	}
}

MUTATOR_HOOKFUNCTION(ok_ItemTouch)
{
	if (autocvar_g_overkill_superguns_builtin)
		return FALSE;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_SpectateCopy)
{
	self.ammo_charge[self.weapon] = other.ammo_charge[other.weapon];
	self.ok_use_ammocharge = other.ok_use_ammocharge;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_SetModname)
{
	modname = "Overkill";
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ok_StartItems)
{
	start_items |= IT_UNLIMITED_WEAPON_AMMO;
	start_weapons = (WEPSET_UZI | WEPSET_NEX | WEPSET_SHOTGUN);
	
	return FALSE;
}

void ok_SetCvars()
{
	// playermodels
	cvar_settemp("sv_defaultcharacter", "1");
	cvar_settemp("sv_defaultplayermodel", "models/ok_player/okrobot1.dpm models/ok_player/okrobot2.dpm models/ok_player/okrobot3.dpm models/ok_player/okrobot4.dpm models/ok_player/okmale1.dpm models/ok_player/okmale2.dpm models/ok_player/okmale3.dpm models/ok_player/okmale4.dpm");
	cvar_settemp("sv_defaultplayermodel_red", "models/ok_player/okrobot1.dpm models/ok_player/okrobot2.dpm models/ok_player/okrobot3.dpm models/ok_player/okrobot4.dpm");
	cvar_settemp("sv_defaultplayermodel_blue", "models/ok_player/okmale1.dpm models/ok_player/okmale2.dpm models/ok_player/okmale3.dpm models/ok_player/okmale4.dpm");

	// health/armor
	cvar_settemp("g_balance_health_regen", "0");
	cvar_settemp("g_balance_health_regenlinear", "100");
	cvar_settemp("g_balance_health_rot", "0");
	cvar_settemp("g_balance_health_rotstable", "200");
	cvar_settemp("g_balance_armor_rotstable", "0");
	cvar_settemp("g_balance_armor_rotlinear", "1");
	cvar_settemp("g_balance_armor_rot", "0");
	cvar_settemp("g_balance_pause_health_regen", "2");
	
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
	
	// uzi
	cvar_settemp("g_balance_uzi_mode", "1");
	cvar_settemp("g_balance_uzi_sustained_damage", "25");
	cvar_settemp("g_balance_uzi_sustained_refire", "0.1");
	cvar_settemp("g_balance_uzi_sustained_spread", "0.01");
	cvar_settemp("g_balance_uzi_sustained_force", "5");
	cvar_settemp("g_balance_uzi_reload_ammo", "30");
	cvar_settemp("g_balance_uzi_reload_time", "1.5");
	cvar_settemp("g_balance_uzi_primary_bulletconstant", "3000");
	
	// nex
	cvar_settemp("g_balance_nex_primary_damage", "100");
	cvar_settemp("g_balance_nex_primary_force", "500");
	cvar_settemp("g_balance_nex_primary_refire", "0.75");
	cvar_settemp("g_balance_nex_primary_animtime", "0.95");
	cvar_settemp("g_balance_nex_primary_ammo", "6");
	cvar_settemp("g_balance_nex_primary_damagefalloff_mindist", "0");
	cvar_settemp("g_balance_nex_primary_damagefalloff_maxdist", "0");
	cvar_settemp("g_balance_nex_primary_damagefalloff_halflife", "0");
	cvar_settemp("g_balance_nex_primary_damagefalloff_forcehalflife", "0");
	cvar_settemp("g_balance_nex_secondary", "1");
	cvar_settemp("g_balance_nex_charge", "0");
	cvar_settemp("g_balance_nex_reload_ammo", "30");
	cvar_settemp("g_balance_nex_reload_time", "2");
	
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
	
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("weapons/dryfire.wav");

	w_uzi(WR_PRECACHE);
	w_nex(WR_PRECACHE);
	w_shotgun(WR_PRECACHE);
	w_laser(WR_PRECACHE);
	
	(get_weaponinfo(WEP_RPC)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
	(get_weaponinfo(WEP_HMG)).spawnflags &= ~WEP_FLAG_MUTATORBLOCKED;
	
	(get_weaponinfo(WEP_SHOTGUN)).mdl = "ok_shotgun";
	(get_weaponinfo(WEP_UZI)).mdl = "ok_mg";
	(get_weaponinfo(WEP_NEX)).mdl = "ok_sniper";
}

MUTATOR_DEFINITION(mutator_overkill)
{
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, ok_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, ok_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, ok_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, ok_PlayerPreThink, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerSpawn, ok_PlayerSpawn, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerDamage_Calculate, ok_PlayerDamage_Calculate, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerDies, ok_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, ok_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(ItemTouch, ok_ItemTouch, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, ok_SetModname, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, ok_ItemRemove, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterDropItem, ok_MonsterDrop, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, ok_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, ok_StartItems, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		ok_Initialize();
	}
	
	MUTATOR_ONREMOVE
	{
		(get_weaponinfo(WEP_RPC)).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
		(get_weaponinfo(WEP_HMG)).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
	}

	return 0;
}
