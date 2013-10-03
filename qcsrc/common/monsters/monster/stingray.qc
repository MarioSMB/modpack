#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ STINGRAY,
/* function   */ m_stingray,
/* spawnflags */ MONSTER_TYPE_SWIM | MONSTER_SIZE_BROKEN | MON_FLAG_MELEE,
/* mins,maxs  */ '-20 -20 -31', '20 20 20',
/* model      */ "fish.mdl",
/* netname    */ "stingray",
/* fullname   */ _("Stingray")
);

#define STINGRAY_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_bite_damage) \
	MON_ADD_CVAR(monster, attack_bite_delay) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
STINGRAY_SETTINGS(stingray)
#endif // SVQC
#else
#ifdef SVQC
const float stingray_anim_attack = 0;
const float stingray_anim_death  = 1;
const float stingray_anim_swim   = 2;
const float stingray_anim_pain   = 3;

float stingray_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return monster_melee(self.enemy, MON_CVAR(stingray, attack_bite_damage), stingray_anim_attack, self.attack_range, MON_CVAR(stingray, attack_bite_delay), DEATH_MONSTER_STINGRAY, FALSE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// no ranged attack for stingray (yet?)
			return FALSE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_stingray()
{
	self.classname = "monster_stingray";
	
	self.monster_spawnfunc = spawnfunc_monster_stingray;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_STINGRAY, TRUE)) { remove(self); return; }
}

float m_stingray(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(stingray, speed_run), MON_CVAR(stingray, speed_walk), MON_CVAR(stingray, speed_stop), stingray_anim_swim, stingray_anim_swim, stingray_anim_swim);
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = stingray_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(stingray, health);
			
			self.monster_loot = spawnfunc_item_health_small;
			self.monster_attackfunc	= stingray_attack;
			self.frame = stingray_anim_swim;
			
			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/fish.mdl");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(STINGRAY_SETTINGS(stingray))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_stingray(float req)
{
	switch(req)
	{
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/fish.mdl");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
