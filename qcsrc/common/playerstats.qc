#ifdef SVQC
void PlayerStats_Prematch(void)
{
	//foobar
}

void PlayerStats_GameReport_AddPlayer(entity e)
{
	if((PS_GR_OUT_DB < 0) || (e.playerstats_id)) { return; }

	// set up player identification
	string s = string_null;

	if((e.crypto_idfp != "") && (e.cvar_cl_allow_uidtracking == 1))
		{ s = e.crypto_idfp; }
	else if(IS_BOT_CLIENT(e))
		{ s = sprintf("bot#%g#%s", skill, e.cleanname); }
		
	if((s == "") || find(world, playerstats_id, s)) // already have one of the ID - next one can't be tracked then!
	{
		if(IS_BOT_CLIENT(e))
			{ s = sprintf("bot#%d", e.playerid); }
		else
			{ s = sprintf("player#%d", e.playerid); }
	}
	
	e.playerstats_id = strzone(s);

	// now add the player to the database
	string key = sprintf("%s:*", e.playerstats_id);
	string p = db_get(PS_GR_OUT_DB, key);
	
	if(p == "")
	{
		if(PS_GR_OUT_PL)
		{
			db_put(PS_GR_OUT_DB, key, PS_GR_OUT_PL);
			strunzone(PS_GR_OUT_PL);
		}
		else { db_put(PS_GR_OUT_DB, key, "#"); }
		PS_GR_OUT_PL = strzone(e.playerstats_id);
	}
}

void PlayerStats_GameReport_AddTeam(float t)
{
	if(PS_GR_OUT_DB < 0) { return; }

	string key = sprintf("%d", t);
	string p = db_get(PS_GR_OUT_DB, key);
	
	if(p == "")
	{
		if(PS_GR_OUT_TL)
		{
			db_put(PS_GR_OUT_DB, key, PS_GR_OUT_TL);
			strunzone(PS_GR_OUT_TL);
		}
		else { db_put(PS_GR_OUT_DB, key, "#"); }
		PS_GR_OUT_TL = strzone(key);
	}
}

void PlayerStats_GameReport_AddEvent(string event_id)
{
	if(PS_GR_OUT_DB < 0) { return; }

	string key = sprintf("*:%s", event_id);
	string p = db_get(PS_GR_OUT_DB, key);
	
	if(p == "")
	{
		if(PS_GR_OUT_EVL)
		{
			db_put(PS_GR_OUT_DB, key, PS_GR_OUT_EVL);
			strunzone(PS_GR_OUT_EVL);
		}
		else { db_put(PS_GR_OUT_DB, key, "#"); }
		PS_GR_OUT_EVL = strzone(event_id);
	}
}

// referred to by PS_GR_P_ADDVAL and PS_GR_T_ADDVAL
float PlayerStats_GameReport_Event(string prefix, string event_id, float value)
{
	if((prefix == "") || (event_id == "") || PS_GR_OUT_DB < 0) { return 0; }

	string key = sprintf("%s:%s", prefix, event_id);
	float val = stof(db_get(PS_GR_OUT_DB, key));
	val += value;
	db_put(PS_GR_OUT_DB, key, ftos(val));
	return val;
}

void PlayerStats_GameReport_Accuracy(entity p)
{
	entity w;
	float i;

	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		w = get_weaponinfo(i);

		#define ACCMAC(suffix,field) \
			PS_GR_P_ADDVAL(p, sprintf("acc-%s-%s", w.netname, suffix), p.accuracy.(field[i-1]));

		ACCMAC("hit", accuracy_hit)
		ACCMAC("fired", accuracy_fired)
		ACCMAC("cnt-hit", accuracy_cnt_hit)
		ACCMAC("cnt-fired", accuracy_cnt_fired)
		ACCMAC("frags", accuracy_frags)

		#undef ACCMAC
	}
}

