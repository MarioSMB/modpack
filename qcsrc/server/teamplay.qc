string cache_mutatormsg;
string cache_lastmutatormsg;

void TeamchangeFrags(entity e)
{
	PlayerScore_Clear(e);
}

void entcs_init();

void LogTeamchange(float player_id, float team_number, float type)
{
	if(!autocvar_sv_eventlog)
		return;

	if(player_id < 1)
		return;

	GameLogEcho(strcat(":team:", ftos(player_id), ":", ftos(team_number), ":", ftos(type)));
}

void default_delayedinit()
{
	if(!scores_initialized)
		ScoreRules_generic();
}

void ActivateTeamplay()
{
	serverflags |= SERVERFLAG_TEAMPLAY;
	teamplay = 1;
}

void InitGameplayMode()
{
	float fraglimit_override, timelimit_override, leadlimit_override, qualifying_override;

	qualifying_override = -1;

	VoteReset();

	// find out good world mins/maxs bounds, either the static bounds found by looking for solid, or the mapinfo specified bounds
	get_mi_min_max(1);
	world.mins = mi_min;
	world.maxs = mi_max;

	MapInfo_LoadMapSettings(mapname);
	teamplay = 0;
	serverflags &= ~SERVERFLAG_TEAMPLAY;

	if (!cvar_value_issafe(world.fog))
	{
		print("The current map contains a potentially harmful fog setting, ignored\n");
		world.fog = string_null;
	}
	if(MapInfo_Map_fog != "")
		if(MapInfo_Map_fog == "none")
			world.fog = string_null;
		else
			world.fog = strzone(MapInfo_Map_fog);
	clientstuff = strzone(MapInfo_Map_clientstuff);

	MapInfo_ClearTemps();

	// set both here, gamemode can override it later
	timelimit_override = autocvar_timelimit_override;
	fraglimit_override = autocvar_fraglimit_override;
	leadlimit_override = autocvar_leadlimit_override;
	gamemode_name = MapInfo_Type_ToText(MapInfo_LoadedGametype);

	if(g_dm)
	{
	}

	if(g_tdm)
	{
		ActivateTeamplay();
		MUTATOR_ADD(gamemode_tdm);

		if(autocvar_g_tdm_team_spawns)
			have_team_spawns = -1; // request team spawns
	}

	if(g_domination)
	{
		ActivateTeamplay();
		fraglimit_override = autocvar_g_domination_point_limit;
		leadlimit_override = autocvar_g_domination_point_leadlimit;
		MUTATOR_ADD(gamemode_domination);

		if(autocvar_g_domination_roundbased && autocvar_g_domination_roundbased_point_limit)
			fraglimit_override = autocvar_g_domination_roundbased_point_limit;

		have_team_spawns = -1; // request team spawns
	}

	if(g_ctf)
	{
		ActivateTeamplay();
		fraglimit_override = autocvar_capturelimit_override;
		leadlimit_override = autocvar_captureleadlimit_override;
		MUTATOR_ADD(gamemode_ctf);
		have_team_spawns = -1; // request team spawns
	}

	if(g_lms)
	{
		fraglimit_override = autocvar_g_lms_lives_override;
		leadlimit_override = 0; // not supported by LMS
		if(fraglimit_override == 0)
			fraglimit_override = -1;
		MUTATOR_ADD(gamemode_lms);
	}

	if(g_ca)
	{
		ActivateTeamplay();
		fraglimit_override = autocvar_g_ca_point_limit;
		leadlimit_override = autocvar_g_ca_point_leadlimit;
		MUTATOR_ADD(gamemode_ca);
		if(autocvar_g_ca_team_spawns)
			have_team_spawns = -1; // request team spawns
	}

	if(g_keyhunt)
	{
		ActivateTeamplay();
		fraglimit_override = autocvar_g_keyhunt_point_limit;
		leadlimit_override = autocvar_g_keyhunt_point_leadlimit;
		if(autocvar_g_keyhunt_team_spawns)
			have_team_spawns = -1; // request team spawns
		MUTATOR_ADD(gamemode_keyhunt);
	}

	if(g_freezetag)
	{
		ActivateTeamplay();
		fraglimit_override = autocvar_g_freezetag_point_limit;
		leadlimit_override = autocvar_g_freezetag_point_leadlimit;
		MUTATOR_ADD(gamemode_freezetag);
		if(autocvar_g_freezetag_team_spawns)
			have_team_spawns = -1; // request team spawns
	}

	if(g_assault)
	{
		ActivateTeamplay();
		MUTATOR_ADD(gamemode_assault);
		have_team_spawns = -1; // request team spawns
	}

	if(g_onslaught)
	{
		ActivateTeamplay();
		have_team_spawns = -1; // request team spawns
		MUTATOR_ADD(gamemode_onslaught);
	}

	if(g_race)
	{
		if(autocvar_g_race_teams)
		{
			ActivateTeamplay();
			race_teams = bound(2, autocvar_g_race_teams, 4);
			have_team_spawns = -1; // request team spawns
		}
		else
			race_teams = 0;

		qualifying_override = autocvar_g_race_qualifying_timelimit_override;
		fraglimit_override = autocvar_g_race_laps_limit;
		leadlimit_override = 0; // currently not supported by race

		MUTATOR_ADD(gamemode_race);
	}

	if(g_cts)
	{
		g_race_qualifying = 1;
		fraglimit_override = 0;
		leadlimit_override = 0;
		MUTATOR_ADD(gamemode_cts);
	}

	if(g_nexball)
	{
        fraglimit_override = autocvar_g_nexball_goallimit;
        leadlimit_override = autocvar_g_nexball_goalleadlimit;
        ActivateTeamplay();
        have_team_spawns = -1; // request team spawns
	    MUTATOR_ADD(gamemode_nexball);
	}

	if(g_keepaway)
	{
		fraglimit_override = autocvar_g_keepaway_point_limit;
		MUTATOR_ADD(gamemode_keepaway);
	}

	if(g_vip)
	{
		fraglimit_override = autocvar_g_vip_point_limit;
		leadlimit_override = autocvar_g_vip_point_leadlimit;
		ActivateTeamplay();
		have_team_spawns = -1; // request team spawns
		MUTATOR_ADD(gamemode_vip);
	}

	if(g_invasion)
	{
		timelimit_override = 0; // no timelimit in invasion, round based
		fraglimit_override = autocvar_g_invasion_round_limit;
		MUTATOR_ADD(gamemode_invasion);
	}

	if(g_infection)
	{
		fraglimit_override = autocvar_g_infection_point_limit;
		leadlimit_override = autocvar_g_infection_point_leadlimit;
		ActivateTeamplay();
		if(autocvar_g_infection_team_spawns)
			have_team_spawns = -1; // request team spawns
		MUTATOR_ADD(gamemode_infection);
	}

	if(g_jailbreak)
	{
		fraglimit_override = autocvar_g_jailbreak_point_limit;
		leadlimit_override = autocvar_g_jailbreak_point_leadlimit;
		ActivateTeamplay();
		have_team_spawns = -1; // request team spawns
		MUTATOR_ADD(gamemode_jailbreak);
	}

	if(teamplay)
		entcs_init();

	cache_mutatormsg = strzone("");
	cache_lastmutatormsg = strzone("");

	// enforce the server's universal frag/time limits
	if(!autocvar_g_campaign)
	{
		if(fraglimit_override >= 0)
			cvar_set("fraglimit", ftos(fraglimit_override));
		if(timelimit_override >= 0)
			cvar_set("timelimit", ftos(timelimit_override));
		if(leadlimit_override >= 0)
			cvar_set("leadlimit", ftos(leadlimit_override));
		if(qualifying_override >= 0)
			cvar_set("g_race_qualifying_timelimit", ftos(qualifying_override));
	}

	if(g_race)
	{
		// we need to find out the correct value for g_race_qualifying
		if(autocvar_g_campaign)
		{
			g_race_qualifying = 1;
		}
		else if(!autocvar_g_campaign && autocvar_g_race_qualifying_timelimit > 0)
		{
			g_race_qualifying = 2;
			race_fraglimit = autocvar_fraglimit;
			race_leadlimit = autocvar_leadlimit;
			race_timelimit = autocvar_timelimit;
			cvar_set("fraglimit", "0");
			cvar_set("leadlimit", "0");
			cvar_set("timelimit", ftos(autocvar_g_race_qualifying_timelimit));
		}
		else
			g_race_qualifying = 0;
	}

	if(g_invasion)
	{
		inv_maxrounds = cvar("fraglimit");
		cvar_set("fraglimit", "0");
	}

	if(g_race || g_cts)
	if(g_race_qualifying)
		independent_players = 1;

	InitializeEntity(world, default_delayedinit, INITPRIO_GAMETYPE_FALLBACK);
}

