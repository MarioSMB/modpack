bool autocvar_g_riflearena_withlaser;

void ra_SetCvars();
// NOTE: this should really have a !g_nexball check, but something in the gametype system is broken...
REGISTER_MUTATOR(ra, cvar("g_riflearena") && !cvar("g_instagib") && !cvar("g_overkill"))
{
	MUTATOR_ONADD
	{
		ra_SetCvars();

		WEP_ACTION(WEP_BLASTER.m_id, WR_INIT);
		WEP_ACTION(WEP_RIFLE.m_id, WR_INIT);
	}
}

void ra_SetCvars()
{
	cvar_settemp("g_balance_rifle_secondary_spread", ftos(cvar("g_riflearena_rifle_secondary_spread")));
	cvar_settemp("g_balance_rifle_secondary_shots", ftos(cvar("g_riflearena_rifle_secondary_shots")));
	cvar_settemp("g_balance_rifle_secondary_animtime", ftos(cvar("g_riflearena_rifle_secondary_animtime")));
	cvar_settemp("g_balance_rifle_secondary_refire", ftos(cvar("g_riflearena_rifle_secondary_refire")));
	cvar_settemp("g_balance_rifle_secondary_damage", ftos(cvar("g_riflearena_rifle_secondary_damage")));
}

MUTATOR_HOOKFUNCTION(ra, PlayerDamage_Calculate)
{
	if(IS_PLAYER(frag_attacker))
	if(IS_PLAYER(frag_target))
	{
		if (DEATH_ISWEAPON(frag_deathtype, WEP_BLASTER.m_id))
		{
			if(frag_attacker == frag_target)
				frag_damage = 5;
			else
				frag_damage = 0;
			frag_mirrordamage = 0;
			if (frag_target != frag_attacker)
			{
				if (frag_target.health >= 1 && IS_PLAYER(frag_target) && !frag_target.frozen && frag_target.deadflag == DEAD_NO)
					Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_SECONDARY_NODAMAGE);
				frag_force = '0 0 0';
			}
		}
	}

	return false;
}

MUTATOR_HOOKFUNCTION(ra, FilterItem)
{
	switch (self.items)
	{
		case IT_5HP:
		case IT_ARMOR_SHARD:
			return false;
	}

	return true;
}

MUTATOR_HOOKFUNCTION(ra, SetStartItems)
{
	start_items |= IT_UNLIMITED_AMMO;
	start_ammo_nails = warmup_start_ammo_nails = 100;
	warmup_start_weapons = start_weapons = WEPSET_RIFLE;
	
	if(autocvar_g_riflearena_withlaser)
	{
		start_weapons |= WEPSET_BLASTER;
		warmup_start_weapons |= WEPSET_BLASTER;
	}

	return false;
}

MUTATOR_HOOKFUNCTION(ra, ForbidThrowCurrentWeapon)
{
	return true;
}

MUTATOR_HOOKFUNCTION(ra, BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":RA");
	return false;
}

MUTATOR_HOOKFUNCTION(ra, BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Rifle Arena");
	return false;
}

MUTATOR_HOOKFUNCTION(ra, SetModname)
{
	modname = "Rifle Arena";
	return true;
}