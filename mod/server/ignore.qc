//FEATURE: Ignore command to keep spammers out of your personal chat log for a match

REGISTER_MUTATOR(ignore, true);

const int IGNORE_MAXPLAYERS = 5;

.string ignore_list; // stores player id's, maybe can be upgraded to store net address for reconnect protection

string ignore_removefromlist(entity list, entity ignore)
{
	if(ignore.crypto_idfp && ignore.crypto_idfp != "" && list.crypto_idfp && list.crypto_idfp != "")
	{
		for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
		{
			string pos = db_get(ServerProgsDB, strcat("/ignore/", list.crypto_idfp, "/", ftos(j)));
			if(pos == ignore.crypto_idfp)
			{
				db_remove(ServerProgsDB, strcat("/ignore/", list.crypto_idfp, "/", ftos(j)));
				return string_null;
			}
		}
		// should this fall back? we know advanced mode is being used
	}

	string newlist = "";
	string theid = ftos(etof(ignore));

	FOREACH_WORD(list.ignore_list, it != theid,
	{
		newlist = cons(newlist, it);
	});

	if(newlist == "")
		return string_null;
	else
		return newlist;
}

bool ignore_playerinlist(entity sender, entity targ)
{
	// TODO: optimize this by saving it to .ignore_list?
	if(targ.crypto_idfp && targ.crypto_idfp != "" && sender.crypto_idfp && sender.crypto_idfp != "")
	{
		string thelist = "";
		for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
		{
			string pos = db_get(ServerProgsDB, strcat("/ignore/", targ.crypto_idfp, "/", ftos(j)));
			thelist = cons(thelist, pos);
		}

		return ((thelist != "") ? PlayerInList(sender, thelist) : false);
	}
	else if(!targ.ignore_list || targ.ignore_list == "")
		return false;

	string theid = ftos(etof(sender));

	FOREACH_WORD(targ.ignore_list, it == theid,
	{
		return true;
	});

	return false;
}

void ignore_clearall(entity this)
{
	for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
	{
		string pos = db_get(ServerProgsDB, strcat("/ignore/", this.crypto_idfp, "/", ftos(j)));
		if(pos != "")
			db_remove(ServerProgsDB, strcat("/ignore/", this.crypto_idfp, "/", ftos(j)));
	}
}

MUTATOR_HOOKFUNCTION(ignore, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	strfree(player.ignore_list);	

	FOREACH_CLIENT(IS_REAL_CLIENT(it) && it.ignore_list,
	{
		if(it.crypto_idfp && it.crypto_idfp != "")
			continue;
		string mylist = ignore_removefromlist(it, player);
		if(it.ignore_list)
			strunzone(it.ignore_list);

		it.ignore_list = strzone(mylist);
	});
}

MUTATOR_HOOKFUNCTION(ignore, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	int cmd_argc = M_ARGV(2, int);
	bool advanced = (player.crypto_idfp && player.crypto_idfp != "");

	if ( cmd_name == "ignore" )
	{
		if(!argv(1) || argv(1) == "")
		{
			sprint(player, "This command requires an argument. Use a player's name or their ID from the status command.\n");
			return true;
		}

		entity client = GetIndexedEntity(cmd_argc, 1);
		int accepted = VerifyClientEntity(client, true, false);

		if(accepted == CLIENT_ACCEPTABLE)
		{
			if(client == player)
			{
				sprint(player, "Hey silly, you can't ignore yourself!\n");
				return true;
			}

			if(ignore_playerinlist(client, player))
			{
				sprint(player, client.netname, " ^7is already ignored!\n");
				return true;
			}

			// advanced ignore mode, works if both the player and the sender have a stats UID
			if(advanced && client.crypto_idfp && client.crypto_idfp != "")
			{
				for(int j = 0; j < IGNORE_MAXPLAYERS; ++j)
				{
					string pos = db_get(ServerProgsDB, strcat("/ignore/", player.crypto_idfp, "/", ftos(j)));
					if(pos == "")
					{
						db_put(ServerProgsDB, strcat("/ignore/", player.crypto_idfp, "/", ftos(j)), client.crypto_idfp);
						sprint(player, "You will no longer recieve messages from ", client.netname, "^7, use unignore to hear them again.\n");
						return true;
					}
				}

				sprint(player, "You may only ignore up to ", ftos(IGNORE_MAXPLAYERS), " players, remove one before trying again.\n");
				return true;
			}

			if(player.ignore_list)
				strunzone(player.ignore_list);
			player.ignore_list = strzone(cons(player.ignore_list, ftos(etof(client))));

			sprint(player, "You no longer receive messages from ", client.netname, "^7, use unignore to hear them again.\n");
		}
		else
			sprint(player, "Unable to ignore this player, check their ID.\n");

		return true;
	}

	if ( cmd_name == "unignore" )
	{
		if(!argv(1) || argv(1) == "")
		{
			sprint(player, "This command requires an argument. Use a player's name or their ID from the status command.\n");
			return true;
		}

		entity client = GetIndexedEntity(cmd_argc, 1);
		int accepted = VerifyClientEntity(client, true, false);

		if(accepted == CLIENT_ACCEPTABLE)
		{
			string mylist = ignore_removefromlist(player, client);
			if(!advanced)
			{
				if(player.ignore_list)
					strunzone(player.ignore_list);

				player.ignore_list = strzone(mylist);
			}

			sprint(player, "You can now receive messages from ", client.netname, " ^7again.\n");
		}
		else
			sprint(player, "Unable to stop ignoring this player, check their ID.\n");

		return true;
	}

	if(cmd_name == "clear_ignores")
	{
		if(!advanced)
		{
			sprint(player, "You don't have a stats UID, unable to clear your ignore list.\n");
			return true;
		}

		ignore_clearall(player);
		sprint(player, "All permanent ignores cleared!\n");
		return true;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(ignore, ChatMessageTo)
{
	entity to = M_ARGV(0, entity);
	entity sender = M_ARGV(1, entity);
	if(IS_REAL_CLIENT(sender) && ignore_playerinlist(sender, to))
		return true; // no sending to this player, thank you very much
}
