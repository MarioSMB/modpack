AUTOCVAR(g_turrets_player_damagerate, float, 1, _("Multiplier for the amount of damage a player takes from turrets"));
AUTOCVAR(g_turrets_weapon_damagerate, float, 1, _("Multiplier for the amount of damage a turret takes from players"));

.entity lastkilled;
.entity lastkiller;

MUTATOR_HOOKFUNCTION(mutator_mod, PlayerDamage_Calculate)
{
	if(IS_PLAYER(frag_target))
	{
		if(DEATH_ISTURRET(frag_deathtype))
			frag_damage *= autocvar_g_turrets_player_damagerate;
	}

	if(IS_TURRET(frag_target))
	{
		if(DEATH_WEAPONOFWEAPONDEATH(frag_deathtype))
			frag_damage *= autocvar_g_turrets_weapon_damagerate;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, PlayerDies)
{
	if(IS_PLAYER(frag_attacker))
	{
		frag_target.lastkiller = frag_attacker;
		frag_attacker.lastkilled = frag_target;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(mutator_mod, FormatMessage)
{
	switch(format_escape)
	{
		case "j": format_replacement = ((self.lastkilled) ? self.lastkilled.netname : "(nobody)"); break;
		case "k": format_replacement = ((self.lastkiller) ? self.lastkiller.netname : "(nobody)"); break;
	}
	return false;
}
