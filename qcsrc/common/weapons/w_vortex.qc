#ifdef REGISTER_WEAPON
REGISTER_WEAPON(
/* WEP_##id  */ VORTEX,
/* function  */ W_Vortex,
/* ammotype  */ ammo_cells,
/* impulse   */ 7,
/* flags     */ WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN,
/* rating    */ BOT_PICKUP_RATING_HIGH,
/* color     */ '0.5 1 1',
/* modelname */ "nex",
/* simplemdl */ "foobar",
/* crosshair */ "gfx/crosshairnex 0.65",
/* wepimg    */ "weaponnex",
/* refname   */ "vortex",
/* wepname   */ _("Vortex")
);

#define VORTEX_SETTINGS(w_cvar,w_prop) VORTEX_SETTINGS_LIST(w_cvar, w_prop, VORTEX, vortex)
#define VORTEX_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, BOTH, ammo) \
	w_cvar(id, sn, BOTH, animtime) \
	w_cvar(id, sn, BOTH, damage) \
	w_cvar(id, sn, BOTH, force) \
	w_cvar(id, sn, BOTH, damagefalloff_mindist) \
	w_cvar(id, sn, BOTH, damagefalloff_maxdist) \
	w_cvar(id, sn, BOTH, damagefalloff_halflife) \
	w_cvar(id, sn, BOTH, damagefalloff_forcehalflife) \
	w_cvar(id, sn, BOTH, refire) \
	w_cvar(id, sn, NONE, charge) \
	w_cvar(id, sn, NONE, charge_mindmg) \
	w_cvar(id, sn, NONE, charge_shot_multiplier) \
	w_cvar(id, sn, NONE, charge_animlimit) \
	w_cvar(id, sn, NONE, charge_limit) \
	w_cvar(id, sn, NONE, charge_rate) \
	w_cvar(id, sn, NONE, charge_rot_rate) \
	w_cvar(id, sn, NONE, charge_rot_pause) \
	w_cvar(id, sn, NONE, charge_start) \
	w_cvar(id, sn, NONE, charge_minspeed) \
	w_cvar(id, sn, NONE, charge_maxspeed) \
	w_cvar(id, sn, NONE, charge_velocity_rate) \
	w_cvar(id, sn, NONE, secondary) \
	w_cvar(id, sn, SEC,  chargepool) \
	w_cvar(id, sn, SEC,  chargepool_regen) \
	w_cvar(id, sn, SEC,  chargepool_pause_regen) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
VORTEX_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#else
#ifdef SVQC
void spawnfunc_weapon_vortex(void) { weapon_defaultspawnfunc(WEP_VORTEX); }
void spawnfunc_weapon_nex(void) { spawnfunc_weapon_vortex(); }

void SendCSQCVortexBeamParticle(float charge) {
	vector v;
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_VORTEXBEAMPARTICLE);
	WriteCoord(MSG_BROADCAST, w_shotorg_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_z);
	WriteCoord(MSG_BROADCAST, v_x);
	WriteCoord(MSG_BROADCAST, v_y);
	WriteCoord(MSG_BROADCAST, v_z);
	WriteByte(MSG_BROADCAST, bound(0, 255 * charge, 255));
}

void W_Vortex_Attack(float issecondary)
{
	float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, myammo, charge;
	
	mydmg = WEP_CVAR_BOTH(vortex, !issecondary, damage);
	myforce = WEP_CVAR_BOTH(vortex, !issecondary, force);
	mymindist = WEP_CVAR_BOTH(vortex, !issecondary, damagefalloff_mindist);
	mymaxdist = WEP_CVAR_BOTH(vortex, !issecondary, damagefalloff_maxdist);
	myhalflife = WEP_CVAR_BOTH(vortex, !issecondary, damagefalloff_halflife);
	myforcehalflife = WEP_CVAR_BOTH(vortex, !issecondary, damagefalloff_forcehalflife);
	myammo = WEP_CVAR_BOTH(vortex, !issecondary, ammo);

	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	if(WEP_CVAR(vortex, charge))
	{
		charge = WEP_CVAR(vortex, charge_mindmg) / mydmg + (1 - WEP_CVAR(vortex, charge_mindmg) / mydmg) * self.vortex_charge;
		self.vortex_charge *= WEP_CVAR(vortex, charge_shot_multiplier); // do this AFTER setting mydmg/myforce
		// O RLY? -- divVerent
		// YA RLY -- FruitieX
	}
	else
		charge = 1;
	mydmg *= charge;
	myforce *= charge;

	W_SetupShot(self, TRUE, 5, "weapons/nexfire.wav", CH_WEAPON_A, mydmg);
	if(charge > WEP_CVAR(vortex, charge_animlimit) && WEP_CVAR(vortex, charge_animlimit)) // if the Vortex is overcharged, we play an extra sound
	{
		sound(self, CH_WEAPON_B, "weapons/nexcharge.wav", VOL_BASE * (charge - 0.5 * WEP_CVAR(vortex, charge_animlimit)) / (1 - 0.5 * WEP_CVAR(vortex, charge_animlimit)), ATTN_NORM);
	}

	yoda = 0;
	FireRailgunBullet(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_VORTEX);

	if(yoda && flying)
		Send_Notification(NOTIF_ONE, self, MSG_ANNCE, ANNCE_ACHIEVEMENT_YODA); 

	//beam and muzzle flash done on client
	SendCSQCVortexBeamParticle(charge);

	W_DecreaseAmmo(myammo);
}

