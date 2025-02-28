#include "playerstats.qh"


#ifdef GAMEQC
REPLICATE(cvar_cl_allow_uid2name, int, "cl_allow_uid2name");
REPLICATE(cvar_cl_allow_uidranking, bool, "cl_allow_uidranking");
REPLICATE(cvar_cl_allow_uidtracking, int, "cl_allow_uidtracking");
#endif

#ifdef SVQC
REPLICATE_APPLYCHANGE("cl_allow_uidtracking", { PlayerStats_GameReport_AddPlayer(this); });
#endif

#ifdef SVQC
void PlayerStats_Prematch()
{
	//foobar
}

// Deletes current playerstats DB, creates a new one and fully initializes it
#if 0
void PlayerStats_GameReport_Reset_All()
{
	strfree(PS_GR_OUT_TL);
	strfree(PS_GR_OUT_PL);
	strfree(PS_GR_OUT_EVL);

	if (PS_GR_OUT_DB >= 0)
	{
		db_close(PS_GR_OUT_DB);
		PlayerStats_GameReport_Init();
	}
	if(PS_GR_OUT_DB < 0)
		return;

	FOREACH_CLIENT(true, {
		// NOTE Adding back a player we are applying any cl_allow_uidtracking change
		// usually only possible by reconnecting to the server
		strfree(it.playerstats_id);
		PlayerStats_GameReport_AddEvent(sprintf("kills-%d", it.playerid));
		PlayerStats_GameReport_AddPlayer(it);
	});
	FOREACH(Scores, true, {
		string label = scores_label(it);
		if (label == "")
			continue;
		PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_TOTAL, label));
		PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_SCOREBOARD, label));
	});
	for(int i = 0; i < MAX_TEAMSCORE; ++i)
	{
		string label = teamscores_label(i);
		if (label == "")
			continue;
		PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_TOTAL, label));
		PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_SCOREBOARD, label));
	}
}
#endif

