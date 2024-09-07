#include "banning.qh"

#include "../ipban.qh"

// =====================================================
//  Banning and kicking command code, written by Samual
//  Last updated: December 29th, 2011
// =====================================================

void BanCommand_ban(int request, int argc, string command)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argc >= 2)
			{
				string ip = argv(1);
				float reason_arg, bantime;
				string reason;

				reason_arg = 2;

				GET_BAN_ARG(bantime, autocvar_g_ban_default_bantime);
				GET_BAN_REASON(reason, "No reason provided");

				Ban_Insert(ip, bantime, reason, 1);
				return;
			}
		}

		default:
			LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd ban <address> [<bantime>] [<reason>]");
			LOG_HELP("  <address> is the IP address or range of the player to ban,");
			LOG_HELP("  <bantime> is the amount of time that the ban is active (default if not provided),");
			LOG_HELP("  and <reason> is the string to label the ban with as reason for banning.");
			LOG_HELP("See also: ^2banlist, kickban, unban^7");
			return;
		}
	}
}

void BanCommand_banlist(int request)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			Ban_View();
			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd banlist");
			LOG_HELP("  No arguments required.");
			LOG_HELP("See also: ^2ban, kickban, unban^7");
			return;
		}
	}
}

void BanCommand_kickban(int request, int argc, string command)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argc >= 2)
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = IS_REAL_CLIENT(client);
				float reason_arg, bantime, masksize;
				string reason;

				if (accepted > 0)
				{
					reason_arg = next_token;

					GET_BAN_ARG(bantime, autocvar_g_ban_default_bantime);
					GET_BAN_ARG(masksize, autocvar_g_ban_default_masksize);
					GET_BAN_REASON(reason, "No reason provided");

					Ban_KickBanClient(client, bantime, masksize, reason);

					return;
				}
				else
				{
					LOG_INFO("kickban: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
			LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd kickban <client> [<bantime>] [<masksize>] [<reason>]");
			LOG_HELP("  <client> is the entity number or name of the player to ban,");
			LOG_HELP("  <bantime> is the amount of time that the ban is active (default if not provided),");
			LOG_HELP("  <masksize> is the range of the IP address (1-thru-4, default if not provided),");
			LOG_HELP("  and <reason> is the string to label the ban with as reason for banning.");
			LOG_HELP("See also: ^2ban, banlist, unban^7");
			return;
		}
	}
}

void BanCommand_mute(int request, int argc, string command)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argc >= 2)
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = VerifyClientEntity(client, true, false);

				if (accepted > 0)
				{
					string theid = "";
					if(!PlayerInIPList(client, autocvar_g_chatban_list))
						theid = cons(theid, client.netaddress);
					if(!PlayerInIDList(client, autocvar_g_chatban_list))
						theid = cons(theid, client.crypto_idfp);
					client.muted = true;
					LOG_INFO(strcat("Mute-banning player ", GetCallerName(client), " (", argv(1), ")."));
					cvar_set("g_chatban_list", cons(autocvar_g_chatban_list, theid));

					return;
				}
				else
				{
					LOG_INFO("mute: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
			LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd mute <client>");
			LOG_HELP("  <client> is the entity number or name of the player to mute.");
			LOG_HELP("See also: ^2unmute, g_chatban_list^7");
			return;
		}
	}
}

void BanCommand_playban(int request, int argc, string command)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argc >= 2)
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = VerifyClientEntity(client, true, false);

				if (accepted > 0)
				{
					string theid = "";
					if(!PlayerInIPList(client, autocvar_g_playban_list))
						theid = cons(theid, client.netaddress);
					if(!PlayerInIDList(client, autocvar_g_playban_list))
						theid = cons(theid, client.crypto_idfp);

					LOG_INFO(strcat("Play-banning player ", GetCallerName(client), " (", argv(1), ")."));
					PutObserverInServer(client);
					cvar_set("g_playban_list", cons(autocvar_g_playban_list, theid));

					return;
				}
				else
				{
					LOG_INFO("playban: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
			LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd playban <client>");
			LOG_HELP("  <client> is the entity number or name of the player to ban being forced to spectate permanently,");
			LOG_HELP("See also: ^2g_playban_list, unplayban^7");
			return;
		}
	}
}

