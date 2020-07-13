//FEATURE: tp command, so admins can sneak up on troublesome players!

REGISTER_MUTATOR(tp, true);

STATIC_INIT_LATE(tpcmd)
{
	localcmd("\nalias tp \"sv_cmd tp ${* ?}\"\n");
}

MUTATOR_HOOKFUNCTION(tp, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);
	int cmd_argc = M_ARGV(1, int);

	if(cmd_name == "tp")
	{
		entity to = GetIndexedEntity(cmd_argc, 2);
		int accepted = VerifyClientEntity(to, false, false);

		if(accepted <= 0 || !IS_PLAYER(to))
		{
			LOG_INFO("Could not teleport to ", to.netname, "^7.");
			return true;
		}

		string arg = argv(1);
		int team_selection = Team_ColorToTeam(arg);

		if(arg == "all" || arg == "@a")
		{
			int fnd = 0;
			FOREACH_CLIENT(IS_PLAYER(it) && it != to,
			{
				setorigin(it, to.origin);
				it.oldorigin = to.origin;
				it.velocity = '0 0 0';
				it.oldvelocity = '0 0 0';

				++fnd;
			});

			if(!fnd)
				LOG_INFO("Found nobody to teleport...");
			else
				LOG_INFO("Teleported everyone to ", to.netname, "^7.");
		}
		else if(teamplay && Team_IsValidTeam(team_selection))
		{
			int fnd = 0;
			FOREACH_CLIENT(IS_PLAYER(it) && it != to && it.team == team_selection,
			{
				setorigin(it, to.origin);
				it.oldorigin = to.origin;
				it.velocity = '0 0 0';
				it.oldvelocity = '0 0 0';

				++fnd;
			});

			if(!fnd)
				LOG_INFO("Found nobody to teleport...");
			else
				LOG_INFO("Teleported everyone on the ", arg, " team to ", to.netname, "^7.");
		}
		else
		{
			entity from = GetIndexedEntity(cmd_argc, 1);
			accepted = VerifyClientEntity(from, false, false);

			if(accepted > 0)
			{
				setorigin(from, to.origin);
				from.oldorigin = to.origin;
				from.velocity = '0 0 0';
				from.oldvelocity = '0 0 0';

				LOG_INFO("Teleported ", from.netname, " ^7to ", to.netname, "^7.");
			}
			else
				LOG_INFO("Could not teleport ", from.netname, " ^7to ", to.netname, "^7.");
		}

		return true;
	}
}

