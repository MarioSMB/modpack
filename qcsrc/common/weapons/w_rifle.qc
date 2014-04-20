#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ RIFLE,
/* function  */ W_Rifle,
/* ammotype  */ ammo_nails,
/* impulse   */ 7,
/* flags     */ WEP_FLAG_MUTATORBLOCKED | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_MID,
/* color     */ '0.5 1 0',
/* modelname */ "campingrifle",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairrifle 0.5",
/* wepimg    */ "weaponrifle",
/* refname   */ "rifle",
/* wepname   */ _("Rifle")
);

#define RIFLE_SETTINGS(w_cvar,w_prop) RIFLE_SETTINGS_LIST(w_cvar, w_prop, RIFLE, rifle)
#define RIFLE_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, bullethail) \
	w_cvar(id, sn, BOTH, burstcost) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, BOTH, shots) \
	w_cvar(id, sn, BOTH, solidpenetration) \
	w_cvar(id, sn, BOTH, spread) \
	w_cvar(id, sn, BOTH, tracer) \
	w_cvar(id, sn, NONE, bursttime) \
	w_cvar(id, sn, NONE, secondary) \
	w_cvar(id, sn, SEC,  reload) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
RIFLE_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
.float rifle_accumulator;
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_rifle(void) { weapon_defaultspawnfunc(WEP_RIFLE); }
void spawnfunc_weapon_campingrifle(void) { spawnfunc_weapon_rifle(); }
void spawnfunc_weapon_sniperrifle(void) { spawnfunc_weapon_rifle(); }

void W_Rifle_FireBullet(float pSpread, float pDamage, float pForce, float pSolidPenetration, float pAmmo, float deathtype, float pTracer, float pShots, string pSound)
{
	float i;

	W_DecreaseAmmo(pAmmo);

	W_SetupShot(self, TRUE, 2, pSound, CH_WEAPON_A, pDamage * pShots);

	pointparticles(particleeffectnum("rifle_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);

	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	}

	for(i = 0; i < pShots; ++i)
		fireBullet(w_shotorg, w_shotdir, pSpread, pSolidPenetration, pDamage, pForce, deathtype, (pTracer ? EF_RED : EF_BLUE));

	if(autocvar_g_casings >= 2)
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);
}

void W_Rifle_Attack(void)
{
	W_Rifle_FireBullet(WEP_CVAR_PRI(rifle, spread), WEP_CVAR_PRI(rifle, damage), WEP_CVAR_PRI(rifle, force), WEP_CVAR_PRI(rifle, solidpenetration), WEP_CVAR_PRI(rifle, ammo), WEP_RIFLE, WEP_CVAR_PRI(rifle, tracer), WEP_CVAR_PRI(rifle, shots), "weapons/campingrifle_fire.wav");
}

void W_Rifle_Attack2(void)
{
	W_Rifle_FireBullet(WEP_CVAR_SEC(rifle, spread), WEP_CVAR_SEC(rifle, damage), WEP_CVAR_SEC(rifle, force), WEP_CVAR_SEC(rifle, solidpenetration), WEP_CVAR_SEC(rifle, ammo), WEP_RIFLE | HITTYPE_SECONDARY, WEP_CVAR_SEC(rifle, tracer), WEP_CVAR_SEC(rifle, shots), "weapons/campingrifle_fire2.wav");
}

