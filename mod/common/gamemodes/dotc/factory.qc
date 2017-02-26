AUTOCVAR(g_dotc_waypointsprites_factories, bool, true, "");
AUTOCVAR(g_dotc_factory_health, int, 5000, "");
AUTOCVAR(g_dotc_factory_squads, int, 5, "");
AUTOCVAR(g_dotc_factory_wait, float, 3, "");


// =========================
// Drone squad pathing setup
// =========================

IntrusiveList g_dotc_dronepaths;
STATIC_INIT(g_dotc_dronepaths) { g_dotc_dronepaths = IL_NEW(); }

void dotc_DronePathThink(entity this)
{
	this.nextthink = time + 0.25;

	if(!round_handler_IsRoundStarted())
		return;

	// debug tracer to show the alignment of paths
	if(autocvar_developer)
	{
		IL_EACH(g_dotc_dronepaths, it != this && it.target == this.targetname,
		{
			te_lightning1(this, this.origin, it.origin);
		});
	}
}

void dotc_DronePathSetup(entity this)
{
	set_movetype(this, MOVETYPE_NONE);
	setthink(this, dotc_DronePathThink);
	this.nextthink = time + 1;

	IL_PUSH(g_dotc_dronepaths, this);

	setorigin(this, this.origin + DOTC_FACTORY_SPAWN_OFFSET);

	// path placement
	if((this.spawnflags & 1) || this.noalign) // don't drop to floor, just stay at fixed location
	{
		this.noalign = true;
	}
	else // drop to floor, automatically find a platform and set that as spawn origin
	{
		this.noalign = false;
		droptofloor(this);
	}
}

spawnfunc(dotc_dronepath)
{
	if(!g_dotc) { delete(this); return; }

	dotc_DronePathSetup(this);
}


// ==================
// Main factory setup
// ==================

void dotc_Factory_DeadThink(entity this)
{
	this.deadflag = DEAD_DEAD;
	setmodel(this, MDL_Null);
	CSQCMODEL_AUTOUPDATE(this);
}

void dotc_Factory_Dead(entity this)
{
	this.deadflag 	= DEAD_DYING;
	setthink(this, dotc_Factory_DeadThink);
	this.nextthink 	= time;
	this.event_damage = func_null;

	Send_Effect(EFFECT_EXPLOSION_BIG, this.origin, '0 0 0', 1);
	sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);

	if(this.wps_factorybase)
		WaypointSprite_Disown(this.wps_factorybase, waypointsprite_deadlifetime);
}

void dotc_FactoryDamage(entity this, entity inflictor, entity attacker, float damage, int deathtype, vector hitloc, vector force)
{	
	if(DOTC_FFCHECK(this, attacker)) { return; }
	
	this.health -= damage;

	if(this.wps_factorybase)
		WaypointSprite_UpdateHealth(this.wps_factorybase, this.health);

	if (this.health <= 0)
	{
		if(IS_CLIENT(attacker))
		{
			PlayerScore_Add(attacker, SP_SCORE, autocvar_g_dotc_factory_killscore);  
			PlayerScore_Add(attacker, SP_DOTC_FACTORY_KILLS, 1);  
		}
			
		dotc_Factory_Dead(this);
	}
	else if(DIFF_TEAM(this, attacker))
		this.dmgtime = time + 1;
}

void dotc_FactoryThink(entity this)
{
	if(game_stopped)
	{
		WaypointSprite_Kill(this.wps_factorybase);
		return;
	}
	
	this.nextthink = time + DOTC_FACTORY_THINKRATE;

	if(!round_handler_IsRoundStarted())
		return;

	entity core = dotc_GetCore(this.team);
	if(core.floodcontrol_chat < time && this.dmgtime > time)
	{
		core.floodcontrol_chat = time + 3;

		Send_Notification(NOTIF_TEAM, this, MSG_CENTER, CENTER_DOTC_FACTORY_UNDERATTACK);
		
		play2team(this.team, SND(DOTC_FACTORY_ATTACK));
	}

	if(this.cnt < this.count && this.lip <= time)
	{
		dotc_spawn_dronesquad(this, this.enemy.origin, this.enemy);
		this.lip = time + this.wait;
		this.cnt += 1;

	}

	CSQCMODEL_AUTOUPDATE(this);
}

void dotc_SpawnWaypoints(entity this)
{
	if(autocvar_g_dotc_waypointsprites_factories)
	{
		entity basename = WP_FactoryNeutral;

		switch(this.team)
		{
			case NUM_TEAM_1: basename = WP_FactoryRed; break;
			case NUM_TEAM_2: basename = WP_FactoryBlue; break;
			case NUM_TEAM_3: basename = WP_FactoryYellow; break;
			case NUM_TEAM_4: basename = WP_FactoryPink; break;
		}

		// waypointsprites
		entity wp = WaypointSprite_SpawnFixed(basename, this.origin + DOTC_FACTORY_WAYPOINT_OFFSET, this, wps_factorybase, RADARICON_FACTORY);
		wp.colormod = ((this.team) ? Team_ColorRGB(this.team) : '1 1 1');
		WaypointSprite_UpdateTeamRadar(this.wps_factorybase, RADARICON_FACTORY, ((this.team) ? colormapPaletteColor(this.team - 1, false) : '1 1 1'));
		WaypointSprite_UpdateRule(this.wps_factorybase, this.team, SPRITERULE_TEAMPLAY);
		WaypointSprite_UpdateMaxHealth(this.wps_factorybase, this.max_health);
		WaypointSprite_UpdateHealth(this.wps_factorybase, this.health);

		this.wps_factorybase.fade_rate = 4500;
		this.wps_factorybase.SendFlags |= 16;
	}
}

