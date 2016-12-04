REGISTER_MUTATOR(ignore, true);

.string ignore_list; // stores player id's, maybe can be upgraded to store net address for reconnect protection

MUTATOR_HOOKFUNCTION(muteban, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	if(player.ignore_list)
	{
		strunzone(player.ignore_list);
		player.ignore_list = string_null;
	}

	FOREACH_CLIENT(IS_REAL_CLIENT(it) && it.ignore_list,
	{
		if(it.ignore_list)
			strunzone(it.ignore_list);
		it.ignore_list = strzone(strreplace(sprintf(" %d ", etof(player)), " ", it.ignore_list));
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
		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);

		if(accepted)
		{
			if(player.ignore_list)
				strunzone(player.ignore_list);
			player.ignore_list = strzone(strcat(player.ignore_list, ftos(etof(client)), " "));

			sprint(player, "You no longer receive messages from ", client.netname, ", use unignore to hear them again.\n");
		}
		else
			sprint(player, "Unable to ignore this player, check their ID.\n");

		return true;
	}

	if ( cmd_name == "unignore" )
	{
		entity client = GetIndexedEntity(cmd_argc, 1);
		bool accepted = VerifyClientEntity(client, true, false);

		if(accepted)
		{
			if(player.ignore_list)
				strunzone(player.ignore_list);
			player.ignore_list = strzone(strreplace(sprintf(" %d ", etof(client)), " ", player.ignore_list));

			sprint(player, "You can now receive messages from ", client.netname, " again.\n");
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

	if(sender.ignore_list && IS_REAL_CLIENT(sender))
	if(strhasword(sender.ignore_list, etof(to)))
		return true; // no sending to this player, thank you very much
}
