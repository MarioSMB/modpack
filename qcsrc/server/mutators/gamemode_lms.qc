// main functions
float LMS_NewPlayerLives()
{
	float fl;
	fl = autocvar_fraglimit;
	if(fl == 0)
		fl = 999;

	// first player has left the game for dying too much? Nobody else can get in.
	if(lms_lowest_lives < 1)
		return 0;

	if(!autocvar_g_lms_join_anytime)
		if(lms_lowest_lives < fl - autocvar_g_lms_last_join)
			return 0;

	return bound(1, lms_lowest_lives, fl);
}

// mutator hooks
MUTATOR_HOOKFUNCTION(lms_ResetMap)
{
	lms_lowest_lives = 999;
	lms_next_place = player_count;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_ResetPlayers)
{
	if(restart_mapalreadyrestarted || (time < game_starttime))
	FOR_EACH_CLIENT(self)
	if(IS_PLAYER(self))
		PlayerScore_Add(self, SP_LMS_LIVES, LMS_NewPlayerLives());
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_PlayerPreSpawn)
{
	// player is dead and becomes observer
	// FIXME fix LMS scoring for new system
	if(PlayerScore_Add(self, SP_LMS_RANK, 0) > 0)
		self.classname = "observer";

	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_PlayerSpawn)
{
	self.lms_nextcheck = time + autocvar_g_lms_campcheck_interval*2;
	self.lms_traveled_distance = 0;
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_PlayerDies)
{
	self.respawn_flags |= RESPAWN_FORCE;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_RemovePlayer)
{
	// Only if the player cannot play at all
	if(PlayerScore_Add(self, SP_LMS_RANK, 0) == 666)
		self.frags = FRAGS_SPECTATOR;
	else
		self.frags = FRAGS_LMS_LOSER;
		
	if(self.killcount != -666)
		if(PlayerScore_Add(self, SP_LMS_RANK, 0) > 0 && self.lms_spectate_warning != 2)
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_LMS_NOLIVES, self.netname);
		else
			Send_Notification(NOTIF_ALL, world, MSG_INFO, INFO_LMS_FORFEIT, self.netname);
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_ClientConnect)
{
	self.classname = "player";
	campaign_bots_may_start = 1;
	
	if(PlayerScore_Add(self, SP_LMS_LIVES, LMS_NewPlayerLives()) <= 0)
	{
		PlayerScore_Add(self, SP_LMS_RANK, 666);
		self.frags = FRAGS_SPECTATOR;
	}
			
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_PlayerThink)
{
	if(self.deadflag == DEAD_DYING)
		self.deadflag = DEAD_RESPAWNING;
		
	if not(self.deadflag)
	if(autocvar_g_lms_campcheck_interval)
	{
		vector dist;

		// calculate player movement (in 2 dimensions only, so jumping on one spot doesn't count as movement)
		dist = self.prevorigin - self.origin;
		dist_z = 0;
		self.lms_traveled_distance += fabs(vlen(dist));

		if((autocvar_g_campaign && !campaign_bots_may_start) || (time < game_starttime))
		{
			self.lms_nextcheck = time + autocvar_g_lms_campcheck_interval*2;
			self.lms_traveled_distance = 0;
		}

		if(time > self.lms_nextcheck)
		{
			if(self.lms_traveled_distance < autocvar_g_lms_campcheck_distance)
			{
				Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_LMS_CAMPCHECK);
				if(self.vehicle)
					Damage(self.vehicle, self, self, autocvar_g_lms_campcheck_damage * 2, DEATH_CAMP, self.vehicle.origin, '0 0 0');
				else
					Damage(self, self, self, bound(0, autocvar_g_lms_campcheck_damage, self.health + self.armorvalue * autocvar_g_balance_armor_blockpercent + 5), DEATH_CAMP, self.origin, '0 0 0');
			}
			self.lms_nextcheck = time + autocvar_g_lms_campcheck_interval;
			self.lms_traveled_distance = 0;
		}
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_PlayerDamage)
{
	if(IS_PLAYER(frag_target))
	if(IS_PLAYER(frag_attacker))
	if(frag_attacker != frag_target)
	{
		frag_target.lms_traveled_distance = autocvar_g_lms_campcheck_distance;
		frag_attacker.lms_traveled_distance = autocvar_g_lms_campcheck_distance;
	}
		
	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_ForbidThrowing)
{
	// forbode!
	return TRUE;
}

