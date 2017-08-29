#ifndef IMPLEMENTATION
MODEL(LIGHTSABRE_ITEM, W_Model("g_lightsabre.md3"));
MODEL(LIGHTSABRE_WORLD, W_Model("v_lightsabre.md3"));
MODEL(LIGHTSABRE_VIEW, W_Model("h_lightsabre.iqm"));
MODEL(LIGHTSABRE_ACTIVE_WORLD, W_Model("v_lightsabre_active.md3"));
MODEL(LIGHTSABRE_ACTIVE_VIEW, W_Model("h_lightsabre_active.iqm"));

SOUND(LIGHTSABRE_MELEE1, W_Sound("lightsabre_melee1"));
SOUND(LIGHTSABRE_MELEE2, W_Sound("lightsabre_melee2"));
SOUND(LIGHTSABRE_ACTIVATE, W_Sound("lightsabre_activate"));
SOUND(LIGHTSABRE_DEACTIVATE, W_Sound("lightsabre_deactivate"));
SOUND(LIGHTSABRE_HIT1, W_Sound("lightsabre_hit1"));
SOUND(LIGHTSABRE_HIT2, W_Sound("lightsabre_hit2"));
SOUND(LIGHTSABRE_HIT3, W_Sound("lightsabre_hit3"));
Sound SND_LIGHTSABRE_HIT_RANDOM() {
    return Sounds_from(SND_LIGHTSABRE_HIT1.m_id + floor(prandom() * 3));
}

AUTOCVAR(g_balance_lightsabre_primary_animtime, float, 0.8, "");
AUTOCVAR(g_balance_lightsabre_primary_damage, float, 70, "");
AUTOCVAR(g_balance_lightsabre_primary_force, float, 200, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_delay, float, 0.1, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_multihit, float, 1, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_no_doubleslap, float, 1, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_nonplayerdamage, float, 40, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_range, float, 120, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_swing_side, float, 80, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_swing_up, float, 60, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_time, float, 0.15, "");
AUTOCVAR(g_balance_lightsabre_primary_melee_traces, float, 10, "");
AUTOCVAR(g_balance_lightsabre_primary_refire, float, 0.5, "");
AUTOCVAR(g_balance_lightsabre_secondary_damage, float, 20, "");
AUTOCVAR(g_balance_lightsabre_secondary_animtime, float, 0.35, "");
AUTOCVAR(g_balance_lightsabre_secondary_force, float, 200, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_delay, float, 0.25, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_multihit, float, 1, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_no_doubleslap, float, 1, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_nonplayerdamage, float, 40, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_range, float, 120, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_swing_side, float, -80, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_swing_up, float, -50, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_time, float, 0.15, "");
AUTOCVAR(g_balance_lightsabre_secondary_melee_traces, float, 10, "");
AUTOCVAR(g_balance_lightsabre_secondary_refire, float, 0.35, "");
AUTOCVAR(g_balance_lightsabre_switchdelay_drop, float, 0.15, "");
AUTOCVAR(g_balance_lightsabre_switchdelay_raise, float, 0.15, "");
AUTOCVAR(g_balance_lightsabre_weaponreplace, string, "", "");
AUTOCVAR(g_balance_lightsabre_weaponstart, float, 0, "");
AUTOCVAR(g_balance_lightsabre_weaponstartoverride, float, -1, "");
AUTOCVAR(g_balance_lightsabre_weaponthrowable, float, 0, "");

CLASS(Lightsabre, Weapon)
/* ammotype  */ //ATTRIB(Lightsabre, ammo_field, .int, ammo_shells);
/* impulse   */ ATTRIB(Lightsabre, impulse, int, 1);
/* flags     */ ATTRIB(Lightsabre, spawnflags, int, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE);
/* rating    */ ATTRIB(Lightsabre, bot_pickupbasevalue, float, 6000);
/* color     */ ATTRIB(Lightsabre, wpcolor, vector, '1 0.25 0.25');
/* modelname */ ATTRIB(Lightsabre, mdl, string, "lightsabre");
#ifdef GAMEQC
/* model     */ ATTRIB(Lightsabre, m_model, Model, MDL_LIGHTSABRE_ITEM);
#endif
/* crosshair */ ATTRIB(Lightsabre, w_crosshair, string, "gfx/crosshairlightsabre");
/* crosshair */ ATTRIB(Lightsabre, w_crosshair_size, float, 0.35);
/* wepimg    */ ATTRIB(Lightsabre, model2, string, "weaponlightsabre");
/* refname   */ ATTRIB(Lightsabre, netname, string, "lightsabre");
/* wepname   */ ATTRIB(Lightsabre, m_name, string, _("Lightsabre"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, animtime, float, BOTH) \
		P(class, prefix, refire, float, BOTH) \
		P(class, prefix, damage, float, BOTH) \
		P(class, prefix, force, float, BOTH) \
		P(class, prefix, melee_time, float, BOTH) \
		P(class, prefix, melee_no_doubleslap, float, BOTH) \
		P(class, prefix, melee_traces, float, BOTH) \
		P(class, prefix, melee_swing_up, float, BOTH) \
		P(class, prefix, melee_swing_side, float, BOTH) \
		P(class, prefix, melee_nonplayerdamage, float, BOTH) \
		P(class, prefix, melee_multihit, float, BOTH) \
		P(class, prefix, melee_delay, float, BOTH) \
		P(class, prefix, melee_range, float, BOTH) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, Lightsabre, lightsabre)
