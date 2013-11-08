#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ LASER,
/* function  */ w_laser,
/* ammotype  */ 0,
/* impulse   */ 1,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ 0,
/* model     */ "laser",
/* shortname */ "laser",
/* fullname  */ _("Laser")
);
#else
#ifdef SVQC
void(float imp) W_SwitchWeapon;
void() W_LastWeapon;

void W_Laser_Touch (void)
{
	PROJECTILE_TOUCH;

	self.event_damage = func_null;
	if (self.dmg)
		RadiusDamage (self, self.realowner, autocvar_g_balance_laser_secondary_damage, autocvar_g_balance_laser_secondary_edgedamage, autocvar_g_balance_laser_secondary_radius, world, autocvar_g_balance_laser_secondary_force, self.projectiledeathtype, other);
	else
		RadiusDamage (self, self.realowner, autocvar_g_balance_laser_primary_damage, autocvar_g_balance_laser_primary_edgedamage, autocvar_g_balance_laser_primary_radius, world, autocvar_g_balance_laser_primary_force, self.projectiledeathtype, other);

	remove (self);
}

void W_Laser_Think()
{
	self.movetype = MOVETYPE_FLY;
	self.think = SUB_Remove;
	if (self.dmg)
		self.nextthink = time + autocvar_g_balance_laser_secondary_lifetime;
	else
		self.nextthink = time + autocvar_g_balance_laser_primary_lifetime;
	CSQCProjectile(self, TRUE, PROJECTILE_LASER, TRUE);
}

void W_Laser_Attack (float issecondary, float deathtype, float wep)
{
	makevectors(self.v_angle);

	entity missile;
	vector s_forward;
	float a;

	a = autocvar_g_balance_laser_primary_shotangle;
	s_forward = v_forward * cos(a * DEG2RAD) + v_up * sin(a * DEG2RAD);

	if(issecondary == 1)
		W_SetupShot_Dir (self, s_forward, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_B, autocvar_g_balance_laser_secondary_damage, wep);
	else
		W_SetupShot_Dir (self, s_forward, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_B, autocvar_g_balance_laser_primary_damage, wep);
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "laserbolt";
	missile.dmg = 0;
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_laser_primary_damage;

	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = deathtype;

	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SETUPPROJECTILEVELOCITY(missile, g_balance_laser_primary);
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = W_Laser_Touch;

	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH;

	missile.think = W_Laser_Think;
	missile.nextthink = time + autocvar_g_balance_laser_primary_delay;

	other = missile; MUTATOR_CALLHOOK(EditProjectile);

	if(time >= missile.nextthink)
	{
		entity oldself;
		oldself = self;
		self = missile;
		self.think();
		self = oldself;
	}
}

.vector hook_start, hook_end;
float gauntletbeam_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_GAUNTLET);
	sf = sf & 0x7F;
	if(sound_allowed(MSG_BROADCAST, self.realowner))
		sf |= 0x80;
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.realowner));
	}
	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.hook_start_x);
		WriteCoord(MSG_ENTITY, self.hook_start_y);
		WriteCoord(MSG_ENTITY, self.hook_start_z);
	}
	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.hook_end_x);
		WriteCoord(MSG_ENTITY, self.hook_end_y);
		WriteCoord(MSG_ENTITY, self.hook_end_z);
	}
	return TRUE;
}
.entity gauntletbeam;
.float prevgauntletfire;
entity lgbeam_owner_ent;
void gauntletbeam_think()
{
	float damage, myforce, myradius;
	damage = autocvar_g_balance_laser_secondary_damage;
	myforce = autocvar_g_balance_laser_secondary_force;
	myradius = autocvar_g_balance_laser_secondary_radius;

	self.realowner.prevgauntletfire = time;
	if (self.realowner.weaponentity.state != WS_INUSE || self != self.realowner.gauntletbeam || self.realowner.deadflag != DEAD_NO || !self.realowner.BUTTON_ATCK2)
	{
		remove(self);
		return;
	}

	self.nextthink = time;

	makevectors(self.realowner.v_angle);

	float dt;
	dt = frametime;

	W_SetupShot_Range(self.realowner, TRUE, 0, "", 0, damage * dt, myradius, self.realowner.weapon);
	if(!lgbeam_owner_ent)
	{
		lgbeam_owner_ent = spawn();
		lgbeam_owner_ent.classname = "lgbeam_owner_ent";
	}
	WarpZone_traceline_antilag(lgbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, lgbeam_owner_ent, ANTILAG_LATENCY(self.owner));

	// apply the damage
	if(trace_ent)
	{
		vector force;
		force = w_shotdir * myforce;
		if(accuracy_isgooddamage(self.owner, trace_ent))
			accuracy_add(self.owner, WEP_LASER, 0, damage * dt);
		Damage (trace_ent, self.owner, self.owner, damage * dt, WEP_LASER | HITTYPE_SECONDARY, trace_endpos, force * dt);
	}

	// draw effect
	if(w_shotorg != self.hook_start)
	{
		self.SendFlags |= 2;
		self.hook_start = w_shotorg;
	}
	if(w_shotend != self.hook_end)
	{
		self.SendFlags |= 4;
		self.hook_end = w_shotend;
	}
}

