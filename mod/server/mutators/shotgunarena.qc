void sha_SetCvars();
// NOTE: this should really have a !g_nexball check, but something in the gametype system is broken...
REGISTER_MUTATOR(sha, cvar("g_shotgunarena") && !cvar("g_instagib") && !cvar("g_overkill") && !cvar("g_riflearena"))
{
	MUTATOR_ONADD
	{
		sha_SetCvars();
	}
}

void sha_SetCvars()
{
	cvar_settemp("g_balance_shotgun_primary_damage", cvar_string("g_shotgunarena_shotgun_primary_damage"));
	cvar_settemp("g_balance_shotgun_primary_force", cvar_string("g_shotgunarena_shotgun_primary_force"));
	cvar_settemp("g_balance_shotgun_primary_refire", cvar_string("g_shotgunarena_shotgun_primary_refire"));
	cvar_settemp("g_balance_shotgun_primary_spread", cvar_string("g_shotgunarena_shotgun_primary_spread"));
	cvar_settemp("g_balance_shotgun_reload_ammo", cvar_string("g_shotgunarena_shotgun_reload_ammo"));
	cvar_settemp("g_balance_shotgun_reload_time", cvar_string("g_shotgunarena_shotgun_reload_time"));
	cvar_settemp("g_balance_shotgun_secondary_damage", cvar_string("g_shotgunarena_shotgun_secondary_damage"));
	cvar_settemp("g_balance_shotgun_secondary_force", cvar_string("g_shotgunarena_shotgun_secondary_force"));
	cvar_settemp("g_balance_shotgun_secondary_melee_time", cvar_string("g_shotgunarena_shotgun_secondary_melee_time"));
	cvar_settemp("g_balance_shotgun_secondary_refire", cvar_string("g_shotgunarena_shotgun_secondary_refire"));
}

MUTATOR_HOOKFUNCTION(sha, FilterItem)
{
	switch (self.items)
	{
		case IT_5HP:
		case IT_ARMOR_SHARD:
			return false;
	}

	return true;
}

MUTATOR_HOOKFUNCTION(sha, SetStartItems)
{
	start_items |= IT_UNLIMITED_WEAPON_AMMO;
	//start_ammo_shells = warmup_start_ammo_shells = 100;
	warmup_start_weapons = start_weapons = WEPSET_SHOTGUN;

	return false;
}

MUTATOR_HOOKFUNCTION(sha, ForbidThrowCurrentWeapon)
{
	return true;
}

MUTATOR_HOOKFUNCTION(sha, BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":SHA");
	return false;
}

MUTATOR_HOOKFUNCTION(sha, BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Shotgun Arena");
	return false;
}

MUTATOR_HOOKFUNCTION(sha, SetModname)
{
	modname = "Shotgun Arena";
	return true;
}
