float playerstats_db;
string teamstats_last;
string playerstats_last;
string events_last;
.float playerstats_addedglobalinfo;
.string playerstats_id;

void PlayerStats_Init() // initiated before InitGameplayMode so that scores are added properly
{
	string uri;
	playerstats_db = -1;
	playerstats_waitforme = TRUE;
	uri = autocvar_g_playerstats_uri;
	if(uri == "")
		return;
	playerstats_db = db_create();
	if(playerstats_db >= 0)
		playerstats_waitforme = FALSE; // must wait for it at match end

	serverflags |= SERVERFLAG_PLAYERSTATS;	

	PlayerStats_AddEvent(PLAYERSTATS_ALIVETIME);
	PlayerStats_AddEvent(PLAYERSTATS_AVGLATENCY);
	PlayerStats_AddEvent(PLAYERSTATS_WINS);
	PlayerStats_AddEvent(PLAYERSTATS_MATCHES);
	PlayerStats_AddEvent(PLAYERSTATS_JOINS);
	PlayerStats_AddEvent(PLAYERSTATS_SCOREBOARD_VALID);
	PlayerStats_AddEvent(PLAYERSTATS_SCOREBOARD_POS);
	PlayerStats_AddEvent(PLAYERSTATS_RANK);

    // accuracy stats
    entity w;
    float i;
    for(i = WEP_FIRST; i <= WEP_LAST; ++i)
    {
        w = get_weaponinfo(i);

        PlayerStats_AddEvent(strcat("acc-", w.netname, "-hit"));
        PlayerStats_AddEvent(strcat("acc-", w.netname, "-fired"));

        PlayerStats_AddEvent(strcat("acc-", w.netname, "-cnt-hit"));
        PlayerStats_AddEvent(strcat("acc-", w.netname, "-cnt-fired"));

        PlayerStats_AddEvent(strcat("acc-", w.netname, "-frags"));
    }

	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_3);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_5);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_10);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_15);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_20);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_25);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_30);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_BOTLIKE);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_FIRSTBLOOD);
	PlayerStats_AddEvent(PLAYERSTATS_ACHIEVEMENT_FIRSTVICTIM);
}

void PlayerStats_AddPlayer(entity e)
{
	string s;

	if(playerstats_db < 0)
		return;
	if(e.playerstats_id)
		return;

	s = string_null;
	if(e.crypto_idfp != "" && e.cvar_cl_allow_uidtracking == 1)
		s = e.crypto_idfp;
	else if(IS_BOT_CLIENT(e))
		s = sprintf("bot#%g#%s", skill, e.cleanname);

	if((s == "") || find(world, playerstats_id, s)) // already have one of the ID - next one can't be tracked then!
	{
		if(IS_BOT_CLIENT(e))
			s = sprintf("bot#%d", e.playerid);
		else
			s = sprintf("player#%d", e.playerid);
	}

	e.playerstats_id = strzone(s);

	string key;
	key = sprintf("%s:*", e.playerstats_id);
	
	string p;
	p = db_get(playerstats_db, key);
	if(p == "")
	{
		if(playerstats_last)
		{
			db_put(playerstats_db, key, playerstats_last);
			strunzone(playerstats_last);
		}
		else
			db_put(playerstats_db, key, "#");
		playerstats_last = strzone(e.playerstats_id);
	}
}

void PlayerStats_AddTeam(float t)
{
	if(playerstats_db < 0)
		return;

	string key;
	key = sprintf("%d", t);
	
	string p;
	p = db_get(playerstats_db, key);
	if(p == "")
	{
		if(teamstats_last)
		{
			db_put(playerstats_db, key, teamstats_last);
			strunzone(teamstats_last);
		}
		else
			db_put(playerstats_db, key, "#");
		teamstats_last = strzone(key);
	}
}

void PlayerStats_AddEvent(string event_id)
{
	if(playerstats_db < 0)
		return;
	
	string key;
	key = sprintf("*:%s", event_id);
	
	string p;
	p = db_get(playerstats_db, key);
	if(p == "")
	{
		if(events_last)
		{
			db_put(playerstats_db, key, events_last);
			strunzone(events_last);
		}
		else
			db_put(playerstats_db, key, "#");
		events_last = strzone(event_id);
	}
}

float PlayerStats_Event(entity e, string event_id, float value)
{
	if((e.playerstats_id == "") || playerstats_db < 0)
		return 0;
	
	string key;
	float val;
	key = sprintf("%s:%s", e.playerstats_id, event_id);
	val = stof(db_get(playerstats_db, key));
	val += value;
	db_put(playerstats_db, key, ftos(val));
	return val;
}

float PlayerStats_TeamScore(float t, string event_id, float value)
{
	if(playerstats_db < 0)
		return 0;

	string key;
	float val;
	key = sprintf("team#%d:%s", t, event_id);
	val = stof(db_get(playerstats_db, key));
	val += value;
	db_put(playerstats_db, key, ftos(val));
	return val;
}

