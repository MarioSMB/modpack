#ifndef IMPLEMENTATION
MODEL(AXE_VIEW,                     W_Model("h_axe.iqm"));
MODEL(AXE_WORLD,                    W_Model("v_axe.md3"));
MODEL(AXE_ITEM,                     W_Model("g_axe.md3"));

SOUND(AXE_MELEE, "quake_weapons/ax1.wav");
SOUND(AXE_MELEE_HIT, "quake_weapons/axhit2.wav");

CLASS(Axe, Weapon)
/* ammotype  */ //ATTRIB(Axe, ammo_field, .int, ammo_none)
/* impulse   */ ATTRIB(Axe, impulse, int, 1)
/* flags     */ //ATTRIB(Axe, spawnflags, int, WEP_FLAG_NORMAL);
/* rating    */ ATTRIB(Axe, bot_pickupbasevalue, float, BOT_PICKUP_RATING_LOW);
/* color     */ ATTRIB(Axe, wpcolor, vector, '0.7 0.7 0.7');
/* modelname */ ATTRIB(Axe, mdl, string, "axe");
#ifndef MENUQC
/* model     */ ATTRIB(Axe, m_model, Model, MDL_AXE_ITEM);
#endif
/* crosshair */ ATTRIB(Axe, w_crosshair, string, "gfx/crosshairdot");
/* crosshair */ ATTRIB(Axe, w_crosshair_size, float, 0.7);
/* wepimg    */ ATTRIB(Axe, model2, string, "weaponaxe");
/* refname   */ ATTRIB(Axe, netname, string, "axe");
/* wepname   */ ATTRIB(Axe, message, string, _("Axe"));
ENDCLASS(Axe)
REGISTER_WEAPON(AXE, NEW(Axe));

#ifdef SVQC
STATIC_INIT(axe_cvars)
{
	localcmd("\ng_balance_axe_reload_ammo 0\n");
	localcmd("\ng_balance_axe_reload_time 2\n");
	localcmd("\ng_balance_axe_animtime 0.35\n");
	localcmd("\ng_balance_axe_damage 15\n");
	localcmd("\ng_balance_axe_debug 0\n");
	localcmd("\ng_balance_axe_force 200\n");
	localcmd("\ng_balance_axe_melee_delay 0.25\n");
	localcmd("\ng_balance_axe_melee_multihit 0\n");
	localcmd("\ng_balance_axe_melee_no_doubleslap 1\n");
	localcmd("\ng_balance_axe_melee_nonplayerdamage 25\n");
	localcmd("\ng_balance_axe_melee_range 70\n");
	localcmd("\ng_balance_axe_melee_swing_side 0\n");
	localcmd("\ng_balance_axe_melee_swing_up 0\n");
	localcmd("\ng_balance_axe_melee_time 0.15\n");
	localcmd("\ng_balance_axe_melee_traces 1\n");
	localcmd("\ng_balance_axe_refire 0.4\n");
	localcmd("\ng_balance_axe_switchdelay_drop 0.2\n");
	localcmd("\ng_balance_axe_switchdelay_raise 0.2\n");
	localcmd("\ng_balance_axe_weaponreplace \"\"\n");
	localcmd("\ng_balance_axe_weaponstart 0\n");
	localcmd("\ng_balance_axe_weaponstartoverride -1\n");
	localcmd("\ng_balance_axe_weaponthrowable 0\n");
}
#endif

#define AXE_SETTINGS(w_cvar,w_prop) AXE_SETTINGS_LIST(w_cvar, w_prop, AXE, axe)
#define AXE_SETTINGS_LIST(w_cvar,w_prop,id,sn) \
	w_cvar(id, sn, NONE, animtime) \
	w_cvar(id, sn, NONE, refire) \
	w_cvar(id, sn, NONE, damage) \
	w_cvar(id, sn, NONE, force) \
	w_cvar(id, sn, NONE, debug) \
	w_cvar(id, sn, NONE,  melee_time) \
	w_cvar(id, sn, NONE,  melee_no_doubleslap) \
	w_cvar(id, sn, NONE,  melee_traces) \
	w_cvar(id, sn, NONE,  melee_swing_up) \
	w_cvar(id, sn, NONE,  melee_swing_side) \
	w_cvar(id, sn, NONE,  melee_nonplayerdamage) \
	w_cvar(id, sn, NONE,  melee_multihit) \
	w_cvar(id, sn, NONE,  melee_delay) \
	w_cvar(id, sn, NONE,  melee_range) \
	w_prop(id, sn, float,  reloading_ammo, reload_ammo) \
	w_prop(id, sn, float,  reloading_time, reload_time) \
	w_prop(id, sn, float,  switchdelay_raise, switchdelay_raise) \
	w_prop(id, sn, float,  switchdelay_drop, switchdelay_drop) \
	w_prop(id, sn, string, weaponreplace, weaponreplace) \
	w_prop(id, sn, float,  weaponstart, weaponstart) \
	w_prop(id, sn, float,  weaponstartoverride, weaponstartoverride) \
	w_prop(id, sn, float,  weaponthrowable, weaponthrowable)

