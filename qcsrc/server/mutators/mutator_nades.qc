.entity nade_spawnloc;

void nade_timer_think()
{
	self.skin = 8 - (self.owner.wait - time) / (autocvar_g_nades_nade_lifetime / 10);
	self.nextthink = time;
	if(!self.owner || wasfreed(self.owner))
		remove(self);
}

void nade_burn_spawn(entity _nade)
{
	CSQCProjectile(_nade, TRUE, Nade_ProjectileFromID(_nade.nade_type, TRUE), TRUE);
}

void nade_spawn(entity _nade)
{
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

	_nade.effects |= EF_LOWPRECISION;

	CSQCProjectile(_nade, TRUE, Nade_ProjectileFromID(_nade.nade_type, FALSE), TRUE);
}

void napalm_damage(float dist, float damage, float edgedamage, float burntime)
{
	entity e;
	float d;
	vector p;
	
	if ( damage < 0 )
		return;

	RandomSelection_Init();
	for(e = WarpZone_FindRadius(self.origin, dist, TRUE); e; e = e.chain)
		if(e.takedamage == DAMAGE_AIM) 
		if(self.realowner != e || autocvar_g_nades_napalm_selfdamage) 
		if(!IS_PLAYER(e) || !self.realowner || DIFF_TEAM(e, self))
		if(!e.frozen) 
		{
			p = e.origin;
			p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
			p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
			p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
			d = vlen(WarpZone_UnTransformOrigin(e, self.origin) - p);
			if(d < dist)
			{
				e.fireball_impactvec = p;
				RandomSelection_Add(e, 0, string_null, 1 / (1 + d), !Fire_IsBurning(e));
			}
		}
	if(RandomSelection_chosen_ent)
	{
		d = vlen(WarpZone_UnTransformOrigin(RandomSelection_chosen_ent, self.origin) - RandomSelection_chosen_ent.fireball_impactvec);
		d = damage + (edgedamage - damage) * (d / dist);
		Fire_AddDamage(RandomSelection_chosen_ent, self.realowner, d * burntime, burntime, self.projectiledeathtype | HITTYPE_BOUNCE);
		//trailparticles(self, particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec);
		pointparticles(particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec - self.origin, 1);
	}
}


void napalm_ball_think()
{
	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
	{
		remove(self);
		return;
	}
	
	if(time > self.pushltime)
	{
		remove(self);
		return;
	}
	
	vector midpoint = ((self.absmin + self.absmax) * 0.5);
	if(pointcontents(midpoint) == CONTENT_WATER)
	{
		self.velocity = self.velocity * 0.5;
					
		if(pointcontents(midpoint + '0 0 16') == CONTENT_WATER)
			{ self.velocity_z = 200; }
	}
	
	self.angles = vectoangles(self.velocity);

	napalm_damage(autocvar_g_nades_napalm_ball_radius,autocvar_g_nades_napalm_ball_damage,
				  autocvar_g_nades_napalm_ball_damage,autocvar_g_nades_napalm_burntime);

	self.nextthink = time + 0.1;
}


void nade_napalm_ball()
{
	entity proj;
	vector kick;
	
	spamsound(self, CH_SHOTS, "weapons/fireball_fire.wav", VOL_BASE, ATTEN_NORM);
	
	proj = spawn ();
	proj.owner = self.owner;
	proj.realowner = self.realowner;
	proj.team = self.owner.team;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_nades_napalm_ball_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = DEATH_NADE_NAPALM;
	PROJECTILE_MAKETRIGGER(proj);
	setmodel(proj, "null");
	proj.scale = 1;//0.5;
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, self.origin);
	proj.think = napalm_ball_think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_nades_napalm_ball_damageforcescale;
	proj.effects = EF_LOWPRECISION | EF_FLAME;
	
	kick_x =(random() - 0.5) * 2 * autocvar_g_nades_napalm_ball_spread;
	kick_y = (random() - 0.5) * 2 * autocvar_g_nades_napalm_ball_spread;
	kick_z = (random()/2+0.5) * autocvar_g_nades_napalm_ball_spread;
	proj.velocity = kick;
	
	proj.pushltime = time + autocvar_g_nades_napalm_ball_lifetime;

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
	
	//CSQCProjectile(proj, TRUE, PROJECTILE_NAPALM_FIRE, TRUE);
}


