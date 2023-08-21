#ifdef SVQC

// list of maps that require clips to be functional, as the engine currently has collision issues
// some default fallbacks that are known to be broken without it
string autocvar_sv_quake_clippedmaps = "cchorde1 eod4 eod7 targstart targ1m1 targ1m2 targ1m3";

int autocvar_noexit;

bool changelevel_checkinlist(string map_name, string list)
{
	if (map_name == "" || list == "")
		return false;

	return (strstrofs(list, map_name, 0) >= 0);
}

.entity chlevel_targ;
void changelevel_touch(entity this, entity toucher)
{
	// simply don't react if a non-player triggers it
	if(!IS_PLAYER(toucher))
		return;

	if((autocvar_noexit == 1) ||((autocvar_noexit == 2) &&(mapname != "start" && mapname != "hipstart" && mapname != "rstart" && mapname != "aopstart" && mapname != "mgstart" && mapname != "quake")))
	{
		T_Damage(toucher, this, this, 50000, DEATH_NOEXIT.m_id);
		return;
	}

	if(!fexists(strcat("maps/", this.map, ".bsp")))
		return;

	toucher.chlevel_targ = this;

	int plnum = 0;
	int realplnum = 0;
	// let's not count bots
	FOREACH_CLIENT(IS_REAL_CLIENT(it),
	{
		++realplnum;
		if(it.chlevel_targ == this)
			++plnum;
	});
	float themin = min(1.0, this.count);
	if(plnum < ceil(realplnum * themin)) // 70% of players
		return;

	if(coop || deathmatch)
		bprintf("%s exited the level\n", toucher.netname);

	nextmap = this.map;
	if(MP_MG)
		intermissiontext = this.endtext;
	if(MP_MG && world.model == "maps/mgend.bsp")
	{
		//Finished the whole pack, clear the runes.
		serverflags = 0;
	}

	SUB_UseTargets(this, toucher, NULL);

	// massive hack to work around collision issues!
	if(changelevel_checkinlist(this.map, autocvar_sv_quake_clippedmaps))
		cvar_set("mod_q1bsp_polygoncollisions", "0");
	else
		cvar_set("mod_q1bsp_polygoncollisions", "1");

	// coded fix for aop's lack of a spawnflag
	if(((this.spawnflags & NO_INTERMISSION) || mapname == "aopstart") &&(deathmatch == 0) && (!MP_MG || (!this.endtext || this.endtext == "")))
	{
		GotoNextMap();
		settouch(this, func_null);
		return;
	}
	
	settouch(this, func_null);

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	setthink(this, execute_changelevel);
	this.nextthink = time + 0.1;
}

/*
QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.
Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
spawnfunc(trigger_changelevel)
{
	if(!this.map || this.map == "")
		objerror(this, "changelevel trigger doesn't have map");

	this.killstring = " tried to leave";

	InitTrigger(this);
	settouch(this, changelevel_touch);
	if(!this.count) { this.count = 0.7; }
}

#endif