string GetClientVersionMessage() {
	string versionmsg;
	if (self.version_mismatch) {
		if(self.version < autocvar_gameversion) {
			versionmsg = "^3Your client version is outdated.\n\n\n### YOU WON'T BE ABLE TO PLAY ON THIS SERVER ###\n\n\nPlease update!!!^8";
		} else {
			versionmsg = "^3This server is using an outdated Xonotic version.\n\n\n ### THIS SERVER IS INCOMPATIBLE AND THUS YOU CANNOT JOIN ###.^8";
		}
	} else {
		versionmsg = "^2client version and server version are compatible.^8";
	}
	return versionmsg;
}

string getwelcomemessage(void)
{
	string s, modifications, motd;

	ret_string = "";
	MUTATOR_CALLHOOK(BuildMutatorsPrettyString);
	modifications = ret_string;

	if(g_weaponarena)
	{
		if(g_weaponarena_random)
			modifications = strcat(modifications, ", ", ftos(g_weaponarena_random), " of ", g_weaponarena_list, " Arena");
		else
			modifications = strcat(modifications, ", ", g_weaponarena_list, " Arena");
	}
	if(autocvar_g_start_weapon_laser == 0)
		modifications = strcat(modifications, ", No start weapons");
	if(cvar("sv_gravity") < stof(cvar_defstring("sv_gravity")))
		modifications = strcat(modifications, ", Low gravity");
	if(g_cloaked && !g_cts)
		modifications = strcat(modifications, ", Cloaked");
	if(g_grappling_hook)
		modifications = strcat(modifications, ", Hook");
	if(g_weapon_stay && !g_cts)
		modifications = strcat(modifications, ", Weapons stay");
	if(g_jetpack)
		modifications = strcat(modifications, ", Jet pack");
	if(autocvar_g_powerups == 0)
		modifications = strcat(modifications, ", No powerups");
	if(autocvar_g_powerups > 0)
		modifications = strcat(modifications, ", Powerups");
	modifications = substring(modifications, 2, strlen(modifications) - 2);

	string versionmessage;
	versionmessage = GetClientVersionMessage();

	s = strcat("This is Xonotic ", autocvar_g_xonoticversion, "\n", versionmessage);
	s = strcat(s, "^8\n\nmatch type is ^1", gamemode_name, "^8\n");

	if(modifications != "")
		s = strcat(s, "^8\nactive modifications: ^3", modifications, "^8\n");

	if (g_grappling_hook)
		s = strcat(s, "\n\n^3grappling hook^8 is enabled, press 'e' to use it\n");

	if (cvar("g_nades"))
		s = strcat(s, "\n\n^3nades^8 are enabled, press 'g' to use them\n");

	if(cache_lastmutatormsg != autocvar_g_mutatormsg)
	{
		if(cache_lastmutatormsg)
			strunzone(cache_lastmutatormsg);
		if(cache_mutatormsg)
			strunzone(cache_mutatormsg);
		cache_lastmutatormsg = strzone(autocvar_g_mutatormsg);
		cache_mutatormsg = strzone(cache_lastmutatormsg);
	}

	if (cache_mutatormsg != "") {
		s = strcat(s, "\n\n^8special gameplay tips: ^7", cache_mutatormsg);
	}

	motd = autocvar_sv_motd;
	if (motd != "") {
		s = strcat(s, "\n\n^8MOTD: ^7", strreplace("\\n", "\n", motd));
	}
	return s;
}