void PlayerStats_GameReport_FinalizePlayer(entity p)
{
	if((p.playerstats_id == "") || PS_GR_OUT_DB < 0) { return; }

	// add global info!
	if(p.alivetime)
	{
		PS_GR_P_ADDVAL(p, PLAYERSTATS_ALIVETIME, time - p.alivetime);
		p.alivetime = 0;
	}

	db_put(PS_GR_OUT_DB, sprintf("%s:_playerid", p.playerstats_id), ftos(p.playerid));

	if(p.cvar_cl_allow_uid2name == 1 || IS_BOT_CLIENT(p))
		db_put(PS_GR_OUT_DB, sprintf("%s:_netname", p.playerstats_id), p.netname);

	if(teamplay)
		db_put(PS_GR_OUT_DB, sprintf("%s:_team", p.playerstats_id), ftos(p.team));

	if(stof(db_get(PS_GR_OUT_DB, sprintf("%s:%s", p.playerstats_id, PLAYERSTATS_ALIVETIME))) > 0)
		PS_GR_P_ADDVAL(p, PLAYERSTATS_JOINS, 1);

	PlayerStats_GameReport_Accuracy(p);

	if(IS_REAL_CLIENT(p))
	{
		if(p.latency_cnt)
		{
			float latency = (p.latency_sum / p.latency_cnt);
			if(latency) { PS_GR_P_ADDVAL(p, PLAYERSTATS_AVGLATENCY, latency); }
		}
	}

	strunzone(p.playerstats_id);
	p.playerstats_id = string_null;
}

void PlayerStats_GameReport(float finished)
{
	if(PS_GR_OUT_DB < 0) { return; }
	
	PlayerScore_Sort(score_dummyfield, 0, 0, 0);
	PlayerScore_Sort(scoreboard_pos, 1, 1, 1);
	if(teamplay) { PlayerScore_TeamStats(); }

	entity p;
	FOR_EACH_CLIENT(p)
	{
		// add personal score rank
		PS_GR_P_ADDVAL(p, PLAYERSTATS_RANK, p.score_dummyfield);

		// scoreboard data
		if(p.scoreboard_pos)
		{
			// scoreboard is valid!
			PS_GR_P_ADDVAL(p, PLAYERSTATS_SCOREBOARD_VALID, 1);

			// add scoreboard position
			PS_GR_P_ADDVAL(p, PLAYERSTATS_SCOREBOARD_POS, p.scoreboard_pos);

			// add scoreboard data
			PlayerScore_PlayerStats(p);

			// if the match ended normally, add winning info
			if(finished)
			{
				PS_GR_P_ADDVAL(p, PLAYERSTATS_WINS, p.winning);
				PS_GR_P_ADDVAL(p, PLAYERSTATS_MATCHES, 1);
			}
		}

		// collect final player information
		PlayerStats_GameReport_FinalizePlayer(p);
	}

	if(autocvar_g_playerstats_gamereport_uri != "")
	{
		PlayerStats_GameReport_DelayMapVote = TRUE;
		url_multi_fopen(
			autocvar_g_playerstats_gamereport_uri,
			FILE_APPEND,
			PlayerStats_GameReport_Handler,
			world
		);
	}
	else
	{
		PlayerStats_GameReport_DelayMapVote = FALSE;
		db_close(PS_GR_OUT_DB);
		PS_GR_OUT_DB = -1;
	}
}

void PlayerStats_GameReport_Init() // initiated before InitGameplayMode so that scores are added properly
{
	if(autocvar_g_playerstats_gamereport_uri == "") { return; }

	PS_GR_OUT_DB = -1;
	PS_GR_OUT_DB = db_create();

	if(PS_GR_OUT_DB >= 0)
	{
		PlayerStats_GameReport_DelayMapVote = TRUE;

		serverflags |= SERVERFLAG_PLAYERSTATS;

		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ALIVETIME);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_AVGLATENCY);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_WINS);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_MATCHES);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_JOINS);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_SCOREBOARD_VALID);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_SCOREBOARD_POS);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_RANK);

		// accuracy stats
		entity w;
		float i;
		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			w = get_weaponinfo(i);
			PlayerStats_GameReport_AddEvent(strcat("acc-", w.netname, "-hit"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", w.netname, "-fired"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", w.netname, "-cnt-hit"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", w.netname, "-cnt-fired"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", w.netname, "-frags"));
		}

		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_3);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_5);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_10);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_15);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_20);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_25);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_30);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_BOTLIKE);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_FIRSTBLOOD);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ACHIEVEMENT_FIRSTVICTIM);
	}
	else { PlayerStats_GameReport_DelayMapVote = FALSE; }
}

