// legacy bot roles
.float race_checkpoint;
void havocbot_role_cts()
{
	if(self.deadflag != DEAD_NO)
		return;

	entity e;
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + autocvar_bot_ai_strategyinterval;
		navigation_goalrating_start();

		for(e = world; (e = find(e, classname, "trigger_race_checkpoint")) != world; )
		{
			if(e.cnt == self.race_checkpoint)
			{
				navigation_routerating(e, 1000000, 5000);
			}
			else if(self.race_checkpoint == -1)
			{
				navigation_routerating(e, 1000000, 5000);
			}
		}

		navigation_goalrating_end();
	}
}

void cts_ScoreRules()
{
	ScoreRules_basics(0, 0, 0, FALSE);
	if(g_race_qualifying)
	{
		ScoreInfo_SetLabel_PlayerScore(SP_CTS_FASTEST, "fastest",   SFL_SORT_PRIO_PRIMARY | SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	else
	{
		ScoreInfo_SetLabel_PlayerScore(SP_CTS_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_CTS_TIME,    "time",      SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER | SFL_TIME);
		ScoreInfo_SetLabel_PlayerScore(SP_CTS_FASTEST, "fastest",   SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	ScoreRules_basics_end();
}

void cts_EventLog(string mode, entity actor) // use an alias for easy changing and quick editing later
{
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":cts:", mode, ":", ((actor != world) ? (strcat(":", ftos(actor.playerid))) : "")));
}

MUTATOR_HOOKFUNCTION(cts_PlayerPhysics)
{
	// force kbd movement for fairness
	float wishspeed;
	vector wishvel;

	// if record times matter
	// ensure nothing EVIL is being done (i.e. div0_evade)
	// this hinders joystick users though
	// but it still gives SOME analog control
	wishvel_x = fabs(self.movement_x);
	wishvel_y = fabs(self.movement_y);
	if(wishvel_x != 0 && wishvel_y != 0 && wishvel_x != wishvel_y)
	{
		wishvel_z = 0;
		wishspeed = vlen(wishvel);
		if(wishvel_x >= 2 * wishvel_y)
		{
			// pure X motion
			if(self.movement_x > 0)
				self.movement_x = wishspeed;
			else
				self.movement_x = -wishspeed;
			self.movement_y = 0;
		}
		else if(wishvel_y >= 2 * wishvel_x)
		{
			// pure Y motion
			self.movement_x = 0;
			if(self.movement_y > 0)
				self.movement_y = wishspeed;
			else
				self.movement_y = -wishspeed;
		}
		else
		{
			// diagonal
			if(self.movement_x > 0)
				self.movement_x = M_SQRT1_2 * wishspeed;
			else
				self.movement_x = -M_SQRT1_2 * wishspeed;
			if(self.movement_y > 0)
				self.movement_y = M_SQRT1_2 * wishspeed;
			else
				self.movement_y = -M_SQRT1_2 * wishspeed;
		}
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_ResetMap)
{
	float s;

	Score_NicePrint(world);

	race_ClearRecords();
	PlayerScore_Sort(race_place, 0, 1, 0);

	entity e;
	FOR_EACH_CLIENT(e)
	{
		if(e.race_place)
		{
			s = PlayerScore_Add(e, SP_RACE_FASTEST, 0);
			if(!s)
				e.race_place = 0;
		}
		cts_EventLog(ftos(e.race_place), e);
	}

	if(g_race_qualifying == 2)
	{
		g_race_qualifying = 0;
		independent_players = 0;
		cvar_set("fraglimit", ftos(race_fraglimit));
		cvar_set("leadlimit", ftos(race_leadlimit));
		cvar_set("timelimit", ftos(race_timelimit));
		cts_ScoreRules();
	}
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_PlayerPreThink)
{
	if(IS_SPEC(self) || IS_OBSERVER(self))
	if(g_race_qualifying)
	if(msg_entity.enemy.race_laptime)
		race_SendNextCheckpoint(msg_entity.enemy, 1);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_ClientConnect)
{
	race_PreparePlayer();
	self.race_checkpoint = -1;
	
	if(IS_REAL_CLIENT(self))
	{
		string rr = CTS_RECORD;

		msg_entity = self;
		race_send_recordtime(MSG_ONE);
		race_send_speedaward(MSG_ONE);

		speedaward_alltimebest = stof(db_get(ServerProgsDB, strcat(GetMapname(), rr, "speed/speed")));
		speedaward_alltimebest_holder = uid2name(db_get(ServerProgsDB, strcat(GetMapname(), rr, "speed/crypto_idfp")));
		race_send_speedaward_alltimebest(MSG_ONE);

		float i;
		for (i = 1; i <= RANKINGS_CNT; ++i)
		{
			race_SendRankings(i, 0, 0, MSG_ONE);
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_MakePlayerObserver)
{
	if(PlayerScore_Add(self, SP_RACE_FASTEST, 0))
		self.frags = FRAGS_LMS_LOSER;
	else
		self.frags = FRAGS_SPECTATOR;

	race_PreparePlayer();
	self.race_checkpoint = -1;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_PlayerSpawn)
{
	if(spawn_spot.target == "")
		// Emergency: this wasn't a real spawnpoint. Can this ever happen?
		race_PreparePlayer();

	// if we need to respawn, do it right
	self.race_respawn_checkpoint = self.race_checkpoint;
	self.race_respawn_spotref = spawn_spot;

	self.race_place = 0;
	
	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_PutClientInServer)
{
	if(IS_PLAYER(self))
	if(!gameover)
	{
		if(self.killcount == -666 /* initial spawn */ || g_race_qualifying) // spawn
			race_PreparePlayer();
		else // respawn
			race_RetractPlayer();

		race_AbandonRaceCheck(self);
	}
	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_PlayerDies)
{
	self.respawn_flags |= RESPAWN_FORCE;
	race_AbandonRaceCheck(self);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_BotRoles)
{
	self.havocbot_role = havocbot_role_cts;
	return TRUE;
}

MUTATOR_HOOKFUNCTION(cts_PlayerPostThink)
{
	if(self.cvar_cl_allow_uidtracking == 1 && self.cvar_cl_allow_uid2name == 1)
	{
		if (!self.stored_netname)
			self.stored_netname = strzone(uid2name(self.crypto_idfp));
		if(self.stored_netname != self.netname)
		{
			db_put(ServerProgsDB, strcat("/uid2name/", self.crypto_idfp), self.netname);
			strunzone(self.stored_netname);
			self.stored_netname = strzone(self.netname);
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_ForbidThrowing)
{
	// no weapon dropping in CTS
	return TRUE;
}

MUTATOR_HOOKFUNCTION(cts_FilterItem)
{
	if(self.classname == "droppedweapon")
		return TRUE;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_PlayerDamage)
{
	if(frag_target == frag_attacker || frag_deathtype == DEATH_FALL)
	if(!autocvar_g_cts_selfdamage)
		frag_damage = 0;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_ForbidClearPlayerScore)
{
	return TRUE; // in CTS, you don't lose score by observing
}

MUTATOR_HOOKFUNCTION(cts_SetMods)
{
	g_cloaked = 1; // always enable cloak in CTS

	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_WantWeapon)
{
	ret_float = (other.weapon == WEP_SHOTGUN);
	return FALSE;
}

MUTATOR_HOOKFUNCTION(cts_AllowMobSpawning)
{
	ret_string = "You cannot spawn monsters in CTS";
	return TRUE;
}

void cts_Initialize()
{
	cts_ScoreRules();
}

MUTATOR_DEFINITION(gamemode_cts)
{
	MUTATOR_HOOK(PlayerPhysics, cts_PlayerPhysics, CBC_ORDER_ANY);
	MUTATOR_HOOK(reset_map_global, cts_ResetMap, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, cts_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientConnect, cts_ClientConnect, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, cts_MakePlayerObserver, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, cts_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PutClientInServer, cts_PutClientInServer, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, cts_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(HavocBot_ChooseRole, cts_BotRoles, CBC_ORDER_ANY);
	MUTATOR_HOOK(GetPressedKeys, cts_PlayerPostThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, cts_ForbidThrowing, CBC_ORDER_ANY);
	MUTATOR_HOOK(FilterItem, cts_FilterItem, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDamage_Calculate, cts_PlayerDamage, CBC_ORDER_ANY);
	MUTATOR_HOOK(ForbidPlayerScore_Clear, cts_ForbidClearPlayerScore, CBC_ORDER_ANY);
	MUTATOR_HOOK(SetModname, cts_SetMods, CBC_ORDER_ANY);
	MUTATOR_HOOK(WantWeapon, cts_WantWeapon, CBC_ORDER_ANY);
	MUTATOR_HOOK(AllowMobSpawning, cts_AllowMobSpawning, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		if(time > 1) // game loads at time 1
			error("This is a game type and it cannot be added at runtime.");
		cts_Initialize();
	}

	MUTATOR_ONROLLBACK_OR_REMOVE
	{
		// we actually cannot roll back cts_Initialize here
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
