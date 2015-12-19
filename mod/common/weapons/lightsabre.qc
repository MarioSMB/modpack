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

CLASS(Lightsabre, Weapon)
/* ammotype  */ //ATTRIB(Lightsabre, ammo_field, .int, ammo_shells)
/* impulse   */ ATTRIB(Lightsabre, impulse, int, 1)
/* flags     */ ATTRIB(Lightsabre, spawnflags, int, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE);
/* rating    */ ATTRIB(Lightsabre, bot_pickupbasevalue, float, BOT_PICKUP_RATING_LOW);
/* color     */ ATTRIB(Lightsabre, wpcolor, vector, '1 0.25 0.25');
/* modelname */ ATTRIB(Lightsabre, mdl, string, "lightsabre");
#ifndef MENUQC
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
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, weaponreplace, string, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_PROPS(X, Lightsabre, lightsabre)
#undef X

ENDCLASS(Lightsabre)
REGISTER_WEAPON(LIGHTSABRE, lightsabre, NEW(Lightsabre));

MSG_INFO_NOTIF(1, INFO_WEAPON_LIGHTSABRE_MURDER,      3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",  "weaponlightsabre",   _("^BG%s%s^K1's hand was sliced off by ^BG%s^K1's Lightsabre%s%s"), "")

MSG_MULTI_NOTIF(1, WEAPON_LIGHTSABRE_MURDER,      NO_MSG,        INFO_WEAPON_LIGHTSABRE_MURDER,      NO_MSG)

#ifdef SVQC
STATIC_INIT(lightsabre_cvars)
{
	localcmd("\ng_balance_lightsabre_primary_animtime 0.8\n");
	localcmd("\ng_balance_lightsabre_primary_damage 65\n");
	localcmd("\ng_balance_lightsabre_primary_force 200\n");
	localcmd("\ng_balance_lightsabre_primary_melee_delay 0.1\n");
	localcmd("\ng_balance_lightsabre_primary_melee_multihit 1\n");
	localcmd("\ng_balance_lightsabre_primary_melee_no_doubleslap 1\n");
	localcmd("\ng_balance_lightsabre_primary_melee_nonplayerdamage 40\n");
	localcmd("\ng_balance_lightsabre_primary_melee_range 120\n");
	localcmd("\ng_balance_lightsabre_primary_melee_swing_side 80\n");
	localcmd("\ng_balance_lightsabre_primary_melee_swing_up 60\n");
	localcmd("\ng_balance_lightsabre_primary_melee_time 0.15\n");
	localcmd("\ng_balance_lightsabre_primary_melee_traces 10\n");
	localcmd("\ng_balance_lightsabre_primary_refire 0.5\n");
	localcmd("\ng_balance_lightsabre_secondary_damage 55\n");
	localcmd("\ng_balance_lightsabre_secondary_animtime 0.5\n");
	localcmd("\ng_balance_lightsabre_secondary_force 200\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_delay 0.25\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_multihit 1\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_no_doubleslap 1\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_nonplayerdamage 40\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_range 120\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_swing_side -80\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_swing_up -50\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_time 0.15\n");
	localcmd("\ng_balance_lightsabre_secondary_melee_traces 10\n");
	localcmd("\ng_balance_lightsabre_secondary_refire 0.65\n");
	localcmd("\ng_balance_lightsabre_switchdelay_drop 0.2\n");
	localcmd("\ng_balance_lightsabre_switchdelay_raise 0.2\n");
	localcmd("\ng_balance_lightsabre_weaponreplace \"\"\n");
	localcmd("\ng_balance_lightsabre_weaponstart 0\n");
	localcmd("\ng_balance_lightsabre_weaponstartoverride -1\n");
	localcmd("\ng_balance_lightsabre_weaponthrowable 0\n");
}
#endif

#endif
#ifdef IMPLEMENTATION
#ifdef SVQC
spawnfunc(weapon_lightsabre) { weapon_defaultspawnfunc(this, WEP_LIGHTSABRE); }

.float swing_prev;
.entity swing_alreadyhit;

bool W_Lightsabre_Melee_Block(entity player)
{
	if(!IS_PLAYER(player)) { return false; }

	entity player_melee = world, e;
	entity myowner = self.realowner;

	for(e = world; (e = find(e, classname, "melee_temp")); )
	if(e.realowner == player)
	{
		player_melee = e;
		break;
	}

	if(!player_melee) { return false; }

	makevectors (player.v_angle);
	float dot = normalize (myowner.origin - player.origin) * v_forward;

	if(dot <= 0.3) { return false; }

	//if((myowner.v_angle_x - player.v_angle_x < 70) && (myowner.v_angle_x - player.v_angle_x > -70)) //Look up and down
	//if((myowner.v_angle_y - player.v_angle_y > 160) || (myowner.v_angle_y - player.v_angle_y < -160)) //Side to side Facing eachother
		// fun stuff

	animdecide_setaction(myowner, ANIMACTION_SHOOT, 1);
	spamsound(myowner, CH_WEAPON_A, SND(LIGHTSABRE_HIT_RANDOM()), VOL_BASE, ATTN_NORM);

	return true;
}

void W_Lightsabre_Melee_Think()
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;
	float isprimary = !(self.realowner.BUTTON_ATCK2);
	int deathtype = WEP_LIGHTSABRE.m_id;
	if(!isprimary)
		deathtype |= HITTYPE_SECONDARY;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time;
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors

	// calculate swing percentage based on time
	meleetime = WEP_CVAR_BOTH(lightsabre, isprimary, melee_time) * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR_BOTH(lightsabre, isprimary, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && WEP_CVAR_BOTH(lightsabre, isprimary, melee_no_doubleslap))
	{
		remove(self);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR_BOTH(lightsabre, isprimary, melee_traces))) * 2 - 1);

		targpos = (self.realowner.origin + self.realowner.view_ofs
			+ (v_forward * WEP_CVAR_BOTH(lightsabre, isprimary, melee_range))
			+ (v_up * swing_factor * WEP_CVAR_BOTH(lightsabre, isprimary, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR_BOTH(lightsabre, isprimary, melee_swing_side)));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, false, self.realowner, ANTILAG_LATENCY(self.realowner));

		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body" || (trace_ent.flags & FL_MONSTER));

		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || WEP_CVAR_BOTH(lightsabre, isprimary, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(!W_Lightsabre_Melee_Block(trace_ent))
			{
				if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
					swing_damage = (WEP_CVAR_BOTH(lightsabre, isprimary, damage) * min(1, swing_factor + 1));
				else
					swing_damage = (WEP_CVAR_BOTH(lightsabre, isprimary, melee_nonplayerdamage) * min(1, swing_factor + 1));

				//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

				Damage(target_victim, self.realowner, self.realowner,
					swing_damage, deathtype,
					self.realowner.origin + self.realowner.view_ofs,
					v_forward * WEP_CVAR_BOTH(lightsabre, isprimary, force));

				spamsound(self.realowner, CH_WEAPON_A, SND(LIGHTSABRE_HIT_RANDOM()), VOL_BASE, ATTN_NORM);

				if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_LIGHTSABRE.m_id, 0, swing_damage); }
			}

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR_BOTH(lightsabre, isprimary, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
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

void W_Lightsabre_Attack(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	bool isprimary = !(fire & 2);
	sound(actor, CH_WEAPON_A, ((isprimary) ? SND_LIGHTSABRE_MELEE2 : SND_LIGHTSABRE_MELEE1), VOL_BASE, ATTN_NORM);
	weapon_thinkf(actor, weaponentity, ((isprimary) ? WFRAME_FIRE2 : WFRAME_FIRE1), WEP_CVAR_BOTH(lightsabre, isprimary, animtime), w_ready);

	entity meleetemp = new(meleetemp);
	make_pure(meleetemp);
	meleetemp.owner = meleetemp.realowner = actor;
	meleetemp.think = W_Lightsabre_Melee_Think;
	meleetemp.nextthink = time + WEP_CVAR_BOTH(lightsabre, isprimary, melee_delay) * W_WeaponRateFactor();
	W_SetupShot_Range(actor, true, 0, "", 0, WEP_CVAR_BOTH(lightsabre, isprimary, damage), WEP_CVAR_BOTH(lightsabre, isprimary, melee_range));
}

.bool lightsabre_active;

void W_LightSabre_SetActive(entity actor, bool newactive, bool dosound)
{
	if(newactive)
	{
		actor.lightsabre_active = true;
		actor.weaponname = "lightsabre_active";
		if(dosound)
			sound(actor, CH_WEAPON_A, SND_LIGHTSABRE_ACTIVATE, VOL_BASE, ATTEN_NORM);
	}
	else
	{
		actor.lightsabre_active = false;
		actor.weaponname = "lightsabre";
		if(dosound)
			sound(actor, CH_WEAPON_A, SND_LIGHTSABRE_DEACTIVATE, VOL_BASE, ATTEN_NORM);
	}
}

		METHOD(Lightsabre, wr_aim, void(entity thiswep))
		{
			if(random() >= 0.5)
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, false);
			else
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, false);
		}
		METHOD(Lightsabre, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if((fire & 1) || (fire & 2))
			if(weapon_prepareattack(thiswep, actor, weaponentity, (fire & 2), WEP_CVAR_BOTH(lightsabre, !(fire & 2), refire)))
			{
				if(!self.lightsabre_active)
				{
					W_LightSabre_SetActive(actor, true, true);
					weapon_thinkf(actor, weaponentity, WFRAME_RELOAD, WEP_CVAR_BOTH(lightsabre, !(fire & 2), animtime), w_ready);
				}
				else
				{
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, W_Lightsabre_Attack);
					animdecide_setaction(actor, ANIMACTION_MELEE, true);
					if (actor.anim_upper_action == ANIMACTION_SHOOT || actor.anim_upper_action == ANIMACTION_MELEE)
						actor.anim_upper_action = 0;
				}
			}
		}
		METHOD(Lightsabre, wr_setup, void(entity thiswep))
		{
			self.ammo_field = ammo_none;
			W_LightSabre_SetActive(self, false, false);
		}
		METHOD(Lightsabre, wr_checkammo1, bool(entity thiswep))
		{
			return true;
		}
		METHOD(Lightsabre, wr_checkammo2, bool(entity thiswep))
		{
			return true;
		}
		METHOD(Lightsabre, wr_reload, void(entity thiswep))
		{
			W_LightSabre_SetActive(self, ((self.lightsabre_active) ? false : true), true);
		}
		METHOD(Lightsabre, wr_suicidemessage, int(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(Lightsabre, wr_killmessage, int(entity thiswep))
		{
			return WEAPON_LIGHTSABRE_MURDER;
		}

#endif
#endif
