#ifdef REGISTER_MONSTER
REGISTER_MONSTER(
/* MON_##id   */ SHARK,
/* function   */ m_shark,
/* spawnflags */ MONSTER_TYPE_SWIM | MON_FLAG_MELEE,
/* mins,maxs  */ '-100 -70 -50', '100 45 55',
/* model      */ "shark.md3",
/* netname    */ "shark",
/* fullname   */ _("Shark")
);

#else
#ifdef SVQC
float autocvar_g_monster_shark_health;
float autocvar_g_monster_shark_attack_bite_damage;
float autocvar_g_monster_shark_attack_bite_delay;
float autocvar_g_monster_shark_speed_stop;
float autocvar_g_monster_shark_speed_run;
float autocvar_g_monster_shark_speed_walk;

float shark_attack(float attack_type)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		{
			return monster_melee(self.enemy, (autocvar_g_monster_shark_attack_bite_damage), 0, self.attack_range, (autocvar_g_monster_shark_attack_bite_delay), DEATH_MONSTER_SHARK, FALSE);
		}
		case MONSTER_ATTACK_RANGED:
		{
			// shark has no ranged attack
		}
	}

	return FALSE;
}

void spawnfunc_monster_shark()
{
	self.classname = "monster_shark";

	if(!monster_initialize(MON_SHARK)) { remove(self); return; }
}

float m_shark(float req)
{
	switch(req)
	{
		case MR_THINK:
		{
			monster_move((autocvar_g_monster_shark_speed_run), (autocvar_g_monster_shark_speed_walk), (autocvar_g_monster_shark_speed_stop), 0, 0, 0);
			return TRUE;
		}
		case MR_DEATH:
		{
			return TRUE;
		}
		case MR_SETUP:
		{
			if(!self.health) self.health = (autocvar_g_monster_shark_health);

			self.monster_loot = spawnfunc_item_health_large;
			self.monster_attackfunc	= shark_attack;

			return TRUE;
		}
		case MR_PRECACHE:
		{
			precache_model("models/monsters/shark.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float m_shark(float req)
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
