#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ MAGE,
/* function   */ m_mage,
/* spawnflags */ MON_FLAG_MELEE | MON_FLAG_RANGED,
/* mins,maxs  */ '-36 -36 -24', '36 36 50',
/* model      */ "mage.dpm",
/* netname    */ "mage",
/* fullname   */ _("Mage")
);

#define MAGE_SETTINGS(monster) \
	MON_ADD_CVAR(monster, health) \
	MON_ADD_CVAR(monster, attack_spike_damage) \
	MON_ADD_CVAR(monster, attack_spike_radius) \
	MON_ADD_CVAR(monster, attack_spike_delay) \
	MON_ADD_CVAR(monster, attack_spike_accel) \
	MON_ADD_CVAR(monster, attack_spike_decel) \
	MON_ADD_CVAR(monster, attack_spike_turnrate) \
	MON_ADD_CVAR(monster, attack_spike_speed_max) \
	MON_ADD_CVAR(monster, attack_spike_smart) \
	MON_ADD_CVAR(monster, attack_spike_smart_trace_min) \
	MON_ADD_CVAR(monster, attack_spike_smart_trace_max) \
	MON_ADD_CVAR(monster, attack_spike_smart_mindist) \
	MON_ADD_CVAR(monster, attack_melee_damage) \
	MON_ADD_CVAR(monster, attack_melee_delay) \
	MON_ADD_CVAR(monster, attack_grenade_damage) \
	MON_ADD_CVAR(monster, attack_grenade_edgedamage) \
	MON_ADD_CVAR(monster, attack_grenade_force) \
	MON_ADD_CVAR(monster, attack_grenade_radius) \
	MON_ADD_CVAR(monster, attack_grenade_lifetime) \
	MON_ADD_CVAR(monster, attack_grenade_chance) \
	MON_ADD_CVAR(monster, attack_grenade_speed) \
	MON_ADD_CVAR(monster, attack_grenade_speed_up) \
	MON_ADD_CVAR(monster, heal_self) \
	MON_ADD_CVAR(monster, heal_allies) \
	MON_ADD_CVAR(monster, heal_minhealth) \
	MON_ADD_CVAR(monster, heal_range) \
	MON_ADD_CVAR(monster, heal_delay) \
	MON_ADD_CVAR(monster, shield_time) \
	MON_ADD_CVAR(monster, shield_delay) \
	MON_ADD_CVAR(monster, shield_blockpercent) \
	MON_ADD_CVAR(monster, speed_stop) \
	MON_ADD_CVAR(monster, speed_run) \
	MON_ADD_CVAR(monster, speed_walk) 

#ifdef SVQC
MAGE_SETTINGS(mage)
#endif // SVQC
#else
#ifdef SVQC
const float mage_anim_idle		= 0;
const float mage_anim_walk 		= 1;
const float mage_anim_attack 	= 2;
const float mage_anim_pain 		= 3;
const float mage_anim_death 	= 4;
const float mage_anim_run		= 5;

void() mage_heal;
void() mage_shield;

float friend_needshelp(entity e)
{
	if(e == world)
		return FALSE;
	if(e.health <= 0)
		return FALSE;
	if(vlen(e.origin - self.origin) > MON_CVAR(mage, heal_range))
		return FALSE;
	if(IsDifferentTeam(e, self))
		return FALSE;
	if(e.frozen)
		return FALSE;
	if(!IS_PLAYER(e))
		return (e.health < e.max_health);
	if(e.items & IT_INVINCIBLE)
		return FALSE;

	switch(self.skin)
	{
		case 0: return (e.health < autocvar_g_balance_health_regenstable);
		case 1: return ((e.ammo_cells && e.ammo_cells < g_pickup_cells_max) || (e.ammo_rockets && e.ammo_rockets < g_pickup_rockets_max) || (e.ammo_nails && e.ammo_nails < g_pickup_nails_max) || (e.ammo_shells && e.ammo_shells < g_pickup_shells_max));
		case 2: return (e.armorvalue < autocvar_g_balance_armor_regenstable);
		case 3: return (e.health > 0);
	}
	
	return FALSE;
}

