#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ DEMON,
/* functions  */ M_Demon, M_Demon_Attack,
/* spawnflags */ MON_FLAG_MELEE | MONSTER_SIZE_BROKEN,
/* mins,maxs  */ '-32 -32 -24', '32 32 24',
/* model      */ "demon.mdl",
/* netname    */ "demon",
/* fullname   */ _("Demon")
);

#else
#ifdef SVQC
float autocvar_g_monster_demon_health;
float autocvar_g_monster_demon_attack_melee_damage;
float autocvar_g_monster_demon_attack_melee_delay;
float autocvar_g_monster_demon_attack_leap_damage;
float autocvar_g_monster_demon_attack_leap_force;
float autocvar_g_monster_demon_attack_leap_speed;
float autocvar_g_monster_demon_attack_leap_delay;
float autocvar_g_monster_demon_attack_leap_mindist;
float autocvar_g_monster_demon_speed_stop;
float autocvar_g_monster_demon_speed_run;
float autocvar_g_monster_demon_speed_walk;

const float demon_anim_stand	= 0;
const float demon_anim_walk		= 1;
const float demon_anim_run		= 2;
const float demon_anim_leap		= 3;
const float demon_anim_pain		= 4;
const float demon_anim_death	= 5;
const float demon_anim_attack	= 6;

void M_Demon_Attack_Leap_Touch()
{
	if (self.health <= 0)
		return;

	vector angles_face;

	if(other.takedamage)
	{
		angles_face = vectoangles(self.moveto - self.origin);
		angles_face = normalize(angles_face) * (autocvar_g_monster_demon_attack_leap_force);
		Damage(other, self, self, (autocvar_g_monster_demon_attack_leap_damage) * MONSTER_SKILLMOD(self), DEATH_MONSTER_DEMON_JUMP, other.origin, angles_face);
		self.touch = Monster_Touch; // instantly turn it off to stop damage spam
		self.state = 0;
	}

	if (trace_dphitcontents)
	{
		self.state = 0;
		self.touch = Monster_Touch;
	}
}

float M_Demon_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_demon_attack_melee_damage), demon_anim_attack, self.attack_range, (autocvar_g_monster_demon_attack_melee_delay), DEATH_MONSTER_DEMON_MELEE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			if(vlen(self.enemy.origin - self.origin) <= autocvar_g_monster_demon_attack_leap_mindist) { return FALSE; }
			makevectors(self.angles);
			return Monster_Attack_Leap(demon_anim_leap, M_Demon_Attack_Leap_Touch, v_forward * (autocvar_g_monster_demon_attack_leap_speed) + '0 0 200', (autocvar_g_monster_demon_attack_leap_delay));
		}
	}

	return FALSE;
}

void spawnfunc_monster_demon() { Monster_Spawn(MON_DEMON); }
void spawnfunc_monster_demon1() { spawnfunc_monster_demon(); }
void spawnfunc_monster_animus() { spawnfunc_monster_demon(); }

float M_Demon(float req)
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
			self.frame = demon_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_demon_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_demon_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_demon_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_demon_speed_stop); }

			self.m_anim_walk = demon_anim_walk;
			self.m_anim_run = demon_anim_run;
			self.m_anim_idle = demon_anim_stand;

			self.monster_loot = spawnfunc_item_health_large;
			self.frame = demon_anim_stand;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/demon.mdl");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#endif // REGISTER_MONSTER
