#include "all.qh"

// TURRET PLUGIN SYSTEM
entity turret_info[TUR_MAXCOUNT];
entity dummy_turret_info;

void turrets_common_precache()
{
	precache_sound ("weapons/rocket_impact.wav");
	precache_model ("models/turrets/base-gib1.md3");
	precache_model ("models/turrets/base-gib2.md3");
	precache_model ("models/turrets/base-gib3.md3");
	precache_model ("models/turrets/base-gib4.md3");
	precache_model ("models/turrets/head-gib1.md3");
	precache_model ("models/turrets/head-gib2.md3");
	precache_model ("models/turrets/head-gib3.md3");
	precache_model ("models/turrets/head-gib4.md3");
	precache_model ("models/turrets/terrainbase.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/rocket.md3");
	
	precache_model ("models/turrets/c512.md3");
	precache_model ("models/marker.md3");
	
#ifdef TURRET_DEBUG
	precache_model ("models/turrets/c512.md3");
	precache_model ("models/pathlib/goodsquare.md3");
	precache_model ("models/pathlib/badsquare.md3");
	precache_model ("models/pathlib/square.md3");
	precache_model ("models/pathlib/edge.md3");
#endif
}

void register_turret(float id, float(float) func, float turretflags, vector min_s, vector max_s, string modelname, string headmodelname, string shortname, string mname)
{
	entity e;
	turret_info[id - 1] = e = spawn();
	e.classname = "turret_info";
	e.turretid = id;
	e.netname = shortname;
	e.turret_name = mname;
	e.turret_func = func;
	e.mdl = modelname;
	e.cvar_basename = shortname;
	e.spawnflags = turretflags;
	e.mins = min_s;
	e.maxs = max_s;
	e.model = strzone(strcat("models/turrets/", modelname));
	e.head_model = strzone(strcat("models/turrets/", headmodelname));
	
	#ifndef MENUQC
	turrets_common_precache();
	#endif
}
float t_null(float dummy) { return 0; }
void register_turrets_done()
{
	dummy_turret_info = spawn();
	dummy_turret_info.classname = "turret_info";
	dummy_turret_info.turretid = 0; // you can recognize dummies by this
	dummy_turret_info.netname = "";
	dummy_turret_info.turret_name = "Turret";
	dummy_turret_info.turret_func = t_null;
	dummy_turret_info.mdl = "";
	dummy_turret_info.mins = '-0 -0 -0';
	dummy_turret_info.maxs = '0 0 0';
	dummy_turret_info.model = "";
}
entity get_turretinfo(float id)
{
	entity m;
	if(id < TUR_FIRST || id > TUR_LAST)
		return dummy_turret_info;
	m = turret_info[id - 1];
	if(m)
		return m;
	return dummy_turret_info;
}