void PlayerStats_GameReport_Handler(entity fh, entity pass, float status)
{
	string t, tn;
	string p, pn;
	string e, en;
	string nn, tt;
	string s;

	switch(status)
	{
		// ======================================
		// -- OUTGOING GAME REPORT INFORMATION --
		// ======================================
		/* SPECIFICATIONS:
		 * V: format version (always a fixed number) - this MUST be the first line!
		 * #: comment (MUST be ignored by any parser)
		 * R: release information on the server
		 * G: game type
		 * O: mod name (icon request) as in server browser
		 * M: map name
		 * I: match ID (see "matchid" in g_world.qc)
		 * S: "hostname" of the server
		 * C: number of "unpure" cvar changes
		 * U: UDP port number of the server
		 * D: duration of the match
		 * L: "ladder" in which the server is participating in
		 * P: player ID of an existing player; this also sets the owner for all following "n", "e" and "t" lines (lower case!)
		 * Q: team number of an existing team (format: team#NN); this also sets the owner for all following "e" lines (lower case!)
		 * i: player index
		 * n: nickname of the player (optional)
		 * t: team ID
		 * e: followed by an event name, a space, and the event count/score
		 *  event names can be:
		 *   alivetime: total playing time of the player
		 *   avglatency: average network latency compounded throughout the match
		 *   wins: number of games won (can only be set if matches is set)
		 *   matches: number of matches played to the end (not aborted by map switch)
		 *   joins: number of matches joined (always 1 unless player never played during the match)
		 *   scoreboardvalid: set to 1 if the player was there at the end of the match
		 *   total-<scoreboardname>: total score of that scoreboard item
		 *   scoreboard-<scoreboardname>: end-of-game score of that scoreboard item (can differ in non-team games)
		 *   achievement-<achievementname>: achievement counters (their "count" is usually 1 if nonzero at all)
		 *   kills-<index>: number of kills against the indexed player
		 *   rank <number>: rank of player
		 *   acc-<weapon netname>-hit: total damage dealt
		 *   acc-<weapon netname>-fired: total damage that all fired projectiles *could* have dealt
		 *   acc-<weapon netname>-cnt-hit: amount of shots that actually hit
		 *   acc-<weapon netname>-cnt-fired: amount of fired shots
		 *   acc-<weapon netname>-frags: amount of frags dealt by weapon
		 */
		case URL_READY_CANWRITE:
		{
			url_fputs(fh, "V 9\n");
			#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
			#endif
			url_fputs(fh, sprintf("G %s\n", GetGametype()));
			url_fputs(fh, sprintf("O %s\n", modname));
			url_fputs(fh, sprintf("M %s\n", GetMapname()));
			url_fputs(fh, sprintf("I %s\n", matchid));
			url_fputs(fh, sprintf("S %s\n", cvar_string("hostname")));
			url_fputs(fh, sprintf("C %d\n", cvar_purechanges_count));
			url_fputs(fh, sprintf("U %d\n", cvar("port")));
			url_fputs(fh, sprintf("D %f\n", max(0, time - game_starttime)));
			url_fputs(fh, sprintf("L %s\n", autocvar_g_playerstats_gamereport_ladder));

			// TEAMS
			if(teamplay)
			{
				for(t = PS_GR_OUT_TL; (tn = db_get(PS_GR_OUT_DB, sprintf("%d", stof(t)))) != ""; t = tn)
				{
					// start team section
					url_fputs(fh, sprintf("Q team#%s\n", t));

					// output team events // todo: does this do unnecessary loops? perhaps we should do a separate "team_events_last" tracker..."
					for(e = PS_GR_OUT_EVL; (en = db_get(PS_GR_OUT_DB, sprintf("*:%s", e))) != ""; e = en)
					{
						float v = stof(db_get(PS_GR_OUT_DB, sprintf("team#%d:%s", stof(t), e)));
						if(v != 0) { url_fputs(fh, sprintf("e %s %g\n", e, v)); }
					}
				}
			}

			// PLAYERS
			for(p = PS_GR_OUT_PL; (pn = db_get(PS_GR_OUT_DB, sprintf("%s:*", p))) != ""; p = pn)
			{
				// start player section
				url_fputs(fh, sprintf("P %s\n", p));

				// playerid/index (entity number for this server)
				nn = db_get(PS_GR_OUT_DB, sprintf("%s:_playerid", p));
				if(nn != "") { url_fputs(fh, sprintf("i %s\n", nn)); }

				// player name 
				nn = db_get(PS_GR_OUT_DB, sprintf("%s:_netname", p));
				if(nn != "") { url_fputs(fh, sprintf("n %s\n", nn)); }

				// team identification number
				if(teamplay)
				{
					tt = db_get(PS_GR_OUT_DB, sprintf("%s:_team", p));
					url_fputs(fh, sprintf("t %s\n", tt));
				}

				// output player events
				for(e = PS_GR_OUT_EVL; (en = db_get(PS_GR_OUT_DB, sprintf("*:%s", e))) != ""; e = en)
				{
					float v = stof(db_get(PS_GR_OUT_DB, sprintf("%s:%s", p, e)));
					if(v != 0) { url_fputs(fh, sprintf("e %s %g\n", e, v)); }
				}
			}
			url_fputs(fh, "\n");
			url_fclose(fh);
			break;
		}

		// ======================================
		// -- INCOMING GAME REPORT INFORMATION --
		// ======================================
		/* SPECIFICATIONS:
		 * stuff
		 */
		case URL_READY_CANREAD:
		{
			// url_fclose is processing, we got a response for writing the data
			// this must come from HTTP
			dprint("Got response from player stats server:\n");
			while((s = url_fgets(fh))) { dprint("  ", s, "\n"); }
			dprint("End of response.\n");
			url_fclose(fh);
			break;
		}
		
		case URL_READY_CLOSED:
		{
			// url_fclose has finished
			dprint("Player stats written\n");
			PlayerStats_GameReport_DelayMapVote = FALSE;
			if(PS_GR_OUT_DB >= 0)
			{
				db_close(PS_GR_OUT_DB);
				PS_GR_OUT_DB = -1;
			}
			break;
		}
		
		case URL_READY_ERROR:
		default:
		{
			print("Player stats writing failed: ", ftos(status), "\n");
			PlayerStats_GameReport_DelayMapVote = FALSE;
			if(PS_GR_OUT_DB >= 0)
			{
				db_close(PS_GR_OUT_DB);
				PS_GR_OUT_DB = -1;
			}
			break;
		}
	}
}

