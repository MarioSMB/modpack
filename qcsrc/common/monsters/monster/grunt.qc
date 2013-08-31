#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ GRUNT,
/* function   */ m_grunt,
/* spawnflags */ 0,
/* mins,maxs  */ '-18 -18 -25', '18 18 47',
/* model      */ "grunt.dpm",
/* netname    */ "grunt",
/* fullname   */ _("Grunt")
);

#define GRUNT_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_melee_damage) \
	MON_ADD_CVAR(monster, target_range) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
GRUNT_SETTINGS(grunt)
#endif // SVQC
#else
#ifdef SVQC
const float grunt_anim_idle 		= 0;
const float grunt_anim_walk 		= 1;
const float grunt_anim_run 			= 2;
const float grunt_anim_attack1 		= 3;
const float grunt_anim_attack2 		= 4;
const float grunt_anim_attackrun 	= 5;
const float grunt_anim_flinch 		= 6;

float grunt_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float rand = random(), chosen_anim;
		
			if(vlen(self.velocity) > 20)
				chosen_anim = grunt_anim_attackrun;
			else if(rand < 0.5)
				chosen_anim = grunt_anim_attack1;
			else
				chosen_anim = grunt_anim_attack2;
				
			monsters_setframe(chosen_anim);
			
			monster_sound(self.msound_attack_melee, 0, FALSE);

			if(vlen(self.velocity) > 20)
				self.attack_finished_single = time + 0.9;
			else
				self.attack_finished_single = time + 1.9;
			
			if(monster_melee(self.enemy, MON_CVAR(grunt, attack_melee_damage), self.attack_range, DEATH_MONSTER_GRUNT, ((vlen(self.velocity) > 20) ? FALSE : TRUE)))
				monster_sound(self.msound_attack_ranged, 0, FALSE); // if it is going to hit, play claw sound too	
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
	}
	
	return FALSE;
}

void grunt_spawn_bodypart(string part, vector o)
{
	entity e = spawn();
	setmodel(e, strcat("models/monsters/grunt_", part, ".md3"));
	setsize(e, '-18 -18 -25', '18 18 47');
	setorigin(e, self.origin + o);
	e.avelocity = randomvec() * 150;
	e.solid = SOLID_CORPSE;
	e.movetype = MOVETYPE_BOUNCE;
	SUB_SetFade(e, time + 5, 1);
}

void monster_grunt_gib()
{
	makevectors(self.angles);
	grunt_spawn_bodypart("torso", '0 0 1' * 50);
	grunt_spawn_bodypart("arm", (v_right * 10) + '0 0 1' * 50);
	grunt_spawn_bodypart("legs", '0 0 1' * 25);
}

void spawnfunc_monster_grunt() 
{
	self.classname = "monster_grunt";
	
	self.monster_spawnfunc = spawnfunc_monster_grunt;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_GRUNT, FALSE)) { remove(self); return; }
}

float m_grunt(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(grunt, speed_run), MON_CVAR(grunt, speed_walk), MON_CVAR(grunt, speed_stop), grunt_anim_walk, grunt_anim_run, grunt_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			monsters_setframe(grunt_anim_flinch);
			self.ltime = time + 5;
			self.solid = SOLID_NOT;
			monster_grunt_gib();
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(grunt, health);
			if not(self.target_range) self.target_range = MON_CVAR(grunt, target_range);
			
			self.monster_flags = MONSTERFLAG_INFRONT; // always use line of sight target finding
			self.monster_moveflags = MONSTER_MOVE_WANDER; // always wander around
			self.monster_attackfunc	= grunt_attack;
			monsters_setframe(grunt_anim_idle);
			
			return TRUE;
		}
		case MR_INIT:
		{
			precache_model ("models/monsters/grunt_torso.md3");
			precache_model ("models/monsters/grunt_legs.md3");
			precache_model ("models/monsters/grunt_arm.md3");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(GRUNT_SETTINGS(grunt))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_grunt(float req)
{
	switch(req)
	{
		case MR_DEATH:
		{
			setmodel(self, "null");
			return TRUE;
		}
		case MR_INIT:
		{
			precache_model ("models/monsters/grunt.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
