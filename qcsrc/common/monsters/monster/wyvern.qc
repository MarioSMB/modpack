#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ WYVERN,
/* functions  */ M_Wyvern, M_Wyvern_Attack,
/* spawnflags */ MONSTER_TYPE_FLY | MONSTER_SIZE_BROKEN | MON_FLAG_RANGED | MON_FLAG_RIDE,
/* mins,maxs  */ '-20 -20 -58', '20 20 20',
/* model      */ "wizard.mdl",
/* netname    */ "wyvern",
/* fullname   */ _("Wyvern")
);

#else
#ifdef SVQC
float autocvar_g_monster_wyvern_health;
float autocvar_g_monster_wyvern_attack_fireball_damage;
float autocvar_g_monster_wyvern_attack_fireball_edgedamage;
float autocvar_g_monster_wyvern_attack_fireball_damagetime;
float autocvar_g_monster_wyvern_attack_fireball_force;
float autocvar_g_monster_wyvern_attack_fireball_radius;
float autocvar_g_monster_wyvern_attack_fireball_speed;
float autocvar_g_monster_wyvern_speed_stop;
float autocvar_g_monster_wyvern_speed_run;
float autocvar_g_monster_wyvern_speed_walk;

const float wyvern_anim_hover	= 0;
const float wyvern_anim_fly		= 1;
const float wyvern_anim_magic	= 2;
const float wyvern_anim_pain	= 3;
const float wyvern_anim_death	= 4;

void M_Wyvern_Attack_Fireball_Explode()
{
	entity e;
	if(self)
	{
		Send_Effect(EFFECT_FIREBALL_EXPLODE, self.origin, '0 0 0', 1);

		RadiusDamage(self, self.realowner, (autocvar_g_monster_wyvern_attack_fireball_damage), (autocvar_g_monster_wyvern_attack_fireball_edgedamage), (autocvar_g_monster_wyvern_attack_fireball_force), world, world, (autocvar_g_monster_wyvern_attack_fireball_radius), self.projectiledeathtype, world);

		for(e = world; (e = findfloat(e, takedamage, DAMAGE_AIM)); ) if(vlen(e.origin - self.origin) <= (autocvar_g_monster_wyvern_attack_fireball_radius))
			Fire_AddDamage(e, self, 5 * MONSTER_SKILLMOD(self), (autocvar_g_monster_wyvern_attack_fireball_damagetime), self.projectiledeathtype);

		remove(self);
	}
}

void M_Wyvern_Attack_Fireball_Touch()
{
	PROJECTILE_TOUCH;

	M_Wyvern_Attack_Fireball_Explode();
}

void M_Wyvern_Attack_Fireball()
{
	entity missile = spawn();
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	monster_makevectors(self.enemy);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_WYVERN;
	setsize(missile, '-6 -6 -6', '6 6 6');
	setorigin(missile, self.origin + self.view_ofs + v_forward * 14);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * (autocvar_g_monster_wyvern_attack_fireball_speed);
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = M_Wyvern_Attack_Fireball_Explode;
	missile.enemy = self.enemy;
	missile.touch = M_Wyvern_Attack_Fireball_Touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_FIREMINE, TRUE);
}

float M_Wyvern_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			self.attack_finished_single = time + 1.2;
			self.anim_finished = time + 1.2;

			M_Wyvern_Attack_Fireball();

			return TRUE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_wyvern() { Monster_Spawn(MON_WYVERN); }

#ifndef MONSTERS_EXTRA
// compatibility with old spawns
void spawnfunc_monster_wizard() { spawnfunc_monster_wyvern(); }
#endif // extra monsters include original wizard

float M_Wyvern(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			return TRUE;
		}
		case MR_PAIN:
		{
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = wyvern_anim_death;
			self.velocity_x = -200 + 400 * random();
			self.velocity_y = -200 + 400 * random();
			self.velocity_z = 100 + 100 * random();
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_wyvern_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_wyvern_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_wyvern_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_wyvern_speed_stop); }

			self.m_anim_walk = wyvern_anim_hover;
			self.m_anim_run = wyvern_anim_fly;
			self.m_anim_idle = wyvern_anim_hover;

			self.monster_loot = spawnfunc_item_cells;
			self.frame = wyvern_anim_hover;

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