void SetPlayerColors(entity pl, float _color)
{
	/*string s;
	s = ftos(cl);
	stuffcmd(pl, strcat("color ", s, " ", s, "\n")  );
	pl.team = cl + 1;
	//pl.clientcolors = pl.clientcolors - (pl.clientcolors & 15) + cl;
	pl.clientcolors = 16*cl + cl;*/

	float pants, shirt;
	pants = _color & 0x0F;
	shirt = _color & 0xF0;


	if(teamplay) {
		setcolor(pl, 16*pants + pants);
	} else {
		setcolor(pl, shirt + pants);
	}
}

void SetPlayerTeam(entity pl, float t, float s, float noprint)
{
	float _color;

	if(t == 4)
		_color = NUM_TEAM_4 - 1;
	else if(t == 3)
		_color = NUM_TEAM_3 - 1;
	else if(t == 2)
		_color = NUM_TEAM_2 - 1;
	else
		_color = NUM_TEAM_1 - 1;

	SetPlayerColors(pl,_color);

	if(t != s) {
		LogTeamchange(pl.playerid, pl.team, 3);  // log manual team join

		if(!noprint)
		bprint(pl.netname, "^7 has changed from ", Team_NumberToColoredFullName(s), "^7 to ", Team_NumberToColoredFullName(t), "\n");
	}

}

