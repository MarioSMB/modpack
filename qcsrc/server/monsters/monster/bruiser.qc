const vector BRUISER_MIN = '-20 -20 -31';
const vector BRUISER_MAX = '20 20 53';

string BRUISER_MODEL = "models/monsters/knight.mdl";

#ifdef SVQC
float autocvar_g_monster_bruiser;
float autocvar_g_monster_bruiser_health;
float autocvar_g_monster_bruiser_melee_damage;
float autocvar_g_monster_bruiser_speed_walk;
float autocvar_g_monster_bruiser_speed_run;

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

void bruiser_think()
{
	self.think = bruiser_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_bruiser_speed_run, autocvar_g_monster_bruiser_speed_walk, 50, bruiser_anim_run, bruiser_anim_walk, bruiser_anim_stand);
}

float bruiser_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float len = vlen(self.velocity);
			monsters_setframe((len < 50) ? bruiser_anim_attack : bruiser_anim_runattack);
			self.attack_finished_single = time + 1.25;
			
			monster_melee(self.enemy, autocvar_g_monster_bruiser_melee_damage, 0.3, DEATH_MONSTER_BRUISER, FALSE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
	}
	
	return FALSE;
}

void bruiser_die()
{
	Monster_CheckDropCvars ("bruiser");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe((random() > 0.5) ? bruiser_anim_death1 : bruiser_anim_death2);
	
	monster_hook_death(); // for post-death mods
}

void bruiser_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_bruiser_health;

	self.damageforcescale   = 0.003;
	self.classname			= "monster_bruiser";
	self.monster_attackfunc	= bruiser_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= bruiser_think;
	
	monsters_setframe(bruiser_anim_stand);
	
	monster_setupsounds("bruiser");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_bruiser()
{
	if not(autocvar_g_monster_bruiser) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_bruiser;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Bruiser", MONSTER_BRUISER,
			 BRUISER_MIN, BRUISER_MAX,
			 FALSE,
			 bruiser_die, bruiser_spawn))
	{
		remove(self);
		return;
	}
}

#endif // SVQC
