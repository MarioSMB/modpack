#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ BRUISER,
/* function   */ m_bruiser,
/* spawnflags */ MONSTER_SIZE_BROKEN | MON_FLAG_MELEE,
/* mins,maxs  */ '-20 -20 -31', '20 20 53',
/* model      */ "knight.mdl",
/* netname    */ "bruiser",
/* fullname   */ _("Bruiser")
);

#define BRUISER_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_melee_damage) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
BRUISER_SETTINGS(bruiser)
#endif // SVQC
#else
#ifdef SVQC
const float bruiser_anim_stand 		= 0;
const float bruiser_anim_run 		= 1;
const float bruiser_anim_runattack 	= 2;
const float bruiser_anim_pain1 		= 3;
const float bruiser_anim_pain2 		= 4;
const float bruiser_anim_attack 	= 5;
const float bruiser_anim_walk 		= 6;
const float bruiser_anim_kneel 		= 7;
const float bruiser_anim_standing 	= 8;
const float bruiser_anim_death1 	= 9;
const float bruiser_anim_death2 	= 10;

float bruiser_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float len = vlen(self.velocity);
			
			return monster_melee(self.enemy, MON_CVAR(bruiser, attack_melee_damage), ((len < 50) ? bruiser_anim_attack : bruiser_anim_runattack), self.attack_range, 1.25, DEATH_MONSTER_BRUISER, FALSE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// no ranged attacks for bruiser
			return FALSE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_bruiser()
{
	self.classname = "monster_bruiser";
	
	self.monster_spawnfunc = spawnfunc_monster_bruiser;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_BRUISER, FALSE)) { remove(self); return; }
}

float m_bruiser(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			entity pet = world;
			pet = findentity(pet, monster_owner, self);
			float rspeed = MON_CVAR(bruiser, speed_run);
			
			if(pet)
			if(self.enemy)
			if(vlen(self.enemy.origin - pet.origin) < vlen(self.enemy.origin - self.origin))
				rspeed = 0;
				
			monster_move(rspeed, MON_CVAR(bruiser, speed_walk), MON_CVAR(bruiser, speed_stop), bruiser_anim_run, bruiser_anim_walk, bruiser_anim_stand);
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = ((random() > 0.5) ? bruiser_anim_death1 : bruiser_anim_death2);
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(bruiser, health);
			
			self.monster_loot = spawnfunc_item_armor_medium;
			self.monster_attackfunc	= bruiser_attack;
			self.frame = bruiser_anim_stand;
			
			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/knight.mdl");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(BRUISER_SETTINGS(bruiser))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_bruiser(float req)
{
	switch(req)
	{
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/knight.mdl");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
