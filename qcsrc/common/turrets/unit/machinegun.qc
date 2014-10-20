#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ MACHINEGUN,
/* function   */ t_machinegun,
/* spawnflags */ TUR_FLAG_PLAYER,
/* mins,maxs  */ '-32 -32 0', '32 32 64',
/* model	  */ "base.md3",
/* head_model */ "machinegun.md3",
/* netname	  */ "machinegun",
/* fullname   */ _("Machinegun Turret")
);
#else
#ifdef SVQC
void spawnfunc_turret_machinegun() { if(!turret_initialize(TUR_MACHINEGUN)) remove(self); }

float t_machinegun(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			fireBullet (self.tur_shotorg, self.tur_shotdir_updated, self.shot_spread, 0, self.shot_dmg, self.shot_force, DEATH_TURRET_MACHINEGUN, 0);

			UziFlash();
			setattachment(self.muzzle_flash, self.tur_head, "tag_fire");

			return TRUE;
		}
		case TR_THINK:
		{
			return TRUE;
		}
		case TR_DEATH:
		{
			return TRUE;
		}
		case TR_SETUP:
		{
			self.damage_flags |= TFL_DMG_HEADSHAKE;
			self.target_select_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK;
			self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIEVE;
			self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
			self.turret_flags |= TUR_FLAG_HITSCAN;

			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/base.md3");
			precache_model ("models/turrets/machinegun.md3");
			precache_sound (W_Sound("uzi_fire"));
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float t_machinegun(float req)
{
	switch(req)
	{
		case TR_SETUP:
		{
			return TRUE;
		}
		case TR_PRECACHE:
		{
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_TURRET
