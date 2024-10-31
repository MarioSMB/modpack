#include "changelevel.qh"

#ifdef SVQC

// list of maps that require clips to be functional, as the engine currently has collision issues
// some default fallbacks that are known to be broken without it
string autocvar_sv_quake_clippedmaps = "cchorde1 eod4 eod7 targstart targ1m1 targ1m2 targ1m3 rj7_ish";
bool autocvar_sv_quake_clipfix = false;

int autocvar_noexit;

bool changelevel_waypointsprite_visible_for_player(entity this, entity player, entity view)
{
	if(gameover || intermission_running)
		return false;
	return (this.owner.chlevel_found && this.wp_extra > 0);
}

bool changelevel_checkinlist(string map_name, string list)
{
	if (map_name == "" || list == "")
		return false;

	return (strstrofs(list, map_name, 0) >= 0);
}

void changelevel_think(entity this)
{
	this.nextthink = time + 0.1;
	if(this.sprite && time > this.wait)
	{
		float oldextra = this.sprite.wp_extra;
		float oldextra2 = this.sprite.wp_extra2;
		this.wait = time + 1; // no need to do this often
		int plnum = 0;
		int realplnum = 0;
		// let's not count bots
		FOREACH_CLIENT(IS_REAL_CLIENT(it) && IS_PLAYER(it),
		{
			++realplnum;
			if(it.chlevel_targ == this)
				++plnum;
		});
		float themin = min(1.0, this.count);
		this.sprite.wp_extra = plnum;
		this.sprite.wp_extra2 = ceil(realplnum * themin);
		if(this.sprite.wp_extra != oldextra || this.sprite.wp_extra2 != oldextra2)
			this.sprite.SendFlags |= 1; // force an update
	}
	//if(this.sprite)
	//{
		//WaypointSprite_UpdateMaxHealth(e, carrier.max_health);
        //WaypointSprite_UpdateHealth(e, carrier.health);
	//}
}

// qdoom-specific hack to allow delayed exit on e1m8_q1
.float chlevel_delay;
void changelevel_touch(entity this, entity toucher)
{
	// simply don't react if a non-player triggers it
	if(!IS_PLAYER(toucher))
		return;
	if(this.active != ACTIVE_ACTIVE)
		return;
	if(this.customflags & CFL_LOCKED)
		return;

	if((autocvar_noexit == 1) ||((autocvar_noexit == 2) &&(mapname != "start" && mapname != "hipstart" && mapname != "rstart" && mapname != "aopstart" && mapname != "mgstart" && mapname != "quake")))
	{
		T_Damage(toucher, this, this, 50000, DEATH_NOEXIT.m_id);
		return;
	}

	if(!fexists(strcat("maps/", this.map, ".bsp")))
		return;

	// qdoom compatibility
	if(this.delay)
	{
		this.chlevel_delay = time + this.delay;
		this.delay = 0;
		return;
	}
	else if(time < this.chlevel_delay)
		return;

	toucher.chlevel_targ = this;

	int plnum = 0;
	int realplnum = 0;
	// let's not count bots
	FOREACH_CLIENT(IS_REAL_CLIENT(it) && IS_PLAYER(it),
	{
		++realplnum;
		if(it.chlevel_targ == this || (it.chlevel_targ && it.chlevel_targ.map == this.map))
			++plnum;
	});
	if(!this.chlevel_found && realplnum > 1)
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_CENTER, CENTER_EXIT_FOUND, toucher.netname);
		FOREACH_ENTITY_CLASS("trigger_changelevel", it.map == this.map,
		{
			it.chlevel_found = true;
		});
	}
	this.chlevel_found = true;

	float themin = min(1.0, this.count);
	if(plnum < ceil(realplnum * themin)) // 70% of players
		return;

	if(coop || deathmatch)
		bprintf("%s exited the level\n", toucher.netname);

	nextmap = this.map;
	intermissiontext = this.endtext;
	if(world.model == "maps/mgend.bsp")
	{
		//Finished the whole pack, clear the runes.
		serverflags = 0;
	}

	SUB_UseTargetsSilent(this, toucher, NULL);

	// massive hack to work around collision issues!
	if(autocvar_sv_quake_clipfix)
	{
		if(changelevel_checkinlist(this.map, autocvar_sv_quake_clippedmaps))
			cvar_set("mod_q1bsp_polygoncollisions", "0");
		else
			cvar_set("mod_q1bsp_polygoncollisions", "1");
	}

	if(this.spawntarget && this.spawntarget != "")
		cvar_set("_spawntarget", MakeConsoleSafe(this.spawntarget));
	else
		cvar_set("_spawntarget", "");

	// coded fix for aop's lack of a spawnflag
	if(((this.spawnflags & NO_INTERMISSION) || mapname == "aopstart") &&(deathmatch == 0) && (!this.endtext || this.endtext == ""))
	{
		GotoNextMap();
		settouch(this, func_null);
		return;
	}
	
	settouch(this, func_null);

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	setthink(this, execute_changelevel);
	this.nextthink = time;
}

void changelevel_use(entity this, entity actor, entity trigger)
{
	this.active = ACTIVE_ACTIVE;
	force_retouch = 2;
}

/*
QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.
Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
spawnfunc(trigger_changelevel)
{
	if(!this.map || this.map == "")
	{
		objerror(this, "changelevel trigger doesn't have map");
		return;
	}

	// hack: any maps that aren't the main campaign auto redirect to our hub instead
	if(this.map == "start")
	{
		if(world.model != "maps/quake.bsp" && world.model != "maps/e1m7.bsp" && world.model != "maps/e2m6.bsp" && world.model != "maps/e3m6.bsp" && world.model != "maps/e4m7.bsp")
			this.map = "quake";
	}

	this.killstring = " tried to leave";

	if(this.targetname && this.targetname != "" && !IsMGMap())
	{
		this.use = changelevel_use;
		this.active = ACTIVE_NOT;
	}
	else
		this.active = ACTIVE_ACTIVE;

	InitTrigger(this);
	settouch(this, changelevel_touch);
	if(!this.count) { this.count = 0.7; }

	setthink(this, changelevel_think);
	this.nextthink = time + 0.1;

	WaypointSprite_SpawnFixed(WP_Exit, (this.absmin + this.absmax) * 0.5, this, sprite, NULL);
	this.sprite.waypointsprite_visible_for_player = changelevel_waypointsprite_visible_for_player;
}

#endif
