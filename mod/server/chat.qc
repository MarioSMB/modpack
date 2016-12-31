REGISTER_MUTATOR(mod_chat, true);

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
		case "H": M_ARGV(2, string) = sprintf("%s%d", rgb_to_hexcolor(('1 0 0' * player.health / g_pickup_healthsmall_max) + ('0 0 1' * ( player.health - 100) / g_pickup_healthsmall_max)), rint(player.health)); break;
		case "A": M_ARGV(2, string) = sprintf("%s%d", rgb_to_hexcolor(('0 2 0' * player.armorvalue / g_pickup_armorsmall_max) + ('0 0 1' * ( player.armorvalue - 100) / g_pickup_armorsmall_max)), rint(player.armorvalue)); break;
	}
}

#define FOREACH_CLIENTSLOT_REVERSE(cond, body) \
	MACRO_BEGIN { \
		for(int _i = maxclients; _i >= 1; --_i) \
		{ \
			const noref int i = _i; \
			ITER_CONST noref entity it = ftoe(i); \
			if(cond) { LAMBDA(body) } \
		} \
	} MACRO_END

MUTATOR_HOOKFUNCTION(mod_chat, PreFormatMessage)
{
	string themsg = M_ARGV(1, string);

	// replace id with the player's name
	FOREACH_CLIENTSLOT_REVERSE(true,
	{
		string myname = strcat("^7", ((IS_CLIENT(it)) ? it.netname : "(nobody)"), "^7");
		themsg = strreplace(strcat("@#", ftos(i)), myname, themsg);
	});

	M_ARGV(1, string) = themsg;
}
