void sha_SetCvars();
REGISTER_MUTATOR(sha, cvar("g_shotgunarena") && !cvar("g_instagib") && !cvar("g_overkill") && !cvar("g_riflearena") && !g_nexball)
{
	MUTATOR_ONADD
	{
		sha_SetCvars();
	}
}

AUTOCVAR(g_shotgunarena, bool, false, _("Enable shotgun arena mutator"));
AUTOCVAR(g_shotgunarena_shotgun_primary_damage, int, 20, "");
AUTOCVAR(g_shotgunarena_shotgun_primary_force, float, 400, "");
AUTOCVAR(g_shotgunarena_shotgun_primary_refire, float, 1.2, "");
AUTOCVAR(g_shotgunarena_shotgun_primary_spread, float, 0.10, "");
AUTOCVAR(g_shotgunarena_shotgun_reload_ammo, int, 0, "");
AUTOCVAR(g_shotgunarena_shotgun_reload_time, float, 1.2, "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_damage, int, 200, "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_force, float, 1600, "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_melee_time, float, 0.10, "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_refire, float, 1.2, "");

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
	entity item = M_ARGV(0, entity);

	switch (item.items)
	{
		case IT_5HP:
		case IT_ARMOR_SHARD:
			return false;
	}

	return true;
}

MUTATOR_HOOKFUNCTION(sha, SetStartItems, CBC_ORDER_LAST)
{
	start_items |= IT_UNLIMITED_WEAPON_AMMO;
	//start_ammo_shells = warmup_start_ammo_shells = 100;
	warmup_start_weapons = start_weapons = WEPSET(SHOTGUN);
}

MUTATOR_HOOKFUNCTION(sha, ForbidThrowCurrentWeapon)
{
	return true;
}

MUTATOR_HOOKFUNCTION(sha, BuildMutatorsString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ":SHA");
}

MUTATOR_HOOKFUNCTION(sha, BuildMutatorsPrettyString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Shotgun Arena");
}

MUTATOR_HOOKFUNCTION(sha, SetModname)
{
	M_ARGV(0, string) = "Shotgun Arena";
	return true;
}
