.float campcheck_nextcheck;
.float campcheck_traveled_distance;

MUTATOR_HOOKFUNCTION(campcheck_PlayerDies)
{
	Kill_Notification(NOTIF_ONE_ONLY, self, MSG_CENTER_CPID, CPID_CAMPCHECK);
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(campcheck_PlayerDamage)
{
	if(IS_PLAYER(frag_target))
	if(IS_PLAYER(frag_attacker))
	if(frag_attacker != frag_target)
	{
		frag_target.campcheck_traveled_distance = autocvar_g_campcheck_distance;
		frag_attacker.campcheck_traveled_distance = autocvar_g_campcheck_distance;
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(campcheck_PlayerThink)
{
	if(IS_PLAYER(self))
	if(self.deadflag == DEAD_NO)
	if(autocvar_g_campcheck_interval)
	{
		vector dist;

		// calculate player movement (in 2 dimensions only, so jumping on one spot doesn't count as movement)
		dist = self.prevorigin - self.origin;
		dist_z = 0;
		self.campcheck_traveled_distance += fabs(vlen(dist));

		if((autocvar_g_campaign && !campaign_bots_may_start) || (time < game_starttime) || (round_handler_IsActive() && !round_handler_IsRoundStarted()))
		{
			self.campcheck_nextcheck = time + autocvar_g_campcheck_interval * 2;
			self.campcheck_traveled_distance = 0;
		}

		if(time > self.campcheck_nextcheck)
		{
			if(self.campcheck_traveled_distance < autocvar_g_campcheck_distance)
			{
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_CAMPCHECK);
				if(self.vehicle)
					Damage(self.vehicle, self, self, autocvar_g_campcheck_damage * 2, DEATH_CAMP, self.vehicle.origin, '0 0 0');
				else
					Damage(self, self, self, bound(0, autocvar_g_campcheck_damage, self.health + self.armorvalue * autocvar_g_balance_armor_blockpercent + 5), DEATH_CAMP, self.origin, '0 0 0');
			}
			self.campcheck_nextcheck = time + autocvar_g_campcheck_interval;
			self.campcheck_traveled_distance = 0;
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(campcheck_PlayerSpawn)
{
	self.campcheck_nextcheck = time + autocvar_g_campcheck_interval * 2;
	self.campcheck_traveled_distance = 0;
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(campcheck_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":CampCheck");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_campcheck)
{
	MUTATOR_HOOK(PlayerDies, campcheck_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, campcheck_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, campcheck_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, campcheck_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, campcheck_BuildMutatorsString, CBC_ORDER_ANY);

	return FALSE;
}