#undef X

ENDCLASS(Lightsabre)
REGISTER_WEAPON(LIGHTSABRE, lightsabre, NEW(Lightsabre));

MSG_INFO_NOTIF(WEAPON_LIGHTSABRE_MURDER,   1,   3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",  "weaponlightsabre",   _("^BG%s%s^K1's hand was sliced off by ^BG%s^K1's Lightsabre%s%s"), "")

MSG_MULTI_NOTIF(WEAPON_LIGHTSABRE_MURDER,   1,   NULL,        INFO_WEAPON_LIGHTSABRE_MURDER,      NULL)

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_lightsabre) { weapon_defaultspawnfunc(this, WEP_LIGHTSABRE); }

REGISTER_MUTATOR(lightsabre_evil, true);

MUTATOR_HOOKFUNCTION(lightsabre_evil, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);
	vector frag_force = M_ARGV(6, vector);

	if(!IS_PLAYER(frag_target))
		return;

	if(DEATH_ISWEAPON(frag_deathtype, WEP_VORTEX) && (frag_target.weapons & WEPSET(LIGHTSABRE)))
	{
		bool have_lightsabre = false;
		for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity wepe = weaponentities[slot];
			if(frag_target.(wepe).m_weapon == WEP_LIGHTSABRE)
			{
				have_lightsabre = true;
				break;
			}
		}

		if(!have_lightsabre)
			return; // quicker to check for this than to loop through all melee entities

		entity player_melee = NULL;
		for(entity e = NULL; (e = find(e, classname, "meleetemp")); )
		if(e.realowner == frag_target)
		{
			player_melee = e;
			break;
		}
		if(!player_melee)
			return;
		makevectors (frag_attacker.v_angle);
		float dot = normalize (frag_target.origin - frag_attacker.origin) * v_forward;

		if(dot <= 0.3)
			return;
		makevectors(frag_target.v_angle);

		M_ARGV(4, float) = 0; // no damage for this!
		.entity weaponentity = player_melee.weaponentity_fld;
		// no accuracy needed for this, really
		FireRailgunBullet(frag_target, weaponentity, v_forward, frag_attacker.origin, frag_damage * 0.5, vlen(frag_force) * 0.5, 0, 0, 0, 0, WEP_VORTEX.m_id);

		animdecide_setaction(frag_target, ANIMACTION_SHOOT, 1);
		spamsound(frag_target, CH_WEAPON_A, SND_LIGHTSABRE_HIT_RANDOM(), VOL_BASE, ATTN_NORM);
	}
}

.float lightsabre_hitshield;

.float swing_prev;
.entity swing_alreadyhit;

