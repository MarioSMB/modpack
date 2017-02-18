#include "axe.qh"
#ifndef IMPLEMENTATION

AUTOCVAR(g_balance_axe_primary_animtime, float, 0.315, "");
AUTOCVAR(g_balance_axe_primary_damage, float, 85, "");
AUTOCVAR(g_balance_axe_primary_force, float, 120, "");
AUTOCVAR(g_balance_axe_primary_melee_delay, float, 0.25, "");
AUTOCVAR(g_balance_axe_primary_melee_multihit, float, 1, "");
AUTOCVAR(g_balance_axe_primary_melee_no_doubleslap, float, 1, "");
AUTOCVAR(g_balance_axe_primary_melee_nonplayerdamage, float, 50, "");
AUTOCVAR(g_balance_axe_primary_melee_range, float, 140, "");
AUTOCVAR(g_balance_axe_primary_melee_swing_side, float, 50, "");
AUTOCVAR(g_balance_axe_primary_melee_swing_up, float, 30, "");
AUTOCVAR(g_balance_axe_primary_melee_time, float, 0.15, "");
AUTOCVAR(g_balance_axe_primary_melee_traces, float, 6, "");
AUTOCVAR(g_balance_axe_primary_refire, float, 0.5, "");
AUTOCVAR(g_balance_axe_switchdelay_drop, float, 0.2, "");
AUTOCVAR(g_balance_axe_switchdelay_raise, float, 0.2, "");
AUTOCVAR(g_balance_axe_weaponreplace, string, "", "");
AUTOCVAR(g_balance_axe_weaponstart, float, 0, "");
AUTOCVAR(g_balance_axe_weaponstartoverride, float, -1, "");
AUTOCVAR(g_balance_axe_weaponthrowable, float, 1, "");

CLASS(Axe, Weapon)
/* ammotype  */ //ATTRIB(Axe, ammo_field, .int, ammo_none);
/* impulse   */ ATTRIB(Axe, impulse, int, 2);
/* flags     */ ATTRIB(Axe, spawnflags, int, WEP_TYPE_HITSCAN | WEP_TYPE_MELEE_PRI | WEP_TYPE_MELEE_SEC);
/* rating    */ ATTRIB(Axe, bot_pickupbasevalue, float, 2000);
/* color     */ ATTRIB(Axe, wpcolor, vector, '0.4 0.3 0.15');
/* modelname */ ATTRIB(Axe, mdl, string, "axe");
#ifdef GAMEQC
/* model     */ ATTRIB(Axe, m_model, Model, MDL_AXE_ITEM);
#endif
/* crosshair */ ATTRIB(Axe, w_crosshair, string, "gfx/crosshair50");
/* crosshair */ ATTRIB(Axe, w_crosshair_size, float, 0.65);
/* wepimg    */ ATTRIB(Axe, model2, string, "weaponaxe");
/* refname   */ ATTRIB(Axe, netname, string, "axe");
/* wepname   */ ATTRIB(Axe, m_name, string, _("Axe"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, animtime, float, PRI) \
		P(class, prefix, damage, float, PRI) \
		P(class, prefix, force, float, PRI) \
		P(class, prefix, melee_delay, float, PRI) \
		P(class, prefix, melee_multihit, float, PRI) \
		P(class, prefix, melee_nonplayerdamage, float, PRI) \
		P(class, prefix, melee_no_doubleslap, float, PRI) \
		P(class, prefix, melee_range, float, PRI) \
		P(class, prefix, melee_swing_side, float, PRI) \
		P(class, prefix, melee_swing_up, float, PRI) \
		P(class, prefix, melee_time, float, PRI) \
		P(class, prefix, melee_traces, float, PRI) \
		P(class, prefix, refire, float, PRI) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, Axe, axe)
#undef X

ENDCLASS(Axe)
REGISTER_WEAPON(AXE, axe, NEW(Axe));