void mageattack_melee()
{
	monster_melee(self.enemy, MON_CVAR(mage, attack_melee_damage), mage_anim_attack, self.attack_range, MON_CVAR(mage, attack_melee_delay) - 0.2, DEATH_MONSTER_MAGE, TRUE);
}

void mage_grenade_explode()
{
	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	
	sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTEN_NORM);
	RadiusDamage (self, self.realowner, MON_CVAR(mage, attack_grenade_damage), MON_CVAR(mage, attack_grenade_edgedamage), MON_CVAR(mage, attack_grenade_radius), world, MON_CVAR(mage, attack_grenade_force), DEATH_MONSTER_MAGE, other);
	remove(self);
}

void mage_grenade_touch()
{
	if(IS_PLAYER(other))
	{
		PROJECTILE_TOUCH;
		mage_grenade_explode();
		return;
	}
}

void mage_throw_itemgrenade()
{
	makevectors(self.angles);
	
	entity gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = FALSE;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_TRIGGER;
	gren.projectiledeathtype = DEATH_MONSTER_MAGE;
	setorigin(gren, CENTER_OR_VIEWOFS(self));
	setsize(gren, '-64 -64 -64', '64 64 64');

	gren.nextthink = time + MON_CVAR(mage, attack_grenade_lifetime);
	gren.think = mage_grenade_explode;
	gren.use = mage_grenade_explode;
	gren.touch = mage_grenade_touch;

	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjectileVelocityEx(gren, v_forward, v_up, MON_CVAR(mage, attack_grenade_speed), MON_CVAR(mage, attack_grenade_speed_up), 0, 0, FALSE);
	
	gren.flags = FL_PROJECTILE;
	
	setmodel(gren, "models/items/g_h50.md3");
	
	self.attack_finished_single = time + 1.5;
}

void mage_spike_explode()
{
	self.event_damage = func_null;
	
	sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTEN_NORM);
	
	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, MON_CVAR(mage, attack_spike_damage), MON_CVAR(mage, attack_spike_damage) * 0.5, MON_CVAR(mage, attack_spike_radius), world, 0, DEATH_MONSTER_MAGE, other);

	remove (self);
}

void mage_spike_touch()
{
	PROJECTILE_TOUCH;

	mage_spike_explode();
}

// copied from W_Seeker_Think
void mage_spike_think()
{
	entity e;
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;
	float spd;

	if (time > self.ltime || self.enemy.health <= 0 || self.owner.health <= 0)
	{
		self.projectiledeathtype |= HITTYPE_SPLASH;
		mage_spike_explode();
	}

	spd = vlen(self.velocity);
	spd = bound(
		spd - MON_CVAR(mage, attack_spike_decel) * frametime,
		MON_CVAR(mage, attack_spike_speed_max),
		spd + MON_CVAR(mage, attack_spike_accel) * frametime
	);

	if (self.enemy != world)
		if (self.enemy.takedamage != DAMAGE_AIM || self.enemy.deadflag != DEAD_NO)
			self.enemy = world;

	if (self.enemy != world)
	{
		e               = self.enemy;
		eorg            = 0.5 * (e.absmin + e.absmax);
		turnrate        = MON_CVAR(mage, attack_spike_turnrate); // how fast to turn
		desireddir      = normalize(eorg - self.origin);
		olddir          = normalize(self.velocity); // get my current direction
		dist            = vlen(eorg - self.origin);

		// Do evasive maneuvers for world objects? ( this should be a cpu hog. :P )
		if (MON_CVAR(mage, attack_spike_smart) && (dist > MON_CVAR(mage, attack_spike_smart_mindist)))
		{
			// Is it a better idea (shorter distance) to trace to the target itself?
			if ( vlen(self.origin + olddir * self.wait) < dist)
				traceline(self.origin, self.origin + olddir * self.wait, FALSE, self);
			else
				traceline(self.origin, eorg, FALSE, self);

			// Setup adaptive tracelength
			self.wait = bound(MON_CVAR(mage, attack_spike_smart_trace_min), vlen(self.origin - trace_endpos), self.wait = MON_CVAR(mage, attack_spike_smart_trace_max));

			// Calc how important it is that we turn and add this to the desierd (enemy) dir.
			desireddir  = normalize(((trace_plane_normal * (1 - trace_fraction)) + (desireddir * trace_fraction)) * 0.5);
		}
		
		newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
	}
	else
		dist = 0;
		
	///////////////

	//self.angles = vectoangles(self.velocity);			// turn model in the new flight direction
	self.nextthink = time;// + 0.05; // csqc projectiles
	UpdateCSQCProjectile(self);
}

