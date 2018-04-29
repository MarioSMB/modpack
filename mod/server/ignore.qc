//FEATURE: Ignore command to keep spammers out of your personal chat log for a match

REGISTER_MUTATOR(ignore, true);

.string ignore_list; // stores player id's, maybe can be upgraded to store net address for reconnect protection

string ignore_removefromlist(string list, string ignore)
{
	string newlist = "";

	FOREACH_WORD(list, it != ignore,
	{
		newlist = cons(newlist, it);
	});

	if(newlist == "")
		return string_null;
	else
		return newlist;
}

bool ignore_playerinlist(entity sender, string list)
{
	string theid = ftos(etof(sender));

	FOREACH_WORD(list, it == theid,
	{
		return true;
	});

	return false;
}

MUTATOR_HOOKFUNCTION(ignore, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	if(player.ignore_list)
		strunzone(player.ignore_list);
	player.ignore_list = string_null;

	FOREACH_CLIENT(IS_REAL_CLIENT(it) && it.ignore_list,
	{
		string mylist = ignore_removefromlist(it.ignore_list, ftos(etof(player)));
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

			if(ignore_playerinlist(client, player.ignore_list))
			{
				sprint(player, client.netname, " ^7is already ignored!\n");
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
			string mylist = ignore_removefromlist(player.ignore_list, ftos(etof(client)));
			if(player.ignore_list)
				strunzone(player.ignore_list);

			player.ignore_list = strzone(mylist);

			sprint(player, "You can now receive messages from ", client.netname, " ^7again.\n");
		}
		else
			sprint(player, "Unable to stop ignoring this player, check their ID.\n");

		return true;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(ignore, ChatMessageTo)
{
	entity to = M_ARGV(0, entity);
	entity sender = M_ARGV(1, entity);

	if(to.ignore_list && IS_REAL_CLIENT(sender))
	if(ignore_playerinlist(sender, to.ignore_list))
		return true; // no sending to this player, thank you very much
}
