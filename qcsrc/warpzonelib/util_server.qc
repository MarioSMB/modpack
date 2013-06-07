void WarpZoneLib_MoveOutOfSolid_Expand(entity e, vector by)
{
	float eps = 0.0625;
	tracebox(e.origin, e.mins - '1 1 1' * eps, e.maxs + '1 1 1' * eps, e.origin + by, MOVE_WORLDONLY, e);
	if (trace_startsolid)
		return;
	if (trace_fraction < 1)
	{
		// hit something
		// adjust origin in the other direction...
		setorigin(e,e.origin - by * (1 - trace_fraction));
	}
}

float WarpZoneLib_MoveOutOfSolid(entity e)
{
	vector o, m0, m1;

	o = e.origin;
	traceline(o, o, MOVE_WORLDONLY, e);
	if (trace_startsolid)
		return FALSE;

	tracebox(o, e.mins, e.maxs, o, MOVE_WORLDONLY, e);
	if (!trace_startsolid)
		return TRUE;

	m0 = e.mins;
	m1 = e.maxs;
	e.mins = '0 0 0';
	e.maxs = '0 0 0';
	WarpZoneLib_MoveOutOfSolid_Expand(e, '1 0 0' * m0_x);
	e.mins_x = m0_x;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '1 0 0' * m1_x);
	e.maxs_x = m1_x;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 1 0' * m0_y);
	e.mins_y = m0_y;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 1 0' * m1_y);
	e.maxs_y = m1_y;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 0 1' * m0_z);
	e.mins_z = m0_z;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 0 1' * m1_z);
	e.maxs_z = m1_z;
	setorigin(e, e.origin);

	tracebox(e.origin, e.mins, e.maxs, e.origin, MOVE_WORLDONLY, e);
	if (trace_startsolid)
	{
		setorigin(e, o);
		return FALSE;
	}

	return TRUE;
}

float WarpZoneLib_ExactTrigger_Touch()
{
	return !WarpZoneLib_BoxTouchesBrush(other.absmin, other.absmax, self, other);
}

void WarpZoneLib_ExactTrigger_Init()
{
	vector mi, ma;
	if (self.movedir == '0 0 0')
	if (self.angles != '0 0 0')
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	self.warpzone_isboxy = 1;
 	if(self.model != "")
 	{
		mi = self.mins;
		ma = self.maxs;
 		precache_model(self.model);
 		setmodel(self, self.model);
		// let mapper-set mins/maxs override the model's bounds if set
		if(mi != '0 0 0' || ma != '0 0 0')
		{
			self.mins = mi;
			self.maxs = ma;
		}
		else
			self.warpzone_isboxy = 0; // enable exacttrigger matching
 	}
	setorigin(self, self.origin);
	if(self.scale)
		setsize(self, self.mins * self.scale, self.maxs * self.scale);
	else
		setsize(self, self.mins, self.maxs);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	self.model = "";
}
