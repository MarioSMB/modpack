.entity scorekeeper;
entity teamscorekeepers[16];
string scores_label[MAX_SCORE];
float scores_flags[MAX_SCORE];
string teamscores_label[MAX_TEAMSCORE];
float teamscores_flags[MAX_TEAMSCORE];
float teamscores_entities_count;
var .float scores_primary;
var .float teamscores_primary;
float scores_flags_primary;
float teamscores_flags_primary;

vector ScoreField_Compare(entity t1, entity t2, .float field, float fieldflags, vector previous, float strict) // returns: cmp value, best prio
{
	if(!strict && !(fieldflags & SFL_SORT_PRIO_MASK)) // column does not sort
		return previous;
	if(fieldflags & SFL_SORT_PRIO_MASK < previous_y)
		return previous;
	if(t1.field == t2.field)
		return previous;

	previous_y = fieldflags & SFL_SORT_PRIO_MASK;

	if(fieldflags & SFL_ZERO_IS_WORST)
	{
		if(t1.field == 0)
		{
			previous_x = -1;
			return previous;
		}
		else if(t2.field == 0)
		{
			previous_x = +1;
			return previous;
		}
	}

	if(fieldflags & SFL_LOWER_IS_BETTER)
		previous_x = (t2.field - t1.field);
	else
		previous_x = (t1.field - t2.field);

	return previous;
}

/*
 * teamscore entities
 */

float TeamScore_SendEntity(entity to, float sendflags)
{
	float i, p, longflags;

	WriteByte(MSG_ENTITY, ENT_CLIENT_TEAMSCORES);
	WriteByte(MSG_ENTITY, self.team - 1);

	longflags = 0;
	for(i = 0, p = 1; i < MAX_TEAMSCORE; ++i, p *= 2)
		if(self.(teamscores[i]) > 127 || self.(teamscores[i]) <= -128)
			longflags |= p;

#if MAX_TEAMSCORE <= 8
	WriteByte(MSG_ENTITY, sendflags);
	WriteByte(MSG_ENTITY, longflags);
#else
	WriteShort(MSG_ENTITY, sendflags);
	WriteShort(MSG_ENTITY, longflags);
#endif
	for(i = 0, p = 1; i < MAX_TEAMSCORE; ++i, p *= 2)
		if(sendflags & p)
		{
			if(longflags & p)
				WriteInt24_t(MSG_ENTITY, self.(teamscores[i]));
			else
				WriteChar(MSG_ENTITY, self.(teamscores[i]));
		}

	return TRUE;
}

void TeamScore_Spawn(float t, string name)
{
	entity ts;
	ts = spawn();
	ts.classname = "csqc_score_team";
	ts.netname = name; // not used yet, FIXME
	ts.team = t;
	Net_LinkEntity(ts, FALSE, 0, TeamScore_SendEntity);
	teamscorekeepers[t - 1] = ts;
	++teamscores_entities_count;
	PlayerStats_AddTeam(t);
}

float TeamScore_AddToTeam(float t, float scorefield, float score)
{
	entity s;

	if(gameover)
		score = 0;

	if(!scores_initialized) return 0; // FIXME remove this when everything uses this system
	if(t <= 0 || t >= 16)
	{
		if(gameover)
			return 0;
		error("Adding score to invalid team!");
	}
	s = teamscorekeepers[t - 1];
	if(!s)
	{
		if(gameover)
			return 0;
		error("Adding score to unknown team!");
	}
	if(score)
		if(teamscores_label[scorefield] != "")
			s.SendFlags |= pow(2, scorefield);
	return (s.(teamscores[scorefield]) += score);
}

float TeamScore_Add(entity player, float scorefield, float score)
{
	return TeamScore_AddToTeam(player.team, scorefield, score);
}

float TeamScore_Compare(entity t1, entity t2, float strict)
{
	if(!t1 || !t2) return (!t2) - !t1;

	vector result = '0 0 0';
	float i;
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		var .float f;
		f = teamscores[i];
		result = ScoreField_Compare(t1, t2, f, teamscores_flags[i], result, strict);
	}

	if (result_x == 0 && strict)
		result_x = t1.team - t2.team;

	return result_x;
}

