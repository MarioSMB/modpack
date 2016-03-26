void ra_SetCvars();
REGISTER_MUTATOR(ra, cvar("g_riflearena") && !cvar("g_instagib") && !cvar("g_overkill") && !g_nexball)
{
	MUTATOR_ONADD
	{
		ra_SetCvars();

		Weapon w;
		w = WEP_BLASTER; w.wr_init(w);
		w = WEP_RIFLE; w.wr_init(w);
	}
}

AUTOCVAR(g_riflearena, bool, false, _("Enable rifle arena mutator"));
AUTOCVAR(g_riflearena_withlaser, bool, false, _("Enable blaster in the rifle arena mutator"));
AUTOCVAR(g_riflearena_rifle_secondary_spread, float, 0, "");
AUTOCVAR(g_riflearena_rifle_secondary_shots, int, 1, "");
AUTOCVAR(g_riflearena_rifle_secondary_animtime, float, 0.15, "");
AUTOCVAR(g_riflearena_rifle_secondary_refire, float, 0.15, "");
AUTOCVAR(g_riflearena_rifle_secondary_damage, int, 40, "");

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
		if (DEATH_ISWEAPON(frag_deathtype, WEP_BLASTER))
		{
			if(frag_attacker == frag_target)
				frag_damage = 5;
			else
				frag_damage = 0;
			frag_mirrordamage = 0;
			if (frag_target != frag_attacker)
			{
				if (frag_target.health >= 1 && IS_PLAYER(frag_target) && !STAT(FROZEN, frag_target) && !IS_DEAD(frag_target))
					Send_Notification(NOTIF_ONE, frag_attacker, MSG_CENTER, CENTER_SECONDARY_NODAMAGE);
				frag_force = '0 0 0';
			}
		}
	}

	return false;
}

MUTATOR_HOOKFUNCTION(ra, FilterItem)
{SELFPARAM();
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
	warmup_start_weapons = start_weapons = WEPSET(RIFLE);
	
	if(autocvar_g_riflearena_withlaser)
	{
		start_weapons |= WEPSET(BLASTER);
		warmup_start_weapons |= WEPSET(BLASTER);
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
