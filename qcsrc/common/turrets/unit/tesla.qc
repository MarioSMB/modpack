#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ TESLA,
/* function   */ t_tesla,
/* spawnflags */ TUR_FLAG_HITSCAN | TUR_FLAG_PLAYER | TUR_FLAG_MISSILE,
/* mins,maxs  */ '-60 -60 0', '60 60 128',
/* model	  */ "tesla_base.md3",
/* head_model */ "tesla_head.md3",
/* netname	  */ "tesla",
/* fullname   */ _("Tesla Coil")
);

#define TESLA_SETTINGS(turret) 


#ifdef SVQC
TESLA_SETTINGS(tesla)
#endif // SVQC
#else
#ifdef SVQC

entity toast(entity from, float range, float damage)
{
	entity e;
	entity etarget = world;
	float d,dd;
	float r;

	dd = range + 1;

	e = findradius(from.origin,range);
	while (e)
	{
		if ((e.railgunhit != 1) && (e != from))
		{
			r = turret_validate_target(self,e,self.target_validate_flags);
			if (r > 0)
			{
				traceline(from.origin,0.5 * (e.absmin + e.absmax),MOVE_WORLDONLY,from);
				if (trace_fraction == 1.0)
				{
					d = vlen(e.origin - from.origin);
					if (d < dd)
					{
						dd = d;
						etarget = e;
					}
				}
			}
		}
		e = e.chain;
	}

	if (etarget)
	{
		te_csqc_lightningarc(from.origin,etarget.origin);
		Damage(etarget, self, self, damage, DEATH_TURRET_TESLA, etarget.origin, '0 0 0');
		etarget.railgunhit = 1;
	}

	return etarget;
}

float turret_tesla_firecheck()
{
	// g_turrets_targetscan_maxdelay forces a target re-scan at least this often
	float do_target_scan = 0;

	if((self.target_select_time + autocvar_g_turrets_targetscan_maxdelay) < time)
		do_target_scan = 1;

	// Old target (if any) invalid?
	if(self.target_validate_time < time)
	if (turret_validate_target(self, self.enemy, self.target_validate_flags) <= 0)
	{
		self.enemy = world;
		self.target_validate_time = time + 0.5;
		do_target_scan = 1;
	}

	// But never more often then g_turrets_targetscan_mindelay!
	if (self.target_select_time + autocvar_g_turrets_targetscan_mindelay > time)
		do_target_scan = 0;

	if(do_target_scan)
	{
		self.enemy = turret_select_target();
		self.target_select_time = time;
	}

	if not (turret_firecheck())
		return 0;

	if(self.enemy)
		return 1;

	return 0;
}

void spawnfunc_turret_tesla() { if not(turret_initialize(TUR_TESLA)) remove(self); }

float t_tesla(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			entity e, t;
			float d, r, i;

			d = self.shot_dmg;
			r = self.target_range;
			e = spawn();
			setorigin(e,self.tur_shotorg);

			self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK;

			t = toast(e,r,d);
			remove(e);

			if (t == world) return TRUE;

			self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_TEAMCHECK;

			self.attack_finished_single = time + self.shot_refire;
			for (i = 0; i < 10; ++i)
			{
				d *= 0.75;
				r *= 0.85;
				t = toast(t, r, d);
				if (t == world) break;

			}

			e = findchainfloat(railgunhit, 1);
			while (e)
			{
				e.railgunhit = 0;
				e = e.chain;
			}

			return TRUE;
		}
		case TR_THINK:
		{
			if not (self.active)
			{
				self.tur_head.avelocity = '0 0 0';
				return TRUE;
			}

			if(self.ammo < self.shot_dmg)
			{
				self.tur_head.avelocity = '0 45 0' * (self.ammo / self.shot_dmg);
			}
			else
			{
				self.tur_head.avelocity = '0 180 0' * (self.ammo / self.shot_dmg);

				if(self.attack_finished_single > time)
					return TRUE;

				float f;
				f = (self.ammo / self.ammo_max);
				f = f * f;
				if(f > random())
					if(random() < 0.1)
						te_csqc_lightningarc(self.tur_shotorg,self.tur_shotorg + (randomvec() * 350));
			}

			return TRUE;
		}
		case TR_DEATH:
		{
			return TRUE;
		}
		case TR_SETUP:
		{
			self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES |
								 TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK;
								 
			self.turret_firecheckfunc = turret_tesla_firecheck;
			self.target_select_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES |
							   TFL_TARGETSELECT_RANGELIMITS | TFL_TARGETSELECT_TEAMCHECK;

			self.firecheck_flags	= TFL_FIRECHECK_REFIRE | TFL_FIRECHECK_AMMO_OWN;
			self.shoot_flags		= TFL_SHOOT_CUSTOM;
			self.ammo_flags			= TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIEVE;
			self.aim_flags			= TFL_AIM_NO;
			self.track_flags		= TFL_TRACK_NO;

			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/tesla_base.md3");
			precache_model ("models/turrets/tesla_head.md3");
			return TRUE;
		}
		case TR_CONFIG:
		{
			TUR_CONFIG_SETTINGS(TESLA_SETTINGS(tesla))
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float t_tesla(float req)
{
	switch(req)
	{
		case TR_SETUP:
		{
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/tesla_base.md3");
			precache_model ("models/turrets/tesla_head.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // CSQC
#endif // REGISTER_TURRET
