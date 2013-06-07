MUTATOR_HOOKFUNCTION(ra_VehicleEnter)
{
	if(other.ok_nade)
		ok_toss_nade(other, '0 0 100', max(other.ok_nade.wait, time + 0.05));
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_PlayerDamage)
{
	if(IS_PLAYER(frag_attacker))
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
	WEPSET_CLEAR_E(self);
	WEPSET_OR_EW(self, WEP_RIFLE);
	WEPSET_OR_EW(self, WEP_LASER);
	
	if(autocvar_g_overkill_spawnsystem_give_nade)
		self.ok_nade_refire = time + autocvar_g_spawnshieldtime;
	else
		self.ok_nade_refire  = time + autocvar_g_overkill_nade_refire;
	
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

MUTATOR_HOOKFUNCTION(ra_PlayerThink)
{
	if(self.ok_nade)
		if(self.ok_nade.wait - 0.1 <= time)
			ok_toss_nade(self, '0 0 0', time + 0.05);

	if(ok_CanThrowNade())
	if(self.ok_nade_refire < time)
	{
		if(self.BUTTON_HOOK)
		{
			if(!self.ok_nade)
				ok_nade_prime();
		}
		else if(time - self.ok_nade.cnt >= 1)
		{
			if(self.ok_nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.ok_nade.cnt;
				_force /= autocvar_g_overkill_nade_lifetime;
				_force = autocvar_g_overkill_nade_minforce + (_force * (autocvar_g_overkill_nade_maxforce - autocvar_g_overkill_nade_minforce));				
				ok_toss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	}
	
	self.hasweapon_complain_spam = time + 5; // this isn't needed, so keep it off
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_RemovePlayer)
{
	if(self.ok_nade)
		remove(self.ok_nade);
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_StartItems)
{
	start_items |= IT_UNLIMITED_AMMO;
	start_ammo_nails = 100;
	
	g_grappling_hook = 0;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(ra_PlayerDies)
{
	if(self.ok_nade)
		ok_toss_nade(self, '0 0 100', max(self.ok_nade.wait, time + 0.05));

	return 0;
}

MUTATOR_HOOKFUNCTION(ra_ForbidThrowCurrentWeapon)
{
	if(!ok_CanThrowNade())
		return 1;

	if(!self.ok_nade)
	{
		if(self.ok_nade_refire < time)
		{
			Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_OVERKILL_GRENADE);
			ok_nade_prime();
			self.ok_nade_refire  = time + autocvar_g_overkill_nade_refire;
		}
	}
	else
	{
		if(time - self.ok_nade.cnt >= 1)
		{
			makevectors(self.v_angle);
			float _force = time - self.ok_nade.cnt;
			_force /= autocvar_g_overkill_nade_lifetime;
			_force = autocvar_g_overkill_nade_minforce + (_force * (autocvar_g_overkill_nade_maxforce - autocvar_g_overkill_nade_minforce));
			ok_toss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
		}
	}
	return 1;
}

MUTATOR_HOOKFUNCTION(ra_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":RA");
	return 0;
}

MUTATOR_HOOKFUNCTION(ra_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Rifle Arena");
	return 0;
}

MUTATOR_HOOKFUNCTION(ra_SetModname)
{
	modname = "Rifle Arena";
	return TRUE;
}

MUTATOR_DEFINITION(mutator_rifle_arena)
{
	MUTATOR_HOOK(VehicleEnter, ra_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, ra_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, ra_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, ra_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, ra_StartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, ra_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, ra_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, ra_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, ra_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, ra_ForbidThrowCurrentWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, ra_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, ra_BuildMutatorsPrettyString, CBC_ORDER_ANY);
	
	MUTATOR_ONADD
	{
		cvar_settemp("g_balance_rifle_secondary_spread", "0");
		cvar_settemp("g_balance_rifle_secondary_shots", "1");
		cvar_settemp("g_balance_rifle_secondary_animtime", "0.15");
		cvar_settemp("g_balance_rifle_secondary_refire", "0.15");
		cvar_settemp("g_balance_rifle_secondary_damage", "40");
		precache_model("models/ok_nade_counter/ok_nade_counter.md3");
		
		precache_model("models/weapons/h_ok_grenade.iqm");
		precache_model("models/weapons/v_ok_grenade.md3");
		precache_sound("weapons/rocket_impact.wav");
		precache_sound("weapons/grenade_bounce1.wav");
		precache_sound("weapons/grenade_bounce2.wav");
		precache_sound("weapons/grenade_bounce3.wav");
		precache_sound("weapons/grenade_bounce4.wav");
		precache_sound("weapons/grenade_bounce5.wav");
		precache_sound("weapons/grenade_bounce6.wav");
		precache_sound("overkill/grenadebip.ogg");
		
		weapon_action(WEP_LASER, WR_PRECACHE);
		weapon_action(WEP_RIFLE, WR_PRECACHE);
		
		get_weaponinfo(WEP_HOOK).spawnflags |= WEP_FLAG_MUTATORBLOCKED;
	}
	
	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		get_weaponinfo(WEP_HOOK).spawnflags &~= WEP_FLAG_MUTATORBLOCKED;
	}
	
	MUTATOR_ONREMOVE
	{
		print("This cannot be removed at runtime\n");
		return -1;
	}

	return 0;
}
