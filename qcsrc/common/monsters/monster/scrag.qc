#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SCRAG,
/* functions  */ M_Scrag, M_Scrag_Attack,
/* spawnflags */ MONSTER_TYPE_FLY | MONSTER_SIZE_BROKEN | MON_FLAG_RANGED,
/* mins,maxs  */ '-20 -20 -58', '20 20 20',
/* model      */ "scrag.mdl",
/* netname    */ "scrag",
/* fullname   */ _("Scrag")
);

#else
#ifdef SVQC
float autocvar_g_monster_scrag_health;
float autocvar_g_monster_scrag_attack_spike_damage;
float autocvar_g_monster_scrag_attack_spike_edgedamage;
float autocvar_g_monster_scrag_attack_spike_force;
float autocvar_g_monster_scrag_attack_spike_radius;
float autocvar_g_monster_scrag_attack_spike_speed;
float autocvar_g_monster_scrag_speed_stop;
float autocvar_g_monster_scrag_speed_run;
float autocvar_g_monster_scrag_speed_walk;

const float scrag_anim_hover	= 0;
const float scrag_anim_fly		= 1;
const float scrag_anim_magic	= 2;
const float scrag_anim_pain		= 3;
const float scrag_anim_death	= 4;

void M_Scrag_Attack_Spike_Explode()
{
	if(self)
	{
		pointparticles(particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);

		RadiusDamage(self, self.realowner, (autocvar_g_monster_scrag_attack_spike_damage), (autocvar_g_monster_scrag_attack_spike_edgedamage), (autocvar_g_monster_scrag_attack_spike_force), world, (autocvar_g_monster_scrag_attack_spike_radius), self.projectiledeathtype, world);

		remove(self);
	}
}

void M_Scrag_Attack_Spike_Touch()
{
	PROJECTILE_TOUCH;

	M_Scrag_Attack_Spike_Explode();
}

void M_Scrag_Attack_Spike()
{
	entity missile = spawn();
	vector viewofs = self.view_ofs + '0 0 20';
	vector dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

	monster_makevectors(self.enemy);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.projectiledeathtype = DEATH_MONSTER_SCRAG;
	setsize(missile, '-6 -6 -6', '6 6 6');
	setorigin(missile, self.origin + viewofs + v_forward * 14);
	missile.flags = FL_PROJECTILE;
	missile.velocity = dir * (autocvar_g_monster_scrag_attack_spike_speed);
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = M_Scrag_Attack_Spike_Explode;
	missile.enemy = self.enemy;
	missile.touch = M_Scrag_Attack_Spike_Touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_SCRAG_SPIKE, TRUE);
}

float M_Scrag_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			if(random() > 0.5)
				self.attack_finished_single = time + 1.2;
			else
				self.attack_finished_single = time + 0.15;

			self.frame = scrag_anim_magic;

			M_Scrag_Attack_Spike();

			/* TODO: add support for this! if(random() <= 0.1)
			{
				makevectors(self.angles);
				self.velocity += (random() >= 0.5) ? (v_right * 300) : (v_right * -300;
			} */

			return TRUE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_scrag() { Monster_Spawn(MON_SCRAG); }

// compatibility with old spawns
void spawnfunc_monster_wizard() { spawnfunc_monster_scrag(); }

float M_Scrag(float req)
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
			self.frame = scrag_anim_death;
			self.velocity_x = -200 + 400 * random();
			self.velocity_y = -200 + 400 * random();
			self.velocity_z = 100 + 100 * random();
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_scrag_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_scrag_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_scrag_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_scrag_speed_stop); }

			self.m_anim_walk = scrag_anim_hover;
			self.m_anim_run = scrag_anim_fly;
			self.m_anim_idle = scrag_anim_hover;

			self.monster_loot = spawnfunc_item_shells;
			self.frame = scrag_anim_hover;

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
