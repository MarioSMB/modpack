#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SHAMBLER,
/* functions  */ M_Shambler, M_Shambler_Attack,
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
float autocvar_g_monster_shambler_attack_smash_range;
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

void M_Shambler_Attack_Smash()
{
	makevectors(self.angles);
	Send_Effect(EFFECT_EXPLOSION_MEDIUM, (self.origin + (v_forward * 150)) - ('0 0 1' * self.maxs_z), '0 0 0', 1);
	sound(self, CH_SHOTS, W_Sound("rocket_impact"), VOL_BASE, ATTEN_NORM);

	// RadiusDamage does NOT support custom starting location, which means we must use this hack...

	tracebox(self.origin + v_forward * 50, self.mins * 0.5, self.maxs * 0.5, self.origin + v_forward * autocvar_g_monster_shambler_attack_smash_range, MOVE_NORMAL, self);

	if(trace_ent.takedamage)
		Damage(trace_ent, self, self, (autocvar_g_monster_shambler_attack_smash_damage) * MONSTER_SKILLMOD(self), DEATH_MONSTER_SHAMBLER_SMASH, trace_ent.origin, normalize(trace_ent.origin - self.origin));
}

void M_Shambler_Attack_Swing()
{
	float r = (random() < 0.5);
	Monster_Attack_Melee(self.enemy, (autocvar_g_monster_shambler_attack_claw_damage), ((r) ? shambler_anim_swingr : shambler_anim_swingl), self.attack_range, 0.8, DEATH_MONSTER_SHAMBLER_CLAW, TRUE);
	if(r)
	{
		Monster_Delay(1, 0, 0.5, M_Shambler_Attack_Swing);
		self.attack_finished_single += 0.5;
		self.anim_finished = self.attack_finished_single;
	}
}

void M_Shambler_Attack_Lightning_Explode()
{
	entity head;

	sound(self, CH_SHOTS, W_Sound("electro_impact"), VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("electro_impact"), self.origin, '0 0 0', 1);

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
		Damage(head, self, self.realowner, (autocvar_g_monster_shambler_attack_lightning_damage) * MONSTER_SKILLMOD(self), DEATH_MONSTER_SHAMBLER_ZAP, head.origin, '0 0 0');
	}

	self.think = SUB_Remove;
	self.nextthink = time + 0.2;
}

void M_Shambler_Attack_Lightning_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;

	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void M_Shambler_Attack_Lightning_Touch()
{
	PROJECTILE_TOUCH;

	self.use ();
}

void M_Shambler_Attack_Lightning_Think()
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		M_Shambler_Attack_Lightning_Explode();
		return;
	}
}

void M_Shambler_Attack_Lightning()
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
	gren.think = M_Shambler_Attack_Lightning_Think;
	gren.use = M_Shambler_Attack_Lightning_Explode;
	gren.touch = M_Shambler_Attack_Lightning_Touch;

	gren.takedamage = DAMAGE_YES;
	gren.health = 50;
	gren.damageforcescale = 0;
	gren.event_damage = M_Shambler_Attack_Lightning_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;
	W_SetupProjVelocity_Explicit(gren, v_forward, v_up, (autocvar_g_monster_shambler_attack_lightning_speed), (autocvar_g_monster_shambler_attack_lightning_speed_up), 0, 0, FALSE);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_SHAMBLER_LIGHTNING, TRUE);
}

float M_Shambler_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			M_Shambler_Attack_Swing();
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			float randomness = random(), enemy_len = vlen(self.enemy.origin - self.origin);

			if(time >= self.shambler_lastattack) // shambler doesn't attack much
			if(self.flags & FL_ONGROUND)
			if(randomness <= 0.5 && enemy_len <= autocvar_g_monster_shambler_attack_smash_range)
			{
				self.frame = shambler_anim_smash;
				Monster_Delay(1, 0, 0.7, M_Shambler_Attack_Smash);
				self.attack_finished_single = time + 1.1;
				self.anim_finished = time + 1.1;
				self.state = MONSTER_ATTACK_MELEE; // kinda a melee attack
				self.shambler_lastattack = time + 3 + random() * 1.5;
				return TRUE;
			}
			else if(randomness <= 0.1 && enemy_len >= autocvar_g_monster_shambler_attack_smash_range * 1.5) // small chance, don't want this spammed
			{
				self.frame = shambler_anim_magic;
				self.state = MONSTER_ATTACK_MELEE; // maybe we should rename this to something more general
				self.attack_finished_single = time + 1.1;
				self.anim_finished = 1.1;
				self.shambler_lastattack = time + 3 + random() * 1.5;
				Monster_Delay(1, 0, 0.6, M_Shambler_Attack_Lightning);
				return TRUE;
			}

			return FALSE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_shambler() { Monster_Spawn(MON_SHAMBLER); }

float M_Shambler(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_PAIN:
		{
			self.pain_finished = time + 0.5;
			self.frame = shambler_anim_pain;
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
			if(!self.speed) { self.speed = (autocvar_g_monster_shambler_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_shambler_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_shambler_speed_stop); }

			self.m_anim_walk = shambler_anim_walk;
			self.m_anim_run = shambler_anim_run;
			self.m_anim_idle = shambler_anim_stand;

			self.monster_loot = spawnfunc_item_health_mega;
			self.frame = shambler_anim_stand;
			self.weapon = WEP_ELECTRO; // matches attacks better than WEP_VORTEX

			self.frame = shambler_anim_magic;
			self.spawn_time = time + 1.1;
			self.spawnshieldtime = self.spawn_time;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