// set c1...c4 to show what teams are allowed
void CheckAllowedTeams (entity for_whom)
{
	float dm = 2;
	entity head;
	string teament_name = string_null;

	c1 = c2 = c3 = c4 = -1;
	cb1 = cb2 = cb3 = cb4 = 0;

	ret_string = teament_name;
	ret_float = dm;
	float mutator_value = MUTATOR_CALLHOOK(GetTeamCount);
	teament_name = ret_string;
	dm = ret_float;

	if(!mutator_value)
	{
		if(dm >= 4)
			c1 = c2 = c3 = c4 = 0;
		else if(dm >= 3)
			c1 = c2 = c3 = 0;
		else
			c1 = c2 = 0;
	}

	// find out what teams are allowed if necessary
	if(teament_name)
	{
		head = find(world, classname, teament_name);
		while(head)
		{
			if(!(g_domination && head.netname == ""))
			{
				switch(head.team)
				{
					case NUM_TEAM_1: c1 = 0; break;
					case NUM_TEAM_2: c2 = 0; break;
					case NUM_TEAM_3: c3 = 0; break;
					case NUM_TEAM_4: c4 = 0; break;
				}
			}
			head = find(head, classname, teament_name);
		}
	}

	// TODO: Balance quantity of bots across > 2 teams when bot_vs_human is set (and remove next line)
	if(c3==-1 && c4==-1)
	if(autocvar_bot_vs_human && for_whom)
	{
		if(autocvar_bot_vs_human > 0)
		{
			// bots are all blue
			if(IS_BOT_CLIENT(for_whom))
				c1 = c3 = c4 = -1;
			else
				c2 = -1;
		}
		else
		{
			// bots are all red
			if(IS_BOT_CLIENT(for_whom))
				c2 = c3 = c4 = -1;
			else
				c1 = -1;
		}
	}

	// if player has a forced team, ONLY allow that one
	if(self.team_forced == NUM_TEAM_1 && c1 >= 0)
		c2 = c3 = c4 = -1;
	else if(self.team_forced == NUM_TEAM_2 && c2 >= 0)
		c1 = c3 = c4 = -1;
	else if(self.team_forced == NUM_TEAM_3 && c3 >= 0)
		c1 = c2 = c4 = -1;
	else if(self.team_forced == NUM_TEAM_4 && c4 >= 0)
		c1 = c2 = c3 = -1;
}

