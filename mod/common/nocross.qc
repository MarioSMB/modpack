//FEATURE: Command to turn off crosshairs on all players, for an extra challenge

#ifdef GAMEQC
REGISTER_STAT(NOCROSS, BOOL);

REGISTER_MUTATOR(nocross, true);
#endif

#ifdef SVQC
bool nocross_active;

STATIC_INIT_LATE(nocross_setvars)
{
	localcmd("\nalias nocross \"sv_cmd nocross ${* ?}\"\n");
}

MUTATOR_HOOKFUNCTION(nocross, ClientConnect)
{
	entity player = M_ARGV(0, entity);
	if(IS_REAL_CLIENT(player))
		STAT(NOCROSS, player) = nocross_active;
}

MUTATOR_HOOKFUNCTION(nocross, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);

	if(cmd_name == "nocross")
	{
		bool crossitoff = boolean(argv(1) == "");
		FOREACH_CLIENT(IS_REAL_CLIENT(it),
		{
			STAT(NOCROSS, it) = crossitoff;
		});
		nocross_active = crossitoff;
		LOG_INFO("Crosshairs have been forced ", ((crossitoff) ? "off" : "on"));
		return true;
	}
}
#elif defined(CSQC)
MUTATOR_HOOKFUNCTION(nocross, DrawCrosshair)
{
	return STAT(NOCROSS);
}
#endif
