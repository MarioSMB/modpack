void nade_timer_think()
{
	self.skin = 8 - (self.owner.wait - time) / (autocvar_g_nades_nade_lifetime / 10);
	self.nextthink = time;
	if(!self.owner || wasfreed(self.owner))
		remove(self);
	
}

void nade_burn_spawn(entity _nade)
{
	float p;
	
	switch(_nade.realowner.team)
	{
		case NUM_TEAM_1: p = PROJECTILE_NADE_RED_BURN; break;
		case NUM_TEAM_2: p = PROJECTILE_NADE_BLUE_BURN; break;
		case NUM_TEAM_3: p = PROJECTILE_NADE_YELLOW_BURN; break;
		case NUM_TEAM_4: p = PROJECTILE_NADE_PINK_BURN; break;
		default:		 p = PROJECTILE_NADE_BURN; break;
	}
	
	CSQCProjectile(_nade, TRUE, p, TRUE);
}

void nade_spawn(entity _nade)
{
	float p;
	entity timer = spawn();
	setmodel(timer, "models/ok_nade_counter/ok_nade_counter.md3");
	setattachment(timer, _nade, "");
	timer.classname = "nade_timer";
	timer.colormap = _nade.colormap;
	timer.glowmod = _nade.glowmod;
	timer.think = nade_timer_think;
	timer.nextthink = time;
	timer.wait = _nade.wait;
	timer.owner = _nade;	
	timer.skin = 10;
	
	switch(_nade.realowner.team)
	{
		case NUM_TEAM_1: p = PROJECTILE_NADE_RED; break;
		case NUM_TEAM_2: p = PROJECTILE_NADE_BLUE; break;
		case NUM_TEAM_3: p = PROJECTILE_NADE_YELLOW; break;
		case NUM_TEAM_4: p = PROJECTILE_NADE_PINK; break;
		default:		 p = PROJECTILE_NADE; break;
	}
	
	CSQCProjectile(_nade, TRUE, p, TRUE);
	
}

void nade_napalm()
{
	entity proj;
	vector kick;
	
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", CH_WEAPON_A, autocvar_g_nades_napalm_damage, self.weapon);
	
	proj = spawn ();
	proj.owner = proj.realowner = self;
	proj.team = self.owner.team;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_nades_napalm_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, self.origin);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_nades_napalm_damageforcescale;
	
	kick_x =(random() - 0.5) * 2 * autocvar_g_nades_napalm_spread;
	kick_y = (random() - 0.5) * 2 * autocvar_g_nades_napalm_spread;
	kick_z = random() * autocvar_g_nades_napalm_spread;
	proj.velocity = kick;
	
	proj.pushltime = time + autocvar_g_nades_napalm_lifetime;

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);
	
	MUTATOR_CALLHOOK(EditProjectile);
}

void nade_napalm_boom()
{
	local float c;
	for (c = 0; c < autocvar_g_nades_napalm_count; c ++) 
		nade_napalm();
}

void nade_boom()
{
	string expef;
	
	switch(self.realowner.team)
	{
		case NUM_TEAM_1: expef = "nade_red_explode"; break;
		case NUM_TEAM_2: expef = "nade_blue_explode"; break;
		case NUM_TEAM_3: expef = "nade_yellow_explode"; break;
		case NUM_TEAM_4: expef = "nade_pink_explode"; break;
		default: 		 expef = "nade_explode"; break;
	}
	
	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTEN_NORM);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum(expef), self.origin + '0 0 1', '0 0 0', 1);
	
	Damage_DamageInfo(self.origin, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage, autocvar_g_nades_nade_radius, '1 1 1' * autocvar_g_nades_nade_force, self.projectiledeathtype, 0, self);

	self.takedamage = DAMAGE_NO;
	
	if ( self.classname != "nade_napalm" || autocvar_g_nades_napalm_blast )
		RadiusDamage(self, self.realowner, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage,
				 autocvar_g_nades_nade_radius, self, autocvar_g_nades_nade_force, self.projectiledeathtype, self.enemy);
	
	if ( self.classname == "nade_napalm" )
		nade_napalm_boom();
	

	remove(self);
}

