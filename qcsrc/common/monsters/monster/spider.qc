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

.float spider_web_delay;

void spider_web_explode()
{
	entity e;
	if(self)
	{
		pointparticles(particleeffectnum("electro_impact"), self.origin, '0 0 0', 1);
		RadiusDamage(self, self.realowner, 0, 0, 25, world, 25, self.projectiledeathtype, world);
		
		for(e = findradius(self.origin, 25); e; e = e.chain) if(e != self) if(e.takedamage && e.deadflag == DEAD_NO) if(e.health > 0)
			e.spider_slowness = time + MON_CVAR(spider, attack_web_damagetime);
		
		remove(self);
	}
}

void spider_web_touch()
{
	PROJECTILE_TOUCH;
	
	spider_web_explode();
}

void spider_shootweb()
{
	monster_makevectors(self.enemy);
	
	sound(self, CH_SHOTS, "weapons/electro_fire2.wav", VOL_BASE, ATTEN_NORM);

	entity proj = spawn ();
	proj.classname = "plasma";
	proj.owner = proj.realowner = self;
	proj.use = spider_web_touch;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = 0;
	proj.nextthink = time + 5;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_MONSTER_SPIDER;
	setorigin(proj, CENTER_OR_VIEWOFS(self));

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SetupProjectileVelocityEx(proj, v_forward, v_up, MON_CVAR(spider, attack_web_speed), MON_CVAR(spider, attack_web_speed_up), 0, 0, FALSE);
	proj.touch = spider_web_touch;
	setsize(proj, '-4 -4 -4', '4 4 4');
	proj.takedamage = DAMAGE_NO;
	proj.damageforcescale = 0;
	proj.health = 500;
	proj.event_damage = func_null;
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = TRUE;

	proj.bouncefactor = 0.3;
	proj.bouncestop = 0.05;
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO, TRUE);
}

float spider_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{	
			return monster_melee(self.enemy, MON_CVAR(spider, attack_bite_damage), ((random() > 0.5) ? spider_anim_attack : spider_anim_attack2), self.attack_range, MON_CVAR(spider, attack_bite_delay), DEATH_MONSTER_SPIDER, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(time >= self.spider_web_delay)
			{
				self.frame = spider_anim_attack2;
				self.attack_finished_single = time + MON_CVAR(spider, attack_web_delay);
				spider_shootweb();
				self.spider_web_delay = time + 3;
				return TRUE;
			}
			
			return FALSE;
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
			self.frame = spider_anim_attack;
			self.angles_x = 180;
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(spider, health);
			
			self.monster_loot = spawnfunc_item_health_medium;
			self.monster_attackfunc	= spider_attack;
			self.frame = spider_anim_idle;
			
			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/spider.dpm");
			precache_sound ("weapons/electro_fire2.wav");
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
		case MR_PRECACHE:
		{
			precache_model ("models/monsters/spider.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
