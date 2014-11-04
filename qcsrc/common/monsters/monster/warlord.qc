#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ WARLORD,
/* functions  */ M_Warlord, M_Warlord_Attack,
/* spawnflags */ MON_FLAG_MELEE | MONSTER_SIZE_BROKEN | MON_FLAG_RANGED,
/* mins,maxs  */ '-16 -16 -24', '16 16 40',
/* model      */ "warlord.mdl",
/* netname    */ "warlord",
/* fullname   */ _("Warlord")
);

#else
#ifdef SVQC
float autocvar_g_monster_warlord_health;
float autocvar_g_monster_warlord_attack_melee_damage;
float autocvar_g_monster_warlord_attack_melee_delay;
float autocvar_g_monster_warlord_attack_leap_damage;
float autocvar_g_monster_warlord_attack_leap_force;
float autocvar_g_monster_warlord_attack_leap_speed;
float autocvar_g_monster_warlord_attack_leap_delay;
float autocvar_g_monster_warlord_speed_stop;
float autocvar_g_monster_warlord_speed_run;
float autocvar_g_monster_warlord_speed_walk;

const float warlord_anim_stand 		= 0
const float warlord_anim_walk 		= 1
const float warlord_anim_run 		= 2
const float warlord_anim_pain 		= 3
const float warlord_anim_death1 	= 4
const float warlord_anim_death2 	= 5
const float warlord_anim_charge1 	= 6
const float warlord_anim_magic1 	= 7
const float warlord_anim_magic2 	= 8
const float warlord_anim_charge2 	= 9
const float warlord_anim_slice 		= 10
const float warlord_anim_smash 		= 11
const float warlord_anim_wattack 	= 12
const float warlord_anim_magic3 	= 13

float M_Warlord_Attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return Monster_Attack_Melee(self.enemy, (autocvar_g_monster_warlord_attack_melee_damage), warlord_anim_slice, self.attack_range, (autocvar_g_monster_warlord_attack_melee_delay), DEATH_MONSTER_WARLORD_MELEE, TRUE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			makevectors(self.angles);
			return Monster_Attack_Leap(warlord_anim_attackleap, M_Warlord_Attack_Leap_Touch, v_forward * (autocvar_g_monster_warlord_attack_leap_speed) + '0 0 200', (autocvar_g_monster_warlord_attack_leap_delay));
		}
	}

	return FALSE;
}

void spawnfunc_monster_warlord() { Monster_Spawn(MON_WARLORD); }

float M_Warlord(float req)
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
			self.frame = ((random() > 0.5) ? warlord_anim_death1 : warlord_anim_death2);
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_warlord_health);
			if(!self.speed) { self.speed = (autocvar_g_monster_warlord_speed_walk); }
			if(!self.speed2) { self.speed2 = (autocvar_g_monster_warlord_speed_run); }
			if(!self.stopspeed) { self.stopspeed = (autocvar_g_monster_warlord_speed_stop); }

			self.m_anim_walk = warlord_anim_walk;
			self.m_anim_run = warlord_anim_run;
			self.m_anim_idle = warlord_anim_stand;

			self.monster_loot = spawnfunc_item_armor_medium;
			self.weapon = WEP_ROCKET_LAUNCHER;

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