void BanCommand_unban(int request, int argc)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argv(1))
			{
				float tmp_number = -1;
				string tmp_string;

				if (substring(argv(1), 0, 1) == "#")
				{
					tmp_string = substring(argv(1), 1, -1);

					if (tmp_string != "") // is it all one token? like #1
						tmp_number = stof(tmp_string);
					else if (argc > 2)    // no, it's two tokens? # 1
						tmp_number = stof(argv(2));
					else tmp_number = -1;
				}
				else  // maybe it's ONLY a number?
				{
					tmp_number = stof(argv(1));

					if ((tmp_number == 0) && (argv(1) != "0")) tmp_number = -1; }

				if (tmp_number >= 0)
				{
					Ban_Delete(tmp_number);
					return;
				}
			}
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd unban <banid>");
			LOG_HELP("  Where <banid> is the ID of the ban of which to remove.");
			LOG_HELP("See also: ^2ban, banlist, kickban^7");
			return;
		}
	}
}

void BanCommand_unmute(int request, int argc)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argc >= 2)
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = VerifyClientEntity(client, true, false);
				string original_arg = argv(1);

				if (accepted > 0)
				{
					string tmp_string = "";
					FOREACH_WORD(autocvar_g_chatban_list, it != client.netaddress,
					{
						if(client.crypto_idfp && it == substring(client.crypto_idfp, 0, strlen(it)))
							continue;
						tmp_string = cons(tmp_string, it);
					});

					cvar_set("g_chatban_list", tmp_string);
					LOG_INFO(strcat("Unmuting player ", GetCallerName(client), " (", original_arg, ")."));
					client.muted = false;

					return;
				}
				else
				{
					LOG_INFO("unmute: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
			LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd unmute <client>");
			LOG_HELP("  <client> is the entity number or name of the player to unmute.");
			LOG_HELP("See also: ^2mute, g_chatban_list^7");
			return;
		}
	}
}

void BanCommand_unplayban(int request, int argc)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argv(1))
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = VerifyClientEntity(client, true, false);
				string original_arg = argv(1);

				if (accepted > 0)
				{
					string tmp_string = "";
					FOREACH_WORD(autocvar_g_playban_list, it != client.netaddress,
					{
						if(client.crypto_idfp && it == substring(client.crypto_idfp, 0, strlen(it)))
							continue;
						tmp_string = cons(tmp_string, it);
					});

					cvar_set("g_playban_list", tmp_string);
					LOG_INFO(strcat("Releasing forced to spectate player ", GetCallerName(client), " (", original_arg, ")."));

					return;
				}
				else
				{
					LOG_INFO("unplayban: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd unplayban <banid>");
			LOG_HELP("  Where <banid> is the ID of the forced to spectate ban of which to remove.");
			LOG_HELP("See also: ^2playban, g_playban_list^7");
			return;
		}
	}
}

void BanCommand_unvoteban(int request, int argc)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argv(1))
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = VerifyClientEntity(client, true, false);
				string original_arg = argv(1);

				if (accepted > 0)
				{
					string tmp_string = "";
					FOREACH_WORD(autocvar_g_voteban_list, it != client.netaddress,
					{
						if(client.crypto_idfp && it == substring(client.crypto_idfp, 0, strlen(it)))
							continue;
						tmp_string = cons(tmp_string, it);
					});

					cvar_set("g_voteban_list", tmp_string);
					LOG_INFO(strcat("Unvote-banning player ", GetCallerName(client), " (", original_arg, ")."));

					return;
				}
				else
				{
					LOG_INFO("unvoteban: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd unvoteban <banid>");
			LOG_HELP("  Where <banid> is the ID of the ban from voting of which to remove.");
			LOG_HELP("See also: ^2voteban, g_voteban_list^7");
			return;
		}
	}
}

