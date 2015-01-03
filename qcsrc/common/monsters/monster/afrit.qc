#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ AFRIT,
/* functions  */ M_Afrit, M_Afrit_Attack,
/* spawnflags */ MONSTER_SIZE_BROKEN | MON_FLAG_RANGED | MONSTER_TYPE_FLY,
/* mins,maxs  */ '-16 -16 -24', '16 16 24',
/* model      */ "afrit.mdl",
/* netname    */ "afrit",
/* fullname   */ _("Afrit")
);

#else
#ifdef SVQC
float autocvar_g_monster_afrit_health;
var float autocvar_g_monster_afrit_damageforcescale = 0.3;
float autocvar_g_monster_afrit_attack_fireball_damage;
float autocvar_g_monster_afrit_attack_fireball_edgedamage;
float autocvar_g_monster_afrit_attack_fireball_damagetime;
float autocvar_g_monster_afrit_attack_fireball_force;
float autocvar_g_monster_afrit_attack_fireball_radius;
float autocvar_g_monster_afrit_attack_fireball_speed;
float autocvar_g_monster_afrit_speed_stop;
float autocvar_g_monster_afrit_speed_run;
float autocvar_g_monster_afrit_speed_walk;

const float afrit_anim_sleep	= 0;
const float afrit_anim_getup	= 1;
const float afrit_anim_fly		= 2;
const float afrit_anim_pain		= 3;
const float afrit_anim_attack	= 4;
const float afrit_anim_die1		= 5;
const float afrit_anim_die2		= 6;

.float afrit_targetrange_backup;
.float afrit_targetcheck_delay;

void M_Afrit_Attack_Fireball_Explode()
{
	entity e;
	if(self)
	{
		pointparticles(particleeffectnum("fireball_explode"), self.origin, '0 0 0', 1);

		RadiusDamage(self, self.realowner, (autocvar_g_monster_afrit_attack_fireball_damage), (autocvar_g_monster_afrit_attack_fireball_edgedamage), 
					(autocvar_g_monster_afrit_attack_fireball_force), world, world, (autocvar_g_monster_afrit_attack_fireball_radius), self.projectiledeathtype, world);

		for(e = world; (e = findfloat(e, takedamage, DAMAGE_AIM)); ) if(vlen(e.origin - self.origin) <= (autocvar_g_monster_afrit_attack_fireball_radius))
			Fire_AddDamage(e, self, 5 * MONSTER_SKILLMOD(self), (autocvar_g_monster_afrit_attack_fireball_damagetime), self.projectiledeathtype);

		remove(self);
	}
}

void M_Afrit_Attack_Fireball_Touch()
{
	PROJECTILE_TOUCH;

	M_Afrit_Attack_Fireball_Explode();
}

void M_Afrit_Attack_Fireball()
{
	entity missile = spawn();
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	monster_makevectors(self.enemy);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_AFRIT;
	setsize(missile, '-6 -6 -6', '6 6 6');
	setorigin(missile, self.origin + '0 0 13' + v_forward * 10);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * (autocvar_g_monster_afrit_attack_fireball_speed);
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = M_Afrit_Attack_Fireball_Explode;
	missile.enemy = self.enemy;
	missile.touch = M_Afrit_Attack_Fireball_Touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_FIREMINE, TRUE);
}

float M_Afrit_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			self.attack_finished_single = time + 2;
			self.anim_finished = time + 1.3;
			self.frame = afrit_anim_attack;

			Monster_Delay(2, 0.3, 0.7, M_Afrit_Attack_Fireball);

			return TRUE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_afrit() { Monster_Spawn(MON_AFRIT); }

float M_Afrit(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			if(self.target_range < 0)
			{
				if(time >= self.afrit_targetcheck_delay)
				{
					self.target_range = self.afrit_targetrange_backup;
					if(Monster_FindTarget(self) != world)
					{
						self.frame = afrit_anim_getup;
						self.anim_finished = time + 2.3;
					}
					else
					{
						self.target_range = -1;
						self.afrit_targetcheck_delay = time + 1;
					}
				}
			}
			self.fire_endtime = 0; // never burns

			if(self.flags & FL_ONGROUND)
				self.m_anim_idle = afrit_anim_sleep;
			else
				self.m_anim_idle = afrit_anim_fly;

			if(self.frame == afrit_anim_sleep)
				self.armorvalue = 0.95; // almost invincible
			else
				self.armorvalue = autocvar_g_monsters_armor_blockpercent;
			return TRUE;
		}
		case MR_PAIN:
		{
			if(frag_deathtype == DEATH_FIRE || frag_deathtype == DEATH_LAVA)
				frag_damage = 0; // afrit doesn't burn
			else
			{
				self.pain_finished = time + 0.6;
				self.frame = afrit_anim_pain;
			}
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = (random() >= 0.5) ? afrit_anim_die1 : afrit_anim_die2;
			self.superweapons_finished = time + 20;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_afrit_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_afrit_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_afrit_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_afrit_speed_stop); }
			if(!self.damageforcescale) { self.damageforcescale = (autocvar_g_monster_afrit_damageforcescale); }

			self.m_anim_walk = afrit_anim_fly;
			self.m_anim_run = afrit_anim_fly;
			self.m_anim_idle = afrit_anim_fly;

			if(!self.target_range) { self.afrit_targetrange_backup = autocvar_g_monsters_target_range; }
			else { self.afrit_targetrange_backup = self.target_range; }
			self.target_range = -1; // special handler

			self.weapon = WEP_FIREBALL; // hehehe
			self.effects |= EF_FLAME;

			self.noalign = FALSE; // starts on ground

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
