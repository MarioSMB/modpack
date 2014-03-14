MUTATOR_HOOKFUNCTION(rvehicles_OnEntityPreSpawn)
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
			tracebox(self.origin, (get_vehicleinfo(i)).mins, (get_vehicleinfo(i)).mins, self.origin, MOVE_NORMAL, self);
			if(trace_fraction == 1.0 && !trace_startsolid)
				RandomSelection_Add(world, i, string_null, 1, 1);
		}

		if(!vehicle_initialize(RandomSelection_chosen_float, FALSE)) { self = oldself; remove(e); return FALSE; }
		self = oldself;
		return TRUE;
	}

	return FALSE;
}

MUTATOR_DEFINITION(mutator_random_vehicles)
{
	MUTATOR_HOOK(OnEntityPreSpawn, rvehicles_OnEntityPreSpawn, CBC_ORDER_ANY);

	return FALSE;
}
