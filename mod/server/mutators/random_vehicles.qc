REGISTER_MUTATOR(rvehicles, cvar("g_random_vehicles") && cvar("g_vehicles"));

AUTOCVAR(g_random_vehicles, bool, false, _("Enable random vehicles mutator"));

MUTATOR_HOOKFUNCTION(rvehicles, OnEntityPreSpawn)
{
	if(startsWith(self.classname, "vehicle_"))
	{
		entity e = spawn(), oldself = self;
		e.classname = self.classname;
		setorigin(e, self.origin + '0 0 10');
		e.angles = self.angles;
		e.team = self.team;
		e.target = self.target;
		e.targetname = self.targetname;
		self = e;

		RandomSelection_Init();
		FOREACH(Vehicles, true, LAMBDA(
			tracebox(self.origin, it.mins * 1.1, it.maxs * 1.1, self.origin, MOVE_NORMAL, self);
			if(trace_fraction == 1.0 && !trace_startsolid)
			{
				if(it == VEH_RAPTOR) // temp hack
				{
					traceline(self.origin, self.origin + '0 0 700', MOVE_NOMONSTERS, self);
					if(!(trace_fraction == 1.0 && !trace_startsolid))
						continue;
				}
				RandomSelection_Add(it, 0, string_null, 1, 1);
			}
		));

		if(!vehicle_initialize(RandomSelection_chosen_ent, false)) { self = oldself; remove(e); return false; }
		self = oldself;
		return true;
	}

	return false;
}
