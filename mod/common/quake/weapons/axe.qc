#ifndef IMPLEMENTATION
MODEL(AXE_VIEW,                     W_Model("h_axe.iqm"));
MODEL(AXE_WORLD,                    W_Model("v_axe.md3"));
MODEL(AXE_ITEM,                     W_Model("g_axe.md3"));

SOUND(AXE_MELEE, "quake_weapons/ax1");
SOUND(AXE_MELEE_HIT, "quake_weapons/axhit2");

float autocvar_g_balance_axe_reload_ammo = 0;
float autocvar_g_balance_axe_reload_time = 2;
float autocvar_g_balance_axe_animtime = 0.35;
float autocvar_g_balance_axe_damage = 15;
float autocvar_g_balance_axe_debug = 0;
float autocvar_g_balance_axe_force = 200;
float autocvar_g_balance_axe_melee_delay = 0.25;
float autocvar_g_balance_axe_melee_multihit = 0;
float autocvar_g_balance_axe_melee_no_doubleslap = 1;
float autocvar_g_balance_axe_melee_nonplayerdamage = 25;
float autocvar_g_balance_axe_melee_range = 70;
float autocvar_g_balance_axe_melee_swing_side = 0;
float autocvar_g_balance_axe_melee_swing_up = 0;
float autocvar_g_balance_axe_melee_time = 0.15;
float autocvar_g_balance_axe_melee_traces = 1;
float autocvar_g_balance_axe_refire = 0.4;
float autocvar_g_balance_axe_switchdelay_drop = 0.2;
float autocvar_g_balance_axe_switchdelay_raise = 0.2;
string autocvar_g_balance_axe_weaponreplace = "";
float autocvar_g_balance_axe_weaponstart = 0;
float autocvar_g_balance_axe_weaponstartoverride = -1;
float autocvar_g_balance_axe_weaponthrowable = 0;

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
/* wepname   */ ATTRIB(Axe, m_name, string, "Axe");

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, animtime, float, NONE) \
		P(class, prefix, damage, float, NONE) \
		P(class, prefix, force, float, NONE) \
		P(class, prefix, refire, float, NONE) \
		P(class, prefix, debug, float, NONE) \
		P(class, prefix, melee_delay, float, NONE) \
		P(class, prefix, melee_multihit, float, NONE) \
		P(class, prefix, melee_no_doubleslap, float, NONE) \
		P(class, prefix, melee_nonplayerdamage, float, NONE) \
		P(class, prefix, melee_range, float, NONE) \
		P(class, prefix, melee_swing_side, float, NONE) \
		P(class, prefix, melee_swing_up, float, NONE) \
		P(class, prefix, melee_time, float, NONE) \
		P(class, prefix, melee_traces, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, Axe, axe)
#undef X

ENDCLASS(Axe)
REGISTER_WEAPON(AXE, axe, NEW(Axe));

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_axe) { weapon_defaultspawnfunc(this, WEP_AXE); }

.float swing_prev;
.entity swing_alreadyhit;
void W_Axe_Melee_Think(entity this)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;

	if(!this.cnt) // set start time of melee
	{
		this.cnt = time;
		W_PlayStrengthSound(this.realowner);
	}

	makevectors(this.realowner.v_angle); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = WEP_CVAR(axe, melee_time) * W_WeaponRateFactor(this.realowner);
	swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR(axe, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if(IS_DEAD(this.realowner) && WEP_CVAR(axe, melee_no_doubleslap))
	{
		remove(this);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=this.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR(axe, melee_traces))) * 2 - 1);

		targpos = (this.realowner.origin + this.realowner.view_ofs
			+ (v_forward * WEP_CVAR(axe, melee_range))
			+ (v_up * swing_factor * WEP_CVAR(axe, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR(axe, melee_swing_side)));

		WarpZone_traceline_antilag(this, this.realowner.origin + this.realowner.view_ofs, targpos, false, this, ANTILAG_LATENCY(this.realowner));

		// draw lightning beams for debugging
		if(WEP_CVAR(axe, debug))
		{
			te_lightning2(world, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
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
			sound(this.realowner, CH_WEAPON_B, SND_AXE_MELEE_HIT, VOL_BASE, ATTEN_NORM);
		}

		if((trace_fraction < 1) // if trace is good, apply the damage and remove this
			&& (trace_ent.solid == SOLID_BSP || trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != this.swing_alreadyhit)
			&& (is_player || WEP_CVAR(axe, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (WEP_CVAR(axe, damage) * min(1, swing_factor + 1));
			else
				swing_damage = (WEP_CVAR(axe, melee_nonplayerdamage) * min(1, swing_factor + 1));

			//print(strcat(this.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, this.realowner, this.realowner,
				swing_damage, WEP_AXE.m_id | HITTYPE_SECONDARY,
				this.realowner.origin + this.realowner.view_ofs,
				v_forward * WEP_CVAR(axe, force));

			if(accuracy_isgooddamage(this.realowner, target_victim)) { accuracy_add(this.realowner, WEP_AXE.m_id, 0, swing_damage); }

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR(axe, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
			{
				this.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(this);
				return;
			}
		}
	}

	if(time >= this.cnt + meleetime)
	{
		// melee is finished
		remove(this);
		return;
	}
	else
	{
		// set up next frame
		this.swing_prev = i;
		this.nextthink = time;
	}
}

void W_Axe_Attack(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	sound(actor, CH_WEAPON_A, SND_AXE_MELEE, VOL_BASEVOICE, ATTEN_NORM);
	weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(axe, animtime), w_ready);

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.realowner = actor;
	setthink(meleetemp, W_Axe_Melee_Think);
	meleetemp.nextthink = time + WEP_CVAR(axe, melee_delay) * W_WeaponRateFactor(actor);
	W_SetupShot_Range(actor, true, 0, SND_Null, 0, WEP_CVAR(axe, damage), WEP_CVAR(axe, melee_range));
}

		METHOD(Axe, wr_aim, void(entity thiswep, entity actor))
		{
			if(vdist(actor.origin - actor.enemy.origin, <=, WEP_CVAR(axe, melee_range)))
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, 1000000, 0, 0.001, false);
			else
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, 1000000, 0, 0.001, false);
		}
		METHOD(Axe, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if(actor.clip_load >= 0) // we are not currently reloading
			if(fire & 1)
			if(weapon_prepareattack(thiswep, actor, weaponentity, true, WEP_CVAR(axe, refire)))
			{
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, W_Axe_Attack);
			}
		}
		METHOD(Axe, wr_setup, void(entity thiswep, entity actor))
		{
			actor.ammo_field = ammo_none;
		}
		METHOD(Axe, wr_checkammo1, bool(entity thiswep, entity actor))
		{
			return true;
		}
		METHOD(Axe, wr_checkammo2, bool(entity thiswep, entity actor))
		{
			return true;
		}
		METHOD(Axe, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
		{
			//W_Reload(actor, WEP_CVAR_PRI(axe, ammo), SND_RELOAD); // WEAPONTODO
		}
		METHOD(Axe, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(Axe, wr_killmessage, Notification(entity thiswep))
		{
			return WEAPON_SHOTGUN_MURDER_SLAP;
		}

#endif
#ifdef CSQC

		METHOD(Axe, wr_impacteffect, void(entity thiswep, entity actor))
		{
			// nothing
		}

#endif
#endif
