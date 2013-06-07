const vector MAGE_MIN = '-36 -36 -24';
const vector MAGE_MAX = '36 36 50';

string MAGE_MODEL = "models/monsters/mage.dpm";

#ifdef SVQC
float autocvar_g_monster_mage;
float autocvar_g_monster_mage_health;
float autocvar_g_monster_mage_speed;
float autocvar_g_monster_mage_attack_spike_damage;
float autocvar_g_monster_mage_attack_spike_radius;
float autocvar_g_monster_mage_attack_spike_delay;
float autocvar_g_monster_mage_attack_melee_damage;
float autocvar_g_monster_mage_attack_melee_delay;
float autocvar_g_monster_mage_heal_self;
float autocvar_g_monster_mage_heal_friends;
float autocvar_g_monster_mage_heal_minhealth;
float autocvar_g_monster_mage_heal_range;
float autocvar_g_monster_mage_heal_delay;
float autocvar_g_monster_mage_shield_time;
float autocvar_g_monster_mage_shield_delay;
float autocvar_g_monster_mage_shield_blockpercent;
float autocvar_g_monster_mage_attack_grenade_damage;
float autocvar_g_monster_mage_attack_grenade_edgedamage;
float autocvar_g_monster_mage_attack_grenade_radius;
float autocvar_g_monster_mage_attack_grenade_lifetime;
float autocvar_g_monster_mage_attack_grenade_force;
float autocvar_g_monster_mage_attack_grenade_chance;

const float mage_anim_idle		= 0;
const float mage_anim_walk 		= 1;
const float mage_anim_attack 	= 2;
const float mage_anim_pain 		= 3;
const float mage_anim_death 	= 4;
const float mage_anim_run		= 5;

void() mage_heal;
void() mage_shield;
void() mage_shield_die;

void mage_think()
{
	entity head;
	float friend_needshelp = FALSE, need_hpammo = FALSE;
	
	FOR_EACH_PLAYER(head)
	{
		need_hpammo = ((g_minstagib) ? head.ammo_cells < start_ammo_cells : head.health < autocvar_g_balance_health_regenstable);
		if not(IsDifferentTeam(head, self))
		if(head.health > 0)
		if(vlen(head.origin - self.origin) < autocvar_g_monster_mage_heal_range)
		if(need_hpammo)
		{
			friend_needshelp = TRUE;
			break; // found 1 player near us who is low on health
		}
	}
	FOR_EACH_MONSTER(head) if(head != self)
	{
		if not(IsDifferentTeam(head, self))
		if(head.health > 0)
		if(vlen(head.origin - self.origin) < autocvar_g_monster_mage_heal_range)
		if(head.health < head.max_health)
		{
			friend_needshelp = TRUE;
			break; // found 1 player near us who is low on health
		}
	}
	
	self.think = mage_think;
	self.nextthink = time + self.ticrate;
	
	if(self.weaponentity)
	if(time >= self.weaponentity.ltime)
		mage_shield_die();
		
	if(self.health < autocvar_g_monster_mage_heal_minhealth || friend_needshelp)
	if(time >= self.attack_finished_single)
	if(random() < 0.5)
		mage_heal();
		
	if(self.enemy)
	if(self.health < self.max_health)
	if(time >= self.lastshielded)
	if(random() < 0.5)
		mage_shield();
	
	monster_move(autocvar_g_monster_mage_speed, autocvar_g_monster_mage_speed, 50, mage_anim_walk, mage_anim_run, mage_anim_idle);
}

void mageattack_melee()
{
	monster_melee(self.enemy, autocvar_g_monster_mage_attack_melee_damage, 0.3, DEATH_MONSTER_MAGE, TRUE);
	
	self.delay = -1;
	self.monster_delayedattack = func_null;
}

void mage_grenade_explode()
{
	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	
	sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
	RadiusDamage (self, self.realowner, autocvar_g_monster_mage_attack_grenade_damage, autocvar_g_monster_mage_attack_grenade_edgedamage, autocvar_g_monster_mage_attack_grenade_radius, world, autocvar_g_monster_mage_attack_grenade_force, DEATH_MONSTER_MAGE, other);
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

	W_SetupShot_ProjectileSize (self, '-64 -64 -64', '64 64 64', FALSE, 4, "", CH_WEAPON_A, autocvar_g_monster_mage_attack_grenade_damage, WEP_GRENADE_LAUNCHER);
	w_shotdir = v_forward; // no TrueAim for grenades please

	entity gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = FALSE;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_TRIGGER;
	gren.projectiledeathtype = DEATH_MONSTER_MAGE;
	setorigin(gren, w_shotorg);
	setsize(gren, '-64 -64 -64', '64 64 64');

	gren.nextthink = time + autocvar_g_monster_mage_attack_grenade_lifetime;
	gren.think = mage_grenade_explode;
	gren.use = mage_grenade_explode;
	gren.touch = mage_grenade_touch;

	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_monster_mage_attack_grenade);
	
	gren.flags = FL_PROJECTILE;
	
	setmodel(gren, "models/items/g_h50.md3");
	
	self.attack_finished_single = time + 1.5;
}