void PlayerStats_GameReport_AddPlayer(entity e)
{
	if((PS_GR_OUT_DB < 0) || (e.playerstats_id)) { return; }

	// set up player identification
	string s = "";

	if((e.crypto_idfp != "") && (e.cvar_cl_allow_uidtracking == 1))
		{ s = e.crypto_idfp; }
	else if(IS_BOT_CLIENT(e))
		{ s = sprintf("bot#%g#%s", autocvar_skill, e.netname); }

	if((s == "") || find(NULL, playerstats_id, s)) // already have one of the ID - next one can't be tracked then!
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

#if 0
void PlayerStats_GameReport_AddTeam(int t)
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
#endif

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

float PlayerStats_GameReport_Event(string prefix, string event_id, float value)
{
	if((prefix == "") || PS_GR_OUT_DB < 0) { return 0; }

	// use a cheaper strcat here since this function is called often in game
	string key = strcat(prefix, ":", event_id);
	float val = stof(db_get(PS_GR_OUT_DB, key));
	val += value;
	db_put(PS_GR_OUT_DB, key, ftos(val));
	return val;
}

#if 0
void PlayerStats_GameReport_Accuracy(entity p)
{
	#define ACCMAC(suffix, field) \
		PlayerStats_GameReport_Event_Player(p, \
			sprintf("acc-%s-%s", it.netname, suffix), p.accuracy.(field[i-1]));
	FOREACH(Weapons, it != WEP_Null, {
		ACCMAC("hit", accuracy_hit)
		ACCMAC("fired", accuracy_fired)
		ACCMAC("cnt-hit", accuracy_cnt_hit)
		ACCMAC("cnt-fired", accuracy_cnt_fired)
		ACCMAC("frags", accuracy_frags)
	});
	#undef ACCMAC
}
#endif

void PlayerStats_GameReport_FinalizePlayer(entity p)
{
	if((p.playerstats_id == "") || PS_GR_OUT_DB < 0) { return; }

	// add global info!
	if(p.alivetime)
	{
		PlayerStats_GameReport_Event_Player(p, PLAYERSTATS_ALIVETIME, time - p.alivetime);
		p.alivetime = 0;
	}

	db_put(PS_GR_OUT_DB, sprintf("%s:_playerid", p.playerstats_id), ftos(p.playerid));

	if(p.cvar_cl_allow_uid2name == 1 || IS_BOT_CLIENT(p))
		db_put(PS_GR_OUT_DB, sprintf("%s:_netname", p.playerstats_id), p.netname);

	if(stof(db_get(PS_GR_OUT_DB, sprintf("%s:%s", p.playerstats_id, PLAYERSTATS_ALIVETIME))) > 0)
		PlayerStats_GameReport_Event_Player(p, PLAYERSTATS_JOINS, 1);

	//PlayerStats_GameReport_Accuracy(p);
	//anticheat_report_to_playerstats(p);

	if(IS_REAL_CLIENT(p))
	{
		if(p.latency_cnt)
		{
			float latency = max(0, p.latency_sum / p.latency_cnt);
			if(latency)
			{
				// if previous average latency exists (player disconnected and reconnected)
				// make the average of previous and current average latency
				float prev_latency = PlayerStats_GameReport_Event_Player(p, PLAYERSTATS_AVGLATENCY, 0);
				float new_latency = !prev_latency ? latency : (prev_latency + latency) / 2;
				PlayerStats_GameReport_Event_Player(p, PLAYERSTATS_AVGLATENCY, -prev_latency + new_latency);
			}
		}

		db_put(PS_GR_OUT_DB, sprintf("%s:_ranked", p.playerstats_id), ftos(p.cvar_cl_allow_uidranking));
	}

	strfree(p.playerstats_id);
}

void PlayerScore_PlayerStats(entity p)
{
	PlayerStats_GameReport_Event_Player(p, strcat(PLAYERSTATS_SCOREBOARD, "kills"), p.frags);
	PlayerStats_GameReport_Event_Player(p, strcat(PLAYERSTATS_SCOREBOARD, "dmg"), p.frags);
}

void PlayerStats_GameReport(bool finished)
{
	if(PS_GR_OUT_DB < 0) { return; }

	FOREACH_CLIENT(true, {
		// add personal score rank
		PlayerStats_GameReport_Event_Player(it, PLAYERSTATS_RANK, etof(it));

		// scoreboard data
		if(IS_PLAYER(it))
		{
			// scoreboard is valid!
			PlayerStats_GameReport_Event_Player(it, PLAYERSTATS_SCOREBOARD_VALID, 1);

			// add scoreboard position
			PlayerStats_GameReport_Event_Player(it, PLAYERSTATS_SCOREBOARD_POS, etof(it));

			// add scoreboard data
			PlayerScore_PlayerStats(it);

			// if the match ended normally, add winning info
			if(finished)
			{
				PlayerStats_GameReport_Event_Player(it, PLAYERSTATS_WINS, true);
				PlayerStats_GameReport_Event_Player(it, PLAYERSTATS_MATCHES, 1);
			}
		}

		// collect final player information
		PlayerStats_GameReport_FinalizePlayer(it);
	});

	if(autocvar_g_playerstats_gamereport_uri == "")
	{
		PlayerStats_GameReport_DelayMapVote = false;
		db_close(PS_GR_OUT_DB);
		PS_GR_OUT_DB = -1;
		return;
	}

	PlayerStats_GameReport_DelayMapVote = true;
	url_multi_fopen(
		autocvar_g_playerstats_gamereport_uri,
		FILE_APPEND,
		PlayerStats_GameReport_Handler,
		NULL
	);
}

void PlayerStats_GameReport_Init() // initiated before InitGameplayMode so that scores are added properly
{
	statsflags &= ~SERVERFLAG_PLAYERSTATS;
	statsflags &= ~SERVERFLAG_PLAYERSTATS_CUSTOM;

	if(autocvar_g_playerstats_gamereport_uri == "") { return; }

	PS_GR_OUT_DB = db_create();

	if(PS_GR_OUT_DB >= 0)
	{
		PlayerStats_GameReport_DelayMapVote = true;

		if(autocvar_g_playerstats_gamereport_uri != cvar_defstring("g_playerstats_gamereport_uri"))
			statsflags |= SERVERFLAG_PLAYERSTATS | SERVERFLAG_PLAYERSTATS_CUSTOM;
		else if(checkextension("DP_CRYPTO") && checkextension("DP_QC_URI_POST"))
			// XonStat submission requires player and server IDs, and HTTPS POST
			statsflags |= SERVERFLAG_PLAYERSTATS;

		PlayerStats_GameReport_AddEvent(PLAYERSTATS_ALIVETIME);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_AVGLATENCY);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_WINS);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_MATCHES);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_JOINS);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_SCOREBOARD_VALID);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_SCOREBOARD_POS);
		PlayerStats_GameReport_AddEvent(PLAYERSTATS_RANK);

		// accuracy stats
		FOREACH(Weapons, it != WEP_Null, {
			PlayerStats_GameReport_AddEvent(strcat("acc-", it.netname, "-hit"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", it.netname, "-fired"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", it.netname, "-cnt-hit"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", it.netname, "-cnt-fired"));
			PlayerStats_GameReport_AddEvent(strcat("acc-", it.netname, "-frags"));
		});

		//anticheat_register_to_playerstats();
	}
	else { PlayerStats_GameReport_DelayMapVote = false; }
}

// this... is a hack, a temporary one until we get a proper duel gametype
// TODO: remove duel hack after servers have migrated to the proper duel gametype!
string PlayerStats_GetGametype()
{
	return "dm";
}

