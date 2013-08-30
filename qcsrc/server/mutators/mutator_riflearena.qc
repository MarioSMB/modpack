void ra_SetCvars()
{
	cvar_settemp("g_balance_rifle_secondary_spread", ftos(cvar("g_riflearena_rifle_secondary_spread")));
	cvar_settemp("g_balance_rifle_secondary_shots", ftos(cvar("g_riflearena_rifle_secondary_shots")));
	cvar_settemp("g_balance_rifle_secondary_animtime", ftos(cvar("g_riflearena_rifle_secondary_animtime")));
	cvar_settemp("g_balance_rifle_secondary_refire", ftos(cvar("g_riflearena_rifle_secondary_refire")));
	cvar_settemp("g_balance_rifle_secondary_damage", ftos(cvar("g_riflearena_rifle_secondary_damage")));
}

MUTATOR_HOOKFUNCTION(ra_PlayerDamage)
{
	if(IS_PLAYER(frag_attacker))
	if(IS_PLAYER(frag_target))
	{
		if (DEATH_ISWEAPON(frag_deathtype, WEP_LASER))
		{
			if(frag_attacker == frag_target)
				frag_damage = 5;
			else
				frag_damage = 0;
			frag_mirrordamage = 0;
			if (frag_target != frag_attacker)
			{
				if (frag_target.health >= 1 && IS_PLAYER(frag_target) && !frag_target.frozen)
					Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_MINSTA_SECONDARY);
				frag_force = '0 0 0';
			}
		}
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_PlayerSpawn)
{
	self.weapons = '0 0 0';
	self.weapons |= WEPSET_RIFLE;
	self.weapons |= WEPSET_LASER;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_FilterItem)
{
	switch (self.items)
	{
		case IT_5HP:
		case IT_ARMOR_SHARD:
			return FALSE;
	}
		
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ra_StartItems)
{
	start_items |= IT_UNLIMITED_AMMO;
	start_ammo_nails = 100;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_ForbidThrowCurrentWeapon)
{
	nades_CheckThrow();
	return TRUE;
}

MUTATOR_HOOKFUNCTION(ra_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":RA");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Rifle Arena");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_SetModname)
{
	modname = "Rifle Arena";
	return TRUE;
}

MUTATOR_DEFINITION(mutator_riflearena)
{
	MUTATOR_HOOK(PlayerDamage_Calculate, ra_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, ra_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, ra_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, ra_StartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, ra_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, ra_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, ra_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		ra_SetCvars();
		
		weapon_action(WEP_LASER, WR_PRECACHE);
		weapon_action(WEP_RIFLE, WR_PRECACHE);
	}
	MUTATOR_ONREMOVE
	{
		print("This cannot be removed at runtime\n");
		return -1;
	}

	return FALSE;
}
