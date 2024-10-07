#include "command/banning.qh"

STATIC_INIT(qmod_cmds)
{
	localcmd("\nalias ircmsg \"sv_cmd ircmsg ${* ?}\"\n");
	localcmd("\nalias _ircmessage \"ircmsg ${* ?}\"\n");
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

void PrintToChatAll(string text);

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

	if (BanCommand(argc, command))
	{
		return;  // handled by server/command/banning.qc
	}

	if(cmdname == "ircmsg")
	{
		IRCSay(substring(command, strlen(argv(0)) + 1, strlen(command)));
		return;
	}

	if(cmdname == "discordsay")
	{
		PrintToChatAll(argv(1));
		return;
	}

	if(cmdname == "gotorandom")
	{
		if(autocvar_sv_quake_maplist != "")
		{
			mapname = PickDMMap(false);
			if(deathmatch)
				NextLevel();
			else
				changelevel(mapname);
		}
		return;
	}

	if(cmdname == "vote")
	{
		VoteCommand(CMD_REQUEST_COMMAND, NULL, argc, command);
		return;
	}

	if(cmdname == "settemp")
	{
		if(argc >= 3)
		{
			float f = cvar_settemp(argv(1), argv(2));
			if(f == 1)
				LOG_TRACE("Creating new settemp tracker for ", argv(1), " and setting it to \"", argv(2), "\" temporarily.");
			else if(f == -1)
				LOG_TRACE("Already had a tracker for ", argv(1), ", updating it to \"", argv(2), "\".");
			// else cvar_settemp itself errors out

			return;
		}
		LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		return;
	}

	if(cmdname == "settemp_restore")
	{
		float i = cvar_settemp_restore();

		if(i)
			LOG_TRACE("Restored ", ftos(i), " temporary cvar settings to their original values.");
		else
			LOG_TRACE("Nothing to restore.");

		return;
	}

	if(cmdname == "addtolist")
	{
		if(argc >= 2)
		{
			string original_cvar = argv(1);
			string tmp_string = argv(2);

			if(cvar_string(original_cvar) == "") // cvar was empty
			{
				cvar_set(original_cvar, tmp_string);
			}
			else // add it to the end of the list if the list doesn't already have it
			{
				FOREACH_WORD(cvar_string(original_cvar), it == tmp_string,
				{
					return; // already in the list
				});

				cvar_set(original_cvar, cons(cvar_string(original_cvar), tmp_string));
			}
			return;
		}

		LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		return;
	}

	if(cmdname == "removefromlist")
	{
		if(argc == 3)
		{
			string original_cvar = argv(1);
			string removal = argv(2);

			string tmp_string = "";
			FOREACH_WORD(cvar_string(original_cvar), it != removal,
			{
				tmp_string = cons(tmp_string, it);
			});

			cvar_set(original_cvar, tmp_string);

			return;
		}

		LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
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
