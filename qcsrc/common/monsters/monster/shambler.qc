#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SHAMBLER,
/* function   */ m_shambler,
/* spawnflags */ MONSTER_SIZE_BROKEN | MON_FLAG_SUPERMONSTER | MON_FLAG_MELEE | MON_FLAG_RANGED,
/* mins,maxs  */ '-41 -41 -31', '41 41 65',
/* model      */ "shambler.mdl",
/* netname    */ "shambler",
/* fullname   */ _("Shambler")
);

#else
#ifdef SVQC
float autocvar_g_monster_shambler_health;
float autocvar_g_monster_shambler_attack_smash_damage;
float autocvar_g_monster_shambler_attack_claw_damage;
float autocvar_g_monster_shambler_attack_lightning_damage;
float autocvar_g_monster_shambler_attack_lightning_force;
float autocvar_g_monster_shambler_attack_lightning_radius;
float autocvar_g_monster_shambler_attack_lightning_radius_zap;
float autocvar_g_monster_shambler_attack_lightning_speed;
float autocvar_g_monster_shambler_attack_lightning_speed_up;
float autocvar_g_monster_shambler_speed_stop;
float autocvar_g_monster_shambler_speed_run;
float autocvar_g_monster_shambler_speed_walk;

const float shambler_anim_stand		= 0;
const float shambler_anim_walk		= 1;
const float shambler_anim_run		= 2;
const float shambler_anim_smash		= 3;
const float shambler_anim_swingr	= 4;
const float shambler_anim_swingl	= 5;
const float shambler_anim_magic		= 6;
const float shambler_anim_pain		= 7;
const float shambler_anim_death		= 8;

.float shambler_lastattack; // delay attacks separately

void shambler_smash()
{
	makevectors(self.angles);
	pointparticles(particleeffectnum("explosion_medium"), (self.origin + (v_forward * 150)) - ('0 0 1' * self.maxs_z), '0 0 0', 1);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);

	tracebox(self.origin + v_forward * 50, self.mins * 0.5, self.maxs * 0.5, self.origin + v_forward * 500, MOVE_NORMAL, self);

	if(trace_ent.takedamage)
		Damage(trace_ent, self, self, (autocvar_g_monster_shambler_attack_smash_damage) * Monster_SkillModifier(), DEATH_MONSTER_SHAMBLER_SMASH, trace_ent.origin, normalize(trace_ent.origin - self.origin));
}

void shambler_swing()
{
	float r = (random() < 0.5);
	monster_melee(self.enemy, (autocvar_g_monster_shambler_attack_claw_damage), ((r) ? shambler_anim_swingr : shambler_anim_swingl), self.attack_range, 0.8, DEATH_MONSTER_SHAMBLER_CLAW, TRUE);
	if(r)
	{
		defer(0.5, shambler_swing);
		self.attack_finished_single += 0.5;
	}
}

void shambler_lightning_explode()
{
	entity head;

	sound(self, CH_SHOTS, "weapons/electro_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("electro_impact"), '0 0 0', '0 0 0', 1);

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage (self, self.realowner, (autocvar_g_monster_shambler_attack_lightning_damage), (autocvar_g_monster_shambler_attack_lightning_damage), (autocvar_g_monster_shambler_attack_lightning_radius), world, world, (autocvar_g_monster_shambler_attack_lightning_force), self.projectiledeathtype, other);

	for(head = findradius(self.origin, (autocvar_g_monster_shambler_attack_lightning_radius_zap)); head; head = head.chain) if(head != self.realowner) if(head.takedamage)
	{
		te_csqc_lightningarc(self.origin, head.origin);
		Damage(head, self, self.realowner, (autocvar_g_monster_shambler_attack_lightning_damage) * Monster_SkillModifier(), DEATH_MONSTER_SHAMBLER_ZAP, head.origin, '0 0 0');
	}

	self.think = SUB_Remove;
	self.nextthink = time + 0.2;
}

void shambler_lightning_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void shambler_lightning_touch()
{
	PROJECTILE_TOUCH;

	self.use ();
}

void shambler_lightning_think()
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		shambler_lightning_explode();
		return;
	}
}

void shambler_lightning()
{
	entity gren;

	monster_makevectors(self.enemy);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = (autocvar_g_monster_shambler_attack_lightning_damage);
	gren.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_SHAMBLER_ZAP;
	setorigin(gren, CENTER_OR_VIEWOFS(self));
	setsize(gren, '-8 -8 -8', '8 8 8');
	gren.scale = 2.5;

	gren.cnt = time + 5;
	gren.nextthink = time;
	gren.think = shambler_lightning_think;
	gren.use = shambler_lightning_explode;
	gren.touch = shambler_lightning_touch;

	gren.takedamage = DAMAGE_YES;
	gren.health = 50;
	gren.damageforcescale = 0;
	gren.event_damage = shambler_lightning_damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjVelocity_Explicit(gren, v_forward, v_up, (autocvar_g_monster_shambler_attack_lightning_speed), (autocvar_g_monster_shambler_attack_lightning_speed_up), 0, 0, FALSE);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_SHAMBLER_LIGHTNING, TRUE);
}

float shambler_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			shambler_swing();
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(time >= self.shambler_lastattack) // shambler doesn't attack much
			if(self.flags & FL_ONGROUND)
			if(random() <= 0.5 && vlen(self.enemy.origin - self.origin) <= 500)
			{
				self.frame = shambler_anim_smash;
				defer(0.7, shambler_smash);
				self.attack_finished_single = time + 1.1;
				self.shambler_lastattack = time + 3;
				return TRUE;
			}
			else if(random() <= 0.1) // small chance, don't want this spammed
			{
				self.frame = shambler_anim_magic;
				self.attack_finished_single = time + 1.1;
				self.shambler_lastattack = time + 3;
				defer(0.6, shambler_lightning);
				return TRUE;
			}

			return FALSE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_shambler()
{
	self.classname = "monster_shambler";

	if(!monster_initialize(MON_SHAMBLER)) { remove(self); return; }
}

float m_shambler(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move((autocvar_g_monster_shambler_speed_run), (autocvar_g_monster_shambler_speed_walk), (autocvar_g_monster_shambler_speed_stop), shambler_anim_run, shambler_anim_walk, shambler_anim_stand);
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = shambler_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_shambler_health);
			if(!self.attack_range) self.attack_range = 150;

			self.monster_loot = spawnfunc_item_health_mega;
			self.monster_attackfunc	= shambler_attack;
			self.frame = shambler_anim_stand;
			self.weapon = WEP_VORTEX;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/shambler.mdl");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_shambler(float req)
{
	switch(req)
	{
		case MR_PRECACHE:
		{
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_MONSTER
