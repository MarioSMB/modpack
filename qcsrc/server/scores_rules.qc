float c1, c2, c3, c4;
void CheckAllowedTeams (entity for_whom);

// NOTE: SP_ constants may not be >= MAX_SCORE; ST_constants may not be >= MAX_TEAMSCORE
// scores that should be in all modes:
float ScoreRules_teams;
void ScoreRules_basics(float teams, float sprio, float stprio, float score_enabled)
{
	float i;
	for(i = 0; i < MAX_SCORE; ++i)
		ScoreInfo_SetLabel_PlayerScore(i, "", 0);
	for(i = 0; i < MAX_TEAMSCORE; ++i)
		ScoreInfo_SetLabel_TeamScore(i, "", 0);

	ScoreRules_teams = teams;

	if(score_enabled)
		ScoreInfo_SetLabel_TeamScore  (ST_SCORE,        "score",     stprio);

	if (!INDEPENDENT_PLAYERS)
		ScoreInfo_SetLabel_PlayerScore(SP_KILLS,        "kills",     0);

	ScoreInfo_SetLabel_PlayerScore(SP_DEATHS,       "deaths",    SFL_LOWER_IS_BETTER);

	if (!INDEPENDENT_PLAYERS)
		ScoreInfo_SetLabel_PlayerScore(SP_SUICIDES,     "suicides",  SFL_LOWER_IS_BETTER);

	if(score_enabled)
		ScoreInfo_SetLabel_PlayerScore(SP_SCORE,        "score",     sprio);
}
void ScoreRules_basics_end()
{
	ScoreInfo_Init(ScoreRules_teams);
}
void ScoreRules_generic()
{
	if(teamplay)
	{
		CheckAllowedTeams(world);
		ScoreRules_basics(((c4>=0) ? 4 : (c3>=0) ? 3 : 2), SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE);
	}
	else
		ScoreRules_basics(0, SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE);
	ScoreRules_basics_end();
}

// Key hunt stuff
#define ST_KH_CAPS 1
#define SP_KH_CAPS 4
#define SP_KH_PUSHES 5
#define SP_KH_DESTROYS 6
#define SP_KH_PICKUPS 7
#define SP_KH_KCKILLS 8
#define SP_KH_LOSSES 9
void ScoreRules_kh(float teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE);
	ScoreInfo_SetLabel_TeamScore  (ST_KH_CAPS,      "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_CAPS,      "caps",      SFL_SORT_PRIO_SECONDARY);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PUSHES,    "pushes",    0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_DESTROYS,  "destroyed", SFL_LOWER_IS_BETTER);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_PICKUPS,   "pickups",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_KCKILLS,   "kckills",   0);
	ScoreInfo_SetLabel_PlayerScore(SP_KH_LOSSES,    "losses",    SFL_LOWER_IS_BETTER);
	ScoreRules_basics_end();
}

// Race stuff
#define ST_RACE_LAPS 1
#define SP_RACE_LAPS 4
#define SP_RACE_TIME 5
#define SP_RACE_FASTEST 6
void ScoreRules_race()
{
	ScoreRules_basics(race_teams, 0, 0, FALSE);
	if(race_teams)
	{
		ScoreInfo_SetLabel_TeamScore(  ST_RACE_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_TIME,    "time",      SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER | SFL_TIME);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_FASTEST, "fastest",   SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	else if(g_race_qualifying)
	{
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_FASTEST, "fastest",   SFL_SORT_PRIO_PRIMARY | SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	else
	{
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_LAPS,    "laps",      SFL_SORT_PRIO_PRIMARY);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_TIME,    "time",      SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER | SFL_TIME);
		ScoreInfo_SetLabel_PlayerScore(SP_RACE_FASTEST, "fastest",   SFL_LOWER_IS_BETTER | SFL_TIME);
	}
	ScoreRules_basics_end();
}

// Nexball stuff
#define ST_NEXBALL_GOALS 1
#define SP_NEXBALL_GOALS 4
#define SP_NEXBALL_FAULTS 5
void ScoreRules_nexball(float teams)
{
	ScoreRules_basics(teams, 0, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(   ST_NEXBALL_GOALS,  "goals", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore( SP_NEXBALL_GOALS,  "goals", SFL_SORT_PRIO_PRIMARY);
	ScoreInfo_SetLabel_PlayerScore(SP_NEXBALL_FAULTS, "faults", SFL_SORT_PRIO_SECONDARY | SFL_LOWER_IS_BETTER);
	ScoreRules_basics_end();
}

#define SP_FREEZETAG_REVIVALS 4
void ScoreRules_freezetag(float teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, SFL_SORT_PRIO_PRIMARY, TRUE); // SFL_SORT_PRIO_PRIMARY
	ScoreInfo_SetLabel_PlayerScore(SP_FREEZETAG_REVIVALS,		"revivals",		0);
	ScoreRules_basics_end();
}

#define ST_CA_ROUNDS 1
void ScoreRules_ca(float teams)
{
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(ST_CA_ROUNDS, "rounds", SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}

// Infection (TODO: move to infection gamemode file?)
#define ST_INF_ROUNDS 1
void ScoreRules_inf(float teams)
{
	CheckAllowedTeams(world);
	ScoreRules_basics(teams, SFL_SORT_PRIO_PRIMARY, 0, TRUE);
	ScoreInfo_SetLabel_TeamScore(ST_INF_ROUNDS, "rounds", SFL_SORT_PRIO_PRIMARY);
	ScoreRules_basics_end();
}
