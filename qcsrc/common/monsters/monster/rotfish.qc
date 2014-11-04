#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ ROTFISH,
/* functions  */ M_Rotfish, M_Rotfish_Attack,
/* spawnflags */ MON_FLAG_MELEE | MONSTER_SIZE_BROKEN | MONSTER_TYPE_SWIM,
/* mins,maxs  */ '-20 -20 -31', '20 20 20',
/* model      */ "fish.mdl",
/* netname    */ "rotfish",
/* fullname   */ _("Rotfish")
);

#else
#ifdef SVQC
float autocvar_g_monster_rotfish_health;
float autocvar_g_monster_rotfish_attack_range;
float autocvar_g_monster_rotfish_attack_melee_damage;
float autocvar_g_monster_rotfish_attack_melee_delay;
float autocvar_g_monster_rotfish_speed_stop;
float autocvar_g_monster_rotfish_speed_run;
float autocvar_g_monster_rotfish_speed_walk;

const float rotfish_anim_attack = 0;
const float rotfish_anim_death  = 1;
const float rotfish_anim_swim   = 2;
const float rotfish_anim_pain   = 3;


float M_Rotfish_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_rotfish_attack_melee_damage), rotfish_anim_attack, self.attack_range, (autocvar_g_monster_rotfish_attack_melee_delay), DEATH_MONSTER_ROTFISH_MELEE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// rotfish has no ranged attack yet
			return FALSE;
		}
	}

	return FALSE;
}

void spawnfunc_monster_rotfish() { Monster_Spawn(MON_ROTFISH); }
void spawnfunc_monster_fish() { spawnfunc_monster_rotfish(); }

float M_Rotfish(float req)
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
			self.frame = rotfish_anim_death;
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_rotfish_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_rotfish_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_rotfish_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_rotfish_speed_stop); }
			if(!self.attack_range) { self.attack_range = autocvar_g_monster_rotfish_attack_range; }

			self.m_anim_walk = rotfish_anim_swim;
			self.m_anim_run = rotfish_anim_swim;
			self.m_anim_idle = rotfish_anim_swim;

			self.monster_loot = spawnfunc_item_armor_small;
			self.frame = rotfish_anim_swim;

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