void mage_spike()
{
	entity missile;
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	makevectors(self.angles);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.think = mage_spike_think;
	missile.ltime = time + 7;
	missile.nextthink = time;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.flags = FL_PROJECTILE;
	setorigin(missile, self.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	setsize (missile, '0 0 0', '0 0 0');	
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.enemy = self.enemy;
	missile.touch = mage_spike_touch;
	
	CSQCProjectile(missile, TRUE, PROJECTILE_MAGE_SPIKE, TRUE);
}

void mage_heal()
{
	entity head;
	float washealed = FALSE;
	
	for(head = world; (head = findfloat(head, monster_attack, TRUE)); ) if(friend_needshelp(head))
	{
		washealed = TRUE;
		string fx = "";
		if(IS_PLAYER(head))
		{
			switch(self.skin)
			{
				case 0:
					if(head.health < autocvar_g_balance_health_regenstable) head.health = bound(0, head.health + MON_CVAR(mage, heal_allies), autocvar_g_balance_health_regenstable);
					fx = "healing_fx";
					break;
				case 1:
					if(head.ammo_cells) head.ammo_cells = bound(head.ammo_cells, head.ammo_cells + 1, g_pickup_cells_max);
					if(head.ammo_rockets) head.ammo_rockets = bound(head.ammo_rockets, head.ammo_rockets + 1, g_pickup_rockets_max);
					if(head.ammo_shells) head.ammo_shells = bound(head.ammo_shells, head.ammo_shells + 2, g_pickup_shells_max);
					if(head.ammo_nails) head.ammo_nails = bound(head.ammo_nails, head.ammo_nails + 5, g_pickup_nails_max);
					fx = "ammoregen_fx";
					break;
				case 2:
					if(head.armorvalue < autocvar_g_balance_armor_regenstable)
					{
						head.armorvalue = bound(0, head.armorvalue + MON_CVAR(mage, heal_allies), autocvar_g_balance_armor_regenstable);
						fx = "armorrepair_fx";
					}
					break;
				case 3:
					head.health = bound(0, head.health - ((head == self)  ? MON_CVAR(mage, heal_self) : MON_CVAR(mage, heal_allies)), autocvar_g_balance_health_regenstable);
					fx = "rage";
					break;
			}
			
			pointparticles(particleeffectnum(fx), head.origin, '0 0 0', 1);
		}
		else
		{
			pointparticles(particleeffectnum("healing_fx"), head.origin, '0 0 0', 1);
			head.health = bound(0, head.health + MON_CVAR(mage, heal_allies), head.max_health);
			head.SendFlags |= MSF_STATUS;
		}
	}
	
	if(washealed)
	{
		monsters_setframe(mage_anim_attack);
		self.attack_finished_single = time + MON_CVAR(mage, heal_delay);
	}
}

void mage_shield_think()
{
	self.nextthink = time;

	if(time >= self.ltime || self.owner.health <= 0)
	{
		self.owner.armorvalue = 0;
		self.owner.m_armor_blockpercent = autocvar_g_monsters_armor_blockpercent;
		remove(self);
		return;
	}
}

void mage_shield()
{
	if(self.weaponentity)
		return; // already have a shield
		
	entity shield = spawn();

	shield.owner = self;
	shield.team = self.team;
	shield.ltime = time + MON_CVAR(mage, shield_time);
	shield.classname = "shield";
	shield.effects = EF_ADDITIVE;
	shield.movetype = MOVETYPE_NOCLIP;
	shield.solid = SOLID_TRIGGER;
	shield.avelocity = '7 0 11';
	shield.scale = self.scale * 0.6;
	shield.think = mage_shield_think;
	shield.nextthink = time;
	
	setattachment(shield, self, "");
	setmodel(shield, "models/ctf/shield.md3");
	setsize(shield, shield.scale * shield.mins, shield.scale * shield.maxs);
	
	self.lastshielded = time + MON_CVAR(mage, shield_delay);
	
	monsters_setframe(mage_anim_attack);
	self.attack_finished_single = time + 1;
	
	self.m_armor_blockpercent = MON_CVAR(mage, shield_blockpercent);
	self.armorvalue = self.health;
}

float mage_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			monsters_setframe(mage_anim_attack);
			self.attack_finished_single = time + MON_CVAR(mage, attack_melee_delay);
			defer(0.2, mageattack_melee);
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(random() < MON_CVAR(mage, attack_grenade_chance) / 100)
			{
				mage_throw_itemgrenade();
				return TRUE;
			}
	
			monsters_setframe(mage_anim_attack);
			self.attack_finished_single = time + MON_CVAR(mage, attack_spike_delay);
			defer(0.2, mage_spike);
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void spawnfunc_monster_mage()
{
	self.classname = "monster_mage";
	
	self.monster_spawnfunc = spawnfunc_monster_mage;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not(monster_initialize(MON_MAGE, FALSE)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_shalrath() { spawnfunc_monster_mage(); }

float m_mage(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			entity head;
			float need_help = FALSE;
			
			FOR_EACH_PLAYER(head)
			if(friend_needshelp(head))
			{
				need_help = TRUE;
				break; // found 1 player near us who is low on health
			}
			if(!need_help)
			FOR_EACH_MONSTER(head)
			if(head != self)
			if(friend_needshelp(head))
			{
				need_help = TRUE;
				break; // found 1 player near us who is low on health
			}
				
			if(self.health < MON_CVAR(mage, heal_minhealth) || need_help)
			if(time >= self.attack_finished_single)
			if(random() < 0.5)
				mage_heal();
				
			if(self.enemy)
			if(self.health < self.max_health)
			if(time >= self.lastshielded)
			if(random() < 0.5)
				mage_shield();
			
			monster_move(MON_CVAR(mage, speed_run), MON_CVAR(mage, speed_walk), MON_CVAR(mage, speed_stop), mage_anim_walk, mage_anim_run, mage_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			monsters_setframe(mage_anim_death);
			return TRUE;
		}
		case MR_SETUP:
		{
			if not(self.health) self.health = MON_CVAR(mage, health);
			
			self.monster_loot = spawnfunc_item_health_large;
			self.monster_attackfunc	= mage_attack;
			monsters_setframe(mage_anim_walk);
			
			return TRUE;
		}
		case MR_INIT:
		{
			precache_model ("models/items/g_h50.md3");
			precache_model ("models/ctf/shield.md3");
			precache_sound ("weapons/grenade_impact.wav");
			return TRUE;
		}
		case MR_CONFIG:
		{
			MON_CONFIG_SETTINGS(MAGE_SETTINGS(mage))
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_mage(float req)
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
			precache_model ("models/monsters/mage.dpm");
			return TRUE;
		}
	}
	
	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