void PlayerStats_PlayerBasic(entity joiningplayer, float newrequest)
{
	// http://stats.xonotic.org/player/GgXRw6piDtFIbMArMuiAi8JG4tiin8VLjZgsKB60Uds=/elo.txt
	if(autocvar_g_playerstats_playerbasic_uri != "")
	{
		string uri = autocvar_g_playerstats_playerbasic_uri;
		if(joiningplayer.crypto_idfp != "")
		{
			// create the database if it doesn't already exist
			if(PS_B_IN_DB < 0)
			{
				PS_B_IN_DB = -1;
				PS_B_IN_DB = db_create();
			}

			// now request the information
			uri = strcat(uri, "/player/", uri_escape(uri_escape(joiningplayer.crypto_idfp)), "/elo.txt");
			dprint("Retrieving playerstats from URL: ", uri, "\n");
			url_single_fopen(
				uri,
				FILE_APPEND,
				PlayerStats_PlayerBasic_Handler,
				joiningplayer
			);

			// set status appropriately // todo: check whether the player info exists in the database previously
			if(newrequest)
			{
				// database still contains useful information, so don't clear it of a useful status
				joiningplayer.playerstats_basicstatus = PS_B_STATUS_WAITING;
			}
			else
			{
				// database was previously empty or never hit received status for some reason
				joiningplayer.playerstats_basicstatus = PS_B_STATUS_UPDATING;
			}
		}
	}
	else
	{
		// server has this disabled, kill the DB and set status to idle
		if(PS_B_IN_DB >= 0)
		{
			entity player;

			db_close(PS_B_IN_DB);
			PS_B_IN_DB = -1;

			FOR_EACH_REALCLIENT(player) { player.playerstats_basicstatus = PS_B_STATUS_IDLE; }
		}
	}
}

void PlayerStats_PlayerBasic_CheckUpdate(entity joiningplayer)
{
	// determine whether we should retrieve playerbasic information again

	#if 0
	printf("PlayerStats_PlayerBasic_CheckUpdate('%s'): %f\n",
		joiningplayer.netname,
		time
	);
	#endif

	// TODO: check to see if this playerid is inside the database already somehow...
	// for now we'll just check the field, but this won't work for players who disconnect and reconnect properly
	// although maybe we should just submit another request ANYWAY?
	if(!joiningplayer.playerstats_basicstatus)
	{
		PlayerStats_PlayerBasic(
			joiningplayer,
			(joiningplayer.playerstats_basicstatus == PS_B_STATUS_RECEIVED)
		);
	}
}