void mage_spike_explode()
{
	self.event_damage = func_null;

	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, autocvar_g_monster_mage_attack_spike_damage, autocvar_g_monster_mage_attack_spike_damage * 0.5, autocvar_g_monster_mage_attack_spike_radius, world, 0, DEATH_MONSTER_MAGE, other);

	remove (self);
}

void mage_spike_touch()
{
	PROJECTILE_TOUCH;

	mage_spike_explode();
}

void mage_spike_think()
{
	if(self.enemy.health <= 0 || self.owner.health <= 0 || time >= self.ltime)
	{
		mage_spike_explode();
		return;
	}
	
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	
	UpdateCSQCProjectile(self);
	
	if (monster_skill == 3)
		self.velocity = dir * 350;
	else
		self.velocity = dir * 250;
		
	self.nextthink = time + 0.2;
	self.think = mage_spike_think;	
}

void mage_spike()
{
	entity missile;
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	
	self.delay = -1;
	self.monster_delayedattack = func_null;

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
	if(self.health < self.max_health) // only show our effect if we are healing ourself too
		pointparticles(particleeffectnum("healing_fx"), self.origin, '0 0 0', 1);
	self.health = bound(0, self.health + autocvar_g_monster_mage_heal_self, self.max_health);
	WaypointSprite_UpdateHealth(self.sprite, self.health);
	monsters_setframe(mage_anim_attack);
	self.attack_finished_single = time + autocvar_g_monster_mage_heal_delay;
	
	for(head = world; (head = findfloat(head, monster_attack, TRUE)); )
	{
		if(head.health > 0)
		if not(head.frozen)
		if(vlen(head.origin - self.origin) < autocvar_g_monster_mage_heal_range)
		if not(IsDifferentTeam(head, self))
		{
			if(IS_PLAYER(head))
			{
				if((g_minstagib && head.ammo_cells < start_ammo_cells) || head.health < start_health)
					pointparticles(particleeffectnum(((g_minstagib) ? "ammoregen_fx" : "healing_fx")), head.origin, '0 0 0', 1);
				if(g_minstagib)
					head.ammo_cells = bound(0, head.ammo_cells + 1, start_ammo_cells);
				else
					head.health = bound(0, head.health + autocvar_g_monster_mage_heal_friends, g_pickup_healthmedium_max);
			}
			else
			{
				if(head.health < head.max_health)
					pointparticles(particleeffectnum("healing_fx"), head.origin, '0 0 0', 1);
				head.health = bound(0, head.health + autocvar_g_monster_mage_heal_friends, head.max_health);
				WaypointSprite_UpdateHealth(head.sprite, head.health);
			}
		}
	}
}

void mage_shield_die()
{
	if not(self.weaponentity)
		return; // why would this be called without a shield?
	
	self.armorvalue = 1;
	
	remove(self.weaponentity);
	
	self.weaponentity = world;
}

void mage_shield()
{
	if(self.weaponentity)
		return; // already have a shield
		
	entity shield = spawn();

	shield.owner = self;
	shield.team = self.team;
	shield.ltime = time + autocvar_g_monster_mage_shield_time;
	shield.health = 70;
	shield.classname = "shield";
	shield.effects = EF_ADDITIVE;
	shield.movetype = MOVETYPE_NOCLIP;
	shield.solid = SOLID_TRIGGER;
	shield.avelocity = '7 0 11';
	shield.scale = self.scale * 0.6;
	
	setattachment(shield, self, "");
	setmodel(shield, "models/ctf/shield.md3");
	setsize(shield, shield.scale * shield.mins, shield.scale * shield.maxs);
	
	self.weaponentity = shield;
	
	self.lastshielded = time + autocvar_g_monster_mage_shield_delay;
	
	monsters_setframe(mage_anim_attack);
	self.attack_finished_single = time + 1;
	
	self.armorvalue = autocvar_g_monster_mage_shield_blockpercent / 100;
}

float mage_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			self.monster_delayedattack = mageattack_melee;
			self.delay = time + 0.2;
			monsters_setframe(mage_anim_attack);
			self.attack_finished_single = time + autocvar_g_monster_mage_attack_melee_delay;
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(random() < autocvar_g_monster_mage_attack_grenade_chance / 100)
			{
				mage_throw_itemgrenade();
				return TRUE;
			}
	
			monsters_setframe(mage_anim_attack);
			self.delay = time + 0.2;
			self.attack_finished_single = time + autocvar_g_monster_mage_attack_spike_delay;
			self.monster_delayedattack = mage_spike;
			
			return TRUE;
		}
	}
	
	return FALSE;
}

void mage_die()
{
	Monster_CheckDropCvars ("mage");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(mage_anim_death);
	
	monster_hook_death(); // for post-death mods
}

void mage_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_mage_health;

	self.damageforcescale   = 0.003;
	self.classname			= "monster_mage";
	self.monster_attackfunc	= mage_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= mage_think;
	
	monsters_setframe(mage_anim_walk);
	
	monster_setupsounds("mage");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_mage()
{
	if not(autocvar_g_monster_mage) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_mage;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Mage", MONSTER_MAGE,
			 MAGE_MIN, MAGE_MAX,
			 FALSE,
			 mage_die, mage_spawn))
	{
		remove(self);
		return;
	}
}

// compatibility with old spawns
void spawnfunc_monster_shalrath() { spawnfunc_monster_mage(); }

#endif // SVQC
