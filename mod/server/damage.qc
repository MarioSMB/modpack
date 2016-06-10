REGISTER_MUTATOR(damage_mod, true);

AUTOCVAR(g_turrets_player_damagerate, float, 1, _("Multiplier for the amount of damage a player takes from turrets"));
AUTOCVAR(g_turrets_weapon_damagerate, float, 1, _("Multiplier for the amount of damage a turret takes from players"));

.entity lastkilled;
.entity lastkiller;

MUTATOR_HOOKFUNCTION(damage_mod, PlayerDamage_Calculate)
{
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if(IS_PLAYER(frag_target))
	{
		if(DEATH_ISTURRET(frag_deathtype))
			M_ARGV(4, float) *= autocvar_g_turrets_player_damagerate;
	}

	if(IS_TURRET(frag_target))
	{
		if(DEATH_WEAPONOF(frag_deathtype) != WEP_Null)
			M_ARGV(4, float) *= autocvar_g_turrets_weapon_damagerate;
	}
}

MUTATOR_HOOKFUNCTION(damage_mod, PlayerDies)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);

	if(IS_PLAYER(frag_attacker))
	{
		frag_target.lastkiller = frag_attacker;
		frag_attacker.lastkilled = frag_target;
	}
}

MUTATOR_HOOKFUNCTION(damage_mod, FormatMessage)
{
	entity player = M_ARGV(0, entity);

	switch(M_ARGV(1, string))
	{
		case "j": M_ARGV(2, string) = ((player.lastkilled) ? player.lastkilled.netname : "(nobody)"); break;
		case "k": M_ARGV(2, string) = ((player.lastkiller) ? player.lastkiller.netname : "(nobody)"); break;
	}
}