void PlayerStats_PlayerBasic_Handler(entity fh, entity p, float status)
{
	switch(status)
	{
		case URL_READY_CANWRITE:
		{
			dprint("-- Sending data to player stats server\n");
			/*url_fputs(fh, "V 1\n");
			#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
			#endif
			url_fputs(fh, sprintf("l %s\n", cvar_string("_menu_prvm_language"))); // language
			url_fputs(fh, sprintf("c %s\n", cvar_string("_menu_prvm_country"))); // country
			url_fputs(fh, sprintf("g %s\n", cvar_string("_menu_prvm_gender"))); // gender
			url_fputs(fh, sprintf("n %s\n", cvar_string("_cl_name"))); // name
			url_fputs(fh, sprintf("m %s %s\n", cvar_string("_cl_playermodel"), cvar_string("_cl_playerskin"))); // model/skin
			*/url_fputs(fh, "\n");
			url_fclose(fh);
			break;
		}
		
		case URL_READY_CANREAD:
		{
			string s = "";
			dprint("-- Got response from player stats server:\n");
			//string gametype = string_null;
			while((s = url_fgets(fh)))
			{
				dprint("  ", s, "\n");
				/*
				string key = "", value = "", data = "";

				n = tokenizebyseparator(s, " "); // key (value) data
				if (n == 1)
					continue;
				else if (n == 2)
				{
				key = argv(0);
				data = argv(1);
				}
				else if (n >= 3)
				{
								key = argv(0);
								value = argv(1);
								data = argv(2);
				}

				if (data == "")
				continue;

				if (key == "#")
				continue;
				else if (key == "V")
				PlayerInfo_AddItem(p, "_version", data);
				else if (key == "R")
				PlayerInfo_AddItem(p, "_release", data);
				else if (key == "T")
				PlayerInfo_AddItem(p, "_time", data);
				else if (key == "S")
				PlayerInfo_AddItem(p, "_statsurl", data);
				else if (key == "P")
				PlayerInfo_AddItem(p, "_hashkey", data);
				else if (key == "n")
				PlayerInfo_AddItem(p, "_playernick", data);
				else if (key == "i")
				PlayerInfo_AddItem(p, "_playerid", data);
				else if (key == "G")
				gametype = data;
				else if (key == "e" && value != "")
				{
				if (gametype == "")
				PlayerInfo_AddItem(p, value, data);
				else
				PlayerInfo_AddItem(p, sprintf("%s/%s", gametype, value), data);
				}
				else
				continue;
				*/
			}
			dprint("-- End of response.\n");
			url_fclose(fh);
			break;
		}
		case URL_READY_CLOSED:
		{
			// url_fclose has finished
			print("Player stats synchronized with server\n");
			break;
		}
		
		case URL_READY_ERROR:
		default:
		{
			print("Receiving player stats failed: ", ftos(status), "\n");
			break;
		}
	}
}
#endif // SVQC

#ifdef MENUQC


#if 0 // reading the entire DB at once
	string e = "", en = "";
	float i = 0;
	for(e = PS_D_IN_EVL; (en = db_get(PS_D_IN_DB, e)) != ""; e = en)
	{
		print(sprintf("%d:%s:%s\n", i, e, db_get(PS_D_IN_DB, sprintf("#%s", e))));
		++i;
	}
#endif

void PlayerStats_PlayerDetail_AddItem(string event, string data)
{
	if(PS_D_IN_DB < 0) { return; }

	// create a marker for the event so that we can access it later
	string marker = sprintf("%s", event);
	if(db_get(PS_D_IN_DB, marker) == "")
	{
		if(PS_D_IN_EVL)
		{
			db_put(PS_D_IN_DB, marker, PS_D_IN_EVL);
			strunzone(PS_D_IN_EVL);
		}
		else { db_put(PS_D_IN_DB, marker, "#"); } 
		PS_D_IN_EVL = strzone(marker);
	}

	// now actually set the event data
	db_put(PS_D_IN_DB, sprintf("#%s", event), data);
	dprint("Added item ", sprintf("#%s", event), "=", data, " to PS_D_IN_DB\n");
}

