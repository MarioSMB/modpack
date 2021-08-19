//FEATURE: New weapon: Z-Saber, the legendary sword of the fallen warrior
// LegendGuard's sword

#include "zsaber.qh"

#ifdef SVQC
REGISTER_MUTATOR(zsaber, true);

MUTATOR_HOOKFUNCTION(zsaber, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);
	vector frag_force = M_ARGV(6, vector);

	if(!IS_PLAYER(frag_target))
		return;

	if(DEATH_ISWEAPON(frag_deathtype, WEP_VORTEX) && (STAT(WEAPONS, frag_target) & WEPSET(ZSABER)))
	{
		bool have_zsaber = false;
		for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
		{
			.entity wepe = weaponentities[slot];
			if(frag_target.(wepe).m_weapon == WEP_ZSABER)
			{
				have_zsaber = true;
				break;
			}
		}

		if(!have_zsaber)
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
		FireRailgunBullet(frag_target, weaponentity, v_forward, frag_attacker.origin, frag_damage * 0.5, true, vlen(frag_force) * 0.5, 0, 0, 0, 0, WEP_VORTEX.m_id);

		animdecide_setaction(frag_target, ANIMACTION_SHOOT, 1);
		spamsound(frag_target, CH_WEAPON_A, SND_ZSABER_HIT_RANDOM(), VOL_BASE, ATTN_NORM);
	}
}

.float zsaber_hitshield;

.float swing_prev;
.entity swing_alreadyhit;