/*
	format spec:

	A collection of lines of the format <key> SPACE <value> NEWLINE, where
	<key> is always a single character.

	The following keys are defined:

	V: format version (always a fixed number) - this MUST be the first line!
	#: comment (MUST be ignored by any parser)
	R: release information on the server
	T: time at which the game ended
	G: game type
	O: mod name (icon request) as in server browser
	M: map name
	I: match ID (see "matchid" in g_world.qc
	S: "hostname" of the server
	C: number of "unpure" cvar changes
	U: UDP port number of the server
	D: duration of the match
	P: player ID of an existing player; this also sets the owner for all following "n", "e" and "t" lines (lower case!)
	Q: team number of an existing team (format: team#NN); this also sets the owner for all following "e" lines (lower case!) 
	n: nickname of the player (optional)
	t: team ID
	i: player index
	e: followed by an event name, a space, and the event count/score
		event names can be:
			alivetime: total playing time of the player
			avglatency: average network latency compounded throughout the match
			wins: number of games won (can only be set if matches is set)
			matches: number of matches played to the end (not aborted by map switch)
			joins: number of matches joined (always 1 unless player never played during the match)
			scoreboardvalid: set to 1 if the player was there at the end of the match
			total-<scoreboardname>: total score of that scoreboard item
			scoreboard-<scoreboardname>: end-of-game score of that scoreboard item (can differ in non-team games)
			achievement-<achievementname>: achievement counters (their "count" is usually 1 if nonzero at all)
			kills-<index>: number of kills against the indexed player
			rank <number>: rank of player
			acc-<weapon netname>-hit: total damage dealt
			acc-<weapon netname>-fired: total damage that all fired projectiles *could* have dealt
			acc-<weapon netname>-cnt-hit: amount of shots that actually hit
			acc-<weapon netname>-cnt-fired: amount of fired shots
			acc-<weapon netname>-frags: amount of frags dealt by weapon

	Response format (not used yet): see https://gist.github.com/4284222
*/

void PlayerStats_ready(entity fh, entity pass, float status)
{
	string t, tn;
	string p, pn;
	string e, en;
	string nn, tt;
	string s;

	switch(status)
	{
		case URL_READY_CANWRITE:
			url_fputs(fh, "V 7\n");
#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
#endif
			url_fputs(fh, sprintf("T %s.%06d\n", strftime(FALSE, "%s"), floor(random() * 1000000)));
			url_fputs(fh, sprintf("G %s\n", GetGametype()));
			url_fputs(fh, sprintf("O %s\n", modname));
			url_fputs(fh, sprintf("M %s\n", GetMapname()));
			url_fputs(fh, sprintf("I %s\n", matchid));
			url_fputs(fh, sprintf("S %s\n", cvar_string("hostname")));
			url_fputs(fh, sprintf("C %d\n", cvar_purechanges_count));
			url_fputs(fh, sprintf("U %d\n", cvar("port")));
			url_fputs(fh, sprintf("D %f\n", max(0, time - game_starttime)));
			if(teamplay)
			{
				for(t = teamstats_last; (tn = db_get(playerstats_db, sprintf("%d", stof(t)))) != ""; t = tn)
				{
					url_fputs(fh, sprintf("Q team#%s\n", t));
					for(e = events_last; (en = db_get(playerstats_db, sprintf("*:%s", e))) != ""; e = en)
					{
						float v;
						v = stof(db_get(playerstats_db, sprintf("team#%d:%s", stof(t), e)));
						if(v != 0)
							url_fputs(fh, sprintf("e %s %g\n", e, v));
					}
				}
			}
			for(p = playerstats_last; (pn = db_get(playerstats_db, sprintf("%s:*", p))) != ""; p = pn)
			{
				url_fputs(fh, sprintf("P %s\n", p));
				nn = db_get(playerstats_db, sprintf("%s:_playerid", p));
				if(nn != "")
					url_fputs(fh, sprintf("i %s\n", nn));
				nn = db_get(playerstats_db, sprintf("%s:_netname", p));
				if(nn != "")
					url_fputs(fh, sprintf("n %s\n", nn));
				if(teamplay)
				{
					tt = db_get(playerstats_db, sprintf("%s:_team", p));
					url_fputs(fh, sprintf("t %s\n", tt));
				}
				for(e = events_last; (en = db_get(playerstats_db, sprintf("*:%s", e))) != ""; e = en)
				{
					float v;
					v = stof(db_get(playerstats_db, sprintf("%s:%s", p, e)));
					if(v != 0)
						url_fputs(fh, sprintf("e %s %g\n", e, v));
				}
			}
			url_fputs(fh, "\n");
			url_fclose(fh);
			break;
		case URL_READY_CANREAD:
			// url_fclose is processing, we got a response for writing the data
			// this must come from HTTP
			print("Got response from player stats server:\n");
			while((s = url_fgets(fh)))
				print("  ", s, "\n");
			print("End of response.\n");
			url_fclose(fh);
			break;
		case URL_READY_CLOSED:
			// url_fclose has finished
			print("Player stats written\n");
			playerstats_waitforme = TRUE;
			db_close(playerstats_db);
			playerstats_db = -1;
			break;
		case URL_READY_ERROR:
		default:
			print("Player stats writing failed: ", ftos(status), "\n");
			playerstats_waitforme = TRUE;
			if(playerstats_db >= 0)
			{
				db_close(playerstats_db);
				playerstats_db = -1;
			}
			break;
	}
}