bool W_Lightsabre_Melee_Block(entity this, entity player)
{
	entity myowner = this.realowner;
	if(IS_PLAYER(player))
	{
		entity player_melee = NULL, e;

		for(e = NULL; (e = find(e, classname, "meleetemp")); )
		if(e.realowner == player)
		{
			player_melee = e;
			break;
		}

		if(!player_melee) { return false; }

		makevectors (player.v_angle);
		float dot = normalize (myowner.origin - player.origin) * v_forward;

		makevectors(myowner.v_angle); // reset v vectors

		if(dot <= 0.3) { return false; }
	}
	else if(!player)
	{
		bool doneblock = false;
		makevectors(myowner.v_angle);
		IL_EACH(g_projectiles, time > it.lightsabre_hitshield,
		{
			if(vdist(it.origin - myowner.origin, <, 256))
			{
				//LOG_INFO("Too close!");
				float dot = normalize(it.origin - myowner.origin) * v_forward;
				//LOG_INFO("dot = ", ftos(dot));
				if(dot <= 0.3) { continue; }

				//LOG_INFO("We got one!");

				W_Devastator_Unregister(it);

				it.velocity *= -1; // straight forward...?
				it.realowner = it.owner = myowner;
				it.lightsabre_hitshield = time + 0.15;
				UpdateCSQCProjectile(it);
				doneblock = true;
			}
		});

		if(!doneblock) { return false; }
	}
	else
		return false; // didn't block it, must be a non-player entity

	//if((myowner.v_angle_x - player.v_angle_x < 70) && (myowner.v_angle_x - player.v_angle_x > -70)) //Look up and down
	//if((myowner.v_angle_y - player.v_angle_y > 160) || (myowner.v_angle_y - player.v_angle_y < -160)) //Side to side Facing eachother
		// fun stuff

	animdecide_setaction(myowner, ANIMACTION_SHOOT, 1);
	spamsound(myowner, CH_WEAPON_A, SND_LIGHTSABRE_HIT_RANDOM(), VOL_BASE, ATTN_NORM);

	return true;
}