void napalm_fountain_think()
{
	
	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
	{
		remove(self);
		return;
	}
	
	if(time >= self.ltime) 
	{
		remove(self);
		return;
	}
	
	vector midpoint = ((self.absmin + self.absmax) * 0.5);
	if(pointcontents(midpoint) == CONTENT_WATER)
	{
		self.velocity = self.velocity * 0.5;
					
		if(pointcontents(midpoint + '0 0 16') == CONTENT_WATER)
			{ self.velocity_z = 200; }
			
		UpdateCSQCProjectile(self);
	}
	
	napalm_damage(autocvar_g_nades_napalm_fountain_radius, autocvar_g_nades_napalm_fountain_damage,
		autocvar_g_nades_napalm_fountain_edgedamage, autocvar_g_nades_napalm_burntime);
	
	self.nextthink = time + 0.1;
	if(time >= self.nade_special_time)
	{
		self.nade_special_time = time + autocvar_g_nades_napalm_fountain_delay;
		nade_napalm_ball();
	}
}

void nade_napalm_boom()
{
	entity fountain;
	local float c;
	for (c = 0; c < autocvar_g_nades_napalm_ball_count; c ++) 
		nade_napalm_ball();
	
	
	fountain = spawn();
	fountain.owner = self.owner;
	fountain.realowner = self.realowner;
	fountain.origin = self.origin;
	setorigin(fountain, fountain.origin);
	fountain.think = napalm_fountain_think;
	fountain.nextthink = time;
	fountain.ltime = time + autocvar_g_nades_napalm_fountain_lifetime;
	fountain.pushltime = fountain.ltime;
	fountain.team = self.team;
	fountain.movetype = MOVETYPE_TOSS;
	fountain.projectiledeathtype = DEATH_NADE_NAPALM;
	fountain.bot_dodge = TRUE;
	fountain.bot_dodgerating = autocvar_g_nades_napalm_fountain_damage;
	fountain.nade_special_time = time;
	setsize(fountain, '-16 -16 -16', '16 16 16');
	CSQCProjectile(fountain, TRUE, PROJECTILE_NAPALM_FOUNTAIN, TRUE);
}

void nade_ice_freeze(entity freezefield, entity frost_target, float freeze_time)
{
	frost_target.frozen_by = freezefield.realowner;
	pointparticles(particleeffectnum("electro_impact"), frost_target.origin, '0 0 0', 1);
	Freeze(frost_target, 1/freeze_time, 3, FALSE);
	if ( frost_target.flagcarried )
		ctf_Handle_Throw(frost_target, world, DROP_THROW);
	if(frost_target.nade)
		toss_nade(frost_target, '0 0 0', time + 0.05);
}

