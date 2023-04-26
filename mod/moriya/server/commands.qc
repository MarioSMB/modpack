STATIC_INIT(qmod_cmds)
{
	localcmd("\nalias ircmsg \"sv_cmd ircmsg ${* ?}\"\n");
	localcmd("\nalias _ircmessage \"ircmsg ${* ?}\"\n");

	// TODO: multiplayer mission selection
	//localcmd("\nalias missionselect \"sv_cmd missionselect ${* ?}\"\n");
}

void IRCSay(string msgstr)
{
	if(msgstr == "")
		return;

	string prefix;
	if(substring(msgstr, 0, 3) == "^4*") // actions
		prefix = "\{3}";
	else
		prefix = "\{1}";

	msgstr = strcat(prefix, strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint

	FOREACH_CLIENTSLOT(IS_REAL_CLIENT(it),
	{
		sprint(it, msgstr);
	});
}

float VerifyClientEntity(entity client, float must_be_real, float must_be_bots)
{
	if (!IS_CLIENT(client)) return false;
	else if (must_be_real && !IS_REAL_CLIENT(client)) return false;

	return true;
}

// is this entity number even in the possible range of entities?
float VerifyClientNumber(float tmp_number)
{
	if ((tmp_number < 1) || (tmp_number > maxclients)) return false;
	else return true;
}

// keep track of the next token to use for argc
float next_token;
entity GetIndexedEntity(float argc, float start_index)
{
	entity selection;
	float tmp_number, index;
	string tmp_string;

	next_token = -1;
	index = start_index;
	selection = NULL;

	if (argc > start_index)
	{
		if (substring(argv(index), 0, 1) == "#")
		{
			tmp_string = substring(argv(index), 1, -1);
			++index;

			if (tmp_string != "")  // is it all one token? like #1
			{
				tmp_number = stof(tmp_string);
			}
			else if (argc > index)  // no, it's two tokens? # 1
			{
				tmp_number = stof(argv(index));
				++index;
			}
			else
			{
				tmp_number = 0;
			}
		}
		else  // maybe it's ONLY a number?
		{
			tmp_number = stof(argv(index));
			++index;
		}

		if (VerifyClientNumber(tmp_number))
		{
			selection = edict_num(tmp_number);  // yes, it was a number
		}
		else  // no, maybe it's a name?
		{
			FOREACH_CLIENT(true, LAMBDA(
				if(strdecolorize(it.netname) == strdecolorize(argv(start_index)))
				{
					selection = it;
					break; // no reason to keep looking
				}
			));

			index = (start_index + 1);
		}
	}

	next_token = index;
	// print(strcat("start_index: ", ftos(start_index), ", next_token: ", ftos(next_token), ", edict: ", ftos(num_for_edict(selection)), ".\n"));
	return selection;
}

void cmd_stuffto(float argc)
{
	// This... is a fairly dangerous and powerful command... - It allows any arguments to be sent to a client via rcon.
	// Because of this, it is disabled by default and must be enabled by the server owner when doing compilation. That way,
	// we can be certain they understand the risks of it... So to enable, compile server with -DSTUFFTO_ENABLED argument.

#ifdef STUFFTO_ENABLED
	if (argv(2))
	{
		entity client = GetIndexedEntity(argc, 1);
		float accepted = VerifyClientEntity(client, true, false);

		if (accepted > 0)
		{
			stuffcmd(client, strcat("\n", argv(next_token), "\n"));
			LOG_INFO(strcat("Command: \"", argv(next_token), "\" sent to ", client.netname, " (", argv(1), ").\n"));
		}
		else
		{
			LOG_INFO("stuffto: failed.\n");
		}

		return;
	}
#else
	LOG_INFO("stuffto command is not enabled on this server.\n");
	return;
#endif
}

void GameCommand(string command)
{
	float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	string cmdname = strtolower(argv(0));

	if(cmdname == "cvar_purechanges")
	{
		LOG_INFO(cvar_purechanges, "\n");
		return;
	}

	if(cmdname == "cvar_changes")
	{
		LOG_INFO(cvar_changes, "\n");
		return;
	}

	if(cmdname == "banlist")
	{
		LOG_INFO("Banning is currently not implemented, sorry Melanobot\n");
		return;
	}

	if(cmdname == "ircmsg")
	{
		IRCSay(substring(command, strlen(argv(0)) + 1, strlen(command)));
		return;
	}

	if(cmdname == "find")
	{
		FOREACH_ENTITY_CLASS_ORDERED(argv(1), true, LOG_INFOF("%i (%s)\n", it, it.classname));
		return;
	}

	if(cmdname == "stuffto")
	{
		cmd_stuffto(argc);
		return;
	}

	if(cmdname == "info")
	{
		string thecmd = cvar_string(strcat("sv_info_", argv(1)));

		if (thecmd) wordwrap_sprint(NULL, thecmd, 1000);
		else LOG_INFO("ERROR: unsupported info command");
		return;
	}

	// nothing above caught the command, must be invalid
	LOG_INFO(((command != "") ? strcat("Unknown server command \"", command, "\"") : "No command provided"), ".\n");
}