#ifdef SVQC
AXE_SETTINGS(WEP_ADD_CVAR, WEP_ADD_PROP)
#endif
#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_axe) { weapon_defaultspawnfunc(this, WEP_AXE); }

.float swing_prev;
.entity swing_alreadyhit;
void W_Axe_Melee_Think(void)
{SELFPARAM();
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time;
		W_PlayStrengthSound(self.realowner);
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = WEP_CVAR(axe, melee_time) * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR(axe, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && WEP_CVAR(axe, melee_no_doubleslap))
	{
		remove(self);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR(axe, melee_traces))) * 2 - 1);

		targpos = (self.realowner.origin + self.realowner.view_ofs
			+ (v_forward * WEP_CVAR(axe, melee_range))
			+ (v_up * swing_factor * WEP_CVAR(axe, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR(axe, melee_swing_side)));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, false, self, ANTILAG_LATENCY(self.realowner));

		// draw lightning beams for debugging
		if(WEP_CVAR(axe, debug))
		{
			te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5);
			te_customflash(targpos, 40,  2, '1 1 1');
		}

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body" || IS_MONSTER(trace_ent));

		if(trace_fraction < 1 && (!trace_ent || trace_ent.solid == SOLID_BSP))
		{
			vector bckoff;
			if(trace_plane_normal != '0 0 0')
				bckoff = trace_plane_normal;
			else
				bckoff = -1 * normalize(trace_endpos - (trace_endpos + normalize(v_forward * WEP_CVAR(axe, force)) * 16));

			vector org2 = trace_endpos + bckoff * 2;
			Send_Effect(EFFECT_SHOTGUN_IMPACT, org2, bckoff * 1000, 1);
			sound(self.realowner, CH_WEAPON_B, SND_AXE_MELEE_HIT, VOL_BASE, ATTEN_NORM);
		}

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.solid == SOLID_BSP || trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || WEP_CVAR(axe, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (WEP_CVAR(axe, damage) * min(1, swing_factor + 1));
			else
				swing_damage = (WEP_CVAR(axe, melee_nonplayerdamage) * min(1, swing_factor + 1));

			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, self.realowner, self.realowner,
				swing_damage, WEP_AXE.m_id | HITTYPE_SECONDARY,
				self.realowner.origin + self.realowner.view_ofs,
				v_forward * WEP_CVAR(axe, force));

			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_AXE.m_id, 0, swing_damage); }

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR(axe, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
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

void W_Axe_Attack(Weapon thiswep, entity actor, int slot, int fire)
{
	sound(actor, CH_WEAPON_A, SND_AXE_MELEE, VOL_BASEVOICE, ATTEN_NORM);
	weapon_thinkf(actor, slot, WFRAME_FIRE1, WEP_CVAR(axe, animtime), w_ready);

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.realowner = actor;
	meleetemp.think = W_Axe_Melee_Think;
	meleetemp.nextthink = time + WEP_CVAR(axe, melee_delay) * W_WeaponRateFactor();
	W_SetupShot_Range(actor, true, 0, "", 0, WEP_CVAR(axe, damage), WEP_CVAR(axe, melee_range));
}

		METHOD(Axe, wr_aim, void(entity thiswep))
		{
			if(vlen(self.origin-self.enemy.origin) <= WEP_CVAR(axe, melee_range))
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, false);
			else
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, false);
		}
		METHOD(Axe, wr_think, void(entity thiswep, entity actor, int slot, int fire))
		{
			if(actor.clip_load >= 0) // we are not currently reloading
			if(fire & 1)
			if(weapon_prepareattack(thiswep, actor, slot, true, WEP_CVAR(axe, refire)))
			{
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				weapon_thinkf(actor, slot, WFRAME_FIRE1, 0, W_Axe_Attack);
			}
		}
		METHOD(Axe, wr_init, void(entity thiswep))
		{
			AXE_SETTINGS(WEP_SKIP_CVAR, WEP_SET_PROP);
		}
		METHOD(Axe, wr_setup, void(entity thiswep))
		{
			self.ammo_field = ammo_none;
		}
		METHOD(Axe, wr_checkammo1, bool(entity thiswep))
		{
			return true;
		}
		METHOD(Axe, wr_checkammo2, bool(entity thiswep))
		{
			return true;
		}
		METHOD(Axe, wr_config, void(entity thiswep))
		{
			AXE_SETTINGS(WEP_CONFIG_WRITE_CVARS, WEP_CONFIG_WRITE_PROPS);
		}
		METHOD(Axe, wr_reload, void(entity thiswep))
		{
			//W_Reload(self, WEP_CVAR_PRI(axe, ammo), SND(RELOAD)); // WEAPONTODO
		}
		METHOD(Axe, wr_suicidemessage, int(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(Axe, wr_killmessage, int(entity thiswep))
		{
			return WEAPON_SHOTGUN_MURDER_SLAP;
		}

#endif
#ifdef CSQC

		METHOD(Axe, wr_impacteffect, void(entity thiswep))
		{
			// nothing
		}

#endif
#endif
