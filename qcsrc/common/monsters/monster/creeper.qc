#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ CREEPER,
/* function   */ m_creeper,
/* spawnflags */ MON_FLAG_MELEE,
/* mins,maxs  */ '-18 -18 -25', '18 18 40',
/* model      */ "creeper.dpm",
/* netname    */ "creeper",
/* fullname   */ _("Creeper")
);

#else
#ifdef SVQC
float autocvar_g_monster_creeper_health;
float autocvar_g_monster_creeper_attack_explode_damage;
float autocvar_g_monster_creeper_attack_explode_edgedamage;
float autocvar_g_monster_creeper_attack_explode_radius;
float autocvar_g_monster_creeper_attack_explode_force;
float autocvar_g_monster_creeper_attack_explode_prime_delay;
float autocvar_g_monster_creeper_speed_stop;
float autocvar_g_monster_creeper_speed_walk;
float autocvar_g_monster_creeper_speed_run;

const float creeper_anim_idle = 0;
const float creeper_anim_walk = 1;
const float creeper_anim_die = 2;

.float creeper_primed;

float creeper_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			if(self.creeper_primed)
			{
				pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);
				sound(self, CH_SHOTS, W_Sound("rocket_impact"), VOL_BASE, ATTEN_NORM);

				RadiusDamage (self, self, (autocvar_g_monster_creeper_attack_explode_damage), (autocvar_g_monster_creeper_attack_explode_edgedamage), (autocvar_g_monster_creeper_attack_explode_radius), world, (autocvar_g_monster_creeper_attack_explode_force), DEATH_MONSTER_CREEPER, other);

				//MonsterSound(monstersound_attack, 0, FALSE, CH_SHOTS);
				Damage (self, world, world, self.health + self.max_health + 200, DEATH_KILL, self.origin, '0 0 0'); // killing monster should be reliable enough
				self.event_damage = func_null;
				self.frame = creeper_anim_idle;
			}
			else
			{
				MonsterSound(monstersound_ranged, 0, FALSE, CH_VOICE);
				self.creeper_primed = TRUE;

				self.colormod = '1 0 0';
				self.frame = creeper_anim_idle;
				self.velocity_x = 0;
				self.velocity_y = 0;
				self.state = MONSTER_STATE_ATTACK_MELEE;
				self.attack_finished_single = time + (autocvar_g_monster_creeper_attack_explode_prime_delay);
			}
			return TRUE;
		}
		case MONSTER_ATTACK_RANGED:
		{
			// creeper has no ranged attacks
			return FALSE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_creeper() { monster_initialize(MON_CREEPER); }

float m_creeper(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			if(self.creeper_primed)
			if(vlen(self.origin - self.enemy.origin) >= self.attack_range * 2)
				self.creeper_primed = FALSE;
			if(self.health > 0 && time > self.attack_finished_single) { self.colormod = '1 1 1'; }
			monster_move((autocvar_g_monster_creeper_speed_run), (autocvar_g_monster_creeper_speed_walk), (autocvar_g_monster_creeper_speed_stop), creeper_anim_walk, creeper_anim_walk, creeper_anim_idle);
			return TRUE;
		}
		case MR_DEATH:
		{
			self.frame = creeper_anim_die;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_creeper_health);
			if(!self.wander_delay) self.wander_delay = 10;
			if(!self.wander_distance) self.wander_distance = 200;

			self.monster_loot = spawnfunc_ammo_rockets;
			self.monster_attackfunc	= creeper_attack;
			self.frame = creeper_anim_idle;
			self.colormod = '1 1 1';

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/creeper.dpm");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
