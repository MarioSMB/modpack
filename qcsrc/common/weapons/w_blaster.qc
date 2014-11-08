#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ BLASTER,
/* function  */ W_Blaster,
/* ammotype  */ ammo_none,
/* impulse   */ 1,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH,
/* rating    */ 0,
/* color     */ '1 0.5 0.5',
/* modelname */ "laser",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairlaser 0.4",
/* wepimg    */ "weaponlaser",
/* refname   */ "blaster",
/* wepname   */ _("Blaster")
);

#define BLASTER_SETTINGS(w_cvar,w_prop) BLASTER_SETTINGS_LIST(w_cvar, w_prop, BLASTER, blaster)
#define BLASTER_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, delay) \
	w_cvar(id, sn, BOTH, edgedamage) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, force_zscale) \
	w_cvar(id, sn, BOTH, lifetime) \
	w_cvar(id, sn, BOTH, radius) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, shotangle) \
	w_cvar(id, sn, BOTH, speed) \
	w_cvar(id, sn, BOTH, spread) \
	w_cvar(id, sn, NONE, secondary) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
BLASTER_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float blaster_damage;
.float blaster_edgedamage;
.float blaster_radius;
.float blaster_force;
.float blaster_lifetime;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_blaster(void) { weapon_defaultspawnfunc(WEP_BLASTER); }
void spawnfunc_weapon_laser(void) { spawnfunc_weapon_blaster(); }

void W_Blaster_Touch(void)
{
	PROJECTILE_TOUCH;

	self.event_damage = func_null;

	RadiusDamage(
		self,
		self.realowner,
		self.blaster_damage,
		self.blaster_edgedamage,
		self.blaster_radius,
		world,
		world,
		self.blaster_force,
		self.projectiledeathtype,
		other
	);
	
	remove(self);
}

void W_Blaster_Think(void)
{
	self.movetype = MOVETYPE_FLY;
	self.think = SUB_Remove;
	self.nextthink = time + self.blaster_lifetime;
	CSQCProjectile(self, TRUE, PROJECTILE_BLASTER, TRUE);
}