void nade_ice_think()
{
	
	if(round_handler_IsActive())
	if(!round_handler_IsRoundStarted())
	{
		remove(self);
		return;
	}
	
	if(time >= self.ltime) 
	{
		if ( autocvar_g_nades_ice_explode )
		{
			string expef;
			switch(self.realowner.team)
			{
				case NUM_TEAM_1: expef = "nade_red_explode"; break;
				case NUM_TEAM_2: expef = "nade_blue_explode"; break;
				case NUM_TEAM_3: expef = "nade_yellow_explode"; break;
				case NUM_TEAM_4: expef = "nade_pink_explode"; break;
				default: 		 expef = "nade_neutral_explode"; break;
			}
			pointparticles(particleeffectnum(expef), self.origin + '0 0 1', '0 0 0', 1);
			sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
			
			RadiusDamage(self, self.realowner, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage,
				autocvar_g_nades_nade_radius, self, autocvar_g_nades_nade_force, self.projectiledeathtype, self.enemy);
			Damage_DamageInfo(self.origin, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage, 
				autocvar_g_nades_nade_radius, '1 1 1' * autocvar_g_nades_nade_force, self.projectiledeathtype, 0, self);
		}
		remove(self);
		return;
	}
	
	
	self.nextthink = time+0.1;
	
	// gaussian
	float randomr;
	randomr = random();
	randomr = exp(-5*randomr*randomr)*autocvar_g_nades_nade_radius;
	float randomw;
	randomw = random()*M_PI*2;
	vector randomp;
	randomp_x = randomr*cos(randomw);
	randomp_y = randomr*sin(randomw);
	randomp_z = 1;
	pointparticles(particleeffectnum("electro_muzzleflash"), self.origin + randomp, '0 0 0', 1);
	
	if(time >= self.nade_special_time)
	{
		self.nade_special_time = time+0.7;
		
		
		pointparticles(particleeffectnum("electro_impact"), self.origin, '0 0 0', 1);
		pointparticles(particleeffectnum("icefield"), self.origin, '0 0 0', 1);
	}
	

	float current_freeze_time = self.ltime - time - 0.1;
	
	entity e;
	for(e = findradius(self.origin, autocvar_g_nades_nade_radius); e; e = e.chain) 
	if(e != self)
	if((autocvar_g_nades_ice_teamcheck && (DIFF_TEAM(e, self.realowner) || e == self.realowner)) || !autocvar_g_nades_ice_teamcheck)
	if(e.takedamage && e.deadflag == DEAD_NO)
	if(e.health > 0) 
	if(!e.frozen)
	if(current_freeze_time > 0)
		nade_ice_freeze(self, e, current_freeze_time);
}

void nade_ice_boom()
{
	entity fountain;
	fountain = spawn();
	fountain.owner = self.owner;
	fountain.realowner = self.realowner;
	fountain.origin = self.origin;
	setorigin(fountain, fountain.origin);
	fountain.think = nade_ice_think;
	fountain.nextthink = time;
	fountain.ltime = time + autocvar_g_nades_ice_freeze_time;
	fountain.pushltime = fountain.wait = fountain.ltime;
	fountain.team = self.team;
	fountain.movetype = MOVETYPE_TOSS;
	fountain.projectiledeathtype = DEATH_NADE_ICE;
	fountain.bot_dodge = FALSE;
	setsize(fountain, '-16 -16 -16', '16 16 16');
	fountain.nade_special_time = time+0.3;
	fountain.angles = self.angles;
	
	if ( autocvar_g_nades_ice_explode )
	{
		setmodel(fountain, "models/grenademodel.md3");
		entity timer = spawn();
		setmodel(timer, "models/ok_nade_counter/ok_nade_counter.md3");
		setattachment(timer, fountain, "");
		timer.classname = "nade_timer";
		timer.colormap = self.colormap;
		timer.glowmod = self.glowmod;
		timer.think = nade_timer_think;
		timer.nextthink = time;
		timer.wait = fountain.ltime;
		timer.owner = fountain;	
		timer.skin = 10;
	}
	else
		setmodel(fountain, "null");
}

void nade_translocate_boom()
{
	vector locout = self.origin + '0 0 1' * (1 - self.realowner.mins_z - 24);
		
	makevectors(self.realowner.angles);
	
	entity oldself = self;
	self = self.realowner;
	MUTATOR_CALLHOOK(PortalTeleport);
	self.realowner = self;
	self = oldself;
	
	TeleportPlayer(self, self.realowner, locout, self.realowner.mangle, v_forward * vlen(self.realowner.velocity), '0 0 0', '0 0 0', TELEPORT_FLAGS_TELEPORTER);
}

