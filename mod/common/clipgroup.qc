// Clip Group implementation in QC

#ifdef GAMEQC
void(vector v1, vector min, vector max, vector v2, float nomonsters, entity forent) tracebox_old = #90;
#ifdef SVQC
void(vector v1, vector v2, float nomonsters, entity forent) traceline_old = #16;
#elif defined(CSQC)
float(vector v1, vector v2, float tryents, entity ignoreentity) traceline_old = #16;
#endif

.float traceclipgroupsolid;
void trace_clipgroup(vector v1, vector min, vector max, vector v2, float nomonsters, entity forent)
{
	bool is_traceline = (min == '0 0 0' && max == '0 0 0');
	if(!forent || !forent.clipgroup || nomonsters == MOVE_NOMONSTERS || nomonsters == MOVE_WORLDONLY)
	{
		// just return a normal tracebox
		if(is_traceline)
			traceline_old(v1, v2, nomonsters, forent);
		else
			tracebox_old(v1, min, max, v2, nomonsters, forent);
		return;
	}

	// save the solidity of all entities with the same clipgroup, then make them nonsolid so trace passes through them
	IL_EACH(g_clipgroup, it != forent && it.clipgroup == forent.clipgroup,
	{
		it.traceclipgroupsolid = it.solid;
		it.solid = SOLID_NOT;
	});

	if(is_traceline)
		traceline_old(v1, v2, nomonsters, forent);
	else
		tracebox_old(v1, min, max, v2, nomonsters, forent);

	// restore their original solidity
	IL_EACH(g_clipgroup, it != forent && it.clipgroup == forent.clipgroup,
	{
		it.solid = it.traceclipgroupsolid;
		it.traceclipgroupsolid = 0;
	});
}

void tracebox_clipgroup(vector v1, vector min, vector max, vector v2, float nomonsters, entity forent)
{
	trace_clipgroup(v1, min, max, v2, nomonsters, forent);
}

#ifdef SVQC
void traceline_clipgroup(vector v1, vector v2, float nomonsters, entity forent)
{
	trace_clipgroup(v1, '0 0 0', '0 0 0', v2, nomonsters, forent);
}
#elif defined(CSQC)
float traceline_clipgroup(vector v1, vector v2, float tryents, entity ignoreentity)
{
	trace_clipgroup(v1, '0 0 0', '0 0 0', v2, tryents, ignoreentity);
	return false; // traceline was never intended to be a float, lame!
}
#endif

STATIC_INIT(clipgroup)
{
	// overwrite the default functions so they apply to our evil hacks!
	tracebox = tracebox_clipgroup;
	traceline = traceline_clipgroup;
}
#endif