void W_Blaster_Attack(
	float atk_deathtype,
	float atk_shotangle,
	float atk_damage,
	float atk_edgedamage,
	float atk_radius,
	float atk_force,
	float atk_speed,
	float atk_spread,
	float atk_delay,
	float atk_lifetime)
{
	vector s_forward = v_forward * cos(atk_shotangle * DEG2RAD) + v_up * sin(atk_shotangle * DEG2RAD);

	W_SetupShot_Dir(self, s_forward, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_B, atk_damage);
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	entity missile = spawn();
	missile.owner = missile.realowner = self;
	missile.classname = "blasterbolt";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = atk_damage;
	PROJECTILE_MAKETRIGGER(missile);

	missile.blaster_damage = atk_damage;
	missile.blaster_edgedamage = atk_edgedamage;
	missile.blaster_radius = atk_radius;
	missile.blaster_force = atk_force;
	missile.blaster_lifetime = atk_lifetime;

	setorigin(missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');
	
	W_SetupProjVelocity_Explicit(
		missile,
		w_shotdir,
		v_up,
		atk_speed,
		0,
		0,
		atk_spread,
		FALSE
	);

	missile.angles = vectoangles(missile.velocity);

	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;

	missile.touch = W_Blaster_Touch;
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH;
	missile.projectiledeathtype = atk_deathtype; 
	missile.think = W_Blaster_Think;
	missile.nextthink = time + atk_delay;

	other = missile; MUTATOR_CALLHOOK(EditProjectile);

	if(time >= missile.nextthink)
	{
		entity oldself;
		oldself = self;
		self = missile;
		self.think();
		self = oldself;
	}
}
float W_Blaster(float request)
{
	switch(request)
	{
		case WR_AIM:
		{
			if(WEP_CVAR(blaster, secondary))
			{
				if((random() * (WEP_CVAR_PRI(blaster, damage) + WEP_CVAR_SEC(blaster, damage))) > WEP_CVAR_PRI(blaster, damage))
					{ self.BUTTON_ATCK2 = bot_aim(WEP_CVAR_SEC(blaster, speed), 0, WEP_CVAR_SEC(blaster, lifetime), FALSE); }
				else
					{ self.BUTTON_ATCK = bot_aim(WEP_CVAR_PRI(blaster, speed), 0, WEP_CVAR_PRI(blaster, lifetime), FALSE); }
			}
			else
				{ self.BUTTON_ATCK = bot_aim(WEP_CVAR_PRI(blaster, speed), 0, WEP_CVAR_PRI(blaster, lifetime), FALSE); }

			return TRUE;
		}
		
		case WR_THINK:
		{
			if(self.BUTTON_ATCK)
			{
				if(weapon_prepareattack(0, WEP_CVAR_PRI(blaster, refire)))
				{
					W_Blaster_Attack(
						WEP_BLASTER,
						WEP_CVAR_PRI(blaster, shotangle),
						WEP_CVAR_PRI(blaster, damage),
						WEP_CVAR_PRI(blaster, edgedamage),
						WEP_CVAR_PRI(blaster, radius),
						WEP_CVAR_PRI(blaster, force),
						WEP_CVAR_PRI(blaster, speed),
						WEP_CVAR_PRI(blaster, spread),
						WEP_CVAR_PRI(blaster, delay),
						WEP_CVAR_PRI(blaster, lifetime)
					);
					weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(blaster, animtime), w_ready);
				}
			}
			else if(self.BUTTON_ATCK2)
			{
				switch(WEP_CVAR(blaster, secondary))
				{
					case 0: // switch to last used weapon
					{
						if(self.switchweapon == WEP_BLASTER) // don't do this if already switching
							W_LastWeapon();
						break;
					}

					case 1: // normal projectile secondary
					{
						if(weapon_prepareattack(1, WEP_CVAR_SEC(blaster, refire)))
						{
							W_Blaster_Attack(
								WEP_BLASTER | HITTYPE_SECONDARY,
								WEP_CVAR_SEC(blaster, shotangle),
								WEP_CVAR_SEC(blaster, damage),
								WEP_CVAR_SEC(blaster, edgedamage),
								WEP_CVAR_SEC(blaster, radius),
								WEP_CVAR_SEC(blaster, force),
								WEP_CVAR_SEC(blaster, speed),
								WEP_CVAR_SEC(blaster, spread),
								WEP_CVAR_SEC(blaster, delay),
								WEP_CVAR_SEC(blaster, lifetime)
							);
							weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(blaster, animtime), w_ready);
						}

						break;
					}
				}
			}
			return TRUE;
		}
		
		case WR_INIT: 
		{
			precache_model("models/weapons/g_laser.md3");
			precache_model("models/weapons/v_laser.md3");
			precache_model("models/weapons/h_laser.iqm");
			precache_sound("weapons/lasergun_fire.wav");
			BLASTER_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		
		case WR_SETUP:
		{
			self.ammo_field = ammo_none;
			return TRUE;
		}
		
		case WR_CHECKAMMO1:
		case WR_CHECKAMMO2:
		{
			return TRUE; // laser has infinite ammo
		}
		
		case WR_CONFIG:
		{
			BLASTER_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_BLASTER_SUICIDE;
		}
		
		case WR_KILLMESSAGE:
		{
			return WEAPON_BLASTER_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Blaster(float request)
{
	switch(request)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 6;
			pointparticles(particleeffectnum("laser_impact"), org2, w_backoff * 1000, 1);
			if(!w_issilent) { sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM); }
			return TRUE;
		}
		
		case WR_INIT:
		{
			precache_sound("weapons/laserimpact.wav");
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			// no weapon specific image for this weapon
			return FALSE;
		}
	}
	return FALSE;
}
#endif
#endif
