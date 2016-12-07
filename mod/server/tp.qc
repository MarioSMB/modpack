REGISTER_MUTATOR(tp, true);

MUTATOR_HOOKFUNCTION(tp, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);
	int cmd_argc = M_ARGV(1, int);

	if(cmd_name == "tp")
	{
		entity to = GetIndexedEntity(cmd_argc, 2);
		bool accepted = VerifyClientEntity(to, false, false);

		if(accepted <= 0)
		{
			LOG_INFO("Could not teleport to ", to.netname, ".\n");
			return true;
		}

		string arg = argv(1);

		if(arg == "all" || arg == "@a")
		{
			FOREACH_CLIENT(IS_REAL_CLIENT(it) && IS_PLAYER(it) && it != to,
			{
				setorigin(it, to.origin);
				it.oldorigin = to.origin;
				it.velocity = '0 0 0';
				it.oldvelocity = '0 0 0';
			});

			LOG_INFO("Teleported everyone to ", to.netname, ".\n");
		}
		else if(teamplay && (arg == "red" || arg == "blue" || arg == "yellow" || arg == "pink"))
		{
			int tnum = NUM_TEAM_1;
			if(arg == "blue") tnum = NUM_TEAM_2;
			if(arg == "yellow") tnum = NUM_TEAM_3;
			if(arg == "pink") tnum = NUM_TEAM_4;

			FOREACH_CLIENT(IS_REAL_CLIENT(it) && IS_PLAYER(it) && it != to && it.team == tnum,
			{
				setorigin(it, to.origin);
				it.oldorigin = to.origin;
				it.velocity = '0 0 0';
				it.oldvelocity = '0 0 0';
			});

			LOG_INFO("Teleported everyone on the ", arg, " team to ", to.netname, ".\n");
		}
		else
		{
			entity from = GetIndexedEntity(cmd_argc, 1);
			accepted = VerifyClientEntity(from, false, false);

			if(accepted > 0 && IS_PLAYER(to))
			{
				setorigin(from, to.origin);
				from.oldorigin = to.origin;
				from.velocity = '0 0 0';
				from.oldvelocity = '0 0 0';

				LOG_INFO("Teleported ", from.netname, " to ", to.netname, ".\n");
			}
			else
				LOG_INFO("Could not teleport ", from.netname, " to ", to.netname, ".\n");
		}

		return true;
	}
}