/*
 * the scoreinfo entity
 */

void ScoreInfo_SetLabel_PlayerScore(float i, string label, float scoreflags)
{
	scores_label[i] = label;
	scores_flags[i] = scoreflags;
	if(scoreflags & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
	{
		scores_primary = scores[i];
		scores_flags_primary = scoreflags;
	}
	if(label != "")
	{
		PlayerStats_AddEvent(strcat(PLAYERSTATS_TOTAL, label));
		PlayerStats_AddEvent(strcat(PLAYERSTATS_SCOREBOARD, label));
	}
}

void ScoreInfo_SetLabel_TeamScore(float i, string label, float scoreflags)
{
	teamscores_label[i] = label;
	teamscores_flags[i] = scoreflags;
	if(scoreflags & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
	{
		teamscores_primary = teamscores[i];
		teamscores_flags_primary = scoreflags;
	}
	if(label != "")
	{
		PlayerStats_AddEvent(strcat(PLAYERSTATS_TOTAL, label));
		PlayerStats_AddEvent(strcat(PLAYERSTATS_SCOREBOARD, label));
	}
}

float ScoreInfo_SendEntity(entity to, float sf)
{
	float i;
	WriteByte(MSG_ENTITY, ENT_CLIENT_SCORES_INFO);
	WriteInt24_t(MSG_ENTITY, MapInfo_LoadedGametype);
	for(i = 0; i < MAX_SCORE; ++i)
	{
		WriteString(MSG_ENTITY, scores_label[i]);
		WriteByte(MSG_ENTITY, scores_flags[i]);
	}
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		WriteString(MSG_ENTITY, teamscores_label[i]);
		WriteByte(MSG_ENTITY, teamscores_flags[i]);
	}
	return TRUE;
}

void ScoreInfo_Init(float teams)
{
	if(scores_initialized)
	{
		scores_initialized.SendFlags |= 1; // force a resend
	}
	else
	{
		scores_initialized = spawn();
		scores_initialized.classname = "ent_client_scoreinfo";
		Net_LinkEntity(scores_initialized, FALSE, 0, ScoreInfo_SendEntity);
	}
	if(teams >= 1)
		TeamScore_Spawn(NUM_TEAM_1, "Red");
	if(teams >= 2)
		TeamScore_Spawn(NUM_TEAM_2, "Blue");
	if(teams >= 3)
		TeamScore_Spawn(NUM_TEAM_3, "Yellow");
	if(teams >= 4)
		TeamScore_Spawn(NUM_TEAM_4, "Pink");
}

/*
 * per-player score entities
 */

float PlayerScore_SendEntity(entity to, float sendflags)
{
	float i, p, longflags;

	WriteByte(MSG_ENTITY, ENT_CLIENT_SCORES);
	WriteByte(MSG_ENTITY, num_for_edict(self.owner));

	longflags = 0;
	for(i = 0, p = 1; i < MAX_SCORE; ++i, p *= 2)
		if(self.(scores[i]) > 127 || self.(scores[i]) <= -128)
			longflags |= p;

#if MAX_SCORE <= 8
	WriteByte(MSG_ENTITY, sendflags);
	WriteByte(MSG_ENTITY, longflags);
#else
	WriteShort(MSG_ENTITY, sendflags);
	WriteShort(MSG_ENTITY, longflags);
#endif
	for(i = 0, p = 1; i < MAX_SCORE; ++i, p *= 2)
		if(sendflags & p)
		{
			if(longflags & p)
				WriteInt24_t(MSG_ENTITY, self.(scores[i]));
			else
				WriteChar(MSG_ENTITY, self.(scores[i]));
		}

	return TRUE;
}

float PlayerScore_Clear(entity player)
{
	entity sk;
	float i;

	if(teamscores_entities_count)
		return 0;

	if(MUTATOR_CALLHOOK(ForbidPlayerScore_Clear)) return 0;

	if(g_cts) return 0; // in CTS, you don't lose score by observing
	if(g_race && g_race_qualifying) return 0; // in qualifying, you don't lose score by observing

	sk = player.scorekeeper;
	for(i = 0; i < MAX_SCORE; ++i)
	{
		if(sk.(scores[i]) != 0)
			if(scores_label[i] != "")
				sk.SendFlags |= pow(2, i);
		sk.(scores[i]) = 0;
	}

	return 1;
}

void Score_ClearAll()
{
	entity p, sk;
	float i, t;
	FOR_EACH_CLIENTSLOT(p)
	{
		sk = p.scorekeeper;
		if(!sk)
			continue;
		for(i = 0; i < MAX_SCORE; ++i)
		{
			if(sk.(scores[i]) != 0)
				if(scores_label[i] != "")
					sk.SendFlags |= pow(2, i);
			sk.(scores[i]) = 0;
		}
	}
	for(t = 0; t < 16; ++t)
	{
		sk = teamscorekeepers[t];
		if(!sk)
			continue;
		for(i = 0; i < MAX_TEAMSCORE; ++i)
		{
			if(sk.(teamscores[i]) != 0)
				if(teamscores_label[i] != "")
					sk.SendFlags |= pow(2, i);
			sk.(teamscores[i]) = 0;
		}
	}
}

void PlayerScore_Attach(entity player)
{
	entity sk;
	if(player.scorekeeper)
		error("player already has a scorekeeper");
	sk = spawn();
	sk.owner = player;
	Net_LinkEntity(sk, FALSE, 0, PlayerScore_SendEntity);
	player.scorekeeper = sk;
}

void PlayerScore_Detach(entity player)
{
	if(!player.scorekeeper)
		error("player has no scorekeeper");
	remove(player.scorekeeper);
	player.scorekeeper = world;
}

float PlayerScore_Add(entity player, float scorefield, float score)
{
	entity s;

	if(gameover)
	if not(g_lms && scorefield == SP_LMS_RANK) // allow writing to this field in intermission as it is needed for newly joining players
		score = 0;

	if(!scores_initialized) return 0; // FIXME remove this when everything uses this system
	s = player.scorekeeper;
	if(!s)
	{
		if(gameover)
			return 0;
		backtrace("Adding score to unknown player!");
		return 0;
	}
	if(score)
		if(scores_label[scorefield] != "")
			s.SendFlags |= pow(2, scorefield);
	if(!inWarmupStage)
		PlayerStats_Event(s.owner, strcat(PLAYERSTATS_TOTAL, scores_label[scorefield]), score);
	return (s.(scores[scorefield]) += score);
}

float PlayerTeamScore_Add(entity player, float pscorefield, float tscorefield, float score)
{
	float r;
	r = PlayerScore_Add(player, pscorefield, score);
	if(teamscores_entities_count) // only for teamplay
		r = TeamScore_Add(player, tscorefield, score);
	return r;
}

float PlayerScore_Compare(entity t1, entity t2, float strict)
{
	if(!t1 || !t2) return (!t2) - !t1;

	vector result = '0 0 0';
	float i;
	for(i = 0; i < MAX_SCORE; ++i)
	{
		var .float f;
		f = scores[i];
		result = ScoreField_Compare(t1, t2, f, scores_flags[i], result, strict);
	}

	if (result_x == 0 && strict)
		result_x = num_for_edict(t1.owner) - num_for_edict(t2.owner);

	return result_x;
}

void WinningConditionHelper()
{
	float c;
	string s;
	entity p;
	float fullstatus;
	entity winnerscorekeeper;
	entity secondscorekeeper;
	entity sk;

	// format:
	// gametype:P<pure>:S<slots>::plabel,plabel:tlabel,tlabel:teamid:tscore,tscore:teamid:tscore,tscore
	// score labels always start with a symbol or with lower case
	// so to match pure, match for :P0:
	// to match full, match for :S0:

	fullstatus = autocvar_g_full_getstatus_responses;

	s = GetGametype();
	s = strcat(s, ":", autocvar_g_xonoticversion);
	s = strcat(s, ":P", ftos(cvar_purechanges_count));
	s = strcat(s, ":S", ftos(nJoinAllowed(world)));
	s = strcat(s, ":F", ftos(serverflags));
	s = strcat(s, ":M", modname);
	s = strcat(s, "::", GetPlayerScoreString(world, (fullstatus ? 1 : 2)));

	if(teamscores_entities_count)
	{
		float t;

		s = strcat(s, ":", GetTeamScoreString(0, 1));
		for(t = 0; t < 16; ++t)
			if(teamscorekeepers[t])
				s = strcat(s, ":", ftos(t+1), ":", GetTeamScoreString(t+1, 1));

		WinningConditionHelper_winnerteam = -1;
		WinningConditionHelper_secondteam = -1;
		winnerscorekeeper = world;
		secondscorekeeper = world;
		for(t = 0; t < 16; ++t)
		{
			sk = teamscorekeepers[t];
			c = TeamScore_Compare(winnerscorekeeper, sk, 1);
			if(c < 0)
			{
				WinningConditionHelper_secondteam = WinningConditionHelper_winnerteam;
				WinningConditionHelper_winnerteam = t + 1;
				secondscorekeeper = winnerscorekeeper;
				winnerscorekeeper = sk;
			}
			else
			{
				c = TeamScore_Compare(secondscorekeeper, sk, 1);
				if(c < 0)
				{
					WinningConditionHelper_secondteam = t + 1;
					secondscorekeeper = sk;
				}
			}
		}

		WinningConditionHelper_equality = (TeamScore_Compare(winnerscorekeeper, secondscorekeeper, 0) == 0);
		if(WinningConditionHelper_equality)
			WinningConditionHelper_winnerteam = WinningConditionHelper_secondteam = -1;

		WinningConditionHelper_topscore = winnerscorekeeper.teamscores_primary;
		WinningConditionHelper_secondscore = secondscorekeeper.teamscores_primary;
		WinningConditionHelper_lowerisbetter = (teamscores_flags_primary & SFL_LOWER_IS_BETTER);
		WinningConditionHelper_zeroisworst = (teamscores_flags_primary & SFL_ZERO_IS_WORST);

		WinningConditionHelper_winner = world; // not supported in teamplay
		WinningConditionHelper_second = world; // not supported in teamplay
	}
	else
	{
		WinningConditionHelper_winner = world;
		WinningConditionHelper_second = world;
		winnerscorekeeper = world;
		secondscorekeeper = world;
		FOR_EACH_PLAYER(p)
		{
			sk = p.scorekeeper;
			c = PlayerScore_Compare(winnerscorekeeper, sk, 1);
			if(c < 0)
			{
				WinningConditionHelper_second = WinningConditionHelper_winner;
				WinningConditionHelper_winner = p;
				secondscorekeeper = winnerscorekeeper;
				winnerscorekeeper = sk;
			}
			else
			{
				c = PlayerScore_Compare(secondscorekeeper, sk, 1);
				if(c < 0)
				{
					WinningConditionHelper_second = p;
					secondscorekeeper = sk;
				}
			}
		}

		WinningConditionHelper_equality = (PlayerScore_Compare(winnerscorekeeper, secondscorekeeper, 0) == 0);
		if(WinningConditionHelper_equality)
			WinningConditionHelper_winner = WinningConditionHelper_second = world;

		WinningConditionHelper_topscore = winnerscorekeeper.scores_primary;
		WinningConditionHelper_secondscore = secondscorekeeper.scores_primary;
		WinningConditionHelper_lowerisbetter = (scores_flags_primary & SFL_LOWER_IS_BETTER);
		WinningConditionHelper_zeroisworst = (scores_flags_primary & SFL_ZERO_IS_WORST);

		WinningConditionHelper_winnerteam = -1; // no teamplay
		WinningConditionHelper_secondteam = -1; // no teamplay
	}

	if(WinningConditionHelper_topscore == 0)
	{
		if(scores_flags_primary & SFL_ZERO_IS_WORST)
		{
			if(WinningConditionHelper_lowerisbetter)
				WinningConditionHelper_topscore = 999999999;
			else
				WinningConditionHelper_topscore = -999999999;
		}
		WinningConditionHelper_equality = 0;
	}

	if(WinningConditionHelper_secondscore == 0)
	{
		if(scores_flags_primary & SFL_ZERO_IS_WORST)
		{
			if(WinningConditionHelper_lowerisbetter)
				WinningConditionHelper_secondscore = 999999999;
			else
				WinningConditionHelper_secondscore = -999999999;
		}
	}

	if(worldstatus)
		strunzone(worldstatus);
	worldstatus = strzone(s);

	FOR_EACH_CLIENT(p)
	{
		if(fullstatus)
		{
			s = GetPlayerScoreString(p, 1);
			if(IS_REAL_CLIENT(p))
				s = strcat(s, ":human");
			else
				s = strcat(s, ":bot");
			if(!IS_PLAYER(p) && !g_arena && p.caplayer != 1 && !g_lms)
				s = strcat(s, ":spectator");
		}
		else
		{
			if(IS_PLAYER(p) || g_arena || p.caplayer == 1 || g_lms)
				s = GetPlayerScoreString(p, 2);
			else
				s = "-666";
		}

		if(p.clientstatus)
			strunzone(p.clientstatus);
		p.clientstatus = strzone(s);
	}
}

string GetScoreLogLabel(string label, float fl)
{
	if(fl & SFL_LOWER_IS_BETTER)
		label = strcat(label, "<");
	if(fl & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
		label = strcat(label, "!!");
	else if(fl & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_SECONDARY)
		label = strcat(label, "!");
	return label;
}

string GetPlayerScoreString(entity pl, float shortString)
{
	string out;
	entity sk;
	float i, f;
	string l;

	out = "";
	if(!pl)
	{
		// label
		for(i = 0; i < MAX_SCORE; ++i)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
			{
				f = scores_flags[i];
				l = scores_label[i];
				out = strcat(out, GetScoreLogLabel(l, f), ",");
			}
		if(shortString < 2)
		for(i = 0; i < MAX_SCORE; ++i)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_SECONDARY)
			{
				f = scores_flags[i];
				l = scores_label[i];
				out = strcat(out, GetScoreLogLabel(l, f), ",");
			}
		if(shortString < 1)
		for(i = 0; i < MAX_SCORE; ++i)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_PRIMARY)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_SECONDARY)
			{
				f = scores_flags[i];
				l = scores_label[i];
				out = strcat(out, GetScoreLogLabel(l, f), ",");
			}
		out = substring(out, 0, strlen(out) - 1);
	}
	else if((sk = pl.scorekeeper))
	{
		for(i = 0; i < MAX_SCORE; ++i)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
				out = strcat(out, ftos(sk.(scores[i])), ",");
		if(shortString < 2)
		for(i = 0; i < MAX_SCORE; ++i)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_SECONDARY)
				out = strcat(out, ftos(sk.(scores[i])), ",");
		if(shortString < 1)
		for(i = 0; i < MAX_SCORE; ++i)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_PRIMARY)
			if(scores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_SECONDARY)
				out = strcat(out, ftos(sk.(scores[i])), ",");
		out = substring(out, 0, strlen(out) - 1);
	}
	return out;
}

