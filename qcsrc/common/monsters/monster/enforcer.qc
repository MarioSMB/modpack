#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ ENFORCER,
/* functions  */ M_Enforcer, M_Enforcer_Attack,
/* spawnflags */ MON_FLAG_MELEE | MONSTER_SIZE_BROKEN,
/* mins,maxs  */ '-16 -16 -24', '16 16 24',
/* model      */ "enforcer.mdl",
/* netname    */ "enforcer",
/* fullname   */ _("Enforcer")
);

#else
#ifdef SVQC
float autocvar_g_monster_enforcer_health;
float autocvar_g_monster_enforcer_attack_plasma_damage;
float autocvar_g_monster_enforcer_attack_plasma_edgedamage;
float autocvar_g_monster_enforcer_attack_plasma_force;
float autocvar_g_monster_enforcer_attack_plasma_radius;
float autocvar_g_monster_enforcer_attack_plasma_spread;
float autocvar_g_monster_enforcer_attack_plasma_speed;
float autocvar_g_monster_enforcer_attack_plasma_lifetime;
float autocvar_g_monster_enforcer_attack_plasma_shots;
float autocvar_g_monster_enforcer_attack_plasma_delay;
float autocvar_g_monster_enforcer_speed_stop;
float autocvar_g_monster_enforcer_speed_run;
float autocvar_g_monster_enforcer_speed_walk;

const float enforcer_anim_stand			= 0;
const float enforcer_anim_walk			= 1;
const float enforcer_anim_run			= 2;
const float enforcer_anim_attack		= 3;
const float enforcer_anim_death1		= 4;
const float enforcer_anim_death2		= 5;
const float enforcer_anim_pain1			= 6;
const float enforcer_anim_pain2			= 7;
const float enforcer_anim_pain3			= 8;
const float enforcer_anim_pain4			= 9;

void M_Enforcer_Attack_Plasma_Explode()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	sound (self, CH_WEAPON_A, W_Sound("tag_impact"), VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("electro_impact"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, autocvar_g_monster_enforcer_attack_plasma_damage, autocvar_g_monster_enforcer_attack_plasma_edgedamage, 
				  autocvar_g_monster_enforcer_attack_plasma_radius, world, autocvar_g_monster_enforcer_attack_plasma_force, self.projectiledeathtype, other);

	remove (self);
}

void M_Enforcer_Attack_Plasma_Touch()
{
	PROJECTILE_TOUCH;
	M_Enforcer_Attack_Plasma_Explode();
}

void M_Enforcer_Attack_Plasma()
{
	entity gren;

	sound (self, CH_WEAPON_A, W_Sound("lasergun_fire"), VOL_BASE, ATTEN_NORM);

	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	vector org = self.origin + v_forward * 14 + '0 0 5' + v_right * -14;

	makevectors(self.angles);

	pointparticles(particleeffectnum("electro_muzzleflash"), org, dir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_monster_enforcer_attack_plasma_damage;
	gren.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_MONSTER_OGRE_GRENADE;
	setorigin(gren, org);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_monster_enforcer_attack_plasma_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = M_Enforcer_Attack_Plasma_Explode;
	gren.touch = M_Enforcer_Attack_Plasma_Touch;

	gren.missile_flags = MIF_SPLASH;
	W_SetupProjectileVelocityEx(gren, dir, v_up, autocvar_g_monster_enforcer_attack_plasma_speed, 0, 0, autocvar_g_monster_enforcer_attack_plasma_spread, FALSE);

	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_ELECTRO, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);

	self.attack_finished_single = time + autocvar_g_monster_enforcer_attack_plasma_delay;
}

float M_Enforcer_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			self.frame = enforcer_anim_attack;
			self.attack_finished_single = time + 0.7;
			self.state = MONSTER_ATTACK_RANGED;
			Monster_Delay(autocvar_g_monster_enforcer_attack_plasma_shots - 1, 0.3, 0.4, M_Enforcer_Attack_Plasma);
			return TRUE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_enforcer() { Monster_Spawn(MON_ENFORCER); }

float M_Enforcer(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_PAIN:
		{
			switch(floor(random() * 5))
			{
				default:
				case 1: self.frame = enforcer_anim_pain1; self.pain_finished = time + 0.3; break;
				case 2: self.frame = enforcer_anim_pain2; self.pain_finished = time + 0.4; break;
				case 3: self.frame = enforcer_anim_pain3; self.pain_finished = time + 0.7; break;
				case 4: self.frame = enforcer_anim_pain4; self.pain_finished = time + 1; break;
			}
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = ((random() > 0.5) ? enforcer_anim_death1 : enforcer_anim_death2);
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_enforcer_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_enforcer_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_enforcer_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_enforcer_speed_stop); }

			self.m_anim_walk = enforcer_anim_walk;
			self.m_anim_run = enforcer_anim_run;
			self.m_anim_idle = enforcer_anim_stand;

			self.monster_loot = spawnfunc_item_cells;
			self.weapon = WEP_CRYLINK;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_sound(W_Sound("tag_impact"));
			precache_sound(W_Sound("lasergun_fire"));
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
