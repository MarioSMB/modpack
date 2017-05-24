REGISTER_MUTATOR(rvehicles, cvar("g_random_vehicles") && cvar("g_vehicles"));

AUTOCVAR_NOREF(g_random_vehicles, bool, false, _("Enable random vehicles mutator"));

MUTATOR_HOOKFUNCTION(rvehicles, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	if(startsWith(ent.classname, "vehicle_"))
	{
		entity e = spawn();
		e.classname = ent.classname;
		setorigin(e, ent.origin + '0 0 10');
		e.angles = ent.angles;
		e.team = ent.team;
		e.target = ent.target;
		e.targetname = ent.targetname;

		RandomSelection_Init();
		FOREACH(Vehicles, !(it.spawnflags & VHF_PLAYERSLOT), LAMBDA(
			tracebox(e.origin, it.m_mins * 1.1, it.m_maxs * 1.1, e.origin, MOVE_NORMAL, e);
			if(trace_fraction == 1.0 && !trace_startsolid)
			{
				if(it == VEH_RAPTOR) // temp hack
				{
					traceline(e.origin, e.origin + '0 0 700', MOVE_NOMONSTERS, e);
					if(!(trace_fraction == 1.0 && !trace_startsolid))
						continue;
				}
				RandomSelection_AddEnt(it, 1, 1);
			}
		));

		if(!vehicle_initialize(e, RandomSelection_chosen_ent, false)) { delete(e); return false; }
		return true;
	}
}