float PlayerValue(entity p)
{
	return 1;
	// FIXME: it always returns 1...
}

// c1...c4 should be set to -1 (not allowed) or 0 (allowed).
// teams that are allowed will now have their player counts stored in c1...c4
void GetTeamCounts(entity ignore)
{
	entity head;
	float value, bvalue;
	// now count how many players are on each team already

	// FIXME: also find and memorize the lowest-scoring bot on each team (in case players must be shuffled around)
	// also remember the lowest-scoring player

	FOR_EACH_CLIENT(head)
	{
		float t;
		if(g_infection && head.inf_realteam)
		{	
			if(IS_PLAYER(head))
				t = head.inf_realteam;
			else if(head.team_forced > 0)
				t = head.team_forced; // reserved
			else continue;
		}
		else if(IS_PLAYER(head))
			t = head.team;
		else if(head.team_forced > 0)
			t = head.team_forced; // reserve the spot
		else
			continue;
		if(head != ignore)// && head.netname != "")
		{
			value = PlayerValue(head);
			if(IS_BOT_CLIENT(head))
				bvalue = value;
			else
				bvalue = 0;
			if(t == NUM_TEAM_1)
			{
				if(c1 >= 0)
				{
					c1 = c1 + value;
					cb1 = cb1 + bvalue;
				}
			}
			if(t == NUM_TEAM_2)
			{
				if(c2 >= 0)
				{
					c2 = c2 + value;
					cb2 = cb2 + bvalue;
				}
			}
			if(t == NUM_TEAM_3)
			{
				if(c3 >= 0)
				{
					c3 = c3 + value;
					cb3 = cb3 + bvalue;
				}
			}
			if(t == NUM_TEAM_4)
			{
				if(c4 >= 0)
				{
					c4 = c4 + value;
					cb4 = cb4 + bvalue;
				}
			}
		}
	}

	// if the player who has a forced team has not joined yet, reserve the spot
	if(autocvar_g_campaign)
	{
		switch(autocvar_g_campaign_forceteam)
		{
			case 1: if(c1 == cb1) ++c1; break;
			case 2: if(c2 == cb2) ++c2; break;
			case 3: if(c3 == cb3) ++c3; break;
			case 4: if(c4 == cb4) ++c4; break;
		}
	}
}

float TeamSmallerEqThanTeam(float ta, float tb, entity e)
{
	// we assume that CheckAllowedTeams and GetTeamCounts have already been called
	float f;
	float ca = -1, cb = -1, cba = 0, cbb = 0, sa = 0, sb = 0;

	switch(ta)
	{
		case 1: ca = c1; cba = cb1; sa = team1_score; break;
		case 2: ca = c2; cba = cb2; sa = team2_score; break;
		case 3: ca = c3; cba = cb3; sa = team3_score; break;
		case 4: ca = c4; cba = cb4; sa = team4_score; break;
	}
	switch(tb)
	{
		case 1: cb = c1; cbb = cb1; sb = team1_score; break;
		case 2: cb = c2; cbb = cb2; sb = team2_score; break;
		case 3: cb = c3; cbb = cb3; sb = team3_score; break;
		case 4: cb = c4; cbb = cb4; sb = team4_score; break;
	}

	// invalid
	if(ca < 0 || cb < 0)
		return FALSE;

	// equal
	if(ta == tb)
		return TRUE;

	if(IS_REAL_CLIENT(e))
	{
		if(bots_would_leave)
		{
			ca -= cba * 0.999;
			cb -= cbb * 0.999;
		}
	}

	// keep teams alive (teams of size 0 always count as smaller, ignoring score)
	if(ca < 1)
		if(cb >= 1)
			return TRUE;
	if(ca >= 1)
		if(cb < 1)
			return FALSE;

	// first, normalize
	f = max(ca, cb, 1);
	ca /= f;
	cb /= f;
	f = max(sa, sb, 1);
	sa /= f;
	sb /= f;

	// the more we're at the end of the match, the more take scores into account
	f = bound(0, game_completion_ratio * autocvar_g_balance_teams_scorefactor, 1);
	ca += (sa - ca) * f;
	cb += (sb - cb) * f;

	return ca <= cb;
}