.void(void) rifle_bullethail_attackfunc;
.float rifle_bullethail_frame;
.float rifle_bullethail_animtime;
.float rifle_bullethail_refire;
void W_Rifle_BulletHail_Continue(void)
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.WEP_AMMO(RIFLE)), "\n");
	r = weapon_prepareattack(self.rifle_bullethail_frame == WFRAME_FIRE2, self.rifle_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.rifle_bullethail_attackfunc();
		weapon_thinkf(self.rifle_bullethail_frame, self.rifle_bullethail_animtime, W_Rifle_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_Rifle_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.rifle_bullethail_attackfunc = AttackFunc;
		self.rifle_bullethail_frame = fr;
		self.rifle_bullethail_animtime = animtime;
		self.rifle_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_Rifle_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

.float bot_secondary_riflemooth;
float W_Rifle(float req)
{
	float ammo_amount;
	
	switch(req)
	{
		case WR_AIM:
		{
			self.BUTTON_ATCK=FALSE;
			self.BUTTON_ATCK2=FALSE;
			if(vlen(self.origin-self.enemy.origin) > 1000)
				self.bot_secondary_riflemooth = 0;
			if(self.bot_secondary_riflemooth == 0)
			{
				if(bot_aim(1000000, 0, 0.001, FALSE))
				{
					self.BUTTON_ATCK = TRUE;
					if(random() < 0.01) self.bot_secondary_riflemooth = 1;
				}
			}
			else
			{
				if(bot_aim(1000000, 0, 0.001, FALSE))
				{
					self.BUTTON_ATCK2 = TRUE;
					if(random() < 0.03) self.bot_secondary_riflemooth = 0;
				}
			}
			
			return TRUE;
		}
		case WR_THINK:
		{
			if(autocvar_g_balance_rifle_reload_ammo && self.clip_load < min(WEP_CVAR_PRI(rifle, ammo), WEP_CVAR_SEC(rifle, ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else
			{
				self.rifle_accumulator = bound(time - WEP_CVAR(rifle, bursttime), self.rifle_accumulator, time);
				if(self.BUTTON_ATCK)
				if(weapon_prepareattack_check(0, WEP_CVAR_PRI(rifle, refire)))
				if(time >= self.rifle_accumulator + WEP_CVAR_PRI(rifle, burstcost))
				{
					weapon_prepareattack_do(0, WEP_CVAR_PRI(rifle, refire));
					W_Rifle_BulletHail(WEP_CVAR_PRI(rifle, bullethail), W_Rifle_Attack, WFRAME_FIRE1, WEP_CVAR_PRI(rifle, animtime), WEP_CVAR_PRI(rifle, refire));
					self.rifle_accumulator += WEP_CVAR_PRI(rifle, burstcost);
				}
				if(self.BUTTON_ATCK2)
				{
					if(WEP_CVAR(rifle, secondary))
					{
						if(WEP_CVAR_SEC(rifle, reload))
							WEP_ACTION(self.weapon, WR_RELOAD);
						else
						{
							if(weapon_prepareattack_check(1, WEP_CVAR_SEC(rifle, refire)))
							if(time >= self.rifle_accumulator + WEP_CVAR_SEC(rifle, burstcost))
							{
								weapon_prepareattack_do(1, WEP_CVAR_SEC(rifle, refire));
								W_Rifle_BulletHail(WEP_CVAR_SEC(rifle, bullethail), W_Rifle_Attack2, WFRAME_FIRE2, WEP_CVAR_SEC(rifle, animtime), WEP_CVAR_PRI(rifle, refire));
								self.rifle_accumulator += WEP_CVAR_SEC(rifle, burstcost);
							}
						}
					}
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/weapons/g_campingrifle.md3");
			precache_model("models/weapons/v_campingrifle.md3");
			precache_model("models/weapons/h_campingrifle.iqm");
			precache_sound("weapons/campingrifle_fire.wav");
			precache_sound("weapons/campingrifle_fire2.wav");
			RIFLE_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.WEP_AMMO(RIFLE) >= WEP_CVAR_PRI(rifle, ammo);
			ammo_amount += self.(weapon_load[WEP_RIFLE]) >= WEP_CVAR_PRI(rifle, ammo);
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			ammo_amount = self.WEP_AMMO(RIFLE) >= WEP_CVAR_SEC(rifle, ammo);
			ammo_amount += self.(weapon_load[WEP_RIFLE]) >= WEP_CVAR_SEC(rifle, ammo);
			return ammo_amount;
		}
		case WR_CONFIG:
		{
			RIFLE_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RESETPLAYER:
		{
			self.rifle_accumulator = time - WEP_CVAR(rifle, bursttime);
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(WEP_CVAR_PRI(rifle, ammo), WEP_CVAR_SEC(rifle, ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			if(w_deathtype & HITTYPE_SECONDARY)
			{
				if(w_deathtype & HITTYPE_BOUNCE)
					return WEAPON_RIFLE_MURDER_HAIL_PIERCING;
				else
					return WEAPON_RIFLE_MURDER_HAIL;
			}
			else
			{
				if(w_deathtype & HITTYPE_BOUNCE)
					return WEAPON_RIFLE_MURDER_PIERCING;
				else
					return WEAPON_RIFLE_MURDER;
			}
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
float W_Rifle(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 2;
			pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
			if(!w_issilent)
			{
				if(w_random < 0.2)
					sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
				else if(w_random < 0.4)
					sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
				else if(w_random < 0.5)
					sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/ric1.wav");
			precache_sound("weapons/ric2.wav");
			precache_sound("weapons/ric3.wav");
			if(autocvar_cl_reticle && autocvar_cl_reticle_weapon)
			{
				precache_pic("gfx/reticle_nex");
			}
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			if(button_zoom || zoomscript_caught)
			{
				reticle_image = "gfx/reticle_nex";
				return TRUE;
			}
			else
			{
				// no weapon specific image for this weapon
				return FALSE;
			}
		}
	}
	return FALSE;
}
#endif
#endif
