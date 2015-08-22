REGISTER_MUTATOR(rvehicles, cvar("g_random_vehicles") && cvar("g_vehicles"));

MUTATOR_HOOKFUNCTION(rvehicles, OnEntityPreSpawn)
{
	if(startsWith(self.classname, "vehicle_"))
	{
		entity e = spawn(), oldself = self;
		float i;
		e.classname = self.classname;
		setorigin(e, self.origin);
		e.angles = self.angles;
		e.team = self.team;
		e.target = self.target;
		e.targetname = self.targetname;
		self = e;
		RandomSelection_Init();
		for(i = VEH_FIRST; i <= VEH_LAST; ++i)
		{
			tracebox(self.origin, (get_vehicleinfo(i)).mins * 1.1, (get_vehicleinfo(i)).maxs * 1.1, self.origin, MOVE_NORMAL, self);
			if(trace_fraction == 1.0 && !trace_startsolid)
			{
				if(i == VEH_RAPTOR) // temp hack
				{
					traceline(self.origin, self.origin + '0 0 700', MOVE_NOMONSTERS, self);
					if(!(trace_fraction == 1.0 && !trace_startsolid))
						continue;
				}
				RandomSelection_Add(world, i, string_null, 1, 1);
			}
		}

		if(!vehicle_initialize(RandomSelection_chosen_float, false)) { self = oldself; remove(e); return false; }
		self = oldself;
		return true;
	}

	return false;
}