void nade_spawn_boom()
{
	entity spawnloc = spawn();
	setorigin(spawnloc, self.origin);
	setsize(spawnloc, self.realowner.mins, self.realowner.maxs);
	spawnloc.movetype = MOVETYPE_NONE;
	spawnloc.solid = SOLID_NOT;
	spawnloc.drawonlytoclient = self.realowner;
	spawnloc.effects = EF_STARDUST;
	
	if(self.realowner.nade_spawnloc)
	{
		remove(self.realowner.nade_spawnloc);
		self.realowner.nade_spawnloc = world;
	}
	
	self.realowner.nade_spawnloc = spawnloc;
}

void nade_boom()
{
	string expef;
	float nade_blast;

	nade_blast = 1;

	switch ( self.nade_type )
	{
		case NADE_TYPE_NAPALM: 
			nade_blast = autocvar_g_nades_napalm_blast;
			expef = "explosion_medium"; 
			break;
		case NADE_TYPE_ICE:   
			nade_blast = 0;
			expef = "electro_combo"; // hookbomb_explode electro_combo bigplasma_impact
			break;
		case NADE_TYPE_TRANSLOCATE:
			nade_blast = 0;
			expef = "";
			break;
		case NADE_TYPE_SPAWN:
			nade_blast = 0;
			switch(self.realowner.team)
			{
				case NUM_TEAM_1: expef = "spawn_event_red"; break;
				case NUM_TEAM_2: expef = "spawn_event_blue"; break;
				case NUM_TEAM_3: expef = "spawn_event_yellow"; break;
				case NUM_TEAM_4: expef = "spawn_event_pink"; break;
				default: expef = "spawn_event_neutral"; break;
			}
			break;

		default:
		case NADE_TYPE_NORMAL:
			switch(self.realowner.team)
			{
				case NUM_TEAM_1: expef = "nade_red_explode"; break;
				case NUM_TEAM_2: expef = "nade_blue_explode"; break;
				case NUM_TEAM_3: expef = "nade_yellow_explode"; break;
				case NUM_TEAM_4: expef = "nade_pink_explode"; break;
				default: 		 expef = "nade_neutral_explode"; break;
			}
	}

	pointparticles(particleeffectnum(expef), self.origin + '0 0 1', '0 0 0', 1);

	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTEN_NORM);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);

	self.takedamage = DAMAGE_NO;

	if(nade_blast)
	{
		RadiusDamage(self, self.realowner, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage,
				 autocvar_g_nades_nade_radius, self, autocvar_g_nades_nade_force, self.projectiledeathtype, self.enemy);
		Damage_DamageInfo(self.origin, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage, autocvar_g_nades_nade_radius, '1 1 1' * autocvar_g_nades_nade_force, self.projectiledeathtype, 0, self);
	}

	switch ( self.nade_type )
	{
		case NADE_TYPE_NAPALM: nade_napalm_boom(); break;
		case NADE_TYPE_ICE: nade_ice_boom(); break;
		case NADE_TYPE_TRANSLOCATE: nade_translocate_boom(); break;
		case NADE_TYPE_SPAWN: nade_spawn_boom(); break;
	}

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
	if(self.nade_type == NADE_TYPE_TRANSLOCATE || self.nade_type == NADE_TYPE_SPAWN)
		return;

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
	if(e.nade == world)
		return;

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

	if(self.v_angle_x >= 70 && self.v_angle_x <= 110)
		_nade.velocity = '0 0 100';
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

void nades_GiveBonus(entity player, float score)
{
	if (autocvar_g_nades)
	if (autocvar_g_nades_bonus)
	if (IS_REAL_CLIENT(player))
	if (IS_PLAYER(player) && player.bonus_nades < autocvar_g_nades_bonus_max)
	if (player.frozen == 0)
	if (player.deadflag == DEAD_NO)
	{
		if ( player.bonus_nade_score < 1 )
			player.bonus_nade_score += score/autocvar_g_nades_bonus_score_max;

		if ( player.bonus_nade_score >= 1 )
		{
			Send_Notification(NOTIF_ONE, player, MSG_CENTER, CENTER_NADE_BONUS);
			play2(player,"kh/alarm.wav");
			player.bonus_nades++;
			player.bonus_nade_score -= 1;
		}
	}
}

