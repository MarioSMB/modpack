void nade_timer_think()
{
	self.skin = 8 - (self.owner.wait - time) / (autocvar_g_overkill_nade_lifetime / 10);
	self.nextthink = time;
	if(!self.owner || wasfreed(self.owner))
		remove(self);
	
}

void ok_nade_burn_spawn(entity nade)
{
	switch(nade.realowner.team)
	{
		case NUM_TEAM_1:
			CSQCProjectile(nade, TRUE, PROJECTILE_OK_NADE_RED_BURN, TRUE);
			break;
		case NUM_TEAM_2:
			CSQCProjectile(nade, TRUE, PROJECTILE_OK_NADE_BLUE_BURN, TRUE);
			break;
		default:
			CSQCProjectile(nade, TRUE, PROJECTILE_OK_NADE_RED_BURN, TRUE);
			break;
	}
}

void ok_nade_spawn(entity nade)
{
	entity timer = spawn();
	setmodel(timer, "models/ok_nade_counter/ok_nade_counter.md3");
	setattachment(timer, nade, "");
	timer.classname = "overkill_nade_timer";
	timer.colormap = nade.colormap;
	timer.glowmod = nade.glowmod;
	timer.think = nade_timer_think;
	timer.nextthink = time;
	timer.wait = nade.wait;
	timer.owner = nade;	
	timer.skin = 10;
	
	CSQCProjectile(nade, TRUE, ((nade.realowner.team == NUM_TEAM_2) ? PROJECTILE_OK_NADE_BLUE: PROJECTILE_OK_NADE_RED) , TRUE);
	
}

void nade_boom() // TODO: DamageInfo
{
	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTN_NORM);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	//ok_nade_explosion_spawn(self);
	pointparticles(particleeffectnum((self.realowner.team == NUM_TEAM_2) ? "ok_grenade_blue_explode" : "ok_grenade_red_explode"), self.origin + '0 0 1', '0 0 0', 1);


	self.takedamage = DAMAGE_NO;
	RadiusDamage(self, self.realowner, autocvar_g_overkill_nade_damage, autocvar_g_overkill_nade_edgedamage,
				 autocvar_g_overkill_nade_radius, self, autocvar_g_overkill_nade_force, self.projectiledeathtype, self.enemy);

	remove(self);
}

void nade_touch()
{
	PROJECTILE_TOUCH;
	setsize(self, '-2 -2 -2', '2 2 2');
	UpdateCSQCProjectile(self);
	if(self.health == autocvar_g_overkill_nade_health)
	{
		spamsound(self, CH_SHOTS, strcat("weapons/grenade_bounce", ftos(1 + rint(random() * 5)), ".wav"), VOL_BASE, ATTN_NORM);
		return;
	}

	self.enemy = other;
	nade_boom();
}

void nade_beep()
{
	sound(self, CH_SHOTS_SINGLE, "overkill/grenadebip.ogg", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
	self.think = nade_boom;
	self.nextthink = max(self.wait, time);
}

void ok_nade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(DEATH_ISWEAPON(deathtype, WEP_LASER))
		return;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX)  || DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
	{
		force *= 6;
		damage = autocvar_g_overkill_nade_health * 0.55;
		self.projectiledeathtype = DEATH_NADE_NEX;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_UZI) || DEATH_ISWEAPON(deathtype, WEP_HMG))
	{
		self.projectiledeathtype = DEATH_NADE_MG;
		damage = autocvar_g_overkill_nade_health * 0.1;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN))
	{
		damage = autocvar_g_overkill_nade_health * 1.1;
		self.projectiledeathtype = DEATH_NADE_SG;
	}
	
	self.velocity += force;

	if(!damage)
		return;

	if(self.health == autocvar_g_overkill_nade_health)
	{
		sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
		self.nextthink = max(time + autocvar_g_overkill_nade_lifetime, time);
		self.think = nade_beep;
	}

	self.health   -= damage;
	self.realowner = attacker;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, nade_boom);
	else
		ok_nade_burn_spawn(self);
}

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