void nade_touch()
{
	PROJECTILE_TOUCH;
	//setsize(self, '-2 -2 -2', '2 2 2');
	//UpdateCSQCProjectile(self);
	if(self.health == self.max_health)
	{
		spamsound(self, CH_SHOTS, strcat("weapons/grenade_bounce", ftos(1 + rint(random() * 5)), ".wav"), VOL_BASE, ATTEN_NORM);
		return;
	}

	self.enemy = other;
	nade_boom();
}

void nade_beep()
{
	sound(self, CH_SHOTS_SINGLE, "overkill/grenadebip.ogg", VOL_BASE, 0.5 *(ATTEN_LARGE + ATTEN_MAX));
	self.think = nade_boom;
	self.nextthink = max(self.wait, time);
}

void nade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(DEATH_ISWEAPON(deathtype, WEP_LASER))
		return;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX) || DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
	{
		force *= 6;
		damage = self.max_health * 0.55;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_UZI) || DEATH_ISWEAPON(deathtype, WEP_HMG))
		damage = self.max_health * 0.1;
		
	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN))
	if(deathtype & HITTYPE_SECONDARY)
	{
		damage = self.max_health * 0.1;
		force *= 10;
	}
	else
		damage = self.max_health * 1.1;
		
	self.velocity += force;

	if(!damage || (self.flags & FL_ONGROUND && IS_PLAYER(attacker)))
		return;

	if(self.health == self.max_health)
	{
		sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, 0.5 *(ATTEN_LARGE + ATTEN_MAX));
		self.nextthink = max(time + autocvar_g_nades_nade_lifetime, time);
		self.think = nade_beep;
	}

	self.health   -= damage;
	self.realowner = attacker;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, nade_boom);
	else
		nade_burn_spawn(self);
}

void toss_nade(entity e, vector _velocity, float _time)
{
	entity _nade = e.nade;
	e.nade = world;
	
	remove(e.fake_nade);
	e.fake_nade = world;
	
	makevectors(e.v_angle);
	
	W_SetupShot(e, FALSE, FALSE, "", CH_WEAPON_A, 0, DEATH_NADE);
	
	Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_NADES);
	
	setorigin(_nade, w_shotorg + (v_right * 25) * -1);
	setmodel(_nade, "models/weapons/v_ok_grenade.md3");
	setattachment(_nade, world, "");
	PROJECTILE_MAKETRIGGER(_nade);
	setsize(_nade, '-16 -16 -16', '16 16 16');
	_nade.movetype = MOVETYPE_BOUNCE;
	
	tracebox(_nade.origin, _nade.mins, _nade.maxs, _nade.origin, FALSE, _nade);
	if (trace_startsolid)
		setorigin(_nade, e.origin);
	
	if(e.crouch)
		_nade.velocity = '0 0 -10';
	else if(autocvar_g_nades_nade_newton_style == 1)
		_nade.velocity = e.velocity + _velocity;
	else if(autocvar_g_nades_nade_newton_style == 2)
		_nade.velocity = _velocity;
	else
		_nade.velocity = W_CalculateProjectileVelocity(e.velocity, _velocity, TRUE);
	
	_nade.touch = nade_touch;
	_nade.health = autocvar_g_nades_nade_health;
	_nade.max_health = _nade.health;
	_nade.takedamage = DAMAGE_AIM;
	_nade.event_damage = nade_damage;
	_nade.teleportable = TRUE;
	_nade.pushable = TRUE;
	_nade.gravity = 1;
	_nade.missile_flags = MIF_SPLASH | MIF_ARC;
	_nade.damagedbycontents = TRUE;
	_nade.angles = vectoangles(_nade.velocity);
	_nade.flags = FL_PROJECTILE;
	_nade.projectiledeathtype = DEATH_NADE;

	nade_spawn(_nade);

	if(_time)
	{
		_nade.think = nade_boom;
		_nade.nextthink = _time;
	}

	e.nade_refire = time + autocvar_g_nades_nade_refire;
}

void nades_GiveBonus(entity player)
{
	if ( autocvar_g_nades_napalm == 1 )
		if ( player.bonus_nades < autocvar_g_nades_napalm_bonus_max )
		{
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_NADE_BONUS);
			player.bonus_nades++;
		}
}

