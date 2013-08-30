#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ ZOMBIE,
/* function   */ m_zombie,
/* spawnflags */ 0,
/* mins,maxs  */ '-18 -18 -25', '18 18 47',
/* model      */ "zombie.dpm",
/* netname    */ "zombie",
/* fullname   */ _("Zombie")
);

#define ZOMBIE_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_melee_damage) \
	MON_ADD_CVAR(monster, attack_melee_delay) \
	MON_ADD_CVAR(monster, attack_leap_damage) \
	MON_ADD_CVAR(monster, attack_leap_force) \
	MON_ADD_CVAR(monster, attack_leap_speed) \
	MON_ADD_CVAR(monster, attack_leap_delay) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
ZOMBIE_SETTINGS(zombie)
#endif // SVQC
#else
#ifdef SVQC
const float zombie_anim_attackleap			= 0;
const float zombie_anim_attackrun1			= 1;
const float zombie_anim_attackrun2			= 2;
const float zombie_anim_attackrun3			= 3;
const float zombie_anim_attackstanding1		= 4;
const float zombie_anim_attackstanding2		= 5;
const float zombie_anim_attackstanding3		= 6;
const float zombie_anim_blockend		   	= 7;
const float zombie_anim_blockstart			= 8;
const float zombie_anim_deathback1			= 9;
const float zombie_anim_deathback2			= 10;
const float zombie_anim_deathback3			= 11;
const float zombie_anim_deathfront1			= 12;
const float zombie_anim_deathfront2			= 13;
const float zombie_anim_deathfront3			= 14;
const float zombie_anim_deathleft1			= 15;
const float zombie_anim_deathleft2			= 16;
const float zombie_anim_deathright1			= 17;
const float zombie_anim_deathright2			= 18;
const float zombie_anim_idle			   	= 19;
const float zombie_anim_painback1		  	= 20;
const float zombie_anim_painback2		  	= 21;
const float zombie_anim_painfront1			= 22;
const float zombie_anim_painfront2			= 23;
const float zombie_anim_runbackwards	   	= 24;
const float zombie_anim_runbackwardsleft   	= 25;
const float zombie_anim_runbackwardsright  	= 26;
const float zombie_anim_runforward			= 27;
const float zombie_anim_runforwardleft	 	= 28;
const float zombie_anim_runforwardright		= 29;
const float zombie_anim_spawn			  	= 30;

void zombie_attack_leap_touch()
{
	if (self.health <= 0)
		return;
		
	vector angles_face;

	if(other.takedamage)
	{
		angles_face = vectoangles(self.moveto - self.origin);
		angles_face = normalize(angles_face) * MON_CVAR(zombie, attack_leap_force);
		Damage(other, self, self, MON_CVAR(zombie, attack_leap_damage) * monster_skill, DEATH_MONSTER_ZOMBIE_JUMP, other.origin, angles_face);
		self.touch = MonsterTouch; // instantly turn it off to stop damage spam
	}

	if (trace_dphitcontents)
		self.touch = MonsterTouch;
}

float zombie_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float rand = random(), chosen_anim;
		
			if(rand < 0.33)
				chosen_anim = zombie_anim_attackstanding1;
			else if(rand < 0.66)
				chosen_anim = zombie_anim_attackstanding2;
			else
				chosen_anim = zombie_anim_attackstanding3;
				
			monsters_setframe(chosen_anim);

			self.attack_finished_single = time + MON_CVAR(zombie, attack_melee_delay);
			
			monster_melee(self.enemy, MON_CVAR(zombie, attack_melee_damage), self.attack_range, DEATH_MONSTER_ZOMBIE_MELEE, TRUE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			if(monster_leap(zombie_anim_attackleap, zombie_attack_leap_touch, v_forward * MON_CVAR(zombie, attack_leap_speed) + '0 0 200', MON_CVAR(zombie, attack_leap_delay)))
				return TRUE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_zombie() 
{
	self.classname = "monster_zombie";
	
	self.monster_spawnfunc = spawnfunc_monster_zombie;
	
	self.spawnflags |= MONSTER_RESPAWN_DEATHPOINT;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_ZOMBIE, FALSE)) { remove(self); return; }
}

float m_zombie(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(zombie, speed_run), MON_CVAR(zombie, speed_walk), MON_CVAR(zombie, speed_stop), zombie_anim_runforward, zombie_anim_runforward, zombie_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			monsters_setframe((random() > 0.5) ? zombie_anim_deathback1 : zombie_anim_deathfront1);
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(zombie, health);
			
			if(self.spawnflags & MONSTERFLAG_NORESPAWN)
				self.spawnflags &= ~MONSTERFLAG_NORESPAWN; // zombies always respawn
			
			self.monster_loot = spawnfunc_item_health_medium;
			self.monster_attackfunc	= zombie_attack;
			monsters_setframe(zombie_anim_spawn);
			self.spawn_time = time + 2.1;
			self.spawnshieldtime = self.spawn_time;
			self.respawntime = 0.2;
			
			return TRUE;
		}
		case MR_INIT:
		{
			// nothing
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(ZOMBIE_SETTINGS(zombie))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_zombie(float req)
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
			precache_model ("models/monsters/zombie.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
