// footstep interval
.float nextstep;

MUTATOR_HOOKFUNCTION(footsteps_PlayerPhysics)
{
	if(self.flags & FL_ONGROUND)
	if(IS_PLAYER(self)) // no fall sounds for observers thank you very much
	if(self.wasFlying)
	{
		self.wasFlying = 0;

		if(self.waterlevel < WATERLEVEL_SWIMMING)
		if(time >= self.ladder_time)
		if not(self.hook)
		{
			self.nextstep = time + 0.3 + random() * 0.1;
			trace_dphitq3surfaceflags = 0;
			tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 1', MOVE_NOMONSTERS, self);
			if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS)
			{
				if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_METALSTEPS)
					GlobalSound(globalsound_metalfall, CH_PLAYER, VOICETYPE_PLAYERSOUND);
				else
					GlobalSound(globalsound_fall, CH_PLAYER, VOICETYPE_PLAYERSOUND);
			}
		}
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(footsteps_StartFrame)
{
	entity oldself = self;
	
	if(gameover)
		return FALSE;
	
	for(self = world; (self = findfloat(self, damagedbycontents, TRUE)); )
	{
		float velocity_len = vlen(self.velocity);
		// play stupid sounds
		if (self.flags & FL_ONGROUND)
		if (velocity_len > autocvar_sv_maxspeed * 0.6)
		if (!self.deadflag)
		if (time < self.lastground + 0.2)
		{
			if((time > self.nextstep) || (time < (self.nextstep - 10.0)))
			{
				self.nextstep = time + 0.3 + random() * 0.1;
				trace_dphitq3surfaceflags = 0;
				tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 1', MOVE_NOMONSTERS, self);
				if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS)
				{
					if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_METALSTEPS)
						GlobalSound(globalsound_metalstep, CH_PLAYER, VOICETYPE_PLAYERSOUND);
					else
						GlobalSound(globalsound_step, CH_PLAYER, VOICETYPE_PLAYERSOUND);
				}
			}
		}
	}
	self = oldself;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(footsteps_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Footsteps");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_footsteps)
{
	MUTATOR_HOOK(PlayerPhysics, footsteps_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(SV_StartFrame, footsteps_StartFrame, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, footsteps_BuildMutatorsString, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		PrecacheGlobalSound((globalsound_step = "misc/footstep0 6"));
        PrecacheGlobalSound((globalsound_metalstep = "misc/metalfootstep0 6"));
	}

	return FALSE;
}
