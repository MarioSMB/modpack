//FEATURE: Shotgun Arena, a funny mode similar to overkill with just the shotgun, and crazy push force

AUTOCVAR(g_shotgunarena, bool, false, "Enable shotgun arena mutator");
void sha_SetCvars();
REGISTER_MUTATOR(sha, autocvar_g_shotgunarena && !autocvar_g_instagib && !cvar("g_overkill") && !cvar("g_riflearena") && !g_nexball)
{
	MUTATOR_ONADD
	{
		sha_SetCvars();
	}
}

AUTOCVAR(g_shotgunarena_shotgun_primary_damage, string, "20", "");
AUTOCVAR(g_shotgunarena_shotgun_primary_force, string, "400", "");
AUTOCVAR(g_shotgunarena_shotgun_primary_refire, string, "1.2", "");
AUTOCVAR(g_shotgunarena_shotgun_primary_spread, string, "0.10", "");
AUTOCVAR(g_shotgunarena_shotgun_reload_ammo, string, "0", "");
AUTOCVAR(g_shotgunarena_shotgun_reload_time, string, "1.2", "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_damage, string, "200", "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_force, string, "1600", "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_melee_time, string, "0.10", "");
AUTOCVAR(g_shotgunarena_shotgun_secondary_refire, string, "1.2", "");

void sha_SetCvars()
{
	cvar_settemp("g_balance_shotgun_primary_damage", autocvar_g_shotgunarena_shotgun_primary_damage);
	cvar_settemp("g_balance_shotgun_primary_force", autocvar_g_shotgunarena_shotgun_primary_force);
	cvar_settemp("g_balance_shotgun_primary_refire", autocvar_g_shotgunarena_shotgun_primary_refire);
	cvar_settemp("g_balance_shotgun_primary_spread", autocvar_g_shotgunarena_shotgun_primary_spread);
	cvar_settemp("g_balance_shotgun_reload_ammo", autocvar_g_shotgunarena_shotgun_reload_ammo);
	cvar_settemp("g_balance_shotgun_reload_time", autocvar_g_shotgunarena_shotgun_reload_time);
	cvar_settemp("g_balance_shotgun_secondary_damage", autocvar_g_shotgunarena_shotgun_secondary_damage);
	cvar_settemp("g_balance_shotgun_secondary_force", autocvar_g_shotgunarena_shotgun_secondary_force);
	cvar_settemp("g_balance_shotgun_secondary_melee_time", autocvar_g_shotgunarena_shotgun_secondary_melee_time);
	cvar_settemp("g_balance_shotgun_secondary_refire", autocvar_g_shotgunarena_shotgun_secondary_refire);
}

MUTATOR_HOOKFUNCTION(sha, FilterItemDefinition)
{
	entity definition = M_ARGV(0, entity);

	switch (definition)
	{
		case ITEM_HealthSmall:
		case ITEM_ArmorSmall:
			return false;
	}

	return true;
}

MUTATOR_HOOKFUNCTION(sha, SetStartItems, CBC_ORDER_LAST)
{
	start_items |= IT_UNLIMITED_AMMO;
	//start_ammo_shells = warmup_start_ammo_shells = 100;
	warmup_start_weapons = start_weapons = WEPSET(SHOTGUN);
}

MUTATOR_HOOKFUNCTION(sha, SetWeaponArena)
{
	// turn weapon arena off
	M_ARGV(0, string) = "off";
}

MUTATOR_HOOKFUNCTION(sha, ForbidThrowCurrentWeapon)
{
	return true;
}

MUTATOR_HOOKFUNCTION(sha, ForbidRandomStartWeapons)
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
