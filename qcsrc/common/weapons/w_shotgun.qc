#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ SHOTGUN,
/* function  */ W_Shotgun,
/* ammotype  */ ammo_none,
/* impulse   */ 2,
/* flags     */ WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_LOW,
/* color     */ '0.5 0.25 0',
/* modelname */ "shotgun",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairshotgun 0.65",
/* wepimg    */ "weaponshotgun",
/* refname   */ "shotgun",
/* wepname   */ _("Shotgun")
);

#define SHOTGUN_SETTINGS(w_cvar,w_prop) SHOTGUN_SETTINGS_LIST(w_cvar, w_prop, SHOTGUN, shotgun)
#define SHOTGUN_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, PRI,  ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, PRI,  bullets) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, PRI,  solidpenetration) \
	w_cvar(id, sn, PRI,  spread) \
	w_cvar(id, sn, NONE, secondary) \
	w_cvar(id, sn, SEC,  melee_time) \
	w_cvar(id, sn, SEC,  melee_no_doubleslap) \
	w_cvar(id, sn, SEC,  melee_traces) \
	w_cvar(id, sn, SEC,  melee_swing_up) \
	w_cvar(id, sn, SEC,  melee_swing_side) \
	w_cvar(id, sn, SEC,  melee_nonplayerdamage) \
	w_cvar(id, sn, SEC,  melee_multihit) \
	w_cvar(id, sn, SEC,  melee_delay) \
	w_cvar(id, sn, SEC,  melee_range) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
SHOTGUN_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_shotgun(void) { weapon_defaultspawnfunc(WEP_SHOTGUN); }

void W_Shotgun_Attack(void)
{
	float	sc;
	entity flash;

	W_DecreaseAmmo(WEP_CVAR_PRI(shotgun, ammo));

	W_SetupShot(self, TRUE, 5, W_Sound("shotgun_fire"), CH_WEAPON_A, WEP_CVAR_PRI(shotgun, damage) * WEP_CVAR_PRI(shotgun, bullets));
	for(sc = 0;sc < WEP_CVAR_PRI(shotgun, bullets);sc = sc + 1)
		fireBullet(w_shotorg, w_shotdir, WEP_CVAR_PRI(shotgun, spread), WEP_CVAR_PRI(shotgun, solidpenetration), WEP_CVAR_PRI(shotgun, damage), WEP_CVAR_PRI(shotgun, force), WEP_SHOTGUN, 0);

	Send_Effect(EFFECT_SHOTGUN_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, WEP_CVAR_PRI(shotgun, ammo));

	// casing code
	if(autocvar_g_casings >= 1)
		for(sc = 0;sc < WEP_CVAR_PRI(shotgun, ammo);sc = sc + 1)
			SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
}

.float swing_prev;
.entity swing_alreadyhit;
void W_Shotgun_Melee_Think(void)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time;
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = WEP_CVAR_SEC(shotgun, melee_time) * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR_SEC(shotgun, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && WEP_CVAR_SEC(shotgun, melee_no_doubleslap))
	{
		remove(self);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR_SEC(shotgun, melee_traces))) * 2 - 1);

		targpos = (self.realowner.origin + self.realowner.view_ofs
			+ (v_forward * WEP_CVAR_SEC(shotgun, melee_range))
			+ (v_up * swing_factor * WEP_CVAR_SEC(shotgun, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR_SEC(shotgun, melee_swing_side)));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, ANTILAG_LATENCY(self.realowner));

		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body" || (trace_ent.flags & FL_MONSTER));

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || WEP_CVAR_SEC(shotgun, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (WEP_CVAR_SEC(shotgun, damage) * min(1, swing_factor + 1));
			else
				swing_damage = (WEP_CVAR_SEC(shotgun, melee_nonplayerdamage) * min(1, swing_factor + 1));

			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, self.realowner, self.realowner,
				swing_damage, WEP_SHOTGUN | HITTYPE_SECONDARY,
				self.realowner.origin + self.realowner.view_ofs,
				v_forward * WEP_CVAR_SEC(shotgun, force));

			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_SHOTGUN, 0, swing_damage); }

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR_SEC(shotgun, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
			{
				self.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(self);
				return;
			}
		}
	}

	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		remove(self);
		return;
	}
	else
	{
		// set up next frame
		self.swing_prev = i;
		self.nextthink = time;
	}
}

