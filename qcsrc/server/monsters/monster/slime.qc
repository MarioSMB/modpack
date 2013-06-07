const vector SLIME_MIN = '-16 -16 -24';
const vector SLIME_MAX = '16 16 16';

string SLIME_MODEL = "models/monsters/slime.dpm";

#ifdef SVQC
float autocvar_g_monster_slime;
float autocvar_g_monster_slime_health;
float autocvar_g_monster_slime_speed_walk;
float autocvar_g_monster_slime_speed_run;

const float slime_anim_walk		= 0;
const float slime_anim_idle		= 1;
const float slime_anim_jump		= 2;
const float slime_anim_fly		= 3;
const float slime_anim_die		= 4;
const float slime_anim_pain		= 5;

void slime_think()
{
	self.think = slime_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_slime_speed_run, autocvar_g_monster_slime_speed_walk, 20, slime_anim_walk, slime_anim_walk, slime_anim_idle);
}

void slime_touch_jump()
{
	if(self.health > 0)
	if(other.health > 0)
	if(other.takedamage)
	if(vlen(self.velocity) > 200)
	{
		Damage (self, world, world, self.health + self.max_health + 200, DEATH_MONSTER_SLIME, self.origin, '0 0 0');
			
		return;
	}

	if(trace_dphitcontents)
	{
		self.touch = MonsterTouch;
		self.movetype = MOVETYPE_WALK;
	}
}

float slime_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			if(monster_leap(slime_anim_jump, slime_touch_jump, v_forward * 600 + '0 0 200', 0.5))
				return TRUE;
		}
	}
	
	return FALSE;
}

void slime_explode()
{
	RadiusDamage(self, self, 250 * monster_skill, 15, 250 * (monster_skill * 0.7), world, 250, DEATH_MONSTER_SLIME, world);
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	
	setmodel(self, "");
}

void slime_dead()
{
	self.health = -100; // gibbed
	slime_explode();
	
	Monster_CheckDropCvars ("slime"); // drop items after exploding to prevent player picking up item before dying
	
	self.deadflag = DEAD_DEAD;
	self.think = Monster_Fade;
	self.nextthink = time + 0.1;
	
	monster_hook_death();
	
	self.event_damage = func_null; // reset by monster_hook_death
	self.takedamage = DAMAGE_NO;
}

void slime_die()
{
	self.think			= slime_dead;
	self.nextthink		= time;
	self.event_damage   = func_null;
	self.movetype		= MOVETYPE_NONE;
	self.enemy		  	= world;
	self.health			= 0;
	
	self.SendFlags |= MSF_MOVE | MSF_STATUS;
}

void slime_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_slime_health;
	
	self.damageforcescale   = 0.003;
	self.classname			= "monster_slime";
	self.monster_attackfunc	= slime_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= slime_think;
	
	monsters_setframe(slime_anim_idle);
	
	monster_setupsounds("slime");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_slime()
{
	if not(autocvar_g_monster_slime) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_slime;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Slime", MONSTER_SLIME,
			 SLIME_MIN, SLIME_MAX,
			 FALSE,
			 slime_die, slime_spawn))
	{
		remove(self);
		return;
	}
}

// compatibility with old spawns
void spawnfunc_monster_tarbaby() { spawnfunc_monster_slime(); }

#endif // SVQC