#ifdef SVQC
float game_starttime;
#endif
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
		 * I: match ID (see "matchid" in world.qc)
		 * S: "hostname" of the server
		 * C: number of "unpure" cvar changes
		 * U: UDP port number of the server
		 * D: duration of the match
		 * RP: number of rounds played
		 * L: "ladder" in which the server is participating in
		 * P: player ID of an existing player; this also sets the owner for all following "n", "e" and "t" lines (lower case!)
		 * Q: team number of an existing team (format: team#NN); this also sets the owner for all following "e" lines (lower case!)
		 * i: player index
		 * n: nickname of the player (optional)
		 * t: team ID
		 * r: player ranking enabled / disabled
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
			url_fputs(fh, sprintf("G %s\n", PlayerStats_GetGametype()));
			url_fputs(fh, sprintf("O %s\n", "Quake"));
			url_fputs(fh, sprintf("M %s\n", mapname));
			url_fputs(fh, sprintf("I %s\n", matchid));
			url_fputs(fh, sprintf("S %s\n", cvar_string("hostname")));
			url_fputs(fh, sprintf("C %d\n", cvar_purechanges_count));
			url_fputs(fh, sprintf("U %d\n", cvar("port")));
			url_fputs(fh, sprintf("D %f\n", max(0, time - game_starttime)));
			if (autocvar_g_playerstats_gamereport_ladder != "")
				url_fputs(fh, sprintf("L %s\n", autocvar_g_playerstats_gamereport_ladder));

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

				// elo ranking enabled
				nn = db_get(PS_GR_OUT_DB, sprintf("%s:_ranked", p));
				if(nn != "") { url_fputs(fh, sprintf("r %s\n", nn)); }

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
			LOG_DEBUG("Got response from player stats server:");
			while((s = url_fgets(fh))) { LOG_DEBUG("  ", s); }
			LOG_DEBUG("End of response.");
			url_fclose(fh);
			break;
		}

		case URL_READY_CLOSED:
		{
			// url_fclose has finished
			LOG_DEBUG("Player stats written");
			PlayerStats_GameReport_DelayMapVote = false;
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
			LOG_INFO("Player stats writing failed: ", ftos(status));
			PlayerStats_GameReport_DelayMapVote = false;
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
		if (joiningplayer.crypto_idfp == "") {
		} else {
			// create the database if it doesn't already exist
			if(PS_B_IN_DB < 0)
				PS_B_IN_DB = db_create();

			// now request the information
			uri = strcat(uri, "/player/", uri_escape(uri_escape(uri_escape(joiningplayer.crypto_idfp))), "/elo.txt");
			LOG_DEBUG("Retrieving playerstats from URL: ", uri);
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
			db_close(PS_B_IN_DB);
			PS_B_IN_DB = -1;

			FOREACH_CLIENT(IS_REAL_CLIENT(it), it.playerstats_basicstatus = PS_B_STATUS_IDLE);
		}
	}
}

SHUTDOWN(PlayerStats_PlayerBasic_Shutdown)
{
	if(PS_B_IN_DB >= 0)
	{
		db_close(PS_B_IN_DB);
		PS_B_IN_DB = -1;
	}

	if(PS_GR_OUT_DB >= 0)
	{
		db_close(PS_GR_OUT_DB);
		PS_GR_OUT_DB = -1;
	}
}

