IntrusiveList g_dotc_addons;
STATIC_INIT(g_dotc_addons) { g_dotc_addons = IL_NEW(); }

// core listing
entity dotc_GetCore(int teamnumber)
{
	entity tmp_entity;

	for(tmp_entity = dotc_worldcorelist; tmp_entity; tmp_entity = tmp_entity.dotc_worldcorenext)
	{
		if(tmp_entity.team == teamnumber)
			return tmp_entity;
	}

	return NULL; // safe?
}


// ===================
// Core addon handling
// ===================

void dotc_Core_Addons_Damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{
	if(this.owner.event_damage)
		this.owner.event_damage(this.owner, inflictor, attacker, damage, deathtype, weaponentity, hitloc, force);
}

void dotc_Core_Addons_Think(entity this)
{
	this.nextthink = time + DOTC_CORE_THINKRATE;

	// prediction
	CSQCMODEL_AUTOUPDATE(this);
}

entity dotc_Core_Addons_Spawn(entity core, Model smdl, string sbone)
{
	entity addon = spawn();

	setmodel(addon, smdl);
	setorigin(addon, gettaginfo(core, gettagindex(core, sbone)));

	addon.dotc_unittype		= DOTC_UF_ADDON;
	addon.colormap 			= core.colormap;
	addon.owner				= core;
	addon.team 				= core.team;
	addon.angles			= vectoangles(v_forward);
	addon.solid 			= core.solid;
	addon.takedamage		= core.takedamage;
	addon.event_damage		= dotc_Core_Addons_Damage;
	addon.dotc_targetflags	= DOTC_TARGET_DRONES;
	setthink(addon, dotc_Core_Addons_Think);
	addon.nextthink			= time + DOTC_CORE_THINKRATE;

	IL_PUSH(g_dotc_addons, addon);

	fix_mins_maxs_for_rotating(addon);
	CSQCMODEL_AUTOINIT(addon);

	return addon;
}

void dotc_Core_Addons_Clear(entity this)
{
	IL_EACH(g_dotc_addons, it.owner == this && it.dotc_unittype == DOTC_UF_ADDON,
	{
		it.owner = NULL;
		setthink(it, SUB_Remove);
		it.nextthink = time;
		IL_REMOVE(g_dotc_addons, it);
	});
}


// ====================
// Level 10 core sphere
// ====================

void dotc_Core_Sphere_Think(entity this)
{
	this.nextthink = time;
	this.avelocity = '10 -60 20';

	CSQCMODEL_AUTOUPDATE(this);
}

void dotc_Core_Sphere_Spawn(entity core)
{
	entity sphere = dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_10, "addon04");
	sphere.solid 	 = SOLID_NOT;
	set_movetype(sphere, MOVETYPE_NOCLIP);
	setthink(sphere, dotc_Core_Sphere_Think);
	sphere.nextthink = time;
}


// =====================
// Core upgrade handling
// =====================

void dotc_Core_SetLevel(entity core, int newlevel, bool silent)
{
	newlevel = bound(1, newlevel, 10);

	if(newlevel == core.dotc_corelevel)
	{
		LOG_DEBUG("Trying to set core level to the same value, aborting\n");
		return;
	}

	if(!silent)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_DOTC_CORE_UPGRADE, core.netname, newlevel);
		play2all(core.snd_core_upgrade);
	}

	core.dotc_corelevel = newlevel;
	core.dotc_nextlevel = core.dotc_nextlevel * autocvar_g_dotc_nextlevel_multiplier;

	if(autocvar_g_dotc_nextlevel_resethealth)
	{
		SetResourceAmountExplicit(core, RESOURCE_HEALTH, core.max_health);
		if(core.wps_corebase)
			WaypointSprite_UpdateHealth(core.wps_corebase, GetResourceAmount(core, RESOURCE_HEALTH));
	}

	dotc_Core_Addons_Clear(core);

	if(newlevel >= 7)
	{
		setmodel(core, MDL_DOTC_CORE_LEVEL_7);
		dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_8_9, "addon01");

		if(newlevel >= 8)
			dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_8_9, "addon02");
		if(newlevel >= 9)
			dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_8_9, "addon03");
		if(newlevel >= 10)
			dotc_Core_Sphere_Spawn(core);
	}
	else if(newlevel >= 4)
	{
		setmodel(core, MDL_DOTC_CORE_LEVEL_4);
		dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_5_6, "addon01");

		if(newlevel >= 5)
			dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_5_6, "addon02");
		if(newlevel >= 6)
			dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_5_6, "addon03");
	}
	else if(newlevel >= 1)
	{
		setmodel(core, MDL_DOTC_CORE_LEVEL_1);
		dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_2_3, "addon01");

		if(newlevel >= 2)
			dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_2_3, "addon02");
		if(newlevel >= 3)
			dotc_Core_Addons_Spawn(core, MDL_DOTC_CORE_LEVEL_2_3, "addon03");
	}

	fix_mins_maxs_for_rotating(core);
	CSQCMODEL_AUTOUPDATE(core);
}


