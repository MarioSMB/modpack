AUTOCVAR(sv_demo_recordplayers, bool, false, "Send all player demos to the demo recording server if available, useful for tournaments");
AUTOCVAR(sv_demo_moments, int, 3, "Number of moments per match a player is allowed to 'snap' for recording (if recording is available)");

.int demo_moments;

REGISTER_MUTATOR(demo, true);

MUTATOR_HOOKFUNCTION(demo, MatchEnd)
{
	if(autocvar_sv_demo_recordplayers)
	{
		FOREACH_CLIENT(IS_PLAYER(it),
		{
			stuffcmd(it, strcat("//", strconv(2, 0, 0, GetGametype()), " RECORD ME ", "\n"));
		});
	}

	return false;
}

MUTATOR_HOOKFUNCTION(demo, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	if(cmd_name == "snap")
	{
		if(!IS_PLAYER(self))
		{
			sprint(self, "You need to be a player to use this command.\n");
			return true;
		}
		if(self.demo_moments >= autocvar_sv_demo_moments)
		{
			sprint(self, "You've recorded too many moments, please wait until the next match.\n");
			return true;
		}

		// write it to the demo
		stuffcmd(self, strcat("//", strconv(2, 0, 0, GetGametype()), " EVENT SNAPPED ", ((argv(1)) ? argv(1) : "-1"), " ", ((argv(2)) ? substring(cmd_string, argv_start_index(2), -1) : ""), "\n"));
		self.demo_moments += 1;

		return true;
	}

	return false;
}
