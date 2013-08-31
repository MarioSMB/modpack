#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SPIDER,
/* function   */ m_spider,
/* spawnflags */ MON_FLAG_MELEE | MON_FLAG_RANGED,
/* mins,maxs  */ '-18 -18 -25', '18 18 30',
/* model      */ "spider.dpm",
/* netname    */ "spider",
/* fullname   */ _("Spider")
);

#define SPIDER_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_bite_damage) \
	MON_ADD_CVAR(monster, attack_bite_delay) \
	MON_ADD_CVAR(monster, attack_web_damagetime) \
	MON_ADD_CVAR(monster, attack_web_speed) \
	MON_ADD_CVAR(monster, attack_web_speed_up) \
	MON_ADD_CVAR(monster, attack_web_delay) \
	MON_ADD_CVAR(monster, attack_type) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
SPIDER_SETTINGS(spider)
#endif // SVQC
#else
#ifdef SVQC
const float spider_anim_idle		= 0;
const float spider_anim_walk		= 1;
const float spider_anim_attack		= 2;
const float spider_anim_attack2		= 3;

.float spider_type; // used to switch between fire & ice attacks
const float SPIDER_TYPE_ICE		= 0;
const float SPIDER_TYPE_FIRE	= 1;

void spider_web_explode()
{
	entity e;
	if(self)
	{
		float damg = 0, edamg = 0, rad = 1;
		switch(self.realowner.spider_type)
		{
			case SPIDER_TYPE_ICE:
				rad = 25;
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
		
		for(e = findradius(self.origin, rad); e; e = e.chain) if(e != self) if(e.takedamage && e.deadflag == DEAD_NO) if(e.health > 0)
		{
			switch(self.realowner.spider_type)
			{
				case SPIDER_TYPE_ICE:
					Freeze(e, 0.3, 2, FALSE);
					break;
				case SPIDER_TYPE_FIRE:
					Fire_AddDamage(e, self.realowner, 5 * monster_skill, MON_CVAR(spider, attack_web_damagetime), DEATH_MONSTER_SPIDER_FIRE);
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
	
	monster_makevectors(self.enemy);
	
	sound(self, CH_SHOTS, snd, VOL_BASE, ATTEN_NORM);

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
	setorigin(proj, CENTER_OR_VIEWOFS(self));

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SetupProjectileVelocityEx(proj, v_forward, v_up, MON_CVAR(spider, attack_web_speed), MON_CVAR(spider, attack_web_speed_up), 0, 0, FALSE);
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
			if(monster_melee(self.enemy, MON_CVAR(spider, attack_bite_damage), ((random() > 0.5) ? spider_anim_attack : spider_anim_attack2), self.attack_range, MON_CVAR(spider, attack_bite_delay), DEATH_MONSTER_SPIDER, TRUE))
				return TRUE;
				
			return FALSE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(self.enemy.frozen)
				return FALSE;
			
			monsters_setframe(spider_anim_attack2);
			self.attack_finished_single = time + MON_CVAR(spider, attack_web_delay);
			spider_shootweb(self.spider_type);
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_spider() 
{
	self.classname = "monster_spider";
	
	self.monster_spawnfunc = spawnfunc_monster_spider;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_SPIDER, FALSE)) { remove(self); return; }
}

float m_spider(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(spider, speed_run), MON_CVAR(spider, speed_walk), MON_CVAR(spider, speed_stop), spider_anim_walk, spider_anim_walk, spider_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			monsters_setframe(spider_anim_attack);
			self.angles += '180 0 0';
			self.SendFlags |= MSF_ANG;
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(spider, health);
			if not(self.spider_type) self.spider_type = MON_CVAR(spider, attack_type);
			
			self.monster_loot = spawnfunc_item_health_medium;
			self.monster_attackfunc	= spider_attack;
			monsters_setframe(spider_anim_idle);
			
			return TRUE;
		}
		case MR_INIT:
		{
			// nothing
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(SPIDER_SETTINGS(spider))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_spider(float req)
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
			precache_model ("models/monsters/spider.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