// ===============
// Main core setup
// ===============

void dotc_CoreDamage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{	
	if(DOTC_FFCHECK(this, attacker))
		return;

	TakeResource(this, RESOURCE_HEALTH, damage);
	
	if(this.wps_corebase)
		WaypointSprite_UpdateHealth(this.wps_corebase, GetResourceAmount(this, RESOURCE_HEALTH));
	
	if (GetResourceAmount(this, RESOURCE_HEALTH) <= 0)
	{
		if(IS_CLIENT(attacker))
			GameRules_scoring_add(attacker, DOTC_DESTROYED, +1);
		this.dotc_status = CORE_DYING;
		this.deadflag = DEAD_DYING;
		this.event_damage = func_null;
		if(this.wps_corebase)
		{
			WaypointSprite_UpdateHealth(this.wps_corebase, 0);
			this.wps_corebase.team = -1;
			this.wps_corebase.SendFlags |= 1;
		}

		Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_DOTC_CORE_DESTROYED, this.netname);
	}
	else if(DIFF_TEAM(attacker, this))
		this.dmgtime = time + 1;
}

void dotc_CoreReset(entity this)
{
	SetResourceAmountExplicit(this, RESOURCE_HEALTH, this.max_health);
	this.dotc_status = CORE_IDLE;
	this.deadflag = DEAD_NO;
	this.event_damage = dotc_CoreDamage;
	this.dotc_corelevel = 0; // reset level below

	if(this.wps_corebase)
	{
		WaypointSprite_UpdateHealth(this.wps_corebase, GetResourceAmount(this, RESOURCE_HEALTH));
		this.wps_corebase.team = 0;
		this.wps_corebase.SendFlags |= 1;
	}

	dotc_Core_SetLevel(this, 1, true);
}