void spawnfunc_weapon_vortex(void); // defined in t_items.qc

.float vortex_chargepool_pauseregen_finished;
float W_Vortex(float req)
{
	float dt;
	float ammo_amount;
	switch(req)
	{
		case WR_AIM:
		{
			if(bot_aim(1000000, 0, 1, FALSE))
				self.BUTTON_ATCK = TRUE;
			else
			{
				if(WEP_CVAR(vortex, charge))
					self.BUTTON_ATCK2 = TRUE;
			}
			return TRUE;
		}
		case WR_THINK:
		{
			if(WEP_CVAR(vortex, charge) && self.vortex_charge < WEP_CVAR(vortex, charge_limit))
				self.vortex_charge = min(1, self.vortex_charge + WEP_CVAR(vortex, charge_rate) * frametime / W_TICSPERFRAME);
				
			if(WEP_CVAR_SEC(vortex, chargepool))
				if(self.vortex_chargepool_ammo < 1)
				{
					if(self.vortex_chargepool_pauseregen_finished < time)
						self.vortex_chargepool_ammo = min(1, self.vortex_chargepool_ammo + WEP_CVAR_SEC(vortex, chargepool_regen) * frametime / W_TICSPERFRAME);
					self.pauseregen_finished = max(self.pauseregen_finished, time + WEP_CVAR_SEC(vortex, chargepool_pause_regen));
				}

			if(autocvar_g_balance_vortex_reload_ammo && self.clip_load < min(WEP_CVAR_PRI(vortex, ammo), WEP_CVAR_SEC(vortex, ammo))) // forced reload
				WEP_ACTION(self.weapon, WR_RELOAD);
			else
			{
				if(self.BUTTON_ATCK)
				{
					if(weapon_prepareattack(0, WEP_CVAR_PRI(vortex, refire)))
					{
						W_Vortex_Attack(0);
						weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_PRI(vortex, animtime), w_ready);
					}
				}
				if((WEP_CVAR(vortex, charge) && !WEP_CVAR(vortex, secondary)) ? (self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) : self.BUTTON_ATCK2)
				{
					if(WEP_CVAR(vortex, charge))
					{
						self.vortex_charge_rottime = time + WEP_CVAR(vortex, charge_rot_pause);
						dt = frametime / W_TICSPERFRAME;

						if(self.vortex_charge < 1)
						{
							if(WEP_CVAR_SEC(vortex, chargepool))
							{
								if(WEP_CVAR_SEC(vortex, ammo))
								{
									// always deplete if secondary is held
									self.vortex_chargepool_ammo = max(0, self.vortex_chargepool_ammo - WEP_CVAR_SEC(vortex, ammo) * dt);

									dt = min(dt, (1 - self.vortex_charge) / WEP_CVAR(vortex, charge_rate));
									self.vortex_chargepool_pauseregen_finished = time + WEP_CVAR_SEC(vortex, chargepool_pause_regen);
									dt = min(dt, self.vortex_chargepool_ammo);
									dt = max(0, dt);

									self.vortex_charge += dt * WEP_CVAR(vortex, charge_rate);
								}
							}

							else if(WEP_CVAR_SEC(vortex, ammo))
							{
								if(self.BUTTON_ATCK2) // only eat ammo when the button is pressed
								{
									dt = min(dt, (1 - self.vortex_charge) / WEP_CVAR(vortex, charge_rate));
									if(!(self.items & IT_UNLIMITED_WEAPON_AMMO))
									{
										// if this weapon is reloadable, decrease its load. Else decrease the player's ammo
										if(autocvar_g_balance_vortex_reload_ammo)
										{
											dt = min(dt, (self.clip_load - WEP_CVAR_PRI(vortex, ammo)) / WEP_CVAR_SEC(vortex, ammo));
											dt = max(0, dt);
											if(dt > 0)
											{
												self.clip_load = max(WEP_CVAR_SEC(vortex, ammo), self.clip_load - WEP_CVAR_SEC(vortex, ammo) * dt);
											}
											self.(weapon_load[WEP_VORTEX]) = self.clip_load;
										}
										else
										{
											dt = min(dt, (self.WEP_AMMO(VORTEX) - WEP_CVAR_PRI(vortex, ammo)) / WEP_CVAR_SEC(vortex, ammo));
											dt = max(0, dt);
											if(dt > 0)
											{
												self.WEP_AMMO(VORTEX) = max(WEP_CVAR_SEC(vortex, ammo), self.WEP_AMMO(VORTEX) - WEP_CVAR_SEC(vortex, ammo) * dt);
											}
										}
									}
									self.vortex_charge += dt * WEP_CVAR(vortex, charge_rate);
								}
							}

							else
							{
								dt = min(dt, (1 - self.vortex_charge) / WEP_CVAR(vortex, charge_rate));
								self.vortex_charge += dt * WEP_CVAR(vortex, charge_rate);
							}
						}
					}
					else if(WEP_CVAR(vortex, secondary))
					{
						if(weapon_prepareattack(0, WEP_CVAR_SEC(vortex, refire)))
						{
							W_Vortex_Attack(1);
							weapon_thinkf(WFRAME_FIRE1, WEP_CVAR_SEC(vortex, animtime), w_ready);
						}
					}
				}
			}
			
			return TRUE;
		}
		case WR_INIT:
		{
			precache_model("models/nexflash.md3");
			precache_model("models/weapons/g_nex.md3");
			precache_model("models/weapons/v_nex.md3");
			precache_model("models/weapons/h_nex.iqm");
			precache_sound("weapons/nexfire.wav");
			precache_sound("weapons/nexcharge.wav");
			precache_sound("weapons/nexwhoosh1.wav");
			precache_sound("weapons/nexwhoosh2.wav");
			precache_sound("weapons/nexwhoosh3.wav");
			VORTEX_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP)
			return TRUE;
		}
		case WR_CHECKAMMO1:
		{
			ammo_amount = self.WEP_AMMO(VORTEX) >= WEP_CVAR_PRI(vortex, ammo);
			ammo_amount += (autocvar_g_balance_vortex_reload_ammo && self.(weapon_load[WEP_VORTEX]) >= WEP_CVAR_PRI(vortex, ammo));
			return ammo_amount;
		}
		case WR_CHECKAMMO2:
		{
			if(WEP_CVAR(vortex, secondary))
			{
				// don't allow charging if we don't have enough ammo
				ammo_amount = self.WEP_AMMO(VORTEX) >= WEP_CVAR_SEC(vortex, ammo);
				ammo_amount += self.(weapon_load[WEP_VORTEX]) >= WEP_CVAR_SEC(vortex, ammo);
				return ammo_amount;
			}
			else
			{
				return FALSE; // zoom is not a fire mode
			}
		}
		case WR_CONFIG:
		{
			VORTEX_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS)
			return TRUE;
		}
		case WR_RELOAD:
		{
			W_Reload(min(WEP_CVAR_PRI(vortex, ammo), WEP_CVAR_SEC(vortex, ammo)), "weapons/reload.wav");
			return TRUE;
		}
		case WR_SUICIDEMESSAGE:
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		case WR_KILLMESSAGE:
		{
			return WEAPON_VORTEX_MURDER;
		}
	}
	return FALSE;
}
#endif
#ifdef CSQC
var float autocvar_g_balance_vortex_secondary = 0; // WEAPONTODO
float W_Vortex(float req)
{
	switch(req)
	{
		case WR_IMPACTEFFECT:
		{
			vector org2;
			org2 = w_org + w_backoff * 6;
			pointparticles(particleeffectnum("nex_impact"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);
				
			return TRUE;
		}
		case WR_INIT:
		{
			precache_sound("weapons/neximpact.wav");
			if(autocvar_cl_reticle && autocvar_cl_reticle_weapon)
			{
				precache_pic("gfx/reticle_nex");
			}
			return TRUE;
		}
		case WR_ZOOMRETICLE:
		{
			if(button_zoom || zoomscript_caught || (!WEP_CVAR(vortex, secondary) && button_attack2))
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