void dotc_FactoryReset(entity this)
{
	this.event_damage 	= dotc_FactoryDamage;
	this.deadflag 		= DEAD_NO;
	setthink(this, dotc_FactoryThink);
	this.nextthink 		= time;
	this.health 		= this.max_health;

	if(this.wps_factorybase)
	{
		WaypointSprite_UpdateHealth(this.wps_factorybase, this.health);
		this.wps_factorybase.team = 0;
		this.wps_factorybase.SendFlags |= 1;
	}
	else
		dotc_SpawnWaypoints(this);

	setmodel(this, MDL_DOTC_FACTORY);
	fix_mins_maxs_for_rotating(this);

	CSQCMODEL_AUTOUPDATE(this);
}

entity dotc_squad_nextpath(entity curpath);
void dotc_DelayedFactorySetup(entity this) // called after a factory is placed on a map by dotc_FactorySetup()
{
	// bot waypoints
	waypoint_spawnforitem_force(this, this.origin);
	this.nearestwaypointtimeout = 0; // activate waypointing again
	this.bot_basewaypoint = this.nearestwaypoint;

	// node target
	entity next_node = dotc_squad_nextpath(this);
	if(!next_node)
		LOG_DEBUG("Warning: factory is missing a target, fix your map!\n");

	this.enemy = next_node;

	// waypointsprites
	dotc_SpawnWaypoints(this);

	// prediction
	CSQCMODEL_AUTOINIT(this);
}

void dotc_FactorySetup(int teamnumber, entity this) // called when spawning a factory entity on the map as a spawnfunc 
{
	// main setup
	this.dotc_worldfactorynext = dotc_worldfactorylist; // link factory into dotc_worldfactorylist
	dotc_worldfactorylist = this;

	setattachment(this, NULL, "");
	setmodel(this, MDL_DOTC_FACTORY);
	fix_mins_maxs_for_rotating(this);

	this.netname = strzone((this.netname == "") ? strcat(dotc_TeamColoredName(teamnumber), " drone factory") : this.netname);
	this.team = teamnumber;
	this.classname = "dotc_factory";
	this.solid = SOLID_BSP;
	this.takedamage = DAMAGE_AIM;
	this.health = ((!this.health) ? ((!autocvar_g_dotc_factory_health) ? 500 : autocvar_g_dotc_factory_health) : this.health);
	this.max_health = this.health;
	this.event_damage = dotc_FactoryDamage;
	this.velocity = '0 0 0';
	this.reset = dotc_FactoryReset;
	setthink(this, dotc_FactoryThink);
	this.colormap = 1024 + (teamnumber - 1) * 17;
	this.glowmod = (teamnumber) ? Team_ColorRGB(teamnumber) : '1 1 1';
	this.dotc_targetflags = DOTC_TARGET_DRONES;
	this.dotc_unittype 	= DOTC_UF_BUILDING;

	if(!this.count) { this.count = autocvar_g_dotc_factory_squads; }
	if(!this.wait) { this.wait = autocvar_g_dotc_factory_wait; }

	this.nextthink = time + this.wait;
	
	// factory placement
	if((this.spawnflags & 1) || this.noalign) // don't drop to floor, just stay at fixed location
		this.noalign = true;
	else // drop to floor, automatically find a platform and set that as spawn origin
	{
		this.noalign = false;
		droptofloor(this);
	}

	set_movetype(this, MOVETYPE_NONE);

	InitializeEntity(this, dotc_DelayedFactorySetup, INITPRIO_SETLOCATION);
}


// ===============
// Spawn functions
// ===============

spawnfunc(dotc_factory)
{
	if(!g_dotc) { delete(this); return; }

	dotc_FactorySetup(this.team, this);
}

// compatibility spawns
spawnfunc(dotc_dronefactory) { spawnfunc_dotc_factory(this); }
spawnfunc(dotc_factory_red) { this.team = NUM_TEAM_1; spawnfunc_dotc_factory(this); }
spawnfunc(dotc_factory_blue) { this.team = NUM_TEAM_2; spawnfunc_dotc_factory(this); }
spawnfunc(dotc_factory_yellow) { this.team = NUM_TEAM_3; spawnfunc_dotc_factory(this); }
spawnfunc(dotc_factory_pink) { this.team = NUM_TEAM_4; spawnfunc_dotc_factory(this); }
spawnfunc(dotc_factory_rogue) { this.team = 0; spawnfunc_dotc_factory(this); }