string GetTeamScoreString(float tm, float shortString)
{
	string out;
	entity sk;
	float i, f;
	string l;

	out = "";
	if(tm == 0)
	{
		// label
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
			{
				f = teamscores_flags[i];
				l = teamscores_label[i];
				out = strcat(out, GetScoreLogLabel(l, f), ",");
			}
		if(shortString < 2)
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_SECONDARY)
			{
				f = teamscores_flags[i];
				l = teamscores_label[i];
				out = strcat(out, GetScoreLogLabel(l, f), ",");
			}
		if(shortString < 1)
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_PRIMARY)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_SECONDARY)
			{
				f = teamscores_flags[i];
				l = teamscores_label[i];
				out = strcat(out, GetScoreLogLabel(l, f), ",");
			}
		out = substring(out, 0, strlen(out) - 1);
	}
	else if((sk = teamscorekeepers[tm - 1]))
	{
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_PRIMARY)
				out = strcat(out, ftos(sk.(teamscores[i])), ",");
		if(shortString < 2)
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK == SFL_SORT_PRIO_SECONDARY)
				out = strcat(out, ftos(sk.(teamscores[i])), ",");
		if(shortString < 1)
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_PRIMARY)
			if(teamscores_flags[i] & SFL_SORT_PRIO_MASK != SFL_SORT_PRIO_SECONDARY)
				out = strcat(out, ftos(sk.(teamscores[i])), ",");
		out = substring(out, 0, strlen(out) - 1);
	}
	return out;
}

