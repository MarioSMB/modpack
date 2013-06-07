// size
const vector GRUNT_MIN = '-18 -18 -25';
const vector GRUNT_MAX = '18 18 47';

// model
string GRUNT_MODEL = "models/monsters/grunt.dpm";

#ifdef SVQC
// cvars
float autocvar_g_monster_grunt;
float autocvar_g_monster_grunt_attack_damage;
float autocvar_g_monster_grunt_health;
float autocvar_g_monster_grunt_speed_walk;
float autocvar_g_monster_grunt_speed_run;
float autocvar_g_monster_grunt_target_range;

// animations
const float grunt_anim_idle 		= 0;
const float grunt_anim_walk 		= 1;
const float grunt_anim_run 			= 2;
const float grunt_anim_attack1 		= 3;
const float grunt_anim_attack2 		= 4;
const float grunt_anim_attackrun 	= 5;
const float grunt_anim_flinch 		= 6;

void grunt_think()
{
	self.think = grunt_think;
	self.nextthink = time + self.ticrate;

	monster_move(autocvar_g_monster_grunt_speed_run, autocvar_g_monster_grunt_speed_walk, 120, grunt_anim_walk, grunt_anim_run, grunt_anim_idle);
}

float grunt_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float rand = random(), chosen_anim, dot;
		
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
			
			monster_melee(self.enemy, autocvar_g_monster_grunt_attack_damage, 0.3, DEATH_MONSTER_GRUNT, ((vlen(self.velocity) > 20) ? FALSE : TRUE)); // only stop if we were already standing
			
			makevectors (self.angles);
			dot = normalize (self.enemy.origin - self.origin) * v_forward;
			
			if(dot > 0.3)
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
	setsize(e, GRUNT_MIN, GRUNT_MAX);
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

void grunt_die ()
{
	Monster_CheckDropCvars ("grunt");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(grunt_anim_flinch);
	self.solid = SOLID_NOT;
	
	monster_grunt_gib();
		
	monster_hook_death(); // for post-death mods
}

void grunt_spawn() 
{
	if not(self.health)
		self.health = autocvar_g_monster_grunt_health;
	
	self.classname			= "monster_grunt";
	self.nextthink			= time + random() * 0.5 + 0.1;
	self.think		  		= grunt_think;
	self.monster_attackfunc	= grunt_attack;
	self.monster_flags		= MONSTERFLAG_INFRONT; // always use line of sight target finding
	self.spawn_time			= self.nextthink;
	self.spawnshieldtime	= self.spawn_time;
	self.monster_moveflags  = MONSTER_MOVE_WANDER; // always wander around
	self.target_range		= autocvar_g_monster_grunt_target_range;
	
	monsters_setframe(grunt_anim_idle);
	
	monster_setupsounds("grunt");
	
	monster_hook_spawn(); // for post-spawn mods
	
	WaypointSprite_Kill(self.sprite); // no sprite for grunt
}

void spawnfunc_monster_grunt() 
{
	if not(autocvar_g_monster_grunt) { remove(self); return; }
	
	precache_model("models/monsters/grunt_torso.md3");
	precache_model("models/monsters/grunt_legs.md3");
	precache_model("models/monsters/grunt_arm.md3");
	
	self.monster_spawnfunc = spawnfunc_monster_grunt;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Grunt", MONSTER_GRUNT,
			 GRUNT_MIN, GRUNT_MAX,
			 FALSE,
			 grunt_die, grunt_spawn))
	{
		remove(self);
		return;
	}
}

#endif //SVQC