void W_Shotgun_Attack2(void)
{
	sound(self, CH_WEAPON_A, W_Sound("shotgun_melee"), VOL_BASE, ATTEN_NORM);
	weapon_thinkf(WFRAME_FIRE2, WEP_CVAR_SEC(shotgun, animtime), w_ready);

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.realowner = self;
	meleetemp.think = W_Shotgun_Melee_Think;
	meleetemp.nextthink = time + WEP_CVAR_SEC(shotgun, melee_delay) * W_WeaponRateFactor();
	W_SetupShot_Range(self, TRUE, 0, "", 0, WEP_CVAR_SEC(shotgun, damage), WEP_CVAR_SEC(shotgun, melee_range));
}

.float shotgun_primarytime;

float W_Shotgun(float req)
{
	switch(req)
	{
		case WR_AIM:
		{
			if(vlen(self.origin-self.enemy.origin) <= WEP_CVAR_SEC(shotgun, melee_range))
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);

			return TRUE;
		}
		case WR_THINK:
		{
			if(WEP_CVAR(shotgun, reload_ammo) && self.clip_load < WEP_CVAR_PRI(shotgun, ammo)) // forced reload
			{
				// don't force reload an empty shotgun if its melee attack is active
				if(!WEP_CVAR(shotgun, secondary))
					WEP_ACTION(self.weapon, WR_RELOAD);
			}
			else
			{
				if(self.BUTTON_ATCK)
				{
					if(time >= self.shotgun_primarytime) // handle refire separately so the secondary can be fired straight after a primary
					{
						if(weapon_prepareattack(0, WEP_CVAR_PRI(shotgun, animtime)))
						{
							W_Shotgun_Attack();
							self.shotgun_primarytime = time + WEP_CVAR_PRI(shotgun, refire) * W_WeaponRateFactor();
							weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(shotgun, animtime), w_ready);
						}
					}
				}
			}
			if(self.clip_load >= 0) // we are not currently reloading
			if(!self.crouch) // no crouchmelee please
			if(self.BUTTON_ATCK2 && WEP_CVAR(shotgun, secondary))
			if(weapon_prepareattack(1, WEP_CVAR_SEC(shotgun, refire)))
			{
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				weapon_thinkf(WFRAME_FIRE1, 0, W_Shotgun_Attack2);
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/uziflash.md3");
			precache_model("models/weapons/g_shotgun.md3");
			precache_model("models/weapons/v_shotgun.md3");
			precache_model("models/weapons/h_shotgun.iqm");
			precache_sound("misc/itempickup.wav");
			precache_sound(W_Sound("shotgun_fire"));
			precache_sound(W_Sound("shotgun_melee"));
			SHOTGUN_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
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
			// shotgun has infinite ammo
			return TRUE;
		}
		case WR_CONFIG:
		{
			SHOTGUN_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(WEP_CVAR_PRI(shotgun, ammo), W_Sound("reload")); // WEAPONTODO
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
				return WEAPON_SHOTGUN_MURDER_SLAP;
			else
				return WEAPON_SHOTGUN_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
.float prevric;
float W_Shotgun(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			pointparticles(particleeffectnum("shotgun_impact"), org2, w_backoff * 1000, 1);
			if(!w_issilent && time - self.prevric > 0.25)
			{
				if(w_random < 0.0165)
					sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTEN_NORM);
				else if(w_random < 0.033)
					sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTEN_NORM);
				else if(w_random < 0.05)
					sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTEN_NORM);
				self.prevric = time;
			}

			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/ric1.wav");
			precache_sound("weapons/ric2.wav");
			precache_sound("weapons/ric3.wav");
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