void PlayerStats_PlayerDetail(void)
{
	// http://stats.xonotic.org/player/me
	if((autocvar_g_playerstats_playerdetail_uri != "") && (crypto_getmyidstatus(0) > 0))
	{
		// create the database if it doesn't already exist
		if(PS_D_IN_DB < 0)
		{
			PS_D_IN_DB = -1;
			PS_D_IN_DB = db_create();
		}

		//uri = strcat(uri, "/player/", uri_escape(crypto_getmyidfp(0)));
		dprint("Retrieving playerstats from URL: ", autocvar_g_playerstats_playerdetail_uri, "\n");
		url_single_fopen(
			autocvar_g_playerstats_playerdetail_uri,
			FILE_APPEND,
			PlayerStats_PlayerDetail_Handler,
			world
		);

		PlayerStats_PlayerDetail_Status = PS_D_STATUS_WAITING;
	}
	else
	{
		// player has this disabled, kill the DB and set status to idle
		if(PS_D_IN_DB >= 0)
		{
			db_close(PS_D_IN_DB);
			PS_D_IN_DB = -1;
		}

		PlayerStats_PlayerDetail_Status = PS_D_STATUS_IDLE;
	}
}

void PlayerStats_PlayerDetail_CheckUpdate(void)
{
	// determine whether we should retrieve playerdetail information again
	float gamecount = cvar("cl_matchcount");

	#if 0
	printf("PlayerStats_PlayerDetail_CheckUpdate(): %f >= %f, %d > %d\n",
		time,
		PS_D_NEXTUPDATETIME,
		PS_D_LASTGAMECOUNT,
		gamecount
	);
	#endif

	if(
		(time >= PS_D_NEXTUPDATETIME)
		||
		(gamecount > PS_D_LASTGAMECOUNT)
	)
	{
		PlayerStats_PlayerDetail();
		PS_D_NEXTUPDATETIME = (time + autocvar_g_playerstats_playerdetail_autoupdatetime);
		PS_D_LASTGAMECOUNT = gamecount;
	}
}

void PlayerStats_PlayerDetail_Handler(entity fh, entity unused, float status)
{
	switch(status)
	{
		case URL_READY_CANWRITE:
		{
			dprint("PlayerStats_PlayerDetail_Handler(): Sending data to player stats server...\n");
			url_fputs(fh, "V 1\n");
			#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
			#endif
			url_fputs(fh, sprintf("l %s\n", cvar_string("_menu_prvm_language"))); // language
			//url_fputs(fh, sprintf("c %s\n", cvar_string("_cl_country"))); // country
			//url_fputs(fh, sprintf("g %s\n", cvar_string("_cl_gender"))); // gender
			url_fputs(fh, sprintf("n %s\n", cvar_string("_cl_name"))); // name
			url_fputs(fh, sprintf("m %s %s\n", cvar_string("_cl_playermodel"), cvar_string("_cl_playerskin"))); // model/skin
			url_fputs(fh, "\n");
			url_fclose(fh);
			break;
		}
		
		case URL_READY_CANREAD:
		{
			//print("PlayerStats_PlayerDetail_Handler(): Got response from player stats server:\n");
			string input = "";
			string gametype = "overall";
			while((input = url_fgets(fh)))
			{
				float count = tokenizebyseparator(input, " ");
				string key = "", event = "", data = "";

				if(argv(0) == "#") { continue; }
				
				if(count == 2)
				{
					key = argv(0);
					data = substring(input, argv_start_index(1), strlen(input) - argv_start_index(1));
				}
				else if(count >= 3)
				{
					key = argv(0);
					event = argv(1);
					data = substring(input, argv_start_index(2), strlen(input) - argv_start_index(2));
				}
				else { continue; }

				switch(key)
				{
					// general info
					case "V": PlayerStats_PlayerDetail_AddItem("version", data); break;
					case "R": PlayerStats_PlayerDetail_AddItem("release", data); break;
					case "T": PlayerStats_PlayerDetail_AddItem("time", data); break;

					// player info
					case "S": PlayerStats_PlayerDetail_AddItem("statsurl", data); break;
					case "P": PlayerStats_PlayerDetail_AddItem("hashkey", data); break;
					case "n": PlayerStats_PlayerDetail_AddItem("playernick", data); break;
					case "i": PlayerStats_PlayerDetail_AddItem("playerid", data); break;

					// other/event info
					case "G": gametype = data; break;
					case "e":
					{
						if(event != "" && data != "")
						{
							PlayerStats_PlayerDetail_AddItem(
								sprintf(
									"%s/%s",
									gametype,
									event
								),
								data
							);
						}
						break;
					}
					
					default:
					{
						printf(
							"PlayerStats_PlayerDetail_Handler(): ERROR: "
							"Key went unhandled? Is our version outdated?\n"
							"PlayerStats_PlayerDetail_Handler(): "
							"Key '%s', Event '%s', Data '%s'\n",
							key,
							event,
							data
						);
						break;
					}
				}

				#if 0
				print(sprintf(
					"PlayerStats_PlayerDetail_Handler(): "
					"Key '%s', Event '%s', Data '%s'\n",
					key,
					event,
					data
				));
				#endif
			}
			//print("PlayerStats_PlayerDetail_Handler(): End of response.\n");
			url_fclose(fh);
			PlayerStats_PlayerDetail_Status = PS_D_STATUS_RECEIVED;
			statslist.getStats(statslist);
			break;
		}

		case URL_READY_CLOSED:
		{
			// url_fclose has finished
			print("PlayerStats_PlayerDetail_Handler(): Player stats synchronized with server.\n");
			break;
		}

		case URL_READY_ERROR:
		default:
		{
			print("PlayerStats_PlayerDetail_Handler(): Receiving player stats failed: ", ftos(status), "\n");
			PlayerStats_PlayerDetail_Status = PS_D_STATUS_ERROR;
			if(PS_D_IN_DB >= 0)
			{
				db_close(PS_D_IN_DB);
				PS_D_IN_DB = -1;
			}
			break;
		}
	}
}
#endif