void dotc_CoreThink(entity this)
{
	if(game_stopped)
	if(this.wps_corebase)
		WaypointSprite_Kill(this.wps_corebase);

	this.nextthink = time + DOTC_CORE_THINKRATE;

	// prediction
	CSQCMODEL_AUTOUPDATE(this);

	// main think method
	switch(this.dotc_status)
	{
		case CORE_IDLE:
		{
			// nothing to see here
			break;
		}

		case CORE_ACTIVE:
		{
			if(time < this.dmgtime)
			if(time >= this.floodcontrol_chat)
			{
				this.floodcontrol_chat = time + 3;
				Send_Notification(NOTIF_TEAM, this, MSG_CENTER, CENTER_DOTC_CORE_UNDERATTACK);
				play2team(this.team, SND(DOTC_CORE_ATTACK));
			}

			if(this.dotc_corelevel < 10)
			if(this.dotc_credits >= this.dotc_nextlevel)
				dotc_Core_SetLevel(this, this.dotc_corelevel + 1, false);

			break;
		}

		case CORE_DYING:
		{
			vector org;

			if(this.frame < 10)
				this.frame += 1;

			if(!this.count)
				this.count = 40;

			// White shockwave
			if(this.count==40||this.count==20)
			{
				Send_Effect(EFFECT_ELECTRO_COMBO, this.origin, '0 0 0', 6);
				sound(this, CH_SHOTS, SND_ONS_SHOCKWAVE, VOL_BASE, ATTEN_NORM);
			}

			// Spawn fire balls
			for(int j = 0; j < 10; ++j)
			{
				org = this.origin + randompos('-30 -30 -30' * j + '0 0 -20', '30 30 30' * j + '0 0 20');
				Send_Effect(EFFECT_ONS_GENERATOR_GIB, org, '0 0 0', 1);
			}

			// Short explosion sound + small explosion
			if(random() < 0.25)
			{
				te_explosion(this.origin);
				sound(this, CH_SHOTS, SND_GRENADE_IMPACT, VOL_BASE, ATTEN_NORM);
			}

			// Particles
			org = this.origin + randompos(this.mins + '8 8 8', this.maxs + '-8 -8 -8');
			Send_Effect(EFFECT_ONS_GENERATOR_EXPLODE, org, '0 0 0', 1);

			// rays
			/*if(random() > 0.25 )
			{
				ons_generator_ray_spawn(this.origin);
			}*/

			// Final explosion
			if(this.count == 1)
			{
				org = this.origin;
				te_explosion(org);
				//ons_generator_shockwave_spawn(org);
				setmodel(this, MDL_Null);
				this.deadflag = DEAD_DEAD;
				this.dotc_status = CORE_DEAD;
				Send_Effect(EFFECT_ONS_GENERATOR_EXPLODE, org, '0 0 0', 1);
				sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);

				IL_EACH(g_dotc_addons, it.owner == this && it.dotc_unittype == DOTC_UF_ADDON,
				{
					it.effects   = EF_FLAME;
					it.colormod  = '-1 -1 -1';
					setsize(it,'-1 -1 -1', '1 1 1');				
						
					if(it.move_movetype == MOVETYPE_NOCLIP) // level 10 sphere
					{
						it.nextthink = 0;
						set_movetype(it, MOVETYPE_BOUNCE);
						it.solid 	= SOLID_CORPSE;
						it.velocity  = normalize(it.origin - this.origin) *  (200 + (random() * 200)) + ('0 0 150' * (random() * 5));
					}
					else
					{
						set_movetype(it, MOVETYPE_BOUNCE);
						it.solid 	= SOLID_CORPSE;
						it.velocity = normalize(it.origin - this.origin) *  (500 + (random() * 1000)) + ('0 0 150' * (random() * 5));					
					}

					it.avelocity = randomvec() * 720;
				});
			}
			else
				this.nextthink = time + 0.05;

			this.count -= 1;
			break;
		}

		case CORE_DEAD:
		{
			// poor thing
			break;
		}

		default: // this should never happen
		{
			LOG_DEBUG("dotc_CoreThink(): Core exists with no status?\n");
			break;
		}
	}
}

void dotc_DelayedCoreSetup(entity this) // called after a core is placed on a map by dotc_CoreSetup()
{
	// bot waypoints
	waypoint_spawnforitem_force(this, this.origin);
	this.nearestwaypointtimeout = 0; // activate waypointing again
	this.bot_basewaypoint = this.nearestwaypoint;

	// waypointsprites
	if(autocvar_g_dotc_waypointsprites_cores)
	{
		entity basename = WP_CoreNeutral;

		switch(this.team)
		{
			case NUM_TEAM_1: basename = WP_CoreRed; break;
			case NUM_TEAM_2: basename = WP_CoreBlue; break;
			case NUM_TEAM_3: basename = WP_CoreYellow; break;
			case NUM_TEAM_4: basename = WP_CorePink; break;
		}

		// waypointsprites
		entity wp = WaypointSprite_SpawnFixed(basename, this.origin + CPGEN_WAYPOINT_OFFSET, this, wps_corebase, RADARICON_GENERATOR);
		wp.colormod = ((this.team) ? Team_ColorRGB(this.team) : '1 1 1');
		WaypointSprite_UpdateTeamRadar(this.wps_corebase, RADARICON_GENERATOR, ((this.team) ? colormapPaletteColor(this.team - 1, false) : '1 1 1'));
		//WaypointSprite_UpdateRule(this.wps_corebase, this.team, SPRITERULE_TEAMPLAY);
		WaypointSprite_UpdateMaxHealth(this.wps_corebase, this.max_health);
		WaypointSprite_UpdateHealth(this.wps_corebase, GetResourceAmount(this, RESOURCE_HEALTH));
	}

	// set initial level
	dotc_Core_SetLevel(this, 1, true);

	// prediction
	CSQCMODEL_AUTOINIT(this);
}