.entity fake_nade;
void ok_toss_nade(entity e, vector _velocity, float _time)
{
	entity _nade = e.ok_nade;
	e.ok_nade = world;
	
	remove(e.fake_nade);
	e.fake_nade = world;
	
	makevectors(self.angles);
	
	Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_OVERKILL);
	
	setorigin(_nade, CENTER_OR_VIEWOFS(e) + (v_right * 10) * -1);
	setmodel(_nade, "models/weapons/v_ok_grenade.md3");
	setattachment(_nade, world, "");
	PROJECTILE_MAKETRIGGER(_nade);
	setsize(_nade, '-16 -16 -16', '16 16 16');
	_nade.movetype = MOVETYPE_BOUNCE;
	
	if(e.crouch)
		_nade.velocity = '0 0 -10';
	else if(autocvar_g_overkill_nade_newton_style == 1)
		_nade.velocity = e.velocity + _velocity;
	else if(autocvar_g_overkill_nade_newton_style == 2)
		_nade.velocity = _velocity;
	else
		_nade.velocity = W_CalculateProjectileVelocity(e.velocity, _velocity, FALSE);

	_nade.solid = SOLID_BBOX;
	_nade.touch = nade_touch;
	_nade.health = autocvar_g_overkill_nade_health;
	_nade.takedamage = DAMAGE_YES;
	_nade.event_damage = ok_nade_damage;
	_nade.teleportable = TRUE;

	ok_nade_spawn(_nade);

	if(_time)
	{
		_nade.think = nade_boom;
		_nade.nextthink = _time;
	}
	else
		_nade.projectiledeathtype = DEATH_NADE_NORMAL;

	e.ok_nade_refire = time + autocvar_g_overkill_nade_refire;
}

void ok_nade_prime()
{
	if(self.ok_nade)
	{
		dprint("overkill: WARNING - self.ok_nade was already spawned!\n");
		remove(self.ok_nade);
	}
	
	if(self.fake_nade)
		remove(self.fake_nade);
		
	makevectors(self.angles);
	
	self.ok_nade = spawn();
	setmodel(self.ok_nade, "null");
	setattachment(self.ok_nade, self, "bip01 l hand");
	self.ok_nade.classname = "overkill_nade";
	self.ok_nade.realowner = self;
	self.ok_nade.colormap = self.colormap;
	self.ok_nade.glowmod = self.glowmod;
	self.ok_nade.wait = time + autocvar_g_overkill_nade_lifetime;
	self.ok_nade.cnt = time;
	self.ok_nade.think = nade_beep;
	self.ok_nade.nextthink = max(self.ok_nade.wait - 3, time);
	self.ok_nade.projectiledeathtype = DEATH_NADE_NORMAL;
	
	self.fake_nade = spawn();
	setmodel(self.fake_nade, "models/weapons/h_ok_grenade.iqm");
	setattachment(self.fake_nade, self.weaponentity, "");
	self.fake_nade.classname = "fake_nade";
	//self.fake_nade.viewmodelforclient = self;
	self.fake_nade.realowner = self.fake_nade.owner = self;
	self.fake_nade.colormap = self.colormap;
	self.fake_nade.glowmod = self.glowmod;
	self.fake_nade.think = SUB_Remove;
	self.fake_nade.nextthink = self.ok_nade.wait;
}