float PlayerTeamScore_Compare(entity p1, entity p2, float teams, float strict)
{
	if(teams && teamscores_entities_count)
	{
		if(p1.team != p2.team)
		{
			entity t1, t2;
			float r;
			t1 = teamscorekeepers[p1.team - 1];
			t2 = teamscorekeepers[p2.team - 1];
			r = TeamScore_Compare(t1, t2, ((teams >= 0) ? 1 : strict));
			return r;
		}
		if(teams < 0)
			return 0;
	}
	
	return PlayerScore_Compare(p1.scorekeeper, p2.scorekeeper, strict);
}

entity PlayerScore_Sort(.float field, float teams, float strict, float nospectators)
{
	entity p, plist, pprev, pbest, pbestprev, pfirst, plast;
	float i, j;

	plist = world;

	FOR_EACH_CLIENT(p)
		p.field = 0;

	FOR_EACH_CLIENT(p) if(p.scorekeeper)
	{
		if(nospectators)
			if(p.frags == FRAGS_SPECTATOR)
				continue;

		p.chain = plist;
		plist = p;
	}
	// Now plist points to the whole list.
	
	pfirst = plast = world;

	i = j = 0;
	while(plist)
	{
		pprev = pbestprev = world;
		pbest = plist;
		for(p = plist; (pprev = p), (p = p.chain); )
		{
			if(PlayerTeamScore_Compare(p, pbest, teams, strict) > 0)
			{
				pbest = p;
				pbestprev = pprev;
			}
		}

		// remove pbest out of the chain
		if(pbestprev == world)
			plist = pbest.chain;
		else
			pbestprev.chain = pbest.chain;
		pbest.chain = world;

		++i;
		if(!plast || PlayerTeamScore_Compare(plast, pbest, teams, 0))
			j = i;

		pbest.field = j;

		if not(pfirst)
			pfirst = pbest;
		if(plast)
			plast.chain = pbest;
		plast = pbest;
	}

	return pfirst;
}