MSG_INFO_NOTIF(WEAPON_AXE_MURDER_SLAP,          1,  3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",       "notify_melee_axe",     _("^BG%s%s^K1 was chopped in half by ^BG%s^K1 Axe%s%s"), "")
MSG_MULTI_NOTIF(WEAPON_AXE_MURDER_SLAP,         1,  NULL,           INFO_WEAPON_AXE_MURDER_SLAP,        NULL)

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_axe) { weapon_defaultspawnfunc(this, WEP_AXE); }

//.float swing_prev;
//.entity swing_alreadyhit;
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
	meleetime = WEP_CVAR_PRI(axe, melee_time) * W_WeaponRateFactor(this.realowner);
	swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR_PRI(axe, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if(IS_DEAD(this.realowner) && WEP_CVAR_PRI(axe, melee_no_doubleslap))
	{
		delete(this);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=this.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR_PRI(axe, melee_traces))) * 2 - 1);

		targpos = (this.realowner.origin + this.realowner.view_ofs
			+ (v_forward * WEP_CVAR_PRI(axe, melee_range))
			+ (v_up * swing_factor * WEP_CVAR_PRI(axe, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR_PRI(axe, melee_swing_side)));

		WarpZone_traceline_antilag(this, this.realowner.origin + this.realowner.view_ofs, targpos, false, this.realowner, ANTILAG_LATENCY(this.realowner));

		// draw lightning beams for debugging
		//te_lightning2(NULL, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body" || IS_MONSTER(trace_ent));

		if((trace_fraction < 1) // if trace is good, apply the damage and remove this
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != this.swing_alreadyhit)
			&& (is_player || WEP_CVAR_PRI(axe, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (WEP_CVAR_PRI(axe, damage) * min(1, swing_factor + 1));
			else
				swing_damage = (WEP_CVAR_PRI(axe, melee_nonplayerdamage) * min(1, swing_factor + 1));

			//print(strcat(this.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

			Damage(target_victim, this.realowner, this.realowner,
				swing_damage, WEP_AXE.m_id,
				this.realowner.origin + this.realowner.view_ofs,
				v_forward * WEP_CVAR_PRI(axe, force));

			if(accuracy_isgooddamage(this.realowner, target_victim)) { accuracy_add(this.realowner, WEP_AXE.m_id, 0, swing_damage); }

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR_PRI(axe, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
			{
				this.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				delete(this);
				return;
			}
		}
	}

	if(time >= this.cnt + meleetime)
	{
		// melee is finished
		delete(this);
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
	sound(actor, CH_WEAPON_A, SND_AXE_MELEE, VOL_BASE, ATTEN_NORM);
	weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR_PRI(axe, animtime), w_ready);

	entity meleetemp = new_pure(meleetemp);
	meleetemp.realowner = actor;
	setthink(meleetemp, W_Axe_Melee_Think);
	meleetemp.nextthink = time + WEP_CVAR_PRI(axe, melee_delay) * W_WeaponRateFactor(actor);
	W_SetupShot_Range(actor, weaponentity, true, 0, SND_Null, 0, WEP_CVAR_PRI(axe, damage), WEP_CVAR_PRI(axe, melee_range));
}

METHOD(Axe, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
{
    if(vdist(actor.origin - actor.enemy.origin, <=, WEP_CVAR_PRI(axe, melee_range)))
        PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
}
METHOD(Axe, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
    if(fire & 1)
    if(weapon_prepareattack(thiswep, actor, weaponentity, true, WEP_CVAR_PRI(axe, refire)))
    {
        // attempt forcing playback of the anim by switching to another anim (that we never play) here...
        weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, W_Axe_Attack);
    }

    if(fire & 2)
    if(actor.(weaponentity).m_switchweapon == WEP_AXE) // don't do this if already switching
        W_LastWeapon(actor, weaponentity);
}
METHOD(Axe, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
    return true;
}
METHOD(Axe, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
{
    return true;
}
METHOD(Axe, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(Axe, wr_killmessage, Notification(entity thiswep))
{
   return WEAPON_AXE_MURDER_SLAP;
}

#endif
#endif
