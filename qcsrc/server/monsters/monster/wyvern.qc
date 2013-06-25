const vector WYVERN_MIN = '-20 -20 -58';
const vector WYVERN_MAX = '20 20 20';

string WYVERN_MODEL = "models/monsters/wizard.mdl";

#ifdef SVQC
float autocvar_g_monster_wyvern;
float autocvar_g_monster_wyvern_health;
float autocvar_g_monster_wyvern_speed_walk;
float autocvar_g_monster_wyvern_speed_run;
float autocvar_g_monster_wyvern_fireball_damage;
float autocvar_g_monster_wyvern_fireball_force;
float autocvar_g_monster_wyvern_fireball_radius;
float autocvar_g_monster_wyvern_fireball_edgedamage;
float autocvar_g_monster_wyvern_fireball_damagetime;
float autocvar_g_monster_wyvern_fireball_speed;

const float wyvern_anim_hover 	= 0;
const float wyvern_anim_fly 	= 1;
const float wyvern_anim_magic 	= 2;
const float wyvern_anim_pain 	= 3;
const float wyvern_anim_death 	= 4;

void wyvern_think()
{
	self.think = wyvern_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_wyvern_speed_run, autocvar_g_monster_wyvern_speed_walk, 300, wyvern_anim_fly, wyvern_anim_hover, wyvern_anim_hover);
}

void wyvern_fireball_explode()
{
	entity e;
	if(self)
	{
		pointparticles(particleeffectnum("fireball_explode"), self.origin, '0 0 0', 1);
		
		RadiusDamage(self, self.realowner, autocvar_g_monster_wyvern_fireball_damage, autocvar_g_monster_wyvern_fireball_edgedamage, autocvar_g_monster_wyvern_fireball_force, world, autocvar_g_monster_wyvern_fireball_radius, self.projectiledeathtype, world);
		
		for(e = world; (e = findfloat(e, takedamage, DAMAGE_AIM)); ) if(vlen(e.origin - self.origin) <= autocvar_g_monster_wyvern_fireball_radius)
			Fire_AddDamage(e, self, 5 * monster_skill, autocvar_g_monster_wyvern_fireball_damagetime, self.projectiledeathtype);
		
		remove(self);
	}
}

void wyvern_fireball_touch()
{
	PROJECTILE_TOUCH;
	
	wyvern_fireball_explode();
}

void wyvern_fireball()
{
	entity missile = spawn();
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	
	monster_makevectors(self.enemy);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_WYVERN;
	setsize(missile, '-6 -6 -6', '6 6 6');		
	setorigin(missile, self.origin + self.view_ofs + v_forward * 14);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * autocvar_g_monster_wyvern_fireball_speed;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = wyvern_fireball_explode;
	missile.enemy = self.enemy;
	missile.touch = wyvern_fireball_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_FIREMINE, TRUE);
}

float wyvern_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			self.attack_finished_single = time + 1.2;
			
			wyvern_fireball();
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void wyvern_die()
{
	Monster_CheckDropCvars ("wyvern");
	
	self.think 			= monster_dead_think;
	self.nextthink 		= time + self.ticrate;
	self.ltime 			= time + 5;
	self.velocity_x 	= -200 + 400 * random();
	self.velocity_y 	= -200 + 400 * random();
	self.velocity_z 	= 100 + 100 * random();
	
	monsters_setframe(wyvern_anim_death);
	
	monster_hook_death(); // for post-death mods
}

void wyvern_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_wyvern_health;
	
	self.classname			= "monster_wyvern";
	self.monster_attackfunc	= wyvern_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.movetype		   	= MOVETYPE_FLY;
	self.flags			   |= FL_FLY;
	self.think			  	= wyvern_think;
	
	monster_setupsounds("wyvern");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_wyvern()
{
	if not(autocvar_g_monster_wyvern) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_wyvern;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Wyvern", MONSTER_WYVERN,
			 WYVERN_MIN, WYVERN_MAX,
			 TRUE,
			 wyvern_die, wyvern_spawn))
	{
		remove(self);
		return;
	}
}

// compatibility with old spawns
void spawnfunc_monster_wizard() { spawnfunc_monster_wyvern(); }

#endif // SVQC