// returns # of smallest team (1, 2, 3, 4)
// NOTE: Assumes CheckAllowedTeams has already been called!
float FindSmallestTeam(entity pl, float ignore_pl)
{
	float totalteams, t;
	totalteams = 0;

	// find out what teams are available
	//CheckAllowedTeams();

	// make sure there are at least 2 teams to join
	if(c1 >= 0)
		totalteams = totalteams + 1;
	if(c2 >= 0)
		totalteams = totalteams + 1;
	if(c3 >= 0)
		totalteams = totalteams + 1;
	if(c4 >= 0)
		totalteams = totalteams + 1;

	if((autocvar_bot_vs_human || pl.team_forced > 0) && totalteams == 1)
		totalteams += 1;

	if(totalteams <= 1)
	{
		if(autocvar_g_campaign && pl && IS_REAL_CLIENT(pl))
			return 1; // special case for campaign and player joining
		else
			error(sprintf("Too few teams available for %s\n", MapInfo_Type_ToString(MapInfo_CurrentGametype())));
	}

	// count how many players are in each team
	if(ignore_pl)
		GetTeamCounts(pl);
	else
		GetTeamCounts(world);

	RandomSelection_Init();

	t = 1;
	if(TeamSmallerEqThanTeam(2, t, pl))
		t = 2;
	if(TeamSmallerEqThanTeam(3, t, pl))
		t = 3;
	if(TeamSmallerEqThanTeam(4, t, pl))
		t = 4;

	// now t is the minimum, or A minimum!
	if(t == 1 || TeamSmallerEqThanTeam(1, t, pl))
		RandomSelection_Add(world, 1, string_null, 1, 1);
	if(t == 2 || TeamSmallerEqThanTeam(2, t, pl))
		RandomSelection_Add(world, 2, string_null, 1, 1);
	if(t == 3 || TeamSmallerEqThanTeam(3, t, pl))
		RandomSelection_Add(world, 3, string_null, 1, 1);
	if(t == 4 || TeamSmallerEqThanTeam(4, t, pl))
		RandomSelection_Add(world, 4, string_null, 1, 1);

	return RandomSelection_chosen_float;
}