MUTATOR_HOOKFUNCTION(lms_GiveFragsForKill)
{
	// remove a life
	float tl;
	tl = PlayerScore_Add(frag_target, SP_LMS_LIVES, -1);
	if(tl < lms_lowest_lives)
		lms_lowest_lives = tl;
	if(tl <= 0)
	{
		if(!lms_next_place)
			lms_next_place = player_count;
		else
			lms_next_place = min(lms_next_place, player_count);
		PlayerScore_Add(frag_target, SP_LMS_RANK, lms_next_place); // won't ever spawn again
		--lms_next_place;
	}
	frag_score = 0;
		
	return TRUE;
}

MUTATOR_HOOKFUNCTION(lms_SetStartItems)
{
	start_items &~= IT_UNLIMITED_AMMO;
	start_ammo_shells = cvar("g_lms_start_ammo_shells");
	start_ammo_nails = cvar("g_lms_start_ammo_nails");
	start_ammo_rockets = cvar("g_lms_start_ammo_rockets");
	start_ammo_cells = cvar("g_lms_start_ammo_cells");
	start_ammo_fuel = cvar("g_lms_start_ammo_fuel");
	start_health = cvar("g_lms_start_health");
	start_armorvalue = cvar("g_lms_start_armor");

	return FALSE;
}

MUTATOR_HOOKFUNCTION(lms_KeepScore)
{
	// don't clear player score
	return TRUE;
}

MUTATOR_HOOKFUNCTION(lms_FilterItem)
{
	if(autocvar_g_lms_extra_lives)
	if(self.classname == "item_health_mega")
	{
		self.max_health = 1;
		return FALSE;
	}
	
	return TRUE;
}

MUTATOR_HOOKFUNCTION(lms_ItemTouch)
{
	// give extra lives for mega health
	if(self.items & IT_HEALTH)
	{
		Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_EXTRALIVES);
		PlayerScore_Add(other, SP_LMS_LIVES, autocvar_g_lms_extra_lives);
	}
	
	return MUT_ITEMTOUCH_CONTINUE;
}

// scoreboard stuff
void lms_ScoreRules()
{
	ScoreRules_basics(0, 0, 0, FALSE);
	ScoreInfo_SetLabel_PlayerScore(SP_LMS_LIVES,    "lives",     SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_LMS_RANK,     "rank",      SFL_LOWER_IS_BETTER | SFL_RANK | SFL_SORT_PRIO_PRIMARY | SFL_ALLOW_HIDE);
	ScoreRules_basics_end();
}

void lms_Initialize()
{
	lms_lowest_lives = 9999;
	lms_next_place = 0;
	
	lms_ScoreRules();
}

MUTATOR_DEFINITION(gamemode_lms)
{
	MUTATOR_HOOK(reset_map_global, lms_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_players, lms_ResetPlayers, CBC_ORDER_ANY);
	MUTATOR_HOOK(PutClientInServer, lms_PlayerPreSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, lms_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, lms_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, lms_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientConnect, lms_ClientConnect, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, lms_PlayerThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, lms_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, lms_ForbidThrowing, CBC_ORDER_ANY);
	MUTATOR_HOOK(GiveFragsForKill, lms_GiveFragsForKill, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetStartItems, lms_SetStartItems, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidPlayerScore_Clear, lms_KeepScore, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, lms_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(ItemTouch, lms_ItemTouch, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		lms_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back lms_Initialize here
		// BUT: we don't need to! If this gets called, adding always
		// succeeds.
	}

	MUTATOR_ONREMOVE
	{
		print("This is a game type and it cannot be removed at runtime.");
		return -1;
	}

	return 0;
}
