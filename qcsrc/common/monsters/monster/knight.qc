#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ KNIGHT,
/* function   */ m_knight,
/* spawnflags */ MONSTER_SIZE_BROKEN,
/* mins,maxs  */ '-20 -20 -32', '20 20 41',
/* model      */ "hknight.mdl",
/* netname    */ "knight",
/* fullname   */ _("Knight")
);

#define KNIGHT_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_melee_damage) \
	MON_ADD_CVAR(monster, attack_inferno_damage) \
	MON_ADD_CVAR(monster, attack_inferno_damagetime) \
	MON_ADD_CVAR(monster, attack_inferno_chance) \
	MON_ADD_CVAR(monster, attack_fireball_damage) \
	MON_ADD_CVAR(monster, attack_fireball_edgedamage) \
	MON_ADD_CVAR(monster, attack_fireball_damagetime) \
	MON_ADD_CVAR(monster, attack_fireball_force) \
	MON_ADD_CVAR(monster, attack_fireball_radius) \
	MON_ADD_CVAR(monster, attack_fireball_chance) \
	MON_ADD_CVAR(monster, attack_spike_damage) \
	MON_ADD_CVAR(monster, attack_spike_edgedamage) \
	MON_ADD_CVAR(monster, attack_spike_force) \
	MON_ADD_CVAR(monster, attack_spike_radius) \
	MON_ADD_CVAR(monster, attack_spike_chance) \
	MON_ADD_CVAR(monster, attack_jump_damage) \
	MON_ADD_CVAR(monster, attack_jump_distance) \
	MON_ADD_CVAR(monster, attack_jump_chance) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
KNIGHT_SETTINGS(knight)
#endif // SVQC
#else
#ifdef SVQC
const float knight_anim_stand 	= 0;
const float knight_anim_walk 	= 1;
const float knight_anim_run 	= 2;
const float knight_anim_pain 	= 3;
const float knight_anim_death1 	= 4;
const float knight_anim_death2 	= 5;
const float knight_anim_charge1 = 6;
const float knight_anim_magic1 	= 7;
const float knight_anim_magic2 	= 8;
const float knight_anim_charge2 = 9;
const float knight_anim_slice 	= 10;
const float knight_anim_smash 	= 11;
const float knight_anim_wattack = 12;
const float knight_anim_magic3 	= 13;

.float knight_cycles;

void knight_inferno()
{
	if not(self.enemy)
		return;
		
	traceline((self.absmin + self.absmax) * 0.5, (self.enemy.absmin + self.enemy.absmax) * 0.5, TRUE, world);
	if (trace_fraction != 1)
		return; // not visible
	
	self.enemy.effects |= EF_MUZZLEFLASH;
	sound(self.enemy, CHAN_AUTO, "player/lava.wav", 1, ATTEN_NORM);
	
	if(vlen(self.enemy.origin - self.origin) <= 2000)
		Fire_AddDamage(self.enemy, self, MON_CVAR(knight, attack_inferno_damage) * monster_skill, MON_CVAR(knight, attack_inferno_damagetime), DEATH_MONSTER_KNIGHT_INFERNO);
}

void knight_fireball_explode()
{
	entity e;
	if(self)
	{
		pointparticles(particleeffectnum("fireball_explode"), self.origin, '0 0 0', 1);
		
		RadiusDamage(self, self.realowner, MON_CVAR(knight, attack_fireball_damage), MON_CVAR(knight, attack_fireball_edgedamage), MON_CVAR(knight, attack_fireball_force), world, MON_CVAR(knight, attack_fireball_radius), self.projectiledeathtype, world);
		
		for(e = world; (e = findfloat(e, takedamage, DAMAGE_AIM)); ) if(vlen(e.origin - self.origin) <= MON_CVAR(knight, attack_inferno_damage))
			Fire_AddDamage(e, self, 5 * monster_skill, MON_CVAR(knight, attack_fireball_damagetime), self.projectiledeathtype);
		
		remove(self);
	}
}

void knight_fireball_touch()
{
	PROJECTILE_TOUCH;
	
	knight_fireball_explode();
}