float TeamScore_GetCompareValue(float t)
{
	float s;
	entity sk;

	if(t <= 0 || t >= 16)
	{
		if(gameover)
			return 0;
		error("Reading score of invalid team!");
	}

	sk = teamscorekeepers[t - 1];
	if not(sk)
		return -999999999;
	s = sk.teamscores_primary;
	if(teamscores_flags_primary & SFL_ZERO_IS_WORST)
		if(!s)
			return -999999999;
	if(teamscores_flags_primary & SFL_LOWER_IS_BETTER)
		s = -s;
	return s;
}

#define NAMEWIDTH 22
#define SCORESWIDTH 58
// TODO put this somewhere in common?
string Score_NicePrint_ItemColor(float vflags)
{
	if(vflags & SFL_SORT_PRIO_PRIMARY)
		return "^3";
	else if(vflags & SFL_SORT_PRIO_SECONDARY)
		return "^5";
	else
		return "^7";
}

void Score_NicePrint_Team(entity to, float t, float w)
{
	string s, s2;
	float i;
	entity sk;
	float fl, sc;
	s = "";

	sk = teamscorekeepers[t - 1];
	if(sk)
	{
		s = strcat(s, Team_ColoredFullName(t));
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(teamscores_label[i] != "")
			{
				fl = teamscores_flags[i];
				sc = sk.(teamscores[i]);
				s = strcat(s, " ", Score_NicePrint_ItemColor(fl), ScoreString(fl, sc));
			}
	}
	else
		s = "Scores:";

	s = strcat(s, strpad(max(0, NAMEWIDTH - strlennocol(s)), ""));
	
	for(i = 0; i < MAX_SCORE; ++i)
		if(scores_label[i] != "")
		{
			fl = scores_flags[i];
			s2 = scores_label[i];
			s = strcat(s, " ", Score_NicePrint_ItemColor(fl), strpad(-w, substring(s2, 0, w)));
		}

	print_to(to, s);
}