float ok_CanThrowNade()
{
	if(self.vehicle)
		return FALSE;
		
	if(gameover)
		return FALSE;
	
	if not(autocvar_g_overkill_nades)
		return FALSE;
		
	if(forbidWeaponUse())
		return FALSE;
		
	return TRUE;
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

MUTATOR_HOOKFUNCTION(ok_VehicleEnter)
{
	if(other.ok_nade)
		ok_toss_nade(other, '0 0 100', max(other.ok_nade.wait, time + 0.05));
		
	return FALSE;
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

MUTATOR_HOOKFUNCTION(ok_ClientDisconnect)
{
	if(self.ok_nade)
		remove(self.ok_nade);
		
	if(self.fake_nade)
		remove(self.fake_nade);

	return 0;
}

MUTATOR_HOOKFUNCTION(ok_WeaponSetup)
{
	switch(self.weapon)
	{
		case WEP_SHOTGUN:
			self.weaponname = "ok_shotgun";
			break;
		case WEP_UZI:
			self.weaponname = "ok_mg";
			break;
		case WEP_NEX:
			self.weaponname = "ok_sniper";
			break;
		case WEP_HMG:
			self.weaponname = "ok_hmg";
			break;  
		case WEP_RPC:
			self.weaponname = "ok_rl";
			break;
	}

	return 0;
}

MUTATOR_HOOKFUNCTION(ok_PlayerDies)
{
	entity oldself = self;

	if(self.ok_nade)
		ok_toss_nade(self, '0 0 100', max(self.ok_nade.wait, time + 0.05));

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

	return 0;
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
	
	if(g_td)
	{
		oldself = self;
		self = spawn();
		self.ok_item = TRUE;
		self.noalign = TRUE;
		self.pickup_anyway = TRUE;
		spawn_td_fuel(oldself.ammo_fuel);
		self.movetype = MOVETYPE_TOSS;
		self.gravity = 1;
		setorigin(self, oldself.origin + '0 0 32');
		self.velocity = randomvec() * 175 + '0 0 325';
		self.touch = ok_Item_Touch;
		SUB_SetFade(self, time + 5, 1);
		self = oldself;
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_ForbidThrowCurrentWeapon)
{
	if(!ok_CanThrowNade())
		return TRUE;

	if(!self.ok_nade)
	{
		if(self.ok_nade_refire < time)
		{
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_OVERKILL_GRENADE);
			ok_nade_prime();
			self.ok_nade_refire  = time + autocvar_g_overkill_nade_refire;
		}
	}
	else
	{
		if(time - self.ok_nade.cnt >= 1)
		{
			makevectors(self.v_angle);
			float _force = time - self.ok_nade.cnt;
			_force /= autocvar_g_overkill_nade_lifetime;
			_force = autocvar_g_overkill_nade_minforce + (_force * (autocvar_g_overkill_nade_maxforce - autocvar_g_overkill_nade_minforce));
			ok_toss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
		}
	}
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ok_PlayerPreThink)
{
	if(intermission_running)
		return 0;

	if(self.deadflag != DEAD_NO || !IS_PLAYER(self))
		return 0;

	if(self.frozen)
		return 0;
	
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
	
	if not(autocvar_g_overkill_ammo_charge)
	if(WEPSET_CONTAINS_EW(self, WEP_HMG))
	if(self.superweapons_finished < time)
	{
		weapon_action(WEP_UZI, WR_RESETPLAYER);
		self.switchweapon = WEP_UZI;
		W_SwitchWeapon(WEP_UZI);
	}
	
	if(self.ok_nade)
		if(self.ok_nade.wait - 0.1 <= time)
			ok_toss_nade(self, '0 0 0', time + 0.05);

	if(ok_CanThrowNade())
	if(self.ok_nade_refire < time)
	{
		if(self.button16)
		{
			if not(self.ok_nade)
				ok_nade_prime();
		}
		else if(time - self.ok_nade.cnt >= 1)
		{
			if(self.ok_nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.ok_nade.cnt;
				_force /= autocvar_g_overkill_nade_lifetime;
				_force = autocvar_g_overkill_nade_minforce + (_force * (autocvar_g_overkill_nade_maxforce - autocvar_g_overkill_nade_minforce));				
				ok_toss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	}

	if(self.BUTTON_ATCK2)
		if(self.jump_interval <= time)
		{
			self.jump_interval = time + autocvar_g_balance_laser_primary_refire * W_WeaponRateFactor();
			makevectors(self.v_angle);
			W_Laser_Attack(3, WEP_LASER, WEP_LASER);
		}

	self.BUTTON_ATCK2 = 0;
	return 0;
}

MUTATOR_HOOKFUNCTION(ok_PlayerSpawn)
{
	WEPSET_CLEAR_E(self);
	WEPSET_OR_EW(self, WEP_UZI);
	WEPSET_OR_EW(self, WEP_NEX);
	WEPSET_OR_EW(self, WEP_SHOTGUN);
	
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

	if(autocvar_g_overkill_spawnsystem_give_nade)
		self.ok_nade_refire = time + autocvar_g_spawnshieldtime;
	else
		self.ok_nade_refire  = time + autocvar_g_overkill_nade_refire;
	
	self.ammo_nails = autocvar_g_overkill_ammo_start;
	self.ammo_cells = autocvar_g_overkill_ammo_start;
	self.ammo_shells = autocvar_g_overkill_ammo_start;
	self.ammo_rockets = autocvar_g_overkill_ammo_start;

	return 0;
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

MUTATOR_HOOKFUNCTION(ok_Decharge)
{
	if not(autocvar_g_overkill_ammo_charge)
		return FALSE; // not using ammo charging system
		
	ok_DecreaseCharge(self, self.weapon);
	
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ok_WeaponFrame)
{
	if not(autocvar_g_overkill_ammo_charge)
		return FALSE; // no charging, so we can always fire
			
	if(!ok_CheckWeaponCharge(self, self.weapon, self.switchweapon))
	{
		if(autocvar_g_overkill_ammo_charge_notice && time > self.ok_notice_time && self.BUTTON_ATCK)
		{
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_OVERKILL_CHARGE);
			self.ok_notice_time = time + 1;
		}
		if(self.weaponentity.state != WS_CLEAR)
			w_ready();
		
		return TRUE; // our weapon cant fire
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ok_WeaponReload)
{
	if(autocvar_g_overkill_ammo_charge)
		return TRUE;
		
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
	
	return FALSE;
}

void ok_SetCvars()
{
	// playermodels
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

	precache_model("models/ok_nade_counter/ok_nade_counter.md3");
		
	precache_model("models/weapons/h_ok_grenade.iqm");
	precache_model("models/weapons/v_ok_grenade.md3");
	precache_sound("weapons/rocket_impact.wav");
	precache_sound("weapons/grenade_bounce1.wav");
	precache_sound("weapons/grenade_bounce2.wav");
	precache_sound("weapons/grenade_bounce3.wav");
	precache_sound("weapons/grenade_bounce4.wav");
	precache_sound("weapons/grenade_bounce5.wav");
	precache_sound("weapons/grenade_bounce6.wav");
	precache_sound("overkill/grenadebip.ogg");

	w_uzi(WR_PRECACHE);
	w_nex(WR_PRECACHE);
	w_shotgun(WR_PRECACHE);
	w_laser(WR_PRECACHE);
}

MUTATOR_DEFINITION(mutator_overkill)
{
	MUTATOR_HOOK(VehicleEnter, ok_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, ok_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, ok_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, ok_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, ok_PlayerPreThink, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerSpawn, ok_PlayerSpawn, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerDamage_Calculate, ok_PlayerDamage_Calculate, CBC_ORDER_LAST);
	MUTATOR_HOOK(PlayerDies, ok_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(WeaponSetup, ok_WeaponSetup, CBC_ORDER_ANY);
	MUTATOR_HOOK(OnEntityPreSpawn, ok_OnEntityPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(WeaponReload, ok_WeaponReload, CBC_ORDER_ANY);
	MUTATOR_HOOK(ItemTouch, ok_ItemTouch, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, ok_SetModname, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, ok_ItemRemove, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterDropItem, ok_MonsterDrop, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, ok_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(DecreaseAmmo, ok_Decharge, CBC_ORDER_ANY);
	MUTATOR_HOOK(WeaponFrame, ok_WeaponFrame, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, ok_StartItems, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		ok_Initialize();
	}

	return 0;
}
