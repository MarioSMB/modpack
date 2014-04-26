#include "all.qh"

// VEHICLE PLUGIN SYSTEM
entity vehicle_info[VEH_MAXCOUNT];
entity dummy_vehicle_info;

void vehicles_common_initialize()
{
#ifdef CSQC
	precache_model("models/vehicles/bomblet.md3");
	precache_model("models/vehicles/clusterbomb.md3");
	precache_model("models/vehicles/clusterbomb_fragment.md3");
	precache_model("models/vehicles/rocket01.md3");
	precache_model("models/vehicles/rocket02.md3");

	precache_sound ("vehicles/alarm.wav");
	precache_sound ("vehicles/alarm_shield.wav");
#endif // CSQC
#ifdef SVQC
	precache_sound("onslaught/ons_hit2.wav");
	precache_sound("onslaught/electricity_explode.wav");

	addstat(STAT_HUD, AS_INT, hud);
	addstat(STAT_VEHICLESTAT_HEALTH,  AS_INT, vehicle_health);
	addstat(STAT_VEHICLESTAT_SHIELD,  AS_INT, vehicle_shield);
	addstat(STAT_VEHICLESTAT_ENERGY,  AS_INT, vehicle_energy);
	
	addstat(STAT_VEHICLESTAT_W2MODE, AS_INT, vehicle_weapon2mode);

	addstat(STAT_VEHICLESTAT_AMMO1,   AS_INT, vehicle_ammo1);
	addstat(STAT_VEHICLESTAT_RELOAD1, AS_INT, vehicle_reload1);

	addstat(STAT_VEHICLESTAT_AMMO2,   AS_INT, vehicle_ammo2);
	addstat(STAT_VEHICLESTAT_RELOAD2, AS_INT, vehicle_reload2);
#endif // SVQC
}

void register_vehicle(float id, float(float) func, float vehicleflags, vector min_s, vector max_s, string modelname, string headmodelname, string hudmodelname, string headtag, string hudtag, string viewtag, string shortname, string vname)
{
	entity e;
	vehicle_info[id - 1] = e = spawn();
	e.classname = "vehicle_info";
	e.vehicleid = id;
	e.netname = shortname;
	e.vehicle_name = vname;
	e.vehicle_func = func;
	e.mdl = modelname;
	e.spawnflags = vehicleflags;
	e.mins = min_s;
	e.maxs = max_s;
	e.model = modelname;
	e.head_model = headmodelname;
	e.hud_model = hudmodelname;
	e.tag_head = headtag;
	e.tag_hud = hudtag;
	e.tag_view = viewtag;
	
	#ifndef MENUQC
	vehicles_common_initialize();
	#endif
}
float v_null(float dummy) { return 0; }
void register_vehicles_done()
{
	dummy_vehicle_info = spawn();
	dummy_vehicle_info.classname = "vehicle_info";
	dummy_vehicle_info.vehicleid = 0; // you can recognize dummies by this
	dummy_vehicle_info.netname = "";
	dummy_vehicle_info.vehicle_name = "Vehicle";
	dummy_vehicle_info.vehicle_func = v_null;
	dummy_vehicle_info.mdl = "";
	dummy_vehicle_info.mins = '-0 -0 -0';
	dummy_vehicle_info.maxs = '0 0 0';
	dummy_vehicle_info.model = "";
	dummy_vehicle_info.head_model = "";
	dummy_vehicle_info.hud_model = "";
}
entity get_vehicleinfo(float id)
{
	entity m;
	if(id < VEH_FIRST || id > VEH_LAST)
		return dummy_vehicle_info;
	m = vehicle_info[id - 1];
	if(m)
		return m;
	return dummy_vehicle_info;
}