//#NO AUTOCVARS START
void PlayerStats_Shutdown()
{
	string uri;

	if(playerstats_db < 0)
		return;

	uri = autocvar_g_playerstats_uri;
	if(uri != "")
	{
		playerstats_waitforme = FALSE;
		url_multi_fopen(uri, FILE_APPEND, PlayerStats_ready, world);
	}
	else
	{
		playerstats_waitforme = TRUE;
		db_close(playerstats_db);
		playerstats_db = -1;
	}
}
//#NO AUTOCVARS END

void PlayerStats_Accuracy(entity p)
{
    entity a, w;
    a = p.accuracy;
    float i;

    for(i = WEP_FIRST; i <= WEP_LAST; ++i)
    {
        w = get_weaponinfo(i);

        PlayerStats_Event(p, strcat("acc-", w.netname, "-hit"), a.(accuracy_hit[i-1]));
        PlayerStats_Event(p, strcat("acc-", w.netname, "-fired"), a.(accuracy_fired[i-1]));

        PlayerStats_Event(p, strcat("acc-", w.netname, "-cnt-hit"), a.(accuracy_cnt_hit[i-1]));
        PlayerStats_Event(p, strcat("acc-", w.netname, "-cnt-fired"), a.(accuracy_cnt_fired[i-1]));

        PlayerStats_Event(p, strcat("acc-", w.netname, "-frags"), a.(accuracy_frags[i-1]));
    }
    //backtrace(strcat("adding player stat accuracy for ", p.netname, ".\n"));
}

void PlayerStats_AddGlobalInfo(entity p)
{
	if(playerstats_db < 0)
		return;
	if((p.playerstats_id == "") || playerstats_db < 0)
		return;
	p.playerstats_addedglobalinfo = TRUE;

	// add global info!
	if(p.alivetime)
	{
		PlayerStats_Event(p, PLAYERSTATS_ALIVETIME, time - p.alivetime);
		p.alivetime = 0;
	}

	db_put(playerstats_db, sprintf("%s:_playerid", p.playerstats_id), ftos(p.playerid));

	if(p.cvar_cl_allow_uid2name == 1 || IS_BOT_CLIENT(p))
		db_put(playerstats_db, sprintf("%s:_netname", p.playerstats_id), p.netname);

	if(teamplay)
		db_put(playerstats_db, sprintf("%s:_team", p.playerstats_id), ftos(p.team));

	if(stof(db_get(playerstats_db, sprintf("%d:%s", p.playerstats_id, PLAYERSTATS_ALIVETIME))) > 0)
		PlayerStats_Event(p, PLAYERSTATS_JOINS, 1);

	PlayerStats_Accuracy(p);

	if(IS_REAL_CLIENT(p))
	{
		if(p.latency_cnt)
		{
			float latency = (p.latency_sum / p.latency_cnt);
			if(latency) { PlayerStats_Event(p, PLAYERSTATS_AVGLATENCY, latency); }
		}
	}

	strunzone(p.playerstats_id);
	p.playerstats_id = string_null;
}

.float scoreboard_pos;
void PlayerStats_EndMatch(float finished)
{
	entity p;
	PlayerScore_Sort(score_dummyfield, 0, 0, 0);
	PlayerScore_Sort(scoreboard_pos, 1, 1, 1);
	if(teamplay)
		PlayerScore_TeamStats();
	FOR_EACH_CLIENT(p)
	{
		// add personal score rank
		PlayerStats_Event(p, PLAYERSTATS_RANK, p.score_dummyfield);

		if(!p.scoreboard_pos)
			continue;

		// scoreboard is valid!
		PlayerStats_Event(p, PLAYERSTATS_SCOREBOARD_VALID, 1);

		// add scoreboard position
		PlayerStats_Event(p, PLAYERSTATS_SCOREBOARD_POS, p.scoreboard_pos);

		// add scoreboard data
		PlayerScore_PlayerStats(p);

		// if the match ended normally, add winning info
		if(finished)
		{
			PlayerStats_Event(p, PLAYERSTATS_WINS, p.winning);
			PlayerStats_Event(p, PLAYERSTATS_MATCHES, 1);
		}
	}
}
