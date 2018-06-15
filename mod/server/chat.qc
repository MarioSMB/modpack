//FEATURE: Even more chat replacements: %p for last shot player, %H for current health and %A for current armor, both nicely colorized
//FEATURE: Ability to use @#3 in chat to get player 3's full name (or any number you choose), making it easier to highlight those awkward names

REGISTER_MUTATOR(mod_chat, true);

AUTOCVAR(chat_replacewords, bool, false, "Allow replacing words in chat via chat_replace_* cvars");
AUTOCVAR(chat_water, bool, false, "Replace chat with a funny message while underwater");

.entity lasthit;

MUTATOR_HOOKFUNCTION(mod_chat, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);

	if(frag_attacker != frag_target)
	if(IS_PLAYER(frag_attacker) && IS_PLAYER(frag_target))
		frag_attacker.lasthit = frag_target;
}

MUTATOR_HOOKFUNCTION(mod_chat, MakePlayerObserver)
{
	entity player = M_ARGV(0, entity);

	player.lasthit = NULL;
}

MUTATOR_HOOKFUNCTION(mod_chat, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	player.lasthit = NULL;
}

MUTATOR_HOOKFUNCTION(mod_chat, FormatMessage)
{
	entity player = M_ARGV(0, entity);

	switch(M_ARGV(1, string)) // escape
	{
		case "p": M_ARGV(2, string) = ((!player.lasthit || player.lasthit.netname == "") ? "(nobody)" : player.lasthit.netname); break;
		case "H": M_ARGV(2, string) = sprintf("%s%d", rgb_to_hexcolor(('1 0 0' * GetResourceAmount(player, RESOURCE_HEALTH) / g_pickup_healthsmall_max) + ('0 0 1' * ( GetResourceAmount(player, RESOURCE_HEALTH) - 100) / g_pickup_healthsmall_max)), rint(GetResourceAmount(player, RESOURCE_HEALTH))); break;
		case "A": M_ARGV(2, string) = sprintf("%s%d", rgb_to_hexcolor(('0 2 0' * GetResourceAmount(player, RESOURCE_ARMOR) / g_pickup_armorsmall_max) + ('0 0 1' * ( GetResourceAmount(player, RESOURCE_ARMOR) - 100) / g_pickup_armorsmall_max)), rint(GetResourceAmount(player, RESOURCE_ARMOR))); break;
	}
}

MUTATOR_HOOKFUNCTION(mod_chat, PreFormatMessage)
{
	entity player = M_ARGV(0, entity);
	string themsg = M_ARGV(1, string);

	if(!IS_CLIENT(player) || themsg == "")
		return; // don't modify map entity strings or other formatted stuff

	if(player.waterlevel >= WATERLEVEL_SUBMERGED && autocvar_chat_water)
	{
		M_ARGV(1, string) = "[glub glub glub]";
		return;
	}

	string newmsg = "";
	FOREACH_WORD(themsg, true,
	{
		string theword = it;

		if(substring(theword, 0, 2) == "@#")
		{
			entity player = GetFilteredEntity(substring(theword, 1, strlen(theword)));
			int accepted = VerifyClientEntity(player, false, false);
			theword = strcat("^7", ((accepted >= 0) ? playername(player, false) : "(nobody)"), "^7");
		}

		if(!autocvar_chat_replacewords)
		{
			newmsg = cons(newmsg, theword);
			continue;
		}

		string myvar = strcat("chat_replace_", theword);
		if(cvar_type(myvar) & CVAR_TYPEFLAG_EXISTS)
			newmsg = cons(newmsg, cvar_string(myvar));
		else
			newmsg = cons(newmsg, theword);
	});

	M_ARGV(1, string) = themsg;
}
