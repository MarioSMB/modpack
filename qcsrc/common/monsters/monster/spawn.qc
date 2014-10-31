#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SPAWN,
/* functions  */ M_Spawn, M_Spawn_Attack,
/* spawnflags */ MON_FLAG_MELEE,
/* mins,maxs  */ '-18 -18 -25', '18 18 47',
/* model      */ "spawn.dpm",
/* netname    */ "spawn",
/* fullname   */ _("Spawn")
);

#else
#ifdef SVQC
float autocvar_g_monster_spawn_health;
float autocvar_g_monster_spawn_attack_melee_damage;
float autocvar_g_monster_spawn_attack_melee_delay;
float autocvar_g_monster_spawn_attack_leap_damage;
float autocvar_g_monster_spawn_attack_leap_force;
float autocvar_g_monster_spawn_attack_leap_speed;
float autocvar_g_monster_spawn_attack_leap_delay;
float autocvar_g_monster_spawn_speed_stop;
float autocvar_g_monster_spawn_speed_run;
float autocvar_g_monster_spawn_speed_walk;

const float spawn_anim_attackleap			= 0;
const float spawn_anim_attackrun1			= 1;
const float spawn_anim_attackrun2			= 2;
const float spawn_anim_attackrun3			= 3;
const float spawn_anim_attackstanding1		= 4;
const float spawn_anim_attackstanding2		= 5;
const float spawn_anim_attackstanding3		= 6;
const float spawn_anim_blockend			= 7;
const float spawn_anim_blockstart			= 8;
const float spawn_anim_deathback1			= 9;
const float spawn_anim_deathback2			= 10;
const float spawn_anim_deathback3			= 11;
const float spawn_anim_deathfront1			= 12;
const float spawn_anim_deathfront2			= 13;
const float spawn_anim_deathfront3			= 14;
const float spawn_anim_deathleft1			= 15;
const float spawn_anim_deathleft2			= 16;
const float spawn_anim_deathright1			= 17;
const float spawn_anim_deathright2			= 18;
const float spawn_anim_idle				= 19;
const float spawn_anim_painback1			= 20;
const float spawn_anim_painback2			= 21;
const float spawn_anim_painfront1			= 22;
const float spawn_anim_painfront2			= 23;
const float spawn_anim_runbackwards		= 24;
const float spawn_anim_runbackwardsleft	= 25;
const float spawn_anim_runbackwardsright	= 26;
const float spawn_anim_runforward			= 27;
const float spawn_anim_runforwardleft		= 28;
const float spawn_anim_runforwardright		= 29;
const float spawn_anim_spawn				= 30;

void M_Spawn_Attack_Explode()
{
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, W_Sound("rocket_impact"), VOL_BASE, ATTEN_NORM);

	RadiusDamage (self, self, (autocvar_g_monster_spawn_attack_explode_damage), (autocvar_g_monster_spawn_attack_explode_edgedamage), (autocvar_g_monster_spawn_attack_explode_radius), world, (autocvar_g_monster_spawn_attack_explode_force), DEATH_MONSTER_CREEPER, other);
}

void M_Spawn_Attack_Leap_Touch()
{
	if (self.health <= 0)
		return;

	vector angles_face;

	if(other.takedamage)
	{
		angles_face = vectoangles(self.moveto - self.origin);
		angles_face = normalize(angles_face) * (autocvar_g_monster_spawn_attack_leap_force);
		Damage(other, self, self, (autocvar_g_monster_spawn_attack_leap_damage) * MONSTER_SKILLMOD(self), DEATH_MONSTER_SPAWN_JUMP, other.origin, angles_face);
		self.touch = Monster_Touch; // instantly turn it off to stop damage spam
	}

	if (trace_dphitcontents)
		self.touch = Monster_Touch;
}

void M_Spawn_Defend_Block_End()
{
	if(self.health <= 0)
		return;

	self.frame = spawn_anim_blockend;
	self.armorvalue = autocvar_g_monsters_armor_blockpercent;
}

float M_Spawn_Defend_Block()
{
	self.frame = spawn_anim_blockstart;
	self.armorvalue = 0.9;
	self.state = MONSTER_ATTACK_MELEE; // freeze monster
	self.attack_finished_single = time + 2.1;

	defer(2, M_Spawn_Defend_Block_End);

	return TRUE;
}

float M_Spawn_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float rand = random(), chosen_anim;

			if(rand < 0.33)
				chosen_anim = spawn_anim_attackstanding1;
			else if(rand < 0.66)
				chosen_anim = spawn_anim_attackstanding2;
			else
				chosen_anim = spawn_anim_attackstanding3;

			if(random() < 0.3 && self.health < 75 && self.enemy.health > 10)
				return M_Spawn_Defend_Block();

			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_spawn_attack_melee_damage), chosen_anim, self.attack_range, (autocvar_g_monster_spawn_attack_melee_delay), DEATH_MONSTER_SPAWN_MELEE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			return Monster_Attack_Leap(spawn_anim_attackleap, M_Spawn_Attack_Leap_Touch, v_forward * (autocvar_g_monster_spawn_attack_leap_speed) + '0 0 200', (autocvar_g_monster_spawn_attack_leap_delay));
		}
	}

	return FALSE;
}

void spawnfunc_monster_spawn() { Monster_Spawn(MON_SPAWN); }

float M_Spawn(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_DEATH:
		{
			// KABOOM!
			self.frame = 0;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_spawn_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_spawn_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_spawn_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_spawn_speed_stop); }

			self.m_anim_walk = spawn_anim_runforward;
			self.m_anim_run = spawn_anim_runforward;
			self.m_anim_idle = spawn_anim_idle;

			if(self.spawnflags & MONSTERFLAG_NORESPAWN)
				self.spawnflags &= ~MONSTERFLAG_NORESPAWN; // spawns always respawn

			self.spawnflags |= MONSTER_RESPAWN_DEATHPOINT;

			self.monster_loot = spawnfunc_item_health_medium;
			self.frame = spawn_anim_spawn;
			self.spawn_time = time + 2.1;
			self.spawnshieldtime = self.spawn_time;
			self.respawntime = 0.2;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/spawn.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
