//FEATURE: Command to permanently prevent certain players from voting

REGISTER_MUTATOR(voteban, true);

AUTOCVAR(sv_voteban_list, string, "", "");

MUTATOR_HOOKFUNCTION(voteban, VoteCommand_Parse)
{
	entity caller = M_ARGV(0, entity);
	if(PlayerInList(caller, autocvar_sv_voteban_list))
		return MUT_VOTEPARSE_UNACCEPTABLE;
}

MUTATOR_HOOKFUNCTION(voteban, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);
	int cmd_argc = M_ARGV(1, int);

	if(cmd_name == "voteban")
	{
		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);

		if (accepted > 0)
		{
			string theid = "";
			if(!PlayerInIPList(client, autocvar_sv_voteban_list))
				theid = cons(theid, client.netaddress);
			if(!PlayerInIDList(client, autocvar_sv_voteban_list))
				theid = cons(theid, client.crypto_idfp);
			LOG_INFO(strcat("Vote-banning player ", GetCallerName(client), " (", argv(1), ")."));
			cvar_set("sv_voteban_list", cons(autocvar_sv_voteban_list, theid));
		}
		else
		{
			LOG_INFO("vote-ban failed: ", GetClientErrorString(accepted, argv(1)), ".");
		}

		return true;
	}

	if(cmd_name == "unvoteban")
	{
		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);
		string original_arg = argv(1);

		if (accepted > 0)
		{
			string tmp_string = "";
			FOREACH_WORD(autocvar_sv_voteban_list, it != client.netaddress,
			{
				if(client.crypto_idfp && it == substring(client.crypto_idfp, 0, strlen(it)))
					continue;
				tmp_string = cons(tmp_string, it);
			});

			cvar_set("sv_voteban_list", tmp_string);
			LOG_INFO(strcat("Unvote-banning player ", GetCallerName(client), " (", original_arg, ")."));
		}
		else
		{
			LOG_INFO("vote-ban failed: ", GetClientErrorString(accepted, original_arg), ", attempting to unban by string.");

			string tmp_string = "";
			FOREACH_WORD(autocvar_sv_voteban_list, it != original_arg,
			{
				tmp_string = cons(tmp_string, it);
			});

			cvar_set("sv_voteban_list", tmp_string);
		}
		return true;
	}
}
