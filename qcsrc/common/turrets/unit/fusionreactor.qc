#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ FUSIONREACTOR,
/* function   */ t_fusionreactor,
/* spawnflags */ TUR_FLAG_SUPPORT | TUR_FLAG_AMMOSOURCE,
/* mins,maxs  */ '-34 -34 0', '34 34 90',
/* model	  */ "base.md3",
/* head_model */ "reactor.md3",
/* netname	  */ "fusionreactor",
/* fullname   */ _("Fusion Reactor")
);
#else
#ifdef SVQC
float turret_fusionreactor_firecheck()
{
	if (self.attack_finished_single > time)
		return 0;

	if (self.enemy.deadflag != DEAD_NO)
		return 0;

	if (self.enemy == world)
		return 0;

	if (self.ammo < self.shot_dmg)
		return 0;

	if (self.enemy.ammo >= self.enemy.ammo_max)
		return 0;

	if (vlen(self.enemy.origin - self.origin) > self.target_range)
		return 0;

	if(self.team != self.enemy.team)
		return 0;

	if(!(self.enemy.ammo_flags & TFL_AMMO_ENERGY))
		return 0;

	return 1;
}

void spawnfunc_turret_fusionreactor() { if(!turret_initialize(TUR_FUSIONREACTOR)) remove(self); }

float t_fusionreactor(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			vector fl_org;

			self.enemy.ammo = min(self.enemy.ammo + self.shot_dmg,self.enemy.ammo_max);
			fl_org = 0.5 * (self.enemy.absmin + self.enemy.absmax);
			te_smallflash(fl_org);
			
			return TRUE;
		}
		case TR_THINK:
		{
			self.tur_head.avelocity = '0 250 0' * (self.ammo / self.ammo_max);
		
			return TRUE;
		}
		case TR_DEATH:
		{
			return TRUE;
		}
		case TR_SETUP:
		{
			self.ammo_flags				= TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE;
			self.target_select_flags	= TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_OWNTEAM | TFL_TARGETSELECT_RANGELIMITS;
			self.firecheck_flags		= TFL_FIRECHECK_AMMO_OWN | TFL_FIRECHECK_AMMO_OTHER | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_DEAD;
			self.shoot_flags			= TFL_SHOOT_HITALLVALID;
			self.aim_flags				= TFL_AIM_NO;
			self.track_flags			= TFL_TRACK_NO;
	
			self.tur_head.scale = 0.75;
			self.tur_head.avelocity = '0 50 0';
			
			self.turret_firecheckfunc = turret_fusionreactor_firecheck;
		
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/base.md3");
			precache_model ("models/turrets/reactor.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float t_fusionreactor(float req)
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
