const vector BRUTE_MIN = '-36 -36 -20';
const vector BRUTE_MAX = '36 36 50';

string BRUTE_MODEL = "models/monsters/ogre.dpm";

#ifdef SVQC
float autocvar_g_monster_brute;
float autocvar_g_monster_brute_health;
float autocvar_g_monster_brute_chainsaw_damage;
float autocvar_g_monster_brute_speed_walk;
float autocvar_g_monster_brute_speed_run;
float autocvar_g_monster_brute_attack_uzi_bullets;
float autocvar_g_monster_brute_attack_uzi_damage;
float autocvar_g_monster_brute_attack_uzi_force;
float autocvar_g_monster_brute_attack_uzi_chance;
float autocvar_g_monster_brute_attack_grenade_damage;
float autocvar_g_monster_brute_attack_grenade_edgedamage;
float autocvar_g_monster_brute_attack_grenade_force;
float autocvar_g_monster_brute_attack_grenade_radius;

const float brute_anim_idle 		= 0;
const float brute_anim_walk 		= 1;
const float brute_anim_run 			= 2;
const float brute_anim_pain 		= 3;
const float brute_anim_swing 		= 4;
const float brute_anim_die 			= 5;

.float brute_cycles;

void brute_think()
{
	self.think = brute_think;
	self.nextthink = time + self.ticrate;
	
	monster_move(autocvar_g_monster_brute_speed_run, autocvar_g_monster_brute_speed_walk, 300, brute_anim_run, brute_anim_walk, brute_anim_idle);
}

void brute_blade()
{
	self.brute_cycles += 1;
	self.angles_y = self.angles_y + random()* 25;
	self.delay = time + 0.2;
	self.monster_delayedattack = brute_blade;
	
	monster_melee(self.enemy, autocvar_g_monster_brute_chainsaw_damage, 0.3, DEATH_MONSTER_BRUTE_BLADE, TRUE);
	
	if(self.brute_cycles >= 4)
	{
		self.monster_delayedattack = func_null;
		self.delay = -1;
	}
}

void brute_uzi()
{
	self.brute_cycles += 1;
	
	if(self.brute_cycles > autocvar_g_monster_brute_attack_uzi_bullets)
	{
		self.monster_delayedattack = func_null;
		self.delay = -1;
		return;
	}
	
	monster_makevectors(self.enemy);
	
	W_SetupShot (self, autocvar_g_antilag_bullets && 18000 >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_monster_brute_attack_uzi_damage, WEP_UZI);
	fireBallisticBullet(w_shotorg, w_shotdir, 0.02, 18000, 5, autocvar_g_monster_brute_attack_uzi_damage, autocvar_g_monster_brute_attack_uzi_force, DEATH_MONSTER_BRUTE_UZI, 0, 1, 115);
	endFireBallisticBullet();
	
	self.delay = time + 0.1;
	self.monster_delayedattack = brute_uzi;
}

void brute_grenade_explode()
{
	pointparticles(particleeffectnum("grenade_explode"), self.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage (self, self.realowner, autocvar_g_monster_brute_attack_grenade_damage, autocvar_g_monster_brute_attack_grenade_edgedamage, autocvar_g_monster_brute_attack_grenade_radius, world, autocvar_g_monster_brute_attack_grenade_force, self.projectiledeathtype, other);

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

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_monster_brute_attack_grenade_damage, WEP_GRENADE_LAUNCHER);
	w_shotdir = v_forward; // no TrueAim for grenades please

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_monster_brute_attack_grenade_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_BRUTE_GRENADE;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + 5;
	gren.nextthink = time;
	gren.think = brute_grenade_think;
	gren.use = brute_grenade_explode;
	gren.touch = brute_grenade_touch;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_primary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_primary_damageforcescale;
	gren.event_damage = brute_grenade_damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_primary);

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
			monsters_setframe(brute_anim_swing);
			self.attack_finished_single = time + 1.3;
			brute_blade();
			
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			self.brute_cycles = 0;
			if(random() <= autocvar_g_monster_brute_attack_uzi_chance)
			{
				monsters_setframe(brute_anim_pain);
				self.attack_finished_single = time + 0.8;
				self.delay = time + 0.1;
				self.monster_delayedattack = brute_uzi;
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

void brute_die()
{
	Monster_CheckDropCvars ("brute");
	
	self.think = monster_dead_think;
	self.nextthink = time + self.ticrate;
	self.ltime = time + 5;
	monsters_setframe(brute_anim_die);
		
	monster_hook_death(); // for post-death mods
}

void brute_spawn()
{
	if not(self.health)
		self.health = autocvar_g_monster_brute_health;

	self.damageforcescale	= 0.003;
	self.classname			= "monster_brute";
	self.monster_attackfunc	= brute_attack;
	self.nextthink			= time + random() * 0.5 + 0.1;
	self.think				= brute_think;
	self.weapon				= WEP_GRENADE_LAUNCHER;
	
	monsters_setframe(brute_anim_idle);
	
	monster_setupsounds("brute");
	
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_brute()
{
	if not(autocvar_g_monster_brute) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_brute;
	
	if(Monster_CheckAppearFlags(self))
		return;
	
	if not (monster_initialize(
			 "Brute", MONSTER_BRUTE,
			 BRUTE_MIN, BRUTE_MAX,
			 FALSE,
			 brute_die, brute_spawn))
	{
		remove(self);
		return;
	}
}

#endif // SVQC
