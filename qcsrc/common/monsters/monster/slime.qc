#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SLIME,
/* function   */ m_slime,
/* spawnflags */ 0,
/* mins,maxs  */ '-16 -16 -24', '16 16 16',
/* model      */ "slime.dpm",
/* netname    */ "slime",
/* fullname   */ _("Slime")
);

#define SLIME_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_explode_damage) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
SLIME_SETTINGS(slime)
#endif // SVQC
#else
#ifdef SVQC
const float slime_anim_walk		= 0;
const float slime_anim_idle		= 1;
const float slime_anim_jump		= 2;
const float slime_anim_fly		= 3;
const float slime_anim_die		= 4;
const float slime_anim_pain		= 5;

void slime_touch_jump()
{
	if(self.health > 0)
	if(other.health > 0)
	if(other.takedamage)
	if(vlen(self.velocity) > 200)
	{
		Damage (self, world, world, MON_CVAR(slime, attack_explode_damage), DEATH_MONSTER_SLIME, self.origin, '0 0 0');
			
		return;
	}

	if(trace_dphitcontents)
	{
		self.touch = MonsterTouch;
		self.movetype = MOVETYPE_WALK;
	}
}

float slime_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			if(monster_leap(slime_anim_jump, slime_touch_jump, v_forward * 600 + '0 0 200', 0.5))
				return TRUE;
		}
	}
	
	return FALSE;
}

void slime_explode()
{
	RadiusDamage(self, self, MON_CVAR(slime, attack_explode_damage), 15, MON_CVAR(slime, attack_explode_damage) * 0.7, world, 250, DEATH_MONSTER_SLIME, world);
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	
	setmodel(self, "");
}

void slime_dead()
{
	self.health = -100; // gibbed
	slime_explode();
	
	self.deadflag = DEAD_DEAD;
	self.think = Monster_Fade;
	self.nextthink = time + 0.1;
}

void spawnfunc_monster_slime()
{
	self.classname = "monster_slime";
	
	self.monster_spawnfunc = spawnfunc_monster_slime;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_SLIME, FALSE)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_tarbaby() { spawnfunc_monster_slime(); }

float m_slime(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(slime, speed_run), MON_CVAR(slime, speed_walk), MON_CVAR(slime, speed_stop), slime_anim_walk, slime_anim_walk, slime_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			self.think			= slime_dead;
			self.nextthink		= time;
			self.event_damage   = func_null;
			self.movetype		= MOVETYPE_NONE;
			self.takedamage 	= DAMAGE_NO;
			self.enemy		  	= world;
			self.health			= 0;
			
			self.SendFlags |= MSF_MOVE | MSF_STATUS;
			
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(slime, health);
			
			self.monster_loot = spawnfunc_item_rockets;
			self.monster_attackfunc	= slime_attack;
			monsters_setframe(slime_anim_idle);
			
			return TRUE;
		}
		case MR_INIT:
		{
			// nothing
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(SLIME_SETTINGS(slime))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_slime(float req)
{
	switch(req)
	{
		case MR_DEATH:
		{
			// nothing
			return TRUE;
		}
		case MR_INIT:
		{
			precache_model ("models/monsters/slime.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
