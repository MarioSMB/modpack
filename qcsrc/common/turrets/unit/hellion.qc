#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ HELLION,
/* function   */ t_hellion,
/* spawnflags */ TUR_FLAG_SPLASH | TUR_FLAG_FASTPROJ | TUR_FLAG_PLAYER | TUR_FLAG_MISSILE,
/* mins,maxs  */ '-32 -32 0', '32 32 64',
/* model	  */ "base.md3",
/* head_model */ "hellion.md3",
/* netname	  */ "hellion",
/* fullname   */ _("Hellion Missile Turret")
);

#define HELLION_SETTINGS(turret) \
	TUR_ADD_CVAR(turret, shot_speed_gain) \
	TUR_ADD_CVAR(turret, shot_speed_max) 


#ifdef SVQC
HELLION_SETTINGS(hellion)
#endif // SVQC
#else
#ifdef SVQC

void turret_hellion_missile_think()
{
	vector olddir,newdir;
	vector pre_pos;
	float itime;

	self.nextthink = time + 0.05;

	olddir = normalize(self.velocity);

	if(self.max_health < time)
		turret_projectile_explode();

	// Enemy dead? just keep on the current heading then.
	if ((self.enemy == world) || (self.enemy.deadflag != DEAD_NO))
	{

		// Make sure we dont return to tracking a respawned player
		self.enemy = world;

		// Turn model
		self.angles = vectoangles(self.velocity);

		if ( (vlen(self.origin - self.owner.origin)) > (self.owner.shot_radius * 5) )
			turret_projectile_explode();

		// Accelerate
		self.velocity = olddir * min(vlen(self.velocity) * TUR_CVAR(hellion, shot_speed_gain), TUR_CVAR(hellion, shot_speed_max));

		UpdateCSQCProjectile(self);

		return;
	}

	// Enemy in range?
	if (vlen(self.origin - self.enemy.origin) < self.owner.shot_radius * 0.2)
		turret_projectile_explode();

	// Predict enemy position
	itime = vlen(self.enemy.origin - self.origin) / vlen(self.velocity);
	pre_pos = self.enemy.origin + self.enemy.velocity * itime;

	pre_pos = (pre_pos + self.enemy.origin) * 0.5;

	// Find out the direction to that place
	newdir = normalize(pre_pos - self.origin);

	// Turn
	newdir = normalize(olddir + newdir * 0.35);

	// Turn model
	self.angles = vectoangles(self.velocity);

	// Accelerate
	self.velocity = newdir * min(vlen(self.velocity) * TUR_CVAR(hellion, shot_speed_gain), TUR_CVAR(hellion, shot_speed_max));

	if (itime < 0.05)
		self.think = turret_projectile_explode;

	UpdateCSQCProjectile(self);
}

void spawnfunc_turret_hellion() { if not(turret_initialize(TUR_HELLION)) remove(self); }

float t_hellion(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			entity missile;

			if(self.tur_head.frame != 0)
				self.tur_shotorg = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire"));
			else
				self.tur_shotorg = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire2"));

			missile = turret_projectile("weapons/rocket_fire.wav", 6, 10, DEATH_TURRET_HELLION, PROJECTILE_ROCKET, FALSE, FALSE);
			te_explosion (missile.origin);
			missile.think		= turret_hellion_missile_think;
			missile.nextthink	= time;
			missile.flags		= FL_PROJECTILE;
			missile.max_health   = time + 9;
			missile.tur_aimpos   = randomvec() * 128;
			missile.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_GUIDED_HEAT;
			self.tur_head.frame += 1;
			
			return TRUE;
		}
		case TR_THINK:
		{
			if (self.tur_head.frame != 0)
				self.tur_head.frame += 1;

			if (self.tur_head.frame >= 7)
				self.tur_head.frame = 0;
		
			return TRUE;
		}
		case TR_DEATH:
		{
			return TRUE;
		}
		case TR_SETUP:
		{
			self.aim_flags = TFL_AIM_SIMPLE;
			self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK ;
			self.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_TEAMCHECK | TFL_FIRECHECK_REFIRE | TFL_FIRECHECK_AFF | TFL_FIRECHECK_AMMO_OWN;
			self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
		
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/base.md3");
			precache_model ("models/turrets/hellion.md3");
			return TRUE;
		}
		case TR_CONFIG:
		{
			TUR_CONFIG_SETTINGS(HELLION_SETTINGS(hellion))
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float t_hellion(float req)
{
	switch(req)
	{
		case TR_SETUP:
		{
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/base.md3");
			precache_model ("models/turrets/hellion.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_TURRET