void PlayerStats_PlayerBasic_CheckUpdate(entity joiningplayer)
{
	// determine whether we should retrieve playerbasic information again

	LOG_DEBUGF("PlayerStats_PlayerBasic_CheckUpdate('%s'): %f",
		joiningplayer.netname,
		time
	);

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
			LOG_DEBUG("-- Sending data to player stats server");
			/*url_fputs(fh, "V 1\n");
			#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
			#endif
			url_fputs(fh, sprintf("l %s\n", cvar_string("_menu_prvm_language"))); // language
			url_fputs(fh, sprintf("c %s\n", cvar_string("_menu_prvm_country"))); // country
			url_fputs(fh, sprintf("n %s\n", cvar_string("_cl_name"))); // name
			url_fputs(fh, sprintf("m %s %s\n", cvar_string("_cl_playermodel"), cvar_string("_cl_playerskin"))); // model/skin
			*/url_fputs(fh, "\n");
			url_fclose(fh);
			return;
		}

		case URL_READY_CANREAD:
		{
			bool handled = false;
			string gt = string_null;
			for (string s = ""; (s = url_fgets(fh)); ) {
				int n = tokenizebyseparator(s, " "); // key value? data
				if (n == 1) continue;
				string key = "", value = "", data = "";
				if (n == 2) {
                    key = argv(0);
                    data = argv(1);
				} else if (n >= 3) {
                    key = argv(0);
                    value = argv(1);
                    data = argv(2);
				}
                switch (key) {
                    case "V":
                        // PlayerInfo_AddItem(p, "_version", data);
                        break;
                    case "R":
                        // PlayerInfo_AddItem(p, "_release", data);
                        break;
                    case "T":
                        // PlayerInfo_AddItem(p, "_time", data);
                        break;
                    case "S":
                        // PlayerInfo_AddItem(p, "_statsurl", data);
                        break;
                    case "P":
                        // PlayerInfo_AddItem(p, "_hashkey", data);
                        break;
                    case "n":
                        // PlayerInfo_AddItem(p, "_playernick", data);
                        break;
                    case "i":
                        // PlayerInfo_AddItem(p, "_playerid", data);
                        // p.xonstat_id = stof(data);
                        break;
                    case "G":
                        gt = data;
                        break;
                    case "e":
                        //LOG_TRACE("G: ", gt);
                        //LOG_TRACE("e: ", data);
                        if (gt == "") {
                            // PlayerInfo_AddItem(p, value, data);
                        } else {
                            // PlayerInfo_AddItem(p, sprintf("%s/%s", gt, value), data);
                        }
                        break;
                }
			}
			url_fclose(fh);
			if (handled) return;
			break;
		}
		case URL_READY_CLOSED:
		{
			// url_fclose has finished
			LOG_INFO("Player stats synchronized with server");
			return;
		}

		case URL_READY_ERROR:
		default:
		{
			LOG_INFO("Receiving player stats failed: ", ftos(status));
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
		LOG_INFOF("%d:%s:%s", i, e, db_get(PS_D_IN_DB, sprintf("#%s", e)));
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
	LOG_DEBUG("Added item ", sprintf("#%s", event), "=", data, " to PS_D_IN_DB");
}

void PlayerStats_PlayerDetail()
{
	// http://stats.xonotic.org/player/me
	if((autocvar_g_playerstats_playerdetail_uri != "") && (crypto_getmyidstatus(0) > 0))
	{
		// create the database if it doesn't already exist
		if(PS_D_IN_DB < 0)
			PS_D_IN_DB = db_create();

		//uri = strcat(uri, "/player/", uri_escape(crypto_getmyidfp(0)));
		LOG_DEBUG("Retrieving playerstats from URL: ", autocvar_g_playerstats_playerdetail_uri);
		url_single_fopen(
			autocvar_g_playerstats_playerdetail_uri,
			FILE_APPEND,
			PlayerStats_PlayerDetail_Handler,
			NULL
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

void PlayerStats_PlayerDetail_CheckUpdate()
{
	// determine whether we should retrieve playerdetail information again
	float gamecount = cvar("cl_matchcount");

	#if 0
	LOG_INFOF("PlayerStats_PlayerDetail_CheckUpdate(): %f >= %f, %d > %d",
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
			LOG_DEBUG("PlayerStats_PlayerDetail_Handler(): Sending data to player stats server...");
			url_fputs(fh, "V 1\n");
			#ifdef WATERMARK
			url_fputs(fh, sprintf("R %s\n", WATERMARK));
			#endif
			url_fputs(fh, sprintf("l %s\n", cvar_string("_menu_prvm_language"))); // language
			//url_fputs(fh, sprintf("c %s\n", cvar_string("_cl_country"))); // country
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
						LOG_INFOF(
							"PlayerStats_PlayerDetail_Handler(): ERROR: "
							"Key went unhandled? Is our version outdated?\n"
							"PlayerStats_PlayerDetail_Handler(): "
							"Key '%s', Event '%s', Data '%s'",
							key,
							event,
							data
						);
						break;
					}
				}

				#if 0
				LOG_INFOF(
					"PlayerStats_PlayerDetail_Handler(): "
					"Key '%s', Event '%s', Data '%s'",
					key,
					event,
					data
				);
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
			LOG_INFO("PlayerStats_PlayerDetail_Handler(): Player stats synchronized with server.");
			break;
		}

		case URL_READY_ERROR:
		default:
		{
			LOG_INFO("PlayerStats_PlayerDetail_Handler(): Receiving player stats failed: ", ftos(status));
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

#ifdef SVQC
STATIC_INIT_LATE(PlayerStats)
{
	PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_TOTAL, "kills"));
	PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_SCOREBOARD, "kills"));

	PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_TOTAL, "dmg"));
	PlayerStats_GameReport_AddEvent(strcat(PLAYERSTATS_SCOREBOARD, "dmg"));

	// just count game start as now
	game_starttime = time;
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
		url_single_fopen(uri, FILE_APPEND, PlayerInfo_ready, NULL);
	}
}
#endif

#ifdef CSQC
// FIXME - crypto_* builtin functions missing in CSQC (csprogsdefs.qh:885)
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
