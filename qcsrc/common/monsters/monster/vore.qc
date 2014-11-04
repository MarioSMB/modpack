#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ VORE,
/* functions  */ M_Vore, M_Vore_Attack,
/* spawnflags */ MON_FLAG_MELEE | MON_FLAG_RANGED,
/* mins,maxs  */ '-32 -32 -24', '32 32 32',
/* model      */ "shalrath.mdl",
/* netname    */ "vore",
/* fullname   */ _("Vore")
);

#else
#ifdef SVQC
float autocvar_g_monster_vore_health;
float autocvar_g_monster_vore_attack_spike_damage;
float autocvar_g_monster_vore_attack_spike_radius;
float autocvar_g_monster_vore_attack_spike_delay;
float autocvar_g_monster_vore_attack_spike_accel;
float autocvar_g_monster_vore_attack_spike_decel;
float autocvar_g_monster_vore_attack_spike_turnrate;
float autocvar_g_monster_vore_attack_spike_speed_max;
float autocvar_g_monster_vore_attack_spike_smart;
float autocvar_g_monster_vore_attack_spike_smart_trace_min;
float autocvar_g_monster_vore_attack_spike_smart_trace_max;
float autocvar_g_monster_vore_attack_spike_smart_mindist;
float autocvar_g_monster_vore_attack_melee_damage;
float autocvar_g_monster_vore_attack_melee_delay;
float autocvar_g_monster_vore_speed_stop;
float autocvar_g_monster_vore_speed_run;
float autocvar_g_monster_vore_speed_walk;

const float vore_anim_attack	= 0;
const float vore_anim_pain		= 1;
const float vore_anim_death		= 2;
const float vore_anim_walk		= 3;

.entity vore_spike;

void M_Vore_Attack_Spike_Explode()
{
	self.event_damage = func_null;

	sound(self, CH_SHOTS, W_Sound("grenade_impact"), VOL_BASE, ATTEN_NORM);

	self.realowner.vore_spike = world;

	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, (autocvar_g_monster_vore_attack_spike_damage), (autocvar_g_monster_vore_attack_spike_damage) * 0.5, (autocvar_g_monster_vore_attack_spike_radius), world, 0, DEATH_MONSTER_VORE, other);

	remove (self);
}

void M_Vore_Attack_Spike_Touch()
{
	PROJECTILE_TOUCH;

	M_Vore_Attack_Spike_Explode();
}

// copied from W_Seeker_Think
void M_Vore_Attack_Spike_Think()
{
	entity e;
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;
	float spd;

	if (time > self.ltime || self.enemy.health <= 0 || self.owner.health <= 0)
	{
		self.projectiledeathtype |= HITTYPE_SPLASH;
		M_Vore_Attack_Spike_Explode();
	}

	spd = vlen(self.velocity);
	spd = bound(
		spd - (autocvar_g_monster_vore_attack_spike_decel) * frametime,
		(autocvar_g_monster_vore_attack_spike_speed_max),
		spd + (autocvar_g_monster_vore_attack_spike_accel) * frametime
	);

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if (self.enemy != world)
	{
		e				= self.enemy;
		eorg			= 0.5 * (e.absmin + e.absmax);
		turnrate		= (autocvar_g_monster_vore_attack_spike_turnrate); // how fast to turn
		desireddir		= normalize(eorg - self.origin);
		olddir			= normalize(self.velocity); // get my current direction
		dist			= vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if ((autocvar_g_monster_vore_attack_spike_smart) && (dist > (autocvar_g_monster_vore_attack_spike_smart_mindist)))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if ( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, FALSE, self);
			else
				traceline(self.origin, eorg, FALSE, self);

			// Setup adaptive tracelength
			self.wait = bound((autocvar_g_monster_vore_attack_spike_smart_trace_min), vlen(self.origin - trace_endpos), self.wait = (autocvar_g_monster_vore_attack_spike_smart_trace_max));

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}

		newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}
	else
		dist = 0;

	///////////////

	//self.angles = vectoangles(self.velocity);			// turn model in the new flight direction
	self.nextthink = time;// + 0.05; // csqc projectiles
	UpdateCSQCProjectile(self);
}

void M_Vore_Attack_Spike()
{
	entity missile;
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	makevectors(self.angles);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.think = M_Vore_Attack_Spike_Think;
	missile.ltime = time + 7;
	missile.nextthink = time;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.flags = FL_PROJECTILE;
	setorigin(missile, self.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	setsize (missile, '0 0 0', '0 0 0');
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.enemy = self.enemy;
	missile.touch = M_Vore_Attack_Spike_Touch;

	self.vore_spike = missile;

	CSQCProjectile(missile, TRUE, PROJECTILE_MAGE_SPIKE, TRUE);
}

float M_Vore_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_vore_attack_melee_damage), vore_anim_attack, self.attack_range, (autocvar_g_monster_vore_attack_melee_delay), DEATH_MONSTER_VORE_MELEE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(!self.vore_spike)
			{
				self.frame = vore_anim_attack;
				self.attack_finished_single = time + (autocvar_g_monster_vore_attack_spike_delay);
				self.anim_finished = time + 1;
				Monster_Delay(1, 0, 0.2, M_Vore_Attack_Spike);
				return TRUE;
			}

			return (self.vore_spike) ? 2 : FALSE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_vore() { Monster_Spawn(MON_VORE); }

// compatibility with old spawns
void spawnfunc_monster_shalrath() { spawnfunc_monster_vore(); }

float M_Vore(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_PAIN:
		{
			self.pain_finished = time + 0.4;
			self.frame = vore_anim_pain;
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = vore_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_vore_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_vore_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_vore_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_vore_speed_stop); }

			self.m_anim_walk = vore_anim_walk;
			self.m_anim_run = vore_anim_walk;
			self.m_anim_idle = vore_anim_walk;

			self.monster_loot = spawnfunc_ammo_cells;
			self.weapon = WEP_UZI;
			self.frame = vore_anim_walk;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_sound (W_Sound("grenade_impact"));
			precache_sound (W_Sound("tagexp1"));
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