void nades_RemoveBonus(entity player)
{
	player.bonus_nades = player.bonus_nade_score = 0;
}


void nade_prime()
{
	if(self.nade)
		remove(self.nade);

	if(self.fake_nade)
		remove(self.fake_nade);

	entity n = spawn(), fn = spawn();

	n.classname = "nade";
	fn.classname = "fake_nade";

	if(self.items & IT_STRENGTH && autocvar_g_nades_bonus_onstrength)
		n.nade_type = self.nade_type;
	else if (self.bonus_nades >= 1)
	{
		n.nade_type = self.nade_type;
		self.bonus_nades -= 1;
	}
	else
		 n.nade_type = ((autocvar_g_nades_client_select) ? self.cvar_cl_nade_type : autocvar_g_nades_nade_type);

	setmodel(n, "null");
	setattachment(n, self, "bip01 l hand");
	n.realowner = self;
	n.colormap = self.colormap;
	n.glowmod = self.glowmod;
	n.wait = time + autocvar_g_nades_nade_lifetime;
	n.lifetime = time;
	n.think = nade_beep;
	n.nextthink = max(n.wait - 3, time);
	n.projectiledeathtype = DEATH_NADE;

	setmodel(fn, "models/weapons/h_ok_grenade.iqm");
	setattachment(fn, self.weaponentity, "");
	fn.realowner = fn.owner = self;
	fn.colormod = Nade_Color(n.nade_type);
	fn.colormap = self.colormap;
	fn.glowmod = self.glowmod;
	fn.think = SUB_Remove;
	fn.nextthink = n.wait;

	self.nade = n;
	self.fake_nade = fn;
}