// experimental gauntlet
void W_Laser_Attack2 ()
{
	// only play fire sound if 0.5 sec has passed since player let go the fire button
	if(time - self.prevgauntletfire > 0.5)
	{
		sound (self, CH_WEAPON_A, "weapons/gauntlet_fire.wav", VOL_BASE, ATTEN_NORM);
	}

	entity beam, oldself;

	self.gauntletbeam = beam = spawn();
	beam.solid = SOLID_NOT;
	beam.think = gauntletbeam_think;
	beam.owner = self;
	beam.movetype = MOVETYPE_NONE;
	beam.shot_spread = 0;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = autocvar_g_balance_laser_primary_damage;
	Net_LinkEntity(beam, FALSE, 0, gauntletbeam_send);

	oldself = self;
	self = beam;
	self.think();
	self = oldself;
}

void LaserInit()
{
	weapon_action(WEP_LASER, WR_PRECACHE);
	gauntlet_shotorigin[0] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LASER), FALSE, FALSE, 1);
	gauntlet_shotorigin[1] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LASER), FALSE, FALSE, 2);
	gauntlet_shotorigin[2] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LASER), FALSE, FALSE, 3);
	gauntlet_shotorigin[3] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LASER), FALSE, FALSE, 4);
}

void spawnfunc_weapon_laser (void)
{
	weapon_defaultspawnfunc(WEP_LASER);
}

float w_laser(float req)
{
	float r1;
	float r2;
	if (req == WR_AIM)
	{
		if(autocvar_g_balance_laser_secondary)
		{
			r1 = autocvar_g_balance_laser_primary_damage;
			r2 = autocvar_g_balance_laser_secondary_damage;
			if (random() * (r2 + r1) > r1)
				self.BUTTON_ATCK2 = bot_aim(autocvar_g_balance_laser_secondary_speed, 0, autocvar_g_balance_laser_secondary_lifetime, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_laser_primary_speed, 0, autocvar_g_balance_laser_primary_lifetime, FALSE);
		}
		else
			self.BUTTON_ATCK = bot_aim(autocvar_g_balance_laser_primary_speed, 0, autocvar_g_balance_laser_primary_lifetime, FALSE);
	}
	else if (req == WR_THINK)
	{
		if(autocvar_g_balance_laser_reload_ammo && self.clip_load < 1) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if (self.BUTTON_ATCK)
		{
			if (weapon_prepareattack(0, autocvar_g_balance_laser_primary_refire))
			{
				W_DecreaseAmmo(ammo_none, 1, TRUE);

				W_Laser_Attack(0, WEP_LASER, self.weapon);
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_laser_primary_animtime, w_ready);
			}
		}
		else if (self.BUTTON_ATCK2)
		{
			if(autocvar_g_balance_laser_secondary)
			{
				W_DecreaseAmmo(ammo_none, 1, TRUE);

				if (weapon_prepareattack(0, 0))
				{
					W_Laser_Attack2();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_laser_secondary_animtime, w_ready);
				}
			}
			else
			{
				if(self.switchweapon == WEP_LASER) // don't do this if already switching
					W_LastWeapon();
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_laser.md3");
		precache_model ("models/weapons/v_laser.md3");
		precache_model ("models/weapons/h_laser.iqm");
		precache_sound ("weapons/lasergun_fire.wav");
		precache_sound ("weapons/gauntlet_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_LASER);
		self.current_ammo = ammo_none;
	}
	else if (req == WR_CHECKAMMO1)
	{
		return TRUE;
	}
	else if (req == WR_CHECKAMMO2)
	{
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(0, autocvar_g_balance_laser_reload_ammo, autocvar_g_balance_laser_reload_time, "weapons/reload.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		return WEAPON_LASER_SUICIDE;
	}
	else if (req == WR_KILLMESSAGE)
	{
		return WEAPON_LASER_MURDER;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_laser(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		pointparticles(particleeffectnum("laser_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTEN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/laserimpact.wav");
	}
	return TRUE;
}
#endif
#endif