float JoinBestTeam(entity pl, float only_return_best, float forcebestteam)
{
	float smallest, selectedteam;

	// don't join a team if we're not playing a team game
	if(!teamplay)
		return 0;

	// find out what teams are available
	CheckAllowedTeams(pl);

	// if we don't care what team he ends up on, put him on whatever team he entered as.
	// if he's not on a valid team, then let other code put him on the smallest team
	if(!forcebestteam)
	{
		if(     c1 >= 0 && pl.team == NUM_TEAM_1)
			selectedteam = pl.team;
		else if(c2 >= 0 && pl.team == NUM_TEAM_2)
			selectedteam = pl.team;
		else if(c3 >= 0 && pl.team == NUM_TEAM_3)
			selectedteam = pl.team;
		else if(c4 >= 0 && pl.team == NUM_TEAM_4)
			selectedteam = pl.team;
		else
			selectedteam = -1;

		if(selectedteam > 0)
		{
			if(!only_return_best)
			{
				SetPlayerColors(pl, selectedteam - 1);

				// when JoinBestTeam is called by client.qc/ClientKill_Now_TeamChange the players team is -1 and thus skipped
				// when JoinBestTeam is called by cl_client.qc/ClientConnect the player_id is 0 the log attempt is rejected
				LogTeamchange(pl.playerid, pl.team, 99);
			}
			return selectedteam;
		}
		// otherwise end up on the smallest team (handled below)
	}

	smallest = FindSmallestTeam(pl, TRUE);

	if(!only_return_best && !pl.bot_forced_team)
	{
		TeamchangeFrags(self);
		if(smallest == 1)
		{
			SetPlayerColors(pl, NUM_TEAM_1 - 1);
		}
		else if(smallest == 2)
		{
			SetPlayerColors(pl, NUM_TEAM_2 - 1);
		}
		else if(smallest == 3)
		{
			SetPlayerColors(pl, NUM_TEAM_3 - 1);
		}
		else if(smallest == 4)
		{
			SetPlayerColors(pl, NUM_TEAM_4 - 1);
		}
		else
		{
			error("smallest team: invalid team\n");
		}

		LogTeamchange(pl.playerid, pl.team, 2); // log auto join

		if(pl.deadflag == DEAD_NO)
			Damage(pl, pl, pl, 100000, DEATH_TEAMCHANGE, pl.origin, '0 0 0');
	}

	return smallest;
}

//void() ctf_playerchanged;
void SV_ChangeTeam(float _color)
{
	float scolor, dcolor, steam, dteam; //, dbotcount, scount, dcount;

	// in normal deathmatch we can just apply the color and we're done
	if(!teamplay) {
		SetPlayerColors(self, _color);
		return;
	}

	scolor = self.clientcolors & 0x0F;
	dcolor = _color & 0x0F;

	if(scolor == NUM_TEAM_1 - 1)
		steam = 1;
	else if(scolor == NUM_TEAM_2 - 1)
		steam = 2;
	else if(scolor == NUM_TEAM_3 - 1)
		steam = 3;
	else // if(scolor == NUM_TEAM_4 - 1)
		steam = 4;
	if(dcolor == NUM_TEAM_1 - 1)
		dteam = 1;
	else if(dcolor == NUM_TEAM_2 - 1)
		dteam = 2;
	else if(dcolor == NUM_TEAM_3 - 1)
		dteam = 3;
	else // if(dcolor == NUM_TEAM_4 - 1)
		dteam = 4;

	CheckAllowedTeams(self);

	if(dteam == 1 && c1 < 0) dteam = 4;
	if(dteam == 4 && c4 < 0) dteam = 3;
	if(dteam == 3 && c3 < 0) dteam = 2;
	if(dteam == 2 && c2 < 0) dteam = 1;

	// not changing teams
	if(scolor == dcolor)
	{
		//bprint("same team change\n");
		SetPlayerTeam(self, dteam, steam, TRUE);
		return;
	}

	if((autocvar_g_campaign) || (autocvar_g_changeteam_banned && self.wasplayer)) {
		sprint(self, "Team changes not allowed\n");
		return; // changing teams is not allowed
	}

	// autocvar_g_balance_teams_prevent_imbalance only makes sense if autocvar_g_balance_teams is on, as it makes the team selection dialog pointless
	if(autocvar_g_balance_teams && autocvar_g_balance_teams_prevent_imbalance)
	{
		GetTeamCounts(self);
		if(!TeamSmallerEqThanTeam(dteam, steam, self))
		{
			sprint(self, "Cannot change to a larger/better/shinier team\n");
			return;
		}
	}

//	bprint("allow change teams from ", ftos(steam), " to ", ftos(dteam), "\n");

	if(IS_PLAYER(self) && steam != dteam)
	{
		// reduce frags during a team change
		TeamchangeFrags(self);
	}

	SetPlayerTeam(self, dteam, steam, FALSE);

	if(IS_PLAYER(self) && steam != dteam)
	{
		// kill player when changing teams
		if(self.deadflag == DEAD_NO)
			Damage(self, self, self, 100000, DEATH_TEAMCHANGE, self.origin, '0 0 0');
	}
}

