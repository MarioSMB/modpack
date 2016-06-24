REGISTER_MUTATOR(mod_chat, true);

.entity lasthit;

MUTATOR_HOOKFUNCTION(mod_chat, PlayerDamage_Calculate)
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
