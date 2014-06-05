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