float CanThrowNade()
{
	if(self.vehicle)
		return FALSE;

	if(gameover)
		return FALSE;

	if(self.deadflag != DEAD_NO)
		return FALSE;

	if (!autocvar_g_nades)
		return FALSE; // allow turning them off mid match

	if(forbidWeaponUse())
		return FALSE;

	if (!IS_PLAYER(self))
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

void nades_Clear(entity player)
{
	if(player.nade)
		remove(player.nade);
	if(player.fake_nade)
		remove(player.fake_nade);

	player.nade = player.fake_nade = world;
}

MUTATOR_HOOKFUNCTION(nades_CheckThrow)
{
	if(MUTATOR_RETURNVALUE) { nades_CheckThrow(); }
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_VehicleEnter)
{
	if(other.nade)
		toss_nade(other, '0 0 100', max(other.nade.wait, time + 0.05));

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerPreThink)
{
	if(!IS_PLAYER(self)) { return FALSE; }

	float key_pressed = self.BUTTON_HOOK;
	float time_score;

	if(g_grappling_hook || client_hasweapon(self, WEP_HOOK, FALSE, FALSE) || (weaponsInMap & WEPSET_HOOK) || g_jetpack || self.items & IT_JETPACK)
		key_pressed = self.button16; // if hook/jetpack is enabled, use an alternate key

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

	if(IS_PLAYER(self))
	{
		if ( autocvar_g_nades_bonus && autocvar_g_nades )
		{
			if(self.flagcarried || self.isvip || self.ballcarried) // this player is important
				time_score = autocvar_g_nades_bonus_score_time_flagcarrier;
			else
				time_score = autocvar_g_nades_bonus_score_time;

			if(autocvar_g_nades_bonus_client_select)
				self.nade_type = self.cvar_cl_nade_type;
			else
				self.nade_type = autocvar_g_nades_bonus_type;

			if(self.bonus_nade_score >= 0 && autocvar_g_nades_bonus_score_max)
				nades_GiveBonus(self, time_score / autocvar_g_nades_bonus_score_max);
		}
		else
		{
			self.bonus_nades = self.bonus_nade_score = 0;
		}
	}
	
	float n = 0;
	entity o = world;
	if(self.freezetag_frozen_timeout > 0 && time >= self.freezetag_frozen_timeout)
		n = -1;
	else
	{
		vector revive_extra_size = '1 1 1' * autocvar_g_freezetag_revive_extra_size;
		n = 0;
		FOR_EACH_PLAYER(other) if(self != other)
		{
			if(other.deadflag == DEAD_NO)
			if(other.frozen == 0)
			if(SAME_TEAM(other, self))
			if(boxesoverlap(self.absmin - revive_extra_size, self.absmax + revive_extra_size, other.absmin, other.absmax))
			{
				if(!o)
					o = other;
				if(self.frozen == 1)
					other.reviving = TRUE;
				++n;
			}
		}
	}

	if(n && self.frozen == 3) // OK, there is at least one teammate reviving us
	{
		self.revive_progress = bound(0, self.revive_progress + frametime * max(1/60, autocvar_g_freezetag_revive_speed), 1);
		self.health = max(1, self.revive_progress * autocvar_g_balance_health_start);

		if(self.revive_progress >= 1)
		{
			Unfreeze(self);

			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_FREEZETAG_REVIVED, o.netname);
			Send_Notification(NOTIF_ONE, o, MSG_CENTER, CENTER_FREEZETAG_REVIVE, self.netname);
		}

		FOR_EACH_PLAYER(other) if(other.reviving)
		{
			other.revive_progress = self.revive_progress;
			other.reviving = FALSE;
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

	if(autocvar_g_nades_bonus_client_select)
		self.nade_type = self.cvar_cl_nade_type;
		
	if(self.nade_spawnloc)
	{
		setorigin(self, self.nade_spawnloc.origin);
		remove(self.nade_spawnloc);
		self.nade_spawnloc = world;
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerDies)
{
	if(frag_target.nade)
		toss_nade(frag_target, '0 0 100', max(frag_target.nade.wait, time + 0.05));

	float killcount_bonus = ((frag_attacker.killcount >= 1) ? bound(0, autocvar_g_nades_bonus_score_minor * frag_attacker.killcount, autocvar_g_nades_bonus_score_medium) : autocvar_g_nades_bonus_score_minor);

	if(IS_PLAYER(frag_attacker))
	{
		if (SAME_TEAM(frag_attacker, frag_target) || frag_attacker == frag_target)
			nades_RemoveBonus(frag_attacker);
		else if(frag_target.flagcarried)
			nades_GiveBonus(frag_attacker, autocvar_g_nades_bonus_score_medium);
		else
			nades_GiveBonus(frag_attacker, killcount_bonus);
	}

	nades_RemoveBonus(frag_target);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_MonsterDies)
{
	if(IS_PLAYER(frag_attacker))
	if(DIFF_TEAM(frag_attacker, self))
	if(!(self.spawnflags & MONSTERFLAG_SPAWNED))
		nades_GiveBonus(frag_attacker, autocvar_g_nades_bonus_score_minor);
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_RemovePlayer)
{
	nades_Clear(self);
	nades_RemoveBonus(self);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_SpectateCopy)
{
	self.nade_type = other.nade_type;
	self.bonus_nades = other.bonus_nades;
	self.bonus_nade_score = other.bonus_nade_score;
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_GetCvars)
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_nade_type, "cl_nade_type");

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
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, nades_CheckThrow, CBC_ORDER_LAST);
	MUTATOR_HOOK(VehicleEnter, nades_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, nades_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, nades_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, nades_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MonsterDies, nades_MonsterDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, nades_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, nades_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(SpectateCopy, nades_SpectateCopy, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetCvars, nades_GetCvars, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_global, nades_RemovePlayer, CBC_ORDER_ANY);
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
