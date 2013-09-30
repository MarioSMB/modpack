#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ ANIMUS,
/* function   */ m_animus,
/* spawnflags */ MONSTER_SIZE_BROKEN | MON_FLAG_MELEE,
/* mins,maxs  */ '-41 -41 -31', '41 41 31',
/* model      */ "demon.mdl",
/* netname    */ "animus",
/* fullname   */ _("Animus")
);

#define ANIMUS_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_jump_damage) \
	MON_ADD_CVAR(monster, attack_melee_damage) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
ANIMUS_SETTINGS(animus)
#endif // SVQC
#else
#ifdef SVQC
const float animus_anim_stand	= 0;
const float animus_anim_walk	= 1;
const float animus_anim_run		= 2;
const float animus_anim_leap	= 3;
const float animus_anim_pain	= 4;
const float animus_anim_death	= 5;
const float animus_anim_attack	= 6;

void animus_touch_jump()
{
	if (self.health <= 0)
		return;

	if (monster_isvalidtarget(other, self))
	{
		if (vlen(self.velocity) > 300)
		{
			Damage(other, self, self, MON_CVAR(animus, attack_jump_damage) * monster_skill, DEATH_MONSTER_ANIMUS, other.origin, normalize(other.origin - self.origin));
			self.touch = MonsterTouch; // instantly turn it off to stop damage spam
		}
	}

	if(trace_dphitcontents)
		self.touch = MonsterTouch;
}

float animus_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return monster_melee(self.enemy, MON_CVAR(animus, attack_melee_damage), animus_anim_attack, self.attack_range, 1, DEATH_MONSTER_ANIMUS, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			return monster_leap(animus_anim_leap, animus_touch_jump, v_forward * 700 + '0 0 300', 0.8);
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_animus()
{
	self.classname = "monster_animus";
	
	self.monster_spawnfunc = spawnfunc_monster_animus;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_ANIMUS, FALSE)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_demon1() { spawnfunc_monster_animus(); }
void spawnfunc_monster_demon() { spawnfunc_monster_animus(); }

float m_animus(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(animus, speed_run), MON_CVAR(animus, speed_walk), MON_CVAR(animus, speed_stop), animus_anim_run, animus_anim_walk, animus_anim_stand);
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = animus_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(animus, health);
			
			self.monster_loot = spawnfunc_item_health_medium;
			self.monster_attackfunc = animus_attack;
			self.frame = animus_anim_stand;
			
			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/demon.mdl");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(ANIMUS_SETTINGS(animus))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_animus(float req)
{
	switch(req)
	{
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/demon.mdl");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