void Score_NicePrint_Player(entity to, entity p, float w)
{
	string s;
	float i;
	entity sk;
	float fl, sc;
	s = "  ";

	sk = p.scorekeeper;

	s = strcat(s, p.netname);
	for(;;)
	{
		i = strlennocol(s) - NAMEWIDTH;
		if(i > 0)
			s = substring(s, 0, strlen(s) - i);
		else
		{
			s = strcat(s, strpad(i, ""));
			break;
		}
	}
	
	for(i = 0; i < MAX_SCORE; ++i)
		if(scores_label[i] != "")
		{
			fl = scores_flags[i];
			sc = sk.(scores[i]);
			s = strcat(s, " ", Score_NicePrint_ItemColor(fl), strpad(-w, ScoreString(fl, sc)));
		}

	print_to(to, s);
}

void Score_NicePrint_Spectators(entity to)
{
	print_to(to, "Spectators:");
}

void Score_NicePrint_Spectator(entity to, entity p)
{
	print_to(to, strcat("  ", p.netname));
}

.float score_dummyfield;
void Score_NicePrint(entity to)
{
	entity p;
	float t, i;
	float w;

	t = 0;
	for(i = 0; i < MAX_SCORE; ++i)
		if(scores_label[i] != "")
			++t;
	w = bound(6, floor(SCORESWIDTH / t - 1), 9);

	p = PlayerScore_Sort(score_dummyfield, 1, 1, 0);
	t = -1;

	if(!teamscores_entities_count)
		Score_NicePrint_Team(to, t, w);
	while(p)
	{
		if(teamscores_entities_count)
			if(t != p.team)
				Score_NicePrint_Team(to, p.team, w);
		Score_NicePrint_Player(to, p, w);
		t = p.team;
		p = p.chain;
	}
	
	t = 0;
	FOR_EACH_CLIENT(p)
	if not(IS_PLAYER(p))
	{
		if not(t)
			Score_NicePrint_Spectators(to);
		Score_NicePrint_Spectator(to, p);
		t = 1;
	}
}

void PlayerScore_PlayerStats(entity p)
{
	entity s;
	float i;
	s = p.scorekeeper;

	for(i = 0; i < MAX_SCORE; ++i)
		if(s.(scores[i]) != 0)
			if(scores_label[i] != "")
				PlayerStats_Event(s.owner, strcat(PLAYERSTATS_SCOREBOARD, scores_label[i]), s.(scores[i]));
}

void PlayerScore_TeamStats(void)
{
	entity sk;
	float t, i;
	for(t = 0; t < 16; ++t)
	{
		sk = teamscorekeepers[t];
		if(!sk)
			continue;
		for(i = 0; i < MAX_TEAMSCORE; ++i)
			if(sk.(teamscores[i]) != 0)
				if(teamscores_label[i] != "")
					// the +1 is important here!
					PlayerStats_TeamScore(t+1, strcat(PLAYERSTATS_SCOREBOARD, teamscores_label[i]), sk.(teamscores[i]));
	}
}
