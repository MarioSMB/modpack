#ifdef REGISTER_TURRET
REGISTER_TURRET(
/* TUR_##id   */ FLAC,
/* function   */ t_flac,
/* spawnflags */ TUR_FLAG_SPLASH | TUR_FLAG_FASTPROJ | TUR_FLAG_MISSILE,
/* mins,maxs  */ '-32 -32 0', '32 32 64',
/* model	  */ "base.md3",
/* head_model */ "flac.md3",
/* netname	  */ "flac",
/* fullname   */ _("FLAC Cannon")
);
#else
#ifdef SVQC
void turret_flac_projectile_think_explode()
{
	if(self.enemy != world)
	if(vlen(self.origin - self.enemy.origin) < self.owner.shot_radius * 3)
		setorigin(self,self.enemy.origin + randomvec() * self.owner.shot_radius);

#ifdef TURRET_DEBUG
	float d;
	d = RadiusDamage (self, self.owner, self.owner.shot_dmg, self.owner.shot_dmg, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
	self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d;
	self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
	RadiusDamage (self, self.realowner, self.owner.shot_dmg, self.owner.shot_dmg, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
#endif
	remove(self);
}

void spawnfunc_turret_flac() { if(!turret_initialize(TUR_FLAC)) remove(self); }

float t_flac(float req)
{
	switch(req)
	{
		case TR_ATTACK:
		{
			entity proj;

			turret_tag_fire_update();

			proj = turret_projectile(W_Sound("hagar_fire"), 5, 0, DEATH_TURRET_FLAC, PROJECTILE_HAGAR, TRUE, TRUE);
			pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);
			proj.think	  = turret_flac_projectile_think_explode;
			proj.nextthink  = time + self.tur_impacttime + (random() * 0.01 - random() * 0.01);
			proj.missile_flags = MIF_SPLASH | MIF_PROXY;

			self.tur_head.frame = self.tur_head.frame + 1;
			if (self.tur_head.frame >= 4)
				self.tur_head.frame = 0;
			
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
			self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
			self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
			self.damage_flags |= TFL_DMG_HEADSHAKE;
			self.target_select_flags |= TFL_TARGETSELECT_NOTURRETS | TFL_TARGETSELECT_MISSILESONLY;
		
			return TRUE;
		}
		case TR_PRECACHE:
		{
			precache_model ("models/turrets/base.md3");
			precache_model ("models/turrets/flac.md3");
			return TRUE;
		}
	}

	return TRUE;
}

#endif // SVQC
#ifdef CSQC
float t_flac(float req)
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
