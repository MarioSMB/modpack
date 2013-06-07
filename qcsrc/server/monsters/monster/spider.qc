const vector SPIDER_MIN = '-18 -18 -25';
const vector SPIDER_MAX = '18 18 30';

string SPIDER_MODEL = "models/monsters/spider.dpm";

#ifdef SVQC
float autocvar_g_monster_spider;
float autocvar_g_monster_spider_stopspeed;
float autocvar_g_monster_spider_attack_leap_delay;
float autocvar_g_monster_spider_attack_stand_damage;
float autocvar_g_monster_spider_attack_stand_delay;
float autocvar_g_monster_spider_attack_fire_time;
float autocvar_g_monster_spider_health;
float autocvar_g_monster_spider_speed_walk;
float autocvar_g_monster_spider_speed_run;
float autocvar_g_monster_spider_attack_type;

const float spider_anim_idle		= 0;
const float spider_anim_walk		= 1;
const float spider_anim_attack		= 2;
const float spider_anim_attack2		= 3;

.float spider_type; // used to switch between fire & ice attacks
const float SPIDER_TYPE_ICE		= 0;
const float SPIDER_TYPE_FIRE	= 1;

void spider_think()
{
	self.think = spider_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_spider_speed_run, autocvar_g_monster_spider_speed_walk, autocvar_g_monster_spider_stopspeed, spider_anim_walk, spider_anim_walk, spider_anim_idle);
}

void spider_web_explode()
{
	entity e;
	if(self)
	{
		float damg = 0, edamg = 0, rad = 1;
		switch(self.realowner.spider_type)
		{
			case SPIDER_TYPE_ICE:
				pointparticles(particleeffectnum("electro_impact"), self.origin, '0 0 0', 1);
				break;
			case SPIDER_TYPE_FIRE:
				pointparticles(particleeffectnum("fireball_explode"), self.origin, '0 0 0', 1);
				damg = 15;
				rad = 25;
				edamg = 6;
				break;
		}
		
		RadiusDamage(self, self.realowner, damg, edamg, 0, world, rad, DEATH_MONSTER_SPIDER_FIRE, world); // ice deals no damage anyway
		
		if(self.realowner.spider_type == SPIDER_TYPE_FIRE)
		for(e = findradius(self.origin, rad); e; e = e.chain) if(e.takedamage && e.deadflag == DEAD_NO)
		{
			switch(self.realowner.spider_type)
			{
				case SPIDER_TYPE_ICE:
					Freeze(other, 0.3, 2, FALSE);
					break;
				case SPIDER_TYPE_FIRE:
					Fire_AddDamage(e, self.realowner, 5 * monster_skill, autocvar_g_monster_spider_attack_fire_time, DEATH_MONSTER_SPIDER_FIRE, FALSE);
					break;
			}
		}
		
		remove(self);
	}
}

void spider_web_touch()
{
	PROJECTILE_TOUCH;
	
	spider_web_explode();
}

void spider_shootweb(float ptype)
{
	float p = 0;
	string snd = "";
	switch(ptype)
	{
		case SPIDER_TYPE_ICE:
			p = PROJECTILE_ELECTRO;
			snd = "weapons/electro_fire2.wav";
			break;
		case SPIDER_TYPE_FIRE:
			p = PROJECTILE_FIREMINE;
			snd = "weapons/fireball_fire.wav";
			break;
	}
	
	vector fmins = '-4 -4 -4', fmaxs = '4 4 4';

	W_SetupShot_ProjectileSize(self, fmins, fmaxs, FALSE, 2, snd, CH_WEAPON_A, 0, DEATH_MONSTER_SPIDER_FIRE);

	w_shotdir = v_forward; // no TrueAim for grenades please

	entity proj = spawn ();
	proj.classname = "plasma";
	proj.owner = proj.realowner = self;
	proj.use = spider_web_touch;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = 0;
	proj.nextthink = time + 5;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_MONSTER_SPIDER_FIRE;
	setorigin(proj, w_shotorg);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_monster_spider_attack_web);
	proj.touch = spider_web_touch;
	setsize(proj, fmins, fmaxs);
	proj.takedamage = DAMAGE_NO;
	proj.damageforcescale = 0;
	proj.health = 500;
	proj.event_damage = func_null;
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = TRUE;

	proj.bouncefactor = 0.3;
	proj.bouncestop = 0.05;
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

	CSQCProjectile(proj, TRUE, p, TRUE);
}

float spider_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			monster_melee(self.enemy, autocvar_g_monster_spider_attack_stand_damage, 0.3, DEATH_MONSTER_SPIDER, TRUE);
			monsters_setframe((random() > 0.5) ? spider_anim_attack : spider_anim_attack2);
			self.attack_finished_single = time + autocvar_g_monster_spider_attack_stand_delay;
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(self.enemy.frozen)
				return FALSE;
			
			monsters_setframe(spider_anim_attack2);
			self.attack_finished_single = time + autocvar_g_monster_spider_attack_leap_delay;
			monster_makevectors(self.enemy);
			spider_shootweb(self.spider_type);
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void spider_die()
{
	Monster_CheckDropCvars ("spider");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(spider_anim_attack);
	self.angles += '180 0 0';
	
	monster_hook_death(); // for post-death mods
}

void spider_spawn() 
{
	if not(self.health)
		self.health = autocvar_g_monster_spider_health;
	
	self.classname			= "monster_spider";
	self.nextthink	  		= time + random() * 0.5 + 0.1;
	self.monster_attackfunc	= spider_attack;
	self.think		  		= spider_think;
	
	monsters_setframe(spider_anim_idle);
	
	monster_setupsounds("spider");
	
	if not(self.spider_type)
		self.spider_type = autocvar_g_monster_spider_attack_type;
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_spider() 
{
	if not(autocvar_g_monster_spider) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_spider;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Spider", MONSTER_SPIDER,
			 SPIDER_MIN, SPIDER_MAX,
			 FALSE,
			 spider_die, spider_spawn))
	{
		remove(self);
		return;
	}
}

#endif // SVQC
