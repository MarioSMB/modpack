#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ BRUTE,
/* function   */ m_brute,
/* spawnflags */ MON_FLAG_MELEE | MON_FLAG_RANGED,
/* mins,maxs  */ '-36 -36 -20', '36 36 50',
/* model      */ "ogre.dpm",
/* netname    */ "brute",
/* fullname   */ _("Brute")
);

#define BRUTE_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_chainsaw_damage) \
	MON_ADD_CVAR(monster, attack_uzi_bullets) \
	MON_ADD_CVAR(monster, attack_uzi_damage) \
	MON_ADD_CVAR(monster, attack_uzi_force) \
	MON_ADD_CVAR(monster, attack_uzi_chance) \
	MON_ADD_CVAR(monster, attack_grenade_damage) \
	MON_ADD_CVAR(monster, attack_grenade_edgedamage) \
	MON_ADD_CVAR(monster, attack_grenade_force) \
	MON_ADD_CVAR(monster, attack_grenade_radius) \
	MON_ADD_CVAR(monster, attack_grenade_speed) \
	MON_ADD_CVAR(monster, attack_grenade_speed_up) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
BRUTE_SETTINGS(brute)
#endif // SVQC
#else
#ifdef SVQC
const float brute_anim_idle 		= 0;
const float brute_anim_walk 		= 1;
const float brute_anim_run 			= 2;
const float brute_anim_pain 		= 3;
const float brute_anim_swing 		= 4;
const float brute_anim_die 			= 5;

.float brute_cycles;

void brute_blade()
{
	self.brute_cycles += 1;
	self.angles_y = self.angles_y + random()* 25;
	
	monster_melee(self.enemy, MON_CVAR(brute, attack_chainsaw_damage), brute_anim_swing, self.attack_range, 0, DEATH_MONSTER_BRUTE_BLADE, TRUE);
	
	if(self.brute_cycles <= 4)
		defer(0.2, brute_blade);
}

void brute_uzi()
{
	self.brute_cycles += 1;
	
	monster_makevectors(self.enemy);
	
	sound(self, CH_WEAPON_A, "weapons/uzi_fire.wav", VOL_BASE, ATTEN_NORM);
	fireBallisticBullet(CENTER_OR_VIEWOFS(self), v_forward, 0.02, 18000, 5, MON_CVAR(brute, attack_uzi_damage), MON_CVAR(brute, attack_uzi_force), DEATH_MONSTER_BRUTE_UZI, 0, 1, 115);
	endFireBallisticBullet();
	
	if(self.brute_cycles <= MON_CVAR(brute, attack_uzi_bullets))
		defer(0.1, brute_uzi);
}

void brute_grenade_explode()
{
	pointparticles(particleeffectnum("grenade_explode"), self.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTEN_NORM);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage (self, self.realowner, MON_CVAR(brute, attack_grenade_damage), MON_CVAR(brute, attack_grenade_edgedamage), MON_CVAR(brute, attack_grenade_radius), world, MON_CVAR(brute, attack_grenade_force), self.projectiledeathtype, other);

	remove (self);
}

void brute_grenade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	self.health = self.health - damage;
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void brute_grenade_touch()
{
	PROJECTILE_TOUCH;
	
	self.use ();
}

void brute_grenade_think()
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		brute_grenade_explode();
		return;
	}
}

void brute_grenade()
{
	entity gren;
	
	monster_makevectors(self.enemy);
	
	sound(self, CH_WEAPON_A, "weapons/grenade_fire.wav", VOL_BASE, ATTEN_NORM);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = MON_CVAR(brute, attack_grenade_damage);
	gren.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_BRUTE_GRENADE;
	setorigin(gren, CENTER_OR_VIEWOFS(self));
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + 5;
	gren.nextthink = time;
	gren.think = brute_grenade_think;
	gren.use = brute_grenade_explode;
	gren.touch = brute_grenade_touch;

	gren.takedamage = DAMAGE_YES;
	gren.health = 50;
	gren.damageforcescale = 0;
	gren.event_damage = brute_grenade_damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjectileVelocityEx(gren, v_forward, v_up, MON_CVAR(brute, attack_grenade_speed), MON_CVAR(brute, attack_grenade_speed_up), 0, 0, FALSE);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
}

float brute_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			self.brute_cycles = 0;
			self.attack_finished_single = time + 1.3;
			brute_blade();
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			self.brute_cycles = 0;
			if(random() <= MON_CVAR(brute, attack_uzi_chance))
			{
				monsters_setframe(brute_anim_pain);
				self.attack_finished_single = time + 0.8;
				defer(0.1, brute_uzi);
			}
			else
			{
				monster_makevectors(self.enemy);
				brute_grenade();
				monsters_setframe(brute_anim_pain);
				self.attack_finished_single = time + 1.2;
			}
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_brute()
{
	self.classname = "monster_brute";
	
	self.monster_spawnfunc = spawnfunc_monster_brute;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_BRUTE, FALSE)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_ogre() { spawnfunc_monster_brute(); }

float m_brute(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(brute, speed_run), MON_CVAR(brute, speed_walk), MON_CVAR(brute, speed_stop), brute_anim_run, brute_anim_walk, brute_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			monsters_setframe(brute_anim_die);
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(brute, health);
			
			self.monster_loot = spawnfunc_item_bullets;
			self.monster_attackfunc	= brute_attack;
			monsters_setframe(brute_anim_idle);
			self.weapon = WEP_GRENADE_LAUNCHER;
			
			return TRUE;
		}
		case MR_INIT:
		{
			precache_sound ("weapons/uzi_fire.wav");
			precache_sound ("weapons/grenade_impact.wav");
			precache_sound ("weapons/grenade_fire.wav");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(BRUTE_SETTINGS(brute))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_brute(float req)
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
			precache_model ("models/monsters/ogre.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
