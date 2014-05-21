#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ WYVERN,
/* function   */ m_wyvern,
/* spawnflags */ MONSTER_TYPE_FLY | MONSTER_SIZE_BROKEN | MON_FLAG_RANGED,
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

void wyvern_fireball_explode()
{
	entity e;
	if(self)
	{
		pointparticles(particleeffectnum("fireball_explode"), self.origin, '0 0 0', 1);

		RadiusDamage(self, self.realowner, (autocvar_g_monster_wyvern_attack_fireball_damage), (autocvar_g_monster_wyvern_attack_fireball_edgedamage), (autocvar_g_monster_wyvern_attack_fireball_force), world, world, (autocvar_g_monster_wyvern_attack_fireball_radius), self.projectiledeathtype, world);

		for(e = world; (e = findfloat(e, takedamage, DAMAGE_AIM)); ) if(vlen(e.origin - self.origin) <= (autocvar_g_monster_wyvern_attack_fireball_radius))
			Fire_AddDamage(e, self, 5 * Monster_SkillModifier(), (autocvar_g_monster_wyvern_attack_fireball_damagetime), self.projectiledeathtype);

		remove(self);
	}
}

void wyvern_fireball_touch()
{
	PROJECTILE_TOUCH;

	wyvern_fireball_explode();
}

void wyvern_fireball()
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
	missile.think = wyvern_fireball_explode;
	missile.enemy = self.enemy;
	missile.touch = wyvern_fireball_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_FIREMINE, TRUE);
}

float wyvern_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			self.attack_finished_single = time + 1.2;

			wyvern_fireball();

			return TRUE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_wyvern()
{
	self.classname = "monster_wyvern";

	if(!monster_initialize(MON_WYVERN)) { remove(self); return; }
}

// compatibility with old spawns
void spawnfunc_monster_wizard() { spawnfunc_monster_wyvern(); }

float m_wyvern(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move((autocvar_g_monster_wyvern_speed_run), (autocvar_g_monster_wyvern_speed_walk), (autocvar_g_monster_wyvern_speed_stop), wyvern_anim_fly, wyvern_anim_hover, wyvern_anim_hover);
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

			self.monster_loot = spawnfunc_item_cells;
			self.monster_attackfunc	= wyvern_attack;
			self.frame = wyvern_anim_hover;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/wizard.mdl");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_wyvern(float req)
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
