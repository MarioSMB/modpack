//FEATURE: snap command for 'snapping' good moments in matches (places a marker in the demo if you're recording it)

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
}

MUTATOR_HOOKFUNCTION(demo, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	entity caller = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	string cmd_string = M_ARGV(2, string);

	if(cmd_name == "snap")
	{
		if(!IS_PLAYER(caller))
		{
			sprint(caller, "You need to be a player to use this command.\n");
			return true;
		}
		if(caller.demo_moments >= autocvar_sv_demo_moments)
		{
			sprint(caller, "You've recorded too many moments, please wait until the next match.\n");
			return true;
		}

		// write it to the demo
		stuffcmd(caller, strcat("//", strconv(2, 0, 0, GetGametype()), " EVENT SNAPPED ", argv(1), " ", ((argv(2)) ? substring(cmd_string, argv_start_index(2), -1) : ""), "\n"));
		caller.demo_moments += 1;
		return true;
	}
}
