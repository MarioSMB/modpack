const vector STINGRAY_MIN = '-20 -20 -31';
const vector STINGRAY_MAX = '20 20 20';

string STINGRAY_MODEL = "models/monsters/fish.mdl";

#ifdef SVQC
float autocvar_g_monster_stingray;
float autocvar_g_monster_stingray_health;
float autocvar_g_monster_stingray_damage;
float autocvar_g_monster_stingray_speed_walk;
float autocvar_g_monster_stingray_speed_run;

const float stingray_anim_attack = 0;
const float stingray_anim_death  = 1;
const float stingray_anim_swim   = 2;
const float stingray_anim_pain   = 3;

void stingray_think()
{
	self.think = stingray_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_stingray_speed_run, autocvar_g_monster_stingray_speed_walk, 10, stingray_anim_swim, stingray_anim_swim, stingray_anim_swim);
}

float stingray_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			monsters_setframe(stingray_anim_attack);
			self.attack_finished_single = time + 0.5;
			monster_melee(self.enemy, autocvar_g_monster_stingray_damage, 0.1, DEATH_MONSTER_STINGRAY, FALSE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
	}
	
	return FALSE;
}

void stingray_die()
{
	Monster_CheckDropCvars ("stingray");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(stingray_anim_death);
	
	monster_hook_death(); // for post-death mods
}

void stingray_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_stingray_health;

	self.damageforcescale   = 0.5;
	self.classname			= "monster_stingray";
	self.monster_attackfunc	= stingray_attack;
	self.flags			   |= FL_SWIM;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= stingray_think;
	
	monster_setupsounds("stingray");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_stingray()
{
	if not(autocvar_g_monster_stingray) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_stingray;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Stingray", MONSTER_STINGRAY,
			 STINGRAY_MIN, STINGRAY_MAX,
			 TRUE,
			 stingray_die, stingray_spawn))
	{
		remove(self);
		return;
	}
}

#endif // SVQC
