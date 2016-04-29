REGISTER_MUTATOR(muteban, true);

AUTOCVAR(sv_muteban_list, string, "", "");

MUTATOR_HOOKFUNCTION(muteban, ClientConnect)
{SELFPARAM();
	if(strhasword(autocvar_sv_muteban_list, self.crypto_idfp) || strhasword(autocvar_sv_muteban_list, self.netaddress))
		self.muted = true;

	return false;
}

MUTATOR_HOOKFUNCTION(muteban, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	if(cmd_name == "muteban")
	{
		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);

		if (accepted > 0)
		{
			string with_crypto = ((client.crypto_idfp != "") ? strcat(" ", client.crypto_idfp) : "");

			cvar_set("sv_muteban_list", strcat(autocvar_sv_muteban_list, with_crypto, " ", client.netaddress));
			client.muted = true;
			LOG_INFO(strcat("Mute-banning player ", GetCallerName(client), " (", argv(1), ").\n"));
		}
		else
		{
			LOG_INFO("mute-ban failed: ", GetClientErrorString(accepted, argv(1)), ".\n");
		}

		return true;
	}

	if(cmd_name == "unmuteban")
	{
		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);
		string original_arg = argv(1);

		if (accepted > 0)
		{
			int argc = tokenizebyseparator(autocvar_sv_muteban_list, " ");

			string tmp_string = "";
			for(int i = 0; i < argc; ++i)
				if(argv(i) != client.netaddress && argv(i) != client.crypto_idfp)
					tmp_string = strcat(tmp_string, " ", argv(i));

			tmp_string = substring(tmp_string, 1, strlen(tmp_string) - 1);
			cvar_set("sv_muteban_list", tmp_string);
			LOG_INFO(strcat("Unmuting player ", GetCallerName(client), " (", original_arg, ").\n"));
			client.muted = false;
		}
		else
		{
			LOG_INFO("mute-ban failed: ", GetClientErrorString(accepted, original_arg), ", attempting to unban by string.\n");

			int argc = tokenizebyseparator(autocvar_sv_muteban_list, " ");

			string tmp_string = "";
			for(int i = 0; i < argc; ++i)
				if(argv(i) != original_arg)
					tmp_string = strcat(tmp_string, " ", argv(i));

			tmp_string = substring(tmp_string, 1, strlen(tmp_string) - 1);
			cvar_set("sv_muteban_list", tmp_string);
		}
		return true;
	}

	return false;
}
