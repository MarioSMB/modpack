#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ MLRS,
/* function   */ t_mlrs,
/* spawnflags */ TUR_FLAG_SPLASH | TUR_FLAG_MEDPROJ | TUR_FLAG_PLAYER,
/* mins,maxs  */ '-32 -32 0', '32 32 64',
/* model	  */ "base.md3",
/* head_model */ "mlrs.md3",
/* netname	  */ "mlrs",
/* fullname   */ _("MLRS Turret")
);
#else
#ifdef SVQC
void spawnfunc_turret_mlrs() { if(!turret_initialize(TUR_MLRS)) remove(self); }

float t_mlrs(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			entity missile;

			turret_tag_fire_update();
			missile = turret_projectile("weapons/rocket_fire.wav", 6, 10, DEATH_TURRET_MLRS, PROJECTILE_ROCKET, TRUE, TRUE);
			missile.nextthink = time + max(self.tur_impacttime,(self.shot_radius * 2) / self.shot_speed);
			missile.missile_flags = MIF_SPLASH;
			te_explosion (missile.origin);

			return TRUE;
		}
		case TR_THINK:
		{
			// 0 = full, 6 = empty
			self.tur_head.frame = bound(0, 6 - floor(0.1 + self.ammo / self.shot_dmg), 6);
			if(self.tur_head.frame < 0)
			{
				dprint("ammo:",ftos(self.ammo),"\n");
				dprint("shot_dmg:",ftos(self.shot_dmg),"\n");
			}
		
			return TRUE;
		}
		case TR_DEATH:
		{
			return TRUE;
		}
		case TR_SETUP:
		{
			self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
			self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
		
			self.damage_flags |= TFL_DMG_HEADSHAKE;
			self.shoot_flags  |= TFL_SHOOT_VOLLYALWAYS;
			self.volly_counter = self.shot_volly;

			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/base.md3");
			precache_model ("models/turrets/mlrs.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float t_mlrs(float req)
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