void nade_prime()
{
	if(self.nade)
		remove(self.nade);
		
	if(self.fake_nade)
		remove(self.fake_nade);
	
	self.nade = spawn();
	setmodel(self.nade, "null");
	setattachment(self.nade, self, "bip01 l hand");
	if not ( autocvar_g_nades_napalm  )
	{
		self.nade.classname = "nade";
	}
	else if ( autocvar_g_nades_napalm > 1 )
	{
		self.nade.classname = "nade_napalm";
	}
	else if ( autocvar_g_nades_napalm == 1 && self.bonus_nades )
	{
		self.bonus_nades --;
		self.nade.classname = "nade_napalm";
	}
	self.nade.realowner = self;
	self.nade.colormap = self.colormap;
	self.nade.glowmod = self.glowmod;
	self.nade.wait = time + autocvar_g_nades_nade_lifetime;
	self.nade.lifetime = time;
	self.nade.think = nade_beep;
	self.nade.nextthink = max(self.nade.wait - 3, time);
	self.nade.projectiledeathtype = DEATH_NADE;

	self.fake_nade = spawn();
	setmodel(self.fake_nade, "models/weapons/h_ok_grenade.iqm");
	setattachment(self.fake_nade, self.weaponentity, "");
	self.fake_nade.classname = "fake_nade";
	self.fake_nade.realowner = self.fake_nade.owner = self;
	self.fake_nade.colormap = self.colormap;
	self.fake_nade.glowmod = self.glowmod;
	self.fake_nade.think = SUB_Remove;
	self.fake_nade.nextthink = self.nade.wait;
}

float CanThrowNade()
{
	if(self.vehicle)
		return FALSE;
		
	if(gameover)
		return FALSE;
		
	if(self.deadflag != DEAD_NO)
		return FALSE;
	
	if not(autocvar_g_nades)
		return FALSE; // allow turning them off mid match
		
	if(forbidWeaponUse())
		return FALSE;
		
	if not(IS_PLAYER(self))
		return FALSE;
		
	return TRUE;
}

void nades_CheckThrow()
{
	if(!CanThrowNade())
		return;
		
	if(!self.nade)
	{
		if(self.nade_refire < time)
		{
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_NADE_THROW);
			nade_prime();
			self.nade_refire = time + autocvar_g_nades_nade_refire;
		}
	}
	else
	{
		if(time - self.nade.lifetime >= 1)
		{
			makevectors(self.v_angle);
			float _force = time - self.nade.lifetime;
			_force /= autocvar_g_nades_nade_lifetime;
			_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));
			toss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
		}
	}
}

MUTATOR_HOOKFUNCTION(nades_VehicleEnter)
{
	if(other.nade)
		toss_nade(other, '0 0 100', max(other.nade.wait, time + 0.05));
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerPreThink)
{
	float key_pressed = self.BUTTON_HOOK;
	
	if(g_grappling_hook || client_hasweapon(self, WEP_HOOK, FALSE, FALSE) || (weaponsInMap & WEPSET_HOOK))
		key_pressed = self.button16; // if hook is enabled, use an alternate key
	
	if(self.nade)
		if(self.nade.wait - 0.1 <= time)
			toss_nade(self, '0 0 0', time + 0.05);
			
	if(CanThrowNade())
	if(self.nade_refire < time)
	{
		if(key_pressed)
		{
			if(!self.nade)
				nade_prime();
		}
		else if(time - self.nade.lifetime >= 1)
		{
			if(self.nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.nade.lifetime;
				_force /= autocvar_g_nades_nade_lifetime;
				_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));				
				toss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerSpawn)
{
	if(autocvar_g_nades_spawn)
		self.nade_refire = time + autocvar_g_spawnshieldtime;
	else
		self.nade_refire  = time + autocvar_g_nades_nade_refire;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerDies)
{
	if(self.nade)
		toss_nade(self, '0 0 100', max(self.nade.wait, time + 0.05));
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_RemovePlayer)
{
	if(self.nade)
		remove(self.nade);

	if(self.fake_nade)
		remove(self.fake_nade);
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Nades");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Nades");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_nades)
{
	MUTATOR_HOOK(VehicleEnter, nades_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, nades_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, nades_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, nades_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, nades_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, nades_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, nades_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, nades_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
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
	}

	return FALSE;
}