void W_Lightsabre_Melee_Think(entity this)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;
	int deathtype = this.projectiledeathtype;
	bool isprimary = !(deathtype & HITTYPE_SECONDARY);

	if(!this.cnt) // set start time of melee
	{
		this.cnt = time;
	}

	makevectors(this.realowner.v_angle); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = WEP_CVAR_BOTH(lightsabre, isprimary, melee_time) * W_WeaponRateFactor(this.realowner);
	swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR_BOTH(lightsabre, isprimary, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if(IS_DEAD(this.realowner) && WEP_CVAR_BOTH(lightsabre, isprimary, melee_no_doubleslap))
	{
		delete(this);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=this.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR_BOTH(lightsabre, isprimary, melee_traces))) * 2 - 1);

		targpos = (this.realowner.origin + this.realowner.view_ofs
			+ (v_forward * WEP_CVAR_BOTH(lightsabre, isprimary, melee_range))
			+ (v_up * swing_factor * WEP_CVAR_BOTH(lightsabre, isprimary, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR_BOTH(lightsabre, isprimary, melee_swing_side)));

		WarpZone_traceline_antilag(this, this.realowner.origin + this.realowner.view_ofs, targpos, false, this.realowner, ANTILAG_LATENCY(this.realowner));

		if(W_Lightsabre_Melee_Block(this, NULL))
			accuracy_add(this.realowner, WEP_LIGHTSABRE.m_id, 0, (WEP_CVAR_BOTH(lightsabre, isprimary, melee_nonplayerdamage) * min(1, swing_factor + 1)));

		// draw lightning beams for debugging
		//te_lightning2(NULL, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body" || (trace_ent.flags & FL_MONSTER));

		if((trace_fraction < 1) // if trace is good, apply the damage and remove this
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != this.swing_alreadyhit)
			&& (is_player || WEP_CVAR_BOTH(lightsabre, isprimary, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(!W_Lightsabre_Melee_Block(this, trace_ent))
			{
				if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
					swing_damage = (WEP_CVAR_BOTH(lightsabre, isprimary, damage) * min(1, swing_factor + 1));
				else
					swing_damage = (WEP_CVAR_BOTH(lightsabre, isprimary, melee_nonplayerdamage) * min(1, swing_factor + 1));

				//print(strcat(this.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

				Damage(target_victim, this.realowner, this.realowner,
					swing_damage, deathtype,
					this.realowner.origin + this.realowner.view_ofs,
					v_forward * WEP_CVAR_BOTH(lightsabre, isprimary, force));

				spamsound(this.realowner, CH_WEAPON_A, SND_LIGHTSABRE_HIT_RANDOM(), VOL_BASE, ATTN_NORM);

				if(accuracy_isgooddamage(this.realowner, target_victim)) { accuracy_add(this.realowner, WEP_LIGHTSABRE.m_id, 0, swing_damage); }
			}

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR_BOTH(lightsabre, isprimary, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
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

void W_Lightsabre_Attack(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	bool isprimary = !(fire & 2);
	sound(actor, CH_WEAPON_A, ((isprimary) ? SND_LIGHTSABRE_MELEE2 : SND_LIGHTSABRE_MELEE1), VOL_BASE, ATTN_NORM);
	weapon_thinkf(actor, weaponentity, ((isprimary) ? WFRAME_FIRE2 : WFRAME_FIRE1), WEP_CVAR_BOTH(lightsabre, isprimary, animtime), w_ready);
	animdecide_setaction(actor, ANIMACTION_MELEE, true);

	entity meleetemp = new(meleetemp);
	meleetemp.owner = meleetemp.realowner = actor;
	setthink(meleetemp, W_Lightsabre_Melee_Think);
	meleetemp.projectiledeathtype = WEP_LIGHTSABRE.m_id;
	if(!isprimary)
		meleetemp.projectiledeathtype |= HITTYPE_SECONDARY;
	meleetemp.weaponentity_fld = weaponentity;
	meleetemp.nextthink = time + WEP_CVAR_BOTH(lightsabre, isprimary, melee_delay) * W_WeaponRateFactor(actor);
	W_SetupShot_Range(actor, weaponentity, true, 0, SND_Null, 0, WEP_CVAR_BOTH(lightsabre, isprimary, damage), WEP_CVAR_BOTH(lightsabre, isprimary, melee_range));
}

// HACK: use tuba_instrument to avoid the need to manually network this from mod
//.bool lightsabre_active;

void W_LightSabre_SetActive(entity actor, .entity weaponentity, bool newactive, bool dosound)
{
	if(newactive)
	{
		actor.(weaponentity).tuba_instrument = true;
		actor.(weaponentity).weaponname = "lightsabre_active";
		if(dosound)
			sound(actor, CH_WEAPON_A, SND_LIGHTSABRE_ACTIVATE, VOL_BASE, ATTEN_NORM);
	}
	else
	{
		actor.(weaponentity).tuba_instrument = false;
		actor.(weaponentity).weaponname = "lightsabre";
		if(dosound)
			sound(actor, CH_WEAPON_A, SND_LIGHTSABRE_DEACTIVATE, VOL_BASE, ATTEN_NORM);
	}

	actor.(weaponentity).state = WS_INUSE;
	weapon_thinkf(actor, weaponentity, WFRAME_RELOAD, 0.1, w_ready);
}

		METHOD(Lightsabre, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
		{
			if(random() >= 0.5)
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
			else
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
		}
		METHOD(Lightsabre, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if((fire & 1) || (fire & 2))
			if(weapon_prepareattack(thiswep, actor, weaponentity, (fire & 2), WEP_CVAR_BOTH(lightsabre, !(fire & 2), refire)))
			{
				if(!actor.(weaponentity).tuba_instrument)
				{
					W_LightSabre_SetActive(actor, weaponentity, true, true);
					//weapon_thinkf(actor, weaponentity, WFRAME_RELOAD, WEP_CVAR_BOTH(lightsabre, !(fire & 2), animtime), w_ready);
				}
				else
				{
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, W_Lightsabre_Attack);
					//animdecide_setaction(actor, ANIMACTION_MELEE, true);
					//if (actor.anim_upper_action == ANIMACTION_SHOOT || actor.anim_upper_action == ANIMACTION_MELEE)
						//actor.anim_upper_action = 0;
				}
			}

			if(actor.(weaponentity).m_switchweapon != WEP_LIGHTSABRE && actor.(weaponentity).tuba_instrument)
				W_LightSabre_SetActive(actor, weaponentity, false, true);
		}
		METHOD(Lightsabre, wr_setup, void(entity thiswep, entity actor, .entity weaponentity))
		{
			actor.ammo_field = ammo_none;
			W_LightSabre_SetActive(actor, weaponentity, false, false);
		}
		METHOD(Lightsabre, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			return true;
		}
		METHOD(Lightsabre, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			return true;
		}
		METHOD(Lightsabre, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(Lightsabre, wr_killmessage, Notification(entity thiswep))
		{
			return WEAPON_LIGHTSABRE_MURDER;
		}

#elif defined(CSQC)
METHOD(Lightsabre, wr_viewmodel, string(Lightsabre this, entity wep))
{
	return (wep.tuba_instrument) ? "lightsabre_active" : "lightsabre";
}
#endif

#ifdef SVQC
METHOD(Lightsabre, wr_reload, void(Lightsabre this, entity actor, .entity weaponentity))
{
	// switch to alternate instruments :)
	if (actor.(weaponentity).state == WS_READY)
	{
		W_LightSabre_SetActive(actor, weaponentity, ((actor.(weaponentity).tuba_instrument) ? false : true), true);
	}
}
#endif
#endif