/*
void PlayerInfo_AddPlayer(entity e)
{
	if(playerinfo_db < 0)
		return;

	string key;
	key = sprintf("#%d:*", e.playerid); // TODO: use hashkey instead?

	string p;
	p = db_get(playerinfo_db, key);
	if(p == "")
	{
		if(playerinfo_last)
		{
			db_put(playerinfo_db, key, playerinfo_last);
			strunzone(playerinfo_last);
		}
		else
			db_put(playerinfo_db, key, "#");
		playerinfo_last = strzone(ftos(e.playerid));
		print("  Added player ", ftos(e.playerid), " to playerinfo_db\n");//DEBUG//
	}
}

void PlayerInfo_AddItem(entity e, string item_id, string val)
{
	if(playerinfo_db < 0)
		return;

	string key;
	key = sprintf("*:%s", item_id);

	string p;
	p = db_get(playerinfo_db, key);
	if(p == "")
	{
		if(playerinfo_events_last)
		{
			db_put(playerinfo_db, key, playerinfo_events_last);
			strunzone(playerinfo_events_last);
		}
		else
			db_put(playerinfo_db, key, "#");
		playerinfo_events_last = strzone(item_id);
	}

	key = sprintf("#%d:%s", e.playerid, item_id);
	db_put(playerinfo_db, key, val);
	print("  Added item ", key, "=", val, " to playerinfo_db\n");//DEBUG//
}

string PlayerInfo_GetItem(entity e, string item_id)
{
	if(playerinfo_db < 0)
		return "";

	string key;
	key = sprintf("#%d:%s",  e.playerid, item_id);
	return db_get(playerinfo_db, key);
}

string PlayerInfo_GetItemLocal(string item_id)
{
        entity p = spawn();
        p.playerid = 0;
        return PlayerInfo_GetItem(p, item_id);
}

void PlayerInfo_ready(entity fh, entity p, float status)
{
	float n;
	string s;

        PlayerInfo_AddPlayer(p);

	switch(status)
	{
                case URL_READY_CANWRITE:
                        print("-- Sending data to player stats server\n");
			url_fputs(fh, "V 1\n");
#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
#endif
#ifdef MENUQC
                        url_fputs(fh, sprintf("l %s\n", cvar_string("_menu_prvm_language"))); // language
                        url_fputs(fh, sprintf("c %s\n", cvar_string("_menu_prvm_country"))); // country
                        url_fputs(fh, sprintf("g %s\n", cvar_string("_menu_prvm_gender"))); // gender
                        url_fputs(fh, sprintf("n %s\n", cvar_string("_cl_name"))); // name
                        url_fputs(fh, sprintf("m %s %s\n", cvar_string("_cl_playermodel"), cvar_string("_cl_playerskin"))); // model/skin
#endif
			url_fputs(fh, "\n");
			url_fclose(fh);
                        break;
                case URL_READY_CANREAD:
			print("-- Got response from player stats server:\n");
			string gametype = string_null;
			while((s = url_fgets(fh)))
			{
				print("  ", s, "\n");

				string key = "", value = "", data = "";

				n = tokenizebyseparator(s, " "); // key (value) data
				if (n == 1)
                                        continue;
				else if (n == 2)
				{
					key = argv(0);
					data = argv(1);
				}
				else if (n >= 3)
				{
                                        key = argv(0);
                                        value = argv(1);
                                        data = argv(2);
				}

				if (data == "")
					continue;

				if (key == "#")
					continue;
				else if (key == "V")
					PlayerInfo_AddItem(p, "_version", data);
				else if (key == "R")
					PlayerInfo_AddItem(p, "_release", data);
				else if (key == "T")
					PlayerInfo_AddItem(p, "_time", data);
				else if (key == "S")
					PlayerInfo_AddItem(p, "_statsurl", data);
				else if (key == "P")
					PlayerInfo_AddItem(p, "_hashkey", data);
				else if (key == "n")
					PlayerInfo_AddItem(p, "_playernick", data);
				else if (key == "i")
					PlayerInfo_AddItem(p, "_playerid", data);
				else if (key == "G")
					gametype = data;
				else if (key == "e" && value != "")
				{
					if (gametype == "")
						PlayerInfo_AddItem(p, value, data);
					else
						PlayerInfo_AddItem(p, sprintf("%s/%s", gametype, value), data);
				}
				else
					continue;
			}
			print("-- End of response.\n");
			url_fclose(fh);
			break;
		case URL_READY_CLOSED:
			// url_fclose has finished
			print("Player stats synchronized with server\n");
			break;
		case URL_READY_ERROR:
		default:
			print("Receiving player stats failed: ", ftos(status), "\n");
			break;
	}
}

void PlayerInfo_Init()
{
	playerinfo_db = -1;
	playerinfo_db = db_create();
}

#ifdef SVQC
void PlayerInfo_Basic(entity p)
{
        print("-- Getting basic PlayerInfo for player ",ftos(p.playerid)," (SVQC)\n");

	if(playerinfo_db < 0)
		return;

        string uri;
        uri = autocvar_g_playerinfo_uri;
	if(uri != "" && p.crypto_idfp != "")
	{
		uri = strcat(uri, "/elo/", uri_escape(p.crypto_idfp));
		print("Retrieving playerstats from URL: ", uri, "\n");
		url_single_fopen(uri, FILE_READ, PlayerInfo_ready, p);
	}
}
#endif

#ifdef MENUQC
void PlayerInfo_Details()
{
        print("-- Getting detailed PlayerInfo for local player (MENUQC)\n");

	if(playerinfo_db < 0)
		return;

        string uri;
        uri = autocvar_g_playerinfo_uri; // FIXME
	if(uri != "" && crypto_getmyidstatus(0) > 0)
	{
		//uri = strcat(uri, "/player/", uri_escape(crypto_getmyidfp(0)));
                uri = strcat(uri, "/player/me");
		print("Retrieving playerstats from URL: ", uri, "\n");
		url_single_fopen(uri, FILE_APPEND, PlayerInfo_ready, world);
	}
}
#endif

#ifdef CSQC
/*
 * FIXME - crypto_* builtin functions missing in CSQC (csprogsdefs.qc:885)
void PlayerInfo_Details()
{
        print("-- Getting detailed PlayerInfo for local player (CSQC)\n");

	if(playerinfo_db < 0)
		return;

        string uri;
        uri = autocvar_g_playerinfo_uri; // FIXME
	if(uri != "" && crypto_getmyidstatus(0) > 0)
	{
		uri = strcat(uri, "/player/", uri_escape(crypto_getmyidfp(0)));
		print("Retrieving playerstats from URL: ", uri, "\n");
		url_single_fopen(uri, FILE_READ, PlayerInfo_ready, p);
	}
}

#endif
*/