void ShufflePlayerOutOfTeam (float source_team)
{
	float smallestteam, smallestteam_count, steam;
	float lowest_bot_score, lowest_player_score;
	entity head, lowest_bot, lowest_player, selected;

	smallestteam = 0;
	smallestteam_count = 999999999;

	if(c1 >= 0 && c1 < smallestteam_count)
	{
		smallestteam = 1;
		smallestteam_count = c1;
	}
	if(c2 >= 0 && c2 < smallestteam_count)
	{
		smallestteam = 2;
		smallestteam_count = c2;
	}
	if(c3 >= 0 && c3 < smallestteam_count)
	{
		smallestteam = 3;
		smallestteam_count = c3;
	}
	if(c4 >= 0 && c4 < smallestteam_count)
	{
		smallestteam = 4;
		smallestteam_count = c4;
	}

	if(!smallestteam)
	{
		bprint("warning: no smallest team\n");
		return;
	}

	if(source_team == 1)
		steam = NUM_TEAM_1;
	else if(source_team == 2)
		steam = NUM_TEAM_2;
	else if(source_team == 3)
		steam = NUM_TEAM_3;
	else // if(source_team == 4)
		steam = NUM_TEAM_4;

	lowest_bot = world;
	lowest_bot_score = 999999999;
	lowest_player = world;
	lowest_player_score = 999999999;

	// find the lowest-scoring player & bot of that team
	FOR_EACH_PLAYER(head)
	{
		if(head.team == steam)
		{
			if(head.isbot)
			{
				if(head.totalfrags < lowest_bot_score)
				{
					lowest_bot = head;
					lowest_bot_score = head.totalfrags;
				}
			}
			else
			{
				if(head.totalfrags < lowest_player_score)
				{
					lowest_player = head;
					lowest_player_score = head.totalfrags;
				}
			}
		}
	}

	// prefers to move a bot...
	if(lowest_bot != world)
		selected = lowest_bot;
	// but it will move a player if it has to
	else
		selected = lowest_player;
	// don't do anything if it couldn't find anyone
	if(!selected)
	{
		bprint("warning: couldn't find a player to move from team\n");
		return;
	}

	// smallest team gains a member
	if(smallestteam == 1)
	{
		c1 = c1 + 1;
	}
	else if(smallestteam == 2)
	{
		c2 = c2 + 1;
	}
	else if(smallestteam == 3)
	{
		c3 = c3 + 1;
	}
	else if(smallestteam == 4)
	{
		c4 = c4 + 1;
	}
	else
	{
		bprint("warning: destination team invalid\n");
		return;
	}
	// source team loses a member
	if(source_team == 1)
	{
		c1 = c1 + 1;
	}
	else if(source_team == 2)
	{
		c2 = c2 + 2;
	}
	else if(source_team == 3)
	{
		c3 = c3 + 3;
	}
	else if(source_team == 4)
	{
		c4 = c4 + 4;
	}
	else
	{
		bprint("warning: source team invalid\n");
		return;
	}

	// move the player to the new team
	TeamchangeFrags(selected);
	SetPlayerTeam(selected, smallestteam, source_team, FALSE);

	if(selected.deadflag == DEAD_NO)
		Damage(selected, selected, selected, 100000, DEATH_AUTOTEAMCHANGE, selected.origin, '0 0 0');
	Send_Notification(NOTIF_ONE, selected, MSG_CENTER, CENTER_DEATH_SELF_AUTOTEAMCHANGE, selected.team);
}