void BanCommand_voteban(int request, int argc, string command)
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (argc >= 2)
			{
				entity client = GetIndexedEntity(argc, 1);
				float accepted = VerifyClientEntity(client, true, false);

				if (accepted > 0)
				{
					string theid = "";
					if(!PlayerInIPList(client, autocvar_g_voteban_list))
						theid = cons(theid, client.netaddress);
					if(!PlayerInIDList(client, autocvar_g_voteban_list))
						theid = cons(theid, client.crypto_idfp);

					LOG_INFO(strcat("Vote-banning player ", GetCallerName(client), " (", argv(1), ")."));
					cvar_set("g_voteban_list", cons(autocvar_g_voteban_list, theid));

					return;
				}
				else
				{
					LOG_INFO("voteban: ", "client not valid: ", argv(1), ".");
				}
			}
		}

		default:
			LOG_INFOF("Incorrect parameters for ^2%s^7", argv(0));
		case CMD_REQUEST_USAGE:
		{
			LOG_HELP("Usage:^3 sv_cmd voteban <client>");
			LOG_HELP("  <client> is the entity number or name of the player to ban from voting,");
			LOG_HELP("See also: ^2g_voteban_list, unvoteban^7");
			return;
		}
	}
}

/* use this when creating a new command, making sure to place it in alphabetical order... also,
** ADD ALL NEW COMMANDS TO commands.cfg WITH PROPER ALIASES IN THE SAME FASHION!
void BanCommand_(int request)
{
    switch(request)
    {
        case CMD_REQUEST_COMMAND:
        {

            return;
        }

        default:
        case CMD_REQUEST_USAGE:
        {
            LOG_HELP("Usage:^3 sv_cmd ");
            LOG_HELP("  No arguments required.");
            return;
        }
    }
}
*/


// ==================================
//  Macro system for server commands
// ==================================

// Do not hard code aliases for these, instead create them in commands.cfg... also: keep in alphabetical order, please ;)
#define BAN_COMMANDS(request, arguments, command) \
	BAN_COMMAND("ban",          BanCommand_ban(request, arguments, command),        "Ban an IP address or a range of addresses (like 1.2.3)") \
	BAN_COMMAND("banlist",      BanCommand_banlist(request),                        "List all existing bans") \
	BAN_COMMAND("kickban",      BanCommand_kickban(request, arguments, command),    "Disconnect a client and ban it at the same time") \
	BAN_COMMAND("mute",         BanCommand_mute(request, arguments, command),       "Disallow a client from talking by muting them") \
	BAN_COMMAND("playban",      BanCommand_playban(request, arguments, command),    "Force to spectate a client permanently") \
	BAN_COMMAND("unban",        BanCommand_unban(request, arguments),               "Remove an existing ban") \
	BAN_COMMAND("unmute",       BanCommand_unmute(request, arguments),              "Unmute a client") \
	BAN_COMMAND("unvoteban",    BanCommand_unvoteban(request, arguments),           "Remove an existing voting ban") \
	BAN_COMMAND("unplayban",    BanCommand_unplayban(request, arguments),           "Remove an existing forced to spectate ban") \
	BAN_COMMAND("voteban",      BanCommand_voteban(request, arguments, command),    "Disallow a client from voting") \
	/* nothing */

void BanCommand_macro_help()
{
	#define BAN_COMMAND(name, function, description) \
		{ if (strtolower(description) != "") { LOG_INFO("  ^2", name, "^7: ", description); } }

	BAN_COMMANDS(0, 0, "");
#undef BAN_COMMAND
}

float BanCommand_macro_command(int argc, string command)
{
	#define BAN_COMMAND(name, function, description) \
		{ if (name == strtolower(argv(0))) { function; return true; } }

	BAN_COMMANDS(CMD_REQUEST_COMMAND, argc, command);
#undef BAN_COMMAND

	return false;
}

float BanCommand_macro_usage(int argc)
{
	#define BAN_COMMAND(name, function, description) \
		{ if (name == strtolower(argv(1))) { function; return true; } }

	BAN_COMMANDS(CMD_REQUEST_USAGE, argc, "");
#undef BAN_COMMAND

	return false;
}

bool BanCommand(int argc, string command)
{
	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	if (BanCommand_macro_command(argc, command)) // continue as usual and scan for normal commands
		return true;                             // handled by one of the above GenericCommand_* functions

	return false;
}
