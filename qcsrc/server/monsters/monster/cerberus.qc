const vector CERBERUS_MIN = '-16 -16 -24';
const vector CERBERUS_MAX = '16 16 12';

string CERBERUS_MODEL = "models/monsters/dog.dpm";

#ifdef SVQC
float autocvar_g_monster_cerberus;
float autocvar_g_monster_cerberus_health;
float autocvar_g_monster_cerberus_bite_damage;
float autocvar_g_monster_cerberus_attack_jump_damage;
float autocvar_g_monster_cerberus_speed_walk;
float autocvar_g_monster_cerberus_speed_run;

const float cerberus_anim_idle	= 0;
const float cerberus_anim_walk	= 1;
const float cerberus_anim_run	= 2;
const float cerberus_anim_attack	= 3;
const float cerberus_anim_die	= 4;
const float cerberus_anim_pain	= 5;

void cerberus_think()
{
	self.think = cerberus_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_cerberus_speed_run, autocvar_g_monster_cerberus_speed_walk, 50, cerberus_anim_run, cerberus_anim_walk, cerberus_anim_idle);
}

void cerberus_touch_jump()
{
	if (other.takedamage)
	if (vlen(self.velocity) > 300)
	{
		Damage(self.enemy, self, self, autocvar_g_monster_cerberus_attack_jump_damage * monster_skill, DEATH_MONSTER_CERBERUS_JUMP, self.enemy.origin, normalize(self.enemy.origin - self.origin));
		self.touch = MonsterTouch;
	}

	if(trace_dphitcontents)
		self.touch = MonsterTouch;
}

float cerberus_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			monsters_setframe(cerberus_anim_attack);
			self.attack_finished_single = time + 0.7;
			monster_melee(self.enemy, autocvar_g_monster_cerberus_bite_damage, 0.2, DEATH_MONSTER_CERBERUS_BITE, TRUE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			if(monster_leap(cerberus_anim_attack, cerberus_touch_jump, v_forward * 300 + '0 0 200', 0.8))
				return TRUE;
		}
	}
	
	return FALSE;
}

void cerberus_die()
{
	Monster_CheckDropCvars ("cerberus");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(cerberus_anim_die);
	
	monster_hook_death(); // for post-death mods
}

void cerberus_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_cerberus_health;

	self.damageforcescale   = 0;
	self.classname			= "monster_cerberus";
	self.monster_attackfunc	= cerberus_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= cerberus_think;
	
	monsters_setframe(cerberus_anim_idle);
	
	monster_setupsounds("cerberus");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_cerberus()
{
	if not(autocvar_g_monster_cerberus) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_cerberus;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Cerberus", MONSTER_CERBERUS,
			 CERBERUS_MIN, CERBERUS_MAX,
			 FALSE,
			 cerberus_die, cerberus_spawn))
	{
		remove(self);
		return;
	}
}

// compatibility with old spawns
void spawnfunc_monster_dog() { spawnfunc_monster_cerberus(); }

#endif // SVQC