void dotc_CoreSetup(int teamnumber, entity this) // called when spawning a core entity on the map as a spawnfunc 
{
	// main setup
	this.dotc_worldcorenext = dotc_worldcorelist; // link core into dotc_worldcorelist
	dotc_worldcorelist = this;

	setattachment(this, NULL, "");

	this.netname = strzone((this.netname == "") ? strcat(dotc_TeamColoredName(teamnumber), " core") : this.netname);
	this.team = teamnumber;
	this.classname = "dotc_core";
	this.solid = SOLID_BSP;
	this.takedamage = DAMAGE_AIM;
	this.dotc_status = CORE_IDLE;
	this.dotc_corelevel = 0;
	this.dotc_nextlevel = 100;
	SetResourceAmountExplicit(this, RESOURCE_HEALTH, ((!GetResourceAmount(this, RESOURCE_HEALTH)) ? ((!autocvar_g_dotc_core_health) ? 1000 : autocvar_g_dotc_core_health) : GetResourceAmount(this, RESOURCE_HEALTH)));
	this.max_health = GetResourceAmount(this, RESOURCE_HEALTH);
	this.event_damage = dotc_CoreDamage;
	this.velocity = '0 0 0';
	this.reset = dotc_CoreReset;
	setthink(this, dotc_CoreThink);
	this.nextthink = time + DOTC_CORE_THINKRATE;
	this.colormap = 1024 + (teamnumber - 1) * 17;
	this.dotc_targetflags = DOTC_TARGET_DRONES;
	this.dotc_unittype 	= DOTC_UF_BUILDING;

	this.snd_core_upgrade = strzone(SND(DOTC_CORE_LEVEL(this.team)));
	
	// core placement
	if((this.spawnflags & 1) || this.noalign) // don't drop to floor, just stay at fixed location
	{
		this.noalign = true;
		set_movetype(this, MOVETYPE_NONE);
	}
	else // drop to floor, automatically find a platform and set that as spawn origin
	{
		this.noalign = false;
		droptofloor(this);

		set_movetype(this, MOVETYPE_NONE);
	}

	InitializeEntity(this, dotc_DelayedCoreSetup, INITPRIO_SETLOCATION);
}


// Debugging
MUTATOR_HOOKFUNCTION(dotc, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);

	if(cmd_name == "set_corelevel")
	{
		if(argv(1) == "" || argv(2) == "")
		{
			LOG_INFO("Both team and level need to be set.");
			return true;
		}

		int forteam = Team_ColorToTeam(argv(1));
		int tolevel = stoi(argv(2));
		entity core = dotc_GetCore(forteam);
		dotc_Core_SetLevel(core, tolevel, true);
		return true;
	}
}


// ===============
// Spawn functions
// ===============

spawnfunc(dotc_core)
{
	if(!g_dotc) { delete(this); return; }

	dotc_CoreSetup(this.team, this);
}

// team based spawns
spawnfunc(dotc_core_red)
{
	if(!g_dotc) { delete(this); return; }
	this.team = NUM_TEAM_1;
	spawnfunc_dotc_core(this);
}

spawnfunc(dotc_core_blue)
{
	if(!g_dotc) { delete(this); return; }
	this.team = NUM_TEAM_2;
	spawnfunc_dotc_core(this);
}

// compatibility with old spawns
spawnfunc(dotc_red_core) { spawnfunc_dotc_core_red(this); }
spawnfunc(dotc_blue_core) { spawnfunc_dotc_core_blue(this); }