void knight_fireball()
{
	entity missile = spawn();
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	
	monster_makevectors(self.enemy);
	
	self.effects |= EF_MUZZLEFLASH;
	sound(self, CHAN_WEAPON, "weapons/fireball2.wav", 1, ATTEN_NORM);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_KNIGHT_FBALL;
	setsize(missile, '-6 -6 -6', '6 6 6');		
	setorigin(missile, self.origin + self.view_ofs + v_forward * 14);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = knight_fireball_explode;
	missile.enemy = self.enemy;
	missile.touch = knight_fireball_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void knight_spike_explode()
{
	if(self)
	{
		pointparticles(particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);
		
		RadiusDamage (self, self.realowner, MON_CVAR(knight, attack_spike_damage), MON_CVAR(knight, attack_spike_edgedamage), MON_CVAR(knight, attack_spike_force), world, MON_CVAR(knight, attack_spike_radius), DEATH_MONSTER_KNIGHT_SPIKE, other);
		remove(self);
	}
}

void knight_spike_touch()
{
	PROJECTILE_TOUCH;
	
	knight_spike_explode();
}

void knight_spike()
{
	entity missile;
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	self.effects |= EF_MUZZLEFLASH;

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + '0 0 10' + v_forward * 14);
	missile.scale = self.scale;
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = knight_spike_explode;
	missile.enemy = self.enemy;
	missile.touch = knight_spike_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void knight_spikes()
{
	self.knight_cycles += 1;
	knight_spike();
	
	if(self.knight_cycles <= 7)
		defer(0.1, knight_spikes);
}

float knight_attack_ranged()
{
	if not(self.flags & FL_ONGROUND)
		return FALSE;
		
	self.knight_cycles = 0;
	
	RandomSelection_Init();
	RandomSelection_Add(world, 1, "", MON_CVAR(knight, attack_fireball_chance), 1);
	RandomSelection_Add(world, 2, "", MON_CVAR(knight, attack_inferno_chance), 1);
	RandomSelection_Add(world, 3, "", MON_CVAR(knight, attack_spike_chance), 1);
	if(self.health >= 100) RandomSelection_Add(world, 4, "", ((vlen(self.enemy.origin - self.origin) > MON_CVAR(knight, attack_jump_distance)) ? 1 : MON_CVAR(knight, attack_jump_chance)), 1);
	
	switch(RandomSelection_chosen_float)
	{
		case 1:
		{
			monsters_setframe(knight_anim_magic2);
			self.attack_finished_single = time + 2;
			defer(0.4, knight_fireball);
			
			return TRUE;
		}
		case 2:
		{
			self.attack_finished_single = time + 3;
			defer(0.5, knight_inferno);
			return TRUE;
		}
		case 3:
		{
			monsters_setframe(knight_anim_magic3);
			self.attack_finished_single = time + 3;
			defer(0.4, knight_spikes);
			
			return TRUE;
		}
		case 4:
		{
			float er = vlen(self.enemy.origin - self.origin);
			
			if(er >= 400 && er < 1200)
			if(findtrajectorywithleading(self.origin, self.mins, self.maxs, self.enemy, 1000, 0, 10, 0, self))
			{
				self.velocity = findtrajectory_velocity;
				Damage(self.enemy, self, self, MON_CVAR(knight, attack_jump_damage) * monster_skill, DEATH_MONSTER_KNIGHT_CRUSH, self.enemy.origin, normalize(self.enemy.origin - self.origin));
				self.attack_finished_single = time + 2;
				return TRUE;
			}
			return FALSE;
		}
	}
	
	return FALSE;
}

float knight_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			float anim;
			if(random() < 0.3)
				anim = knight_anim_slice;
			else if(random() < 0.6)
				anim = knight_anim_smash;
			else
				anim = knight_anim_wattack;
			
			monsters_setframe(anim);
			self.attack_finished_single = time + 0.7;
			monster_melee(self.enemy, MON_CVAR(knight, attack_melee_damage), self.attack_range, DEATH_MONSTER_KNIGHT_MELEE, TRUE);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(knight_attack_ranged())
				return TRUE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_knight()
{
	self.classname = "monster_knight";
	
	self.monster_spawnfunc = spawnfunc_monster_knight;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_KNIGHT, FALSE)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_hell_knight() { spawnfunc_monster_knight(); }

float m_knight(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move(MON_CVAR(knight, speed_run), MON_CVAR(knight, speed_walk), MON_CVAR(knight, speed_stop), knight_anim_run, knight_anim_walk, knight_anim_stand);
			return TRUE;
		}
		case MR_DEATH:
		{
			float chance = random();
			monsters_setframe((random() > 0.5) ? knight_anim_death1 : knight_anim_death2);
			if(chance < 0.10 || self.spawnflags & MONSTERFLAG_MINIBOSS)
			if(self.candrop)
			{
				self.superweapons_finished = time + autocvar_g_balance_superweapons_time + 5; // give the player a few seconds to find the weapon
				self.weapon = WEP_FIREBALL;
			}
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(knight, health);
			
			self.monster_loot = spawnfunc_item_armor_big;
			self.monster_attackfunc	= knight_attack;
			monsters_setframe(knight_anim_stand);
			
			return TRUE;
		}
		case MR_INIT:
		{
			precache_sound ("player/lava.wav");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(KNIGHT_SETTINGS(knight))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_knight(float req)
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
			precache_model ("models/monsters/hknight.mdl");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