bool W_ZSaber_Melee_Block(entity this, entity player)
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
		int deathtype = this.projectiledeathtype;
		bool isprimary = !(deathtype & HITTYPE_SECONDARY);
		bool doneblock = false;
		makevectors(myowner.v_angle);
		IL_EACH(g_projectiles, time > it.zsaber_hitshield,
		{
			if(it.classname != "grapplinghook" && vdist(it.origin - myowner.origin, <, 256))
			{
				//LOG_INFO("Too close!");
				float dot = normalize(it.origin - myowner.origin) * v_forward;
				//LOG_INFO("dot = ", ftos(dot));
				if(dot <= 0.3) { continue; }

				if(!(it.classname == "rocket" || it.classname == "grenade") || WEP_CVAR_BOTH(zsaber, isprimary, melee_deflectrockets))
				{
					it.velocity *= -1; // straight forward...?
					UpdateCSQCProjectile(it);
				}
				it.zsaber_hitshield = time + 0.15;
				it.realowner = it.owner = myowner;

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
	spamsound(myowner, CH_WEAPON_A, SND_ZSABER_HIT_RANDOM(), VOL_BASE, ATTN_NORM);

	return true;
}

void W_ZSaber_Melee_Think(entity this)
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
	meleetime = WEP_CVAR_BOTH(zsaber, isprimary, melee_time) * W_WeaponRateFactor(this.realowner);
	swing = bound(0, (this.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * WEP_CVAR_BOTH(zsaber, isprimary, melee_traces));

	// check to see if we can still continue, otherwise give up now
	if(IS_DEAD(this.realowner) && WEP_CVAR_BOTH(zsaber, isprimary, melee_no_doubleslap))
	{
		delete(this);
		return;
	}

	// if okay, perform the traces needed for this frame
	for(i=this.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / WEP_CVAR_BOTH(zsaber, isprimary, melee_traces))) * 2 - 1);

		targpos = (this.realowner.origin + this.realowner.view_ofs
			+ (v_forward * WEP_CVAR_BOTH(zsaber, isprimary, melee_range))
			+ (v_up * swing_factor * WEP_CVAR_BOTH(zsaber, isprimary, melee_swing_up))
			+ (v_right * swing_factor * WEP_CVAR_BOTH(zsaber, isprimary, melee_swing_side)));

		WarpZone_traceline_antilag(this, this.realowner.origin + this.realowner.view_ofs, targpos, false, this.realowner, ANTILAG_LATENCY(this.realowner));

		if(W_ZSaber_Melee_Block(this, NULL))
			accuracy_add(this.realowner, WEP_ZSABER, 0, (WEP_CVAR_BOTH(zsaber, isprimary, melee_nonplayerdamage) * min(1, swing_factor + 1)));

		// draw lightning beams for debugging
		//te_lightning2(NULL, targpos, this.realowner.origin + this.realowner.view_ofs + v_forward * 5 - v_up * 5);
		//te_customflash(targpos, 40,  2, '1 1 1');

		is_player = (IS_PLAYER(trace_ent) || trace_ent.classname == "body" || (trace_ent.flags & FL_MONSTER));

		if((trace_fraction < 1) // if trace is good, apply the damage and remove this
			&& (trace_ent.takedamage == DAMAGE_AIM)
			&& (trace_ent != this.swing_alreadyhit)
			&& (is_player || WEP_CVAR_BOTH(zsaber, isprimary, melee_nonplayerdamage)))
		{
			target_victim = trace_ent; // so it persists through other calls

			if(!W_ZSaber_Melee_Block(this, trace_ent))
			{
				if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
					swing_damage = (WEP_CVAR_BOTH(zsaber, isprimary, damage) * min(1, swing_factor + 1));
				else
					swing_damage = (WEP_CVAR_BOTH(zsaber, isprimary, melee_nonplayerdamage) * min(1, swing_factor + 1));

				//print(strcat(this.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));

				Damage(target_victim, this.realowner, this.realowner,
					swing_damage, deathtype, this.weaponentity_fld,
					this.realowner.origin + this.realowner.view_ofs,
					v_forward * WEP_CVAR_BOTH(zsaber, isprimary, force));

				spamsound(this.realowner, CH_WEAPON_A, SND_ZSABER_HIT_RANDOM(), VOL_BASE, ATTN_NORM);

				if(accuracy_isgooddamage(this.realowner, target_victim)) { accuracy_add(this.realowner, WEP_ZSABER, 0, swing_damage); }
			}

			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');

			if(WEP_CVAR_BOTH(zsaber, isprimary, melee_multihit)) // allow multiple hits with one swing, but not against the same player twice.
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

void W_ZSaber_Attack(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	bool isprimary = !(fire & 2);
	sound(actor, CH_WEAPON_A, ((isprimary) ? SND_ZSABER_MELEE2 : SND_ZSABER_MELEE1), VOL_BASE, ATTN_NORM);
	weapon_thinkf(actor, weaponentity, ((isprimary) ? WFRAME_FIRE2 : WFRAME_FIRE1), WEP_CVAR_BOTH(zsaber, isprimary, animtime), w_ready);
	animdecide_setaction(actor, ANIMACTION_MELEE, true);

	entity meleetemp = new(meleetemp);
	meleetemp.owner = meleetemp.realowner = actor;
	setthink(meleetemp, W_ZSaber_Melee_Think);
	meleetemp.projectiledeathtype = WEP_ZSABER.m_id;
	if(!isprimary)
		meleetemp.projectiledeathtype |= HITTYPE_SECONDARY;
	meleetemp.weaponentity_fld = weaponentity;
	meleetemp.nextthink = time + WEP_CVAR_BOTH(zsaber, isprimary, melee_delay) * W_WeaponRateFactor(actor);
	W_SetupShot_Range(actor, weaponentity, true, 0, SND_Null, 0, WEP_CVAR_BOTH(zsaber, isprimary, damage), WEP_CVAR_BOTH(zsaber, isprimary, melee_range), meleetemp.projectiledeathtype);
}

// HACK: use tuba_instrument to avoid the need to manually network this from mod
//.bool zsaber_active;

void W_ZSaber_SetActive(entity actor, .entity weaponentity, bool newactive, bool dosound)
{
	if(newactive)
	{
		actor.(weaponentity).tuba_instrument = true;
		actor.(weaponentity).weaponname = "zsaber_active";
		if(dosound)
			sound(actor, CH_WEAPON_A, SND_ZSABER_ACTIVATE, VOL_BASE, ATTEN_NORM);
	}
	else
	{
		actor.(weaponentity).tuba_instrument = false;
		actor.(weaponentity).weaponname = "zsaber";
		if(dosound)
			sound(actor, CH_WEAPON_A, SND_ZSABER_DEACTIVATE, VOL_BASE, ATTEN_NORM);
	}

	actor.(weaponentity).state = WS_INUSE;
	weapon_thinkf(actor, weaponentity, WFRAME_RELOAD, 0.1, w_ready);
}

/*
// TODO: Make Z-Saber shockwave projectile

void W_ZSaber_Bolt_Think(entity this)
{
	// sys_phys_update_single(this);
	if(time >= this.ltime)
	{
		this.use(this, NULL, NULL);
		return;
	}

	if(WEP_CVAR_PRI(zsaber, midaircombo_radius))
	{
		float found = 0;
		entity e = WarpZone_FindRadius(this.origin, WEP_CVAR_PRI(zsaber, midaircombo_radius), true);

		// loop through nearby orbs and trigger them
		while(e)
		{
			if(e.classname == "zsaber_orb")
			{
				bool explode;
				if (this.owner == e.owner)
				{
					explode = WEP_CVAR_PRI(zsaber, midaircombo_own);
				}
				else if (SAME_TEAM(this.owner, e.owner))
				{
					explode = WEP_CVAR_PRI(zsaber, midaircombo_teammate);
				}
				else
				{
					explode = WEP_CVAR_PRI(zsaber, midaircombo_enemy);
				}

				if (explode)
				{
					// change owner to whoever caused the combo explosion
					e.realowner = this.realowner;
					e.takedamage = DAMAGE_NO;
					e.classname = "zsaber_orb_chain";

					// Only first orb explosion uses midaircombo_speed, others use the normal combo_speed.
					// This allows to avoid the delay on the first explosion which looks better
					// (the bolt and orb should explode together because they interacted together)
					// while keeping the chaining delay.
					setthink(e, W_ZSaber_ExplodeCombo);
					float delay = 0;
					if (WEP_CVAR_PRI(zsaber, midaircombo_speed))
						delay = vlen(e.WarpZone_findradius_dist) / WEP_CVAR_PRI(zsaber, midaircombo_speed);
					e.nextthink = time + delay;

					++found;
				}
			}
			e = e.chain;
		}

		// if we triggered an orb, should we explode? if not, lets try again next time
		if(found && WEP_CVAR_PRI(zsaber, midaircombo_explode))
			{ this.use(this, NULL, NULL); }
		else
			{ this.nextthink = min(time + WEP_CVAR_PRI(zsaber, midaircombo_interval), this.ltime); }
	}
	else { this.nextthink = this.ltime; }
	// this.nextthink = time;
}

void W_ZSaber_Attack_Bolt(Weapon thiswep, entity actor, .entity weaponentity)
{
	entity proj;

	W_DecreaseAmmo(thiswep, actor, WEP_CVAR_PRI(zsaber, ammo), weaponentity);

	W_SetupShot_ProjectileSize(
		actor,
		weaponentity,
		'0 0 -3',
		'0 0 -3',
		false,
		2,
		SND_ELECTRO_FIRE,
		CH_WEAPON_A,
		WEP_CVAR_PRI(zsaber, damage),
		thiswep.m_id
	);

	W_MuzzleFlash(thiswep, actor, weaponentity, w_shotorg, w_shotdir);

	proj = new(zsaber_bolt);
	proj.owner = proj.realowner = actor;
	proj.bot_dodge = true;
	proj.bot_dodgerating = WEP_CVAR_PRI(zsaber, damage);
	proj.use = W_ZSaber_Explode_use;
	setthink(proj, W_ZSaber_Bolt_Think);
	proj.nextthink = time;
	proj.ltime = time + WEP_CVAR_PRI(zsaber, lifetime);
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = thiswep.m_id;
	proj.weaponentity_fld = weaponentity;
	setorigin(proj, w_shotorg);

	// if (IS_CSQC)
	set_movetype(proj, MOVETYPE_FLY);
	W_SetupProjVelocity_PRI(proj, zsaber);
	proj.angles = vectoangles(proj.velocity);
	settouch(proj, W_ZSaber_TouchExplode);
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;
	IL_PUSH(g_projectiles, proj);
	IL_PUSH(g_bot_dodge, proj);
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, true, PROJECTILE_ELECTRO_BEAM, true);

	MUTATOR_CALLHOOK(EditProjectile, actor, proj);
	// proj.com_phys_pos = proj.origin;
	// proj.com_phys_vel = proj.velocity;
}
*/

		METHOD(ZSaber, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
		{
			if(random() >= 0.5)
				PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
			else
				PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
		}
		METHOD(ZSaber, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
		{
			if((fire & 1) || (fire & 2))
			if(weapon_prepareattack(thiswep, actor, weaponentity, (fire & 2), WEP_CVAR_BOTH(zsaber, !(fire & 2), refire)))
			{
				if(!actor.(weaponentity).tuba_instrument)
				{
					W_ZSaber_SetActive(actor, weaponentity, true, true);
					//weapon_thinkf(actor, weaponentity, WFRAME_RELOAD, WEP_CVAR_BOTH(zsaber, !(fire & 2), animtime), w_ready);
				}
				else
				{
					weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, W_ZSaber_Attack);
					//animdecide_setaction(actor, ANIMACTION_MELEE, true);
					//if (actor.anim_upper_action == ANIMACTION_SHOOT || actor.anim_upper_action == ANIMACTION_MELEE)
						//actor.anim_upper_action = 0;
				}
			}

			if(actor.(weaponentity).m_switchweapon != WEP_ZSABER && actor.(weaponentity).tuba_instrument)
				W_ZSaber_SetActive(actor, weaponentity, false, true);
		}
		METHOD(ZSaber, wr_setup, void(entity thiswep, entity actor, .entity weaponentity))
		{
			W_ZSaber_SetActive(actor, weaponentity, false, false);
		}
		METHOD(ZSaber, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			return true;
		}
		METHOD(ZSaber, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
		{
			return true;
		}
		METHOD(ZSaber, wr_suicidemessage, Notification(entity thiswep))
		{
			return WEAPON_THINKING_WITH_PORTALS;
		}
		METHOD(ZSaber, wr_killmessage, Notification(entity thiswep))
		{
			return WEAPON_ZSABER_MURDER;
		}

#elif defined(CSQC)
METHOD(ZSaber, wr_viewmodel, string(ZSaber this, entity wep))
{
	return (wep.tuba_instrument) ? "zsaber_active" : "zsaber";
}
#endif

#ifdef SVQC
METHOD(ZSaber, wr_reload, void(ZSaber this, entity actor, .entity weaponentity))
{
	// switch to alternate instruments :)
	if (actor.(weaponentity).state == WS_READY)
	{
		W_ZSaber_SetActive(actor, weaponentity, ((actor.(weaponentity).tuba_instrument) ? false : true), true);
	}
}
#endif
