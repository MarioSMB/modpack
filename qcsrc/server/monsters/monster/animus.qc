const vector ANIMUS_MIN = '-41 -41 -31';
const vector ANIMUS_MAX = '41 41 31';

string ANIMUS_MODEL = "models/monsters/demon.mdl";

#ifdef SVQC
float autocvar_g_monster_animus;
float autocvar_g_monster_animus_health;
float autocvar_g_monster_animus_attack_jump_damage;
float autocvar_g_monster_animus_damage;
float autocvar_g_monster_animus_speed_walk;
float autocvar_g_monster_animus_speed_run;

const float animus_anim_stand	= 0;
const float animus_anim_walk	= 1;
const float animus_anim_run		= 2;
const float animus_anim_leap	= 3;
const float animus_anim_pain	= 4;
const float animus_anim_death	= 5;
const float animus_anim_attack	= 6;

void animus_think()
{
	self.think = animus_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_animus_speed_run, autocvar_g_monster_animus_speed_walk, 100, animus_anim_run, animus_anim_walk, animus_anim_stand);
}

void animus_touch_jump()
{
	if (self.health <= 0)
		return;

	if (monster_isvalidtarget(other, self))
	{
		if (vlen(self.velocity) > 300)
		{
			Damage(other, self, self, autocvar_g_monster_animus_attack_jump_damage * monster_skill, DEATH_MONSTER_ANIMUS, other.origin, normalize(other.origin - self.origin));
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
			monsters_setframe(animus_anim_attack);
			self.attack_finished_single = time + 1;
			monster_melee(self.enemy, autocvar_g_monster_animus_damage, 0.3, DEATH_MONSTER_ANIMUS, TRUE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			if(monster_leap(animus_anim_leap, animus_touch_jump, v_forward * 700 + '0 0 300', 0.8))
				return TRUE;
		}
	}
	
	return FALSE;
}

void animus_die()
{
	Monster_CheckDropCvars ("animus");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(animus_anim_death);
	
	monster_hook_death(); // for post-death mods
}

void animus_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_animus_health;

	self.damageforcescale   = 0;
	self.classname			= "monster_animus";
	self.monster_attackfunc	= animus_attack;
	self.nextthink		 	= time + random() * 0.5 + 0.1;
	self.think			  	= animus_think;
	
	monsters_setframe(animus_anim_stand);
	
	monster_setupsounds("animus");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_animus()
{
	if not(autocvar_g_monster_animus) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_animus;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Animus", MONSTER_ANIMUS,
			 ANIMUS_MIN, ANIMUS_MAX,
			 FALSE,
			 animus_die, animus_spawn))
	{
		remove(self);
		return;
	}
}

// compatibility with old spawns
void spawnfunc_monster_demon1() { spawnfunc_monster_animus(); }
void spawnfunc_monster_demon() { spawnfunc_monster_animus(); }

#endif // SVQC
