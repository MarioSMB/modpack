float GameTypeVote_AvailabilityStatus(string gtname) 
{ 
	float type = MapInfo_Type_FromString(gtname);
	if( type == 0 )
		return GTV_FORBIDDEN;
	
	if ( autocvar_nextmap != "" )
	{
		if ( !MapInfo_Get_ByName(autocvar_nextmap, FALSE, 0) )
			return GTV_FORBIDDEN;
		if (!(MapInfo_Map_supportedGametypes & type))
			return GTV_FORBIDDEN;
	}
	
	return GTV_AVAILABLE;
}

float GameTypeVote_GetMask()
{
	float n, j, gametype_mask;
	n = tokenizebyseparator(autocvar_sv_vote_gametype_options, " ");
	n = min(MAPVOTE_COUNT, n);
	gametype_mask = 0;
	for(j = 0; j < n; ++j)
		gametype_mask |= MapInfo_Type_FromString(argv(j));
	return gametype_mask;
}

string GameTypeVote_MapInfo_FixName(string m)
{
	if ( autocvar_sv_vote_gametype )
	{
		MapInfo_Enumerate();
		MapInfo_FilterGametype(GameTypeVote_GetMask(), 0, MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
	}
	return MapInfo_FixName(m);
}

void MapVote_ClearAllVotes()
{
	FOR_EACH_CLIENT(other)
		other.mapvote = 0;
}

void MapVote_UnzoneStrings()
{
	float j;
	for(j = 0; j < mapvote_count; ++j)
	{
		if ( mapvote_maps[j] )
		{
			strunzone(mapvote_maps[j]);
			mapvote_maps[j] = string_null;
		}
		if ( mapvote_maps_pakfile[j] )
		{
			strunzone(mapvote_maps_pakfile[j]);
			mapvote_maps_pakfile[j] = string_null;
		}
	}
}

string MapVote_Suggest(string m)
{
	float i;
	if(m == "")
		return "That's not how to use this command.";
	if(!autocvar_g_maplist_votable_suggestions)
		return "Suggestions are not accepted on this server.";
	if(mapvote_initialized)
	if(!gametypevote)
		return "Can't suggest - voting is already in progress!";
	m = GameTypeVote_MapInfo_FixName(m);
	if (!m)
		return "The map you suggested is not available on this server.";
	if(!autocvar_g_maplist_votable_suggestions_override_mostrecent)
		if(Map_IsRecent(m))
			return "This server does not allow for recent maps to be played again. Please be patient for some rounds.";

	if (!autocvar_sv_vote_gametype)
	if(!MapInfo_CheckMap(m))
		return "The map you suggested does not support the current game mode.";
	for(i = 0; i < mapvote_suggestion_ptr; ++i)
		if(mapvote_suggestions[i] == m)
			return "This map was already suggested.";
	if(mapvote_suggestion_ptr >= MAPVOTE_COUNT)
	{
		i = floor(random() * mapvote_suggestion_ptr);
	}
	else
	{
		i = mapvote_suggestion_ptr;
		mapvote_suggestion_ptr += 1;
	}
	if(mapvote_suggestions[i] != "")
		strunzone(mapvote_suggestions[i]);
	mapvote_suggestions[i] = strzone(m);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":vote:suggested:", m, ":", ftos(self.playerid)));
	return strcat("Suggestion of ", m, " accepted.");
}

void MapVote_AddVotable(string nextMap, float isSuggestion)
{
	float j, i, o;
	string pakfile, mapfile;

	if(nextMap == "")
		return;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMap)
			return;
	// suggestions might be no longer valid/allowed after gametype switch!
	if(isSuggestion)
		if(!MapInfo_CheckMap(nextMap))
			return;
	mapvote_maps[mapvote_count] = strzone(nextMap);
	mapvote_maps_suggested[mapvote_count] = isSuggestion;

	pakfile = string_null;
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
	{
		mapfile = strcat(mapvote_screenshot_dirs[i], "/", mapvote_maps[i]);
		pakfile = whichpack(strcat(mapfile, ".tga"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".jpg"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".png"));
		if(pakfile != "")
			break;
	}
	if(i >= mapvote_screenshot_dirs_count)
		i = 0; // FIXME maybe network this error case, as that means there is no mapshot on the server?
	for(o = strstr(pakfile, "/", 0)+1; o > 0; o = strstr(pakfile, "/", 0)+1)
		pakfile = substring(pakfile, o, -1);

	mapvote_maps_screenshot_dir[mapvote_count] = i;
	mapvote_maps_pakfile[mapvote_count] = strzone(pakfile);
	mapvote_maps_availability[mapvote_count] = GTV_AVAILABLE;

	mapvote_count += 1;
}

void MapVote_Init()
{
	float i;
	float nmax, smax;

	MapVote_ClearAllVotes();
	MapVote_UnzoneStrings();

	mapvote_count = 0;
	mapvote_detail = !autocvar_g_maplist_votable_nodetail;
	mapvote_abstain = autocvar_g_maplist_votable_abstain;

	if(mapvote_abstain)
		nmax = min(MAPVOTE_COUNT - 1, autocvar_g_maplist_votable);
	else
		nmax = min(MAPVOTE_COUNT, autocvar_g_maplist_votable);
	smax = min3(nmax, autocvar_g_maplist_votable_suggestions, mapvote_suggestion_ptr);

	// we need this for AddVotable, as that cycles through the screenshot dirs
	mapvote_screenshot_dirs_count = tokenize_console(autocvar_g_maplist_votable_screenshot_dir);
	if(mapvote_screenshot_dirs_count == 0)
		mapvote_screenshot_dirs_count = tokenize_console("maps levelshots");
	mapvote_screenshot_dirs_count = min(mapvote_screenshot_dirs_count, MAPVOTE_SCREENSHOT_DIRS_COUNT);
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
		mapvote_screenshot_dirs[i] = strzone(argv(i));

	if(mapvote_suggestion_ptr)
		for(i = 0; i < 100 && mapvote_count < smax; ++i)
			MapVote_AddVotable(mapvote_suggestions[floor(random() * mapvote_suggestion_ptr)], TRUE);

	for(i = 0; i < 100 && mapvote_count < nmax; ++i)
		MapVote_AddVotable(GetNextMap(), FALSE);

	if(mapvote_count == 0)
	{
		bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllowedMaps(MapInfo_CurrentGametype(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
		for(i = 0; i < 100 && mapvote_count < nmax; ++i)
			MapVote_AddVotable(GetNextMap(), FALSE);
	}

	mapvote_count_real = mapvote_count;
	if(mapvote_abstain)
		MapVote_AddVotable("don't care", 0);

	//dprint("mapvote count is ", ftos(mapvote_count), "\n");

	mapvote_keeptwotime = time + autocvar_g_maplist_votable_keeptwotime;
	mapvote_timeout = time + autocvar_g_maplist_votable_timeout;
	if(mapvote_count_real < 3 || mapvote_keeptwotime <= time)
		mapvote_keeptwotime = 0;
	mapvote_message = "Choose a map and press its key!";

	MapVote_Spawn();
}

void MapVote_SendPicture(float id)
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_PICTURE);
	WriteByte(MSG_ONE, id);
	WritePicture(MSG_ONE, strcat(mapvote_screenshot_dirs[mapvote_maps_screenshot_dir[id]], "/", mapvote_maps[id]), 3072);
}


void MapVote_WriteMask()
{
	float i;
	if ( mapvote_count < 24 )
	{
		float mask,power;
		mask = 0;
		for(i = 0, power = 1; i < mapvote_count; ++i, power *= 2)
			if(mapvote_maps_availability[i] == GTV_AVAILABLE )
				mask |= power;
			
		if(mapvote_count < 8)
			WriteByte(MSG_ENTITY, mask);
		else if (mapvote_count < 16)
			WriteShort(MSG_ENTITY,mask);
		else
			WriteLong(MSG_ENTITY, mask);
	}
	else
	{
		for ( i = 0; i < mapvote_count; ++i )
			WriteByte(MSG_ENTITY, mapvote_maps_availability[i]);
	}
}

float MapVote_SendEntity(entity to, float sf)
{
	float i;

	if(sf & 1)
		sf &= ~2; // if we send 1, we don't need to also send 2

	WriteByte(MSG_ENTITY, ENT_CLIENT_MAPVOTE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		// flag 1 == initialization
		for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
			WriteString(MSG_ENTITY, mapvote_screenshot_dirs[i]);
		WriteString(MSG_ENTITY, "");
		WriteByte(MSG_ENTITY, mapvote_count);
		WriteByte(MSG_ENTITY, mapvote_abstain);
		WriteByte(MSG_ENTITY, mapvote_detail);
		WriteCoord(MSG_ENTITY, mapvote_timeout);
		
		if ( gametypevote )
		{
			// gametype vote
			WriteByte(MSG_ENTITY, 1);
			WriteString(MSG_ENTITY, autocvar_nextmap);
		}
		else if ( autocvar_sv_vote_gametype )
		{
			 // map vote but gametype has been chosen via voting screen
			WriteByte(MSG_ENTITY, 2);
			WriteString(MSG_ENTITY, MapInfo_Type_ToText(MapInfo_CurrentGametype()));
		}
		else
			WriteByte(MSG_ENTITY, 0); // map vote

		MapVote_WriteMask();

		for(i = 0; i < mapvote_count; ++i)
		{
			if(mapvote_abstain && i == mapvote_count - 1)
			{
				WriteString(MSG_ENTITY, ""); // abstain needs no text
				WriteString(MSG_ENTITY, ""); // abstain needs no pack
				WriteByte(MSG_ENTITY, 0); // abstain needs no screenshot dir
				WriteByte(MSG_ENTITY, GTV_AVAILABLE);
			}
			else
			{
				WriteString(MSG_ENTITY, mapvote_maps[i]);
				WriteString(MSG_ENTITY, mapvote_maps_pakfile[i]);
				WriteByte(MSG_ENTITY, mapvote_maps_screenshot_dir[i]);
				WriteByte(MSG_ENTITY, mapvote_maps_availability[i]);
			}
		}
	}

	if(sf & 2)
	{
		// flag 2 == update of mask
		MapVote_WriteMask();
	}

	if(sf & 4)
	{
		if(mapvote_detail)
			for(i = 0; i < mapvote_count; ++i)
				if ( mapvote_maps_availability[i] == GTV_AVAILABLE )
					WriteByte(MSG_ENTITY, mapvote_selections[i]);

		WriteByte(MSG_ENTITY, to.mapvote);
	}

	return TRUE;
}

void MapVote_Spawn()
{
	Net_LinkEntity(mapvote_ent = spawn(), FALSE, 0, MapVote_SendEntity);
}

void MapVote_TouchMask()
{
	mapvote_ent.SendFlags |= 2;
}

void MapVote_TouchVotes(entity voter)
{
	mapvote_ent.SendFlags |= 4;
}

float MapVote_Finished(float mappos)
{
	if(alreadychangedlevel)
		return FALSE;

	string result;
	float i;
	float didntvote;

	if(autocvar_sv_eventlog)
	{
		result = strcat(":vote:finished:", mapvote_maps[mappos]);
		result = strcat(result, ":", ftos(mapvote_selections[mappos]), "::");
		didntvote = mapvote_voters;
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps_availability[i] == GTV_AVAILABLE )
			{
				didntvote -= mapvote_selections[i];
				if(i != mappos)
				{
					result = strcat(result, ":", mapvote_maps[i]);
					result = strcat(result, ":", ftos(mapvote_selections[i]));
				}
			}
		result = strcat(result, ":didn't vote:", ftos(didntvote));

		GameLogEcho(result);
		if(mapvote_maps_suggested[mappos])
			GameLogEcho(strcat(":vote:suggestion_accepted:", mapvote_maps[mappos]));
	}

	FOR_EACH_REALCLIENT(other)
		FixClientCvars(other);

	if(gametypevote)
	{
		if ( GameTypeVote_Finished(mappos) )
		{
			gametypevote = FALSE;
			if(autocvar_nextmap != "")
			{
				Map_Goto_SetStr(autocvar_nextmap);
				Map_Goto(0);
				alreadychangedlevel = TRUE;
				return TRUE;
			}
			else
				MapVote_Init();
		}
		return FALSE;
	}
	
	Map_Goto_SetStr(mapvote_maps[mappos]);
	Map_Goto(0);
	alreadychangedlevel = TRUE;
	
	return TRUE;
}

void MapVote_CheckRules_1()
{
	float i;

	for(i = 0; i < mapvote_count; ++i) 
		if( mapvote_maps_availability[i] == GTV_AVAILABLE )
		{
			//dprint("Map ", ftos(i), ": "); dprint(mapvote_maps[i], "\n");
			mapvote_selections[i] = 0;
		}

	mapvote_voters = 0;
	FOR_EACH_REALCLIENT(other)
	{
		++mapvote_voters;
		if(other.mapvote)
		{
			i = other.mapvote - 1;
			//dprint("Player ", other.netname, " vote = ", ftos(other.mapvote - 1), "\n");
			mapvote_selections[i] = mapvote_selections[i] + 1;
		}
	}
}

float MapVote_CheckRules_2()
{
	float i;
	float firstPlace, secondPlace, currentPlace;
	float firstPlaceVotes, secondPlaceVotes, currentVotes;
	float mapvote_voters_real;
	string result;

	if(mapvote_count_real == 1)
		return MapVote_Finished(0);

	mapvote_voters_real = mapvote_voters;
	if(mapvote_abstain)
		mapvote_voters_real -= mapvote_selections[mapvote_count - 1];

	RandomSelection_Init();
	currentPlace = 0;
	currentVotes = -1;
	for(i = 0; i < mapvote_count_real; ++i) 
		if ( mapvote_maps_availability[i] == GTV_AVAILABLE )
		{
			RandomSelection_Add(world, i, string_null, 1, mapvote_selections[i]);
			if ( gametypevote &&  mapvote_maps[i] == MapInfo_Type_ToString(MapInfo_CurrentGametype()) )
			{
				currentVotes = mapvote_selections[i];
				currentPlace = i;
			}
		}
	firstPlaceVotes = RandomSelection_best_priority;
	if ( autocvar_sv_vote_gametype_default_current && currentVotes == firstPlaceVotes )
		firstPlace = currentPlace;
	else
		firstPlace = RandomSelection_chosen_float;
	
	//dprint("First place: ", ftos(firstPlace), "\n");
	//dprint("First place votes: ", ftos(firstPlaceVotes), "\n");

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i)
		if(i != firstPlace)
		if ( mapvote_maps_availability[i] == GTV_AVAILABLE )
			RandomSelection_Add(world, i, string_null, 1, mapvote_selections[i]);
	secondPlace = RandomSelection_chosen_float;
	secondPlaceVotes = RandomSelection_best_priority;
	//dprint("Second place: ", ftos(secondPlace), "\n");
	//dprint("Second place votes: ", ftos(secondPlaceVotes), "\n");

	if(firstPlace == -1)
		error("No first place in map vote... WTF?");

	if(secondPlace == -1 || time > mapvote_timeout || (mapvote_voters_real - firstPlaceVotes) < firstPlaceVotes)
		return MapVote_Finished(firstPlace);

	if(mapvote_keeptwotime)
		if(time > mapvote_keeptwotime || (mapvote_voters_real - firstPlaceVotes - secondPlaceVotes) < secondPlaceVotes)
		{
			float didntvote;
			MapVote_TouchMask();
			mapvote_message = "Now decide between the TOP TWO!";
			mapvote_keeptwotime = 0;
			result = strcat(":vote:keeptwo:", mapvote_maps[firstPlace]);
			result = strcat(result, ":", ftos(firstPlaceVotes));
			result = strcat(result, ":", mapvote_maps[secondPlace]);
			result = strcat(result, ":", ftos(secondPlaceVotes), "::");
			didntvote = mapvote_voters;
			for(i = 0; i < mapvote_count; ++i)
			{
				didntvote -= mapvote_selections[i];
				if(i != firstPlace)
					if(i != secondPlace)
					{
						result = strcat(result, ":", mapvote_maps[i]);
						result = strcat(result, ":", ftos(mapvote_selections[i]));
						if(i < mapvote_count_real)
						{
							mapvote_maps_availability[i] = GTV_FORBIDDEN;
						}
					}
			}
			result = strcat(result, ":didn't vote:", ftos(didntvote));
			if(autocvar_sv_eventlog)
				GameLogEcho(result);
		}

	return FALSE;
}

void MapVote_Tick()
{
	float keeptwo;
	float totalvotes;

	keeptwo = mapvote_keeptwotime;
	MapVote_CheckRules_1(); // count
	if(MapVote_CheckRules_2()) // decide
		return;

	totalvotes = 0;
	FOR_EACH_REALCLIENT(other)
	{
		// hide scoreboard again
		if(other.health != 2342)
		{
			other.health = 2342;
			other.impulse = 0;
			if(IS_REAL_CLIENT(other))
			{
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_FINALE);
				WriteString(MSG_ONE, "");
			}
		}

		// clear possibly invalid votes
		if ( mapvote_maps_availability[other.mapvote-1] != GTV_AVAILABLE )
			other.mapvote = 0;
		// use impulses as new vote
		if(other.impulse >= 1 && other.impulse <= mapvote_count)
			if( mapvote_maps_availability[other.impulse - 1] == GTV_AVAILABLE )
			{
				other.mapvote = other.impulse;
				MapVote_TouchVotes(other);
			}
		other.impulse = 0;

		if(other.mapvote)
			++totalvotes;
	}

	MapVote_CheckRules_1(); // just count
}

void MapVote_Start()
{
	// if mapvote is already running, don't do this initialization again
	if(mapvote_run) { return; }

	// don't start mapvote until after playerstats gamereport is sent
	if(PlayerStats_GameReport_DelayMapVote) { return; }

	MapInfo_Enumerate();
	if(MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
		mapvote_run = TRUE;
}

void MapVote_Think()
{
	if(!mapvote_run)
		return;

	if(alreadychangedlevel)
		return;

	if(time < mapvote_nextthink)
		return;
	//dprint("tick\n");

	mapvote_nextthink = time + 0.5;

	if(!mapvote_initialized)
	{
		if(autocvar_rescan_pending == 1)
		{
			cvar_set("rescan_pending", "2");
			localcmd("fs_rescan\nrescan_pending 3\n");
			return;
		}
		else if(autocvar_rescan_pending == 2)
		{
			return;
		}
		else if(autocvar_rescan_pending == 3)
		{
			// now build missing mapinfo files
			if(!MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
				return;

			// we're done, start the timer
			cvar_set("rescan_pending", "0");
		}

		mapvote_initialized = TRUE;
		if(DoNextMapOverride(0))
			return;
		if(!autocvar_g_maplist_votable || player_count <= 0)
		{
			GotoNextMap(0);
			return;
		}
		
		if(autocvar_sv_vote_gametype) { GameTypeVote_Start(); }
		else if(autocvar_nextmap == "") { MapVote_Init(); }
	}

	MapVote_Tick();
}

float GameTypeVote_SetGametype(float type)
{
	if (MapInfo_CurrentGametype() == type)
		return TRUE;
		
	float tsave = MapInfo_CurrentGametype();

	MapInfo_SwitchGameType(type);

	MapInfo_Enumerate();
	MapInfo_FilterGametype(type, MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
	if(MapInfo_count > 0)
	{
		// update lsmaps in case the gametype changed, this way people can easily list maps for it
		if(lsmaps_reply != "") { strunzone(lsmaps_reply); }
		lsmaps_reply = strzone(getlsmaps());
		bprint("Game type successfully switched to ", MapInfo_Type_ToString(type), "\n");
	}
	else
	{
		bprint("Cannot use this game type: no map for it found\n");
		MapInfo_SwitchGameType(tsave);
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
		return FALSE;
	}

	//localcmd("gametype ", MapInfo_Type_ToString(type), "\n");

	cvar_set("g_maplist", MapInfo_ListAllowedMaps(type, MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()) );
	if(autocvar_g_maplist_shuffle)
		ShuffleMaplist();

	return TRUE;
}

float gametypevote_finished;
float GameTypeVote_Finished(float pos)
{
	if(!gametypevote || gametypevote_finished)
		return FALSE;
	
	if ( !GameTypeVote_SetGametype(MapInfo_Type_FromString(mapvote_maps[pos])) )
	{
		dprint("Selected gametype is not supported by any map");
	}
	
	localcmd("sv_vote_gametype_hook_all\n");
	localcmd("sv_vote_gametype_hook_", mapvote_maps[pos], "\n");
	
	gametypevote_finished = TRUE;
	
	return TRUE;
}

float GameTypeVote_AddVotable(string nextMode)
{
	float j;
	if ( nextMode == "" || MapInfo_Type_FromString(nextMode) == 0 )
		return FALSE;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMode)
			return FALSE;
	
	mapvote_maps[mapvote_count] = strzone(nextMode);
	mapvote_maps_suggested[mapvote_count] = FALSE;

	mapvote_maps_screenshot_dir[mapvote_count] = 0;
	mapvote_maps_pakfile[mapvote_count] = strzone("");
	mapvote_maps_availability[mapvote_count] = GameTypeVote_AvailabilityStatus(nextMode);

	mapvote_count += 1;
	
	return TRUE;
	
}

float GameTypeVote_Start()
{
	float j;
	MapVote_ClearAllVotes();
	MapVote_UnzoneStrings();
	
	mapvote_count = 0;
	mapvote_timeout = time + autocvar_sv_vote_gametype_timeout;
	mapvote_abstain = 0;
	mapvote_detail = !autocvar_g_maplist_votable_nodetail;
	
	float n = tokenizebyseparator(autocvar_sv_vote_gametype_options, " ");
	n = min(MAPVOTE_COUNT, n);
	
	float really_available, which_available;
	really_available = 0;
	which_available = -1;
	for(j = 0; j < n; ++j)
	{
		if ( GameTypeVote_AddVotable(argv(j)) )
		if ( mapvote_maps_availability[j] == GTV_AVAILABLE )
		{
			really_available++;
			which_available = j;
		}
	}

	mapvote_count_real = mapvote_count;
	
	gametypevote = 1;
	
	if ( really_available == 0 )
	{
		if ( mapvote_count > 0 )
			strunzone(mapvote_maps[0]);
		mapvote_maps[0] = strzone(MapInfo_Type_ToString(MapInfo_CurrentGametype()));
		//GameTypeVote_Finished(0);
		MapVote_Finished(0);
		return FALSE;
	}
	if ( really_available == 1 )
	{
		//GameTypeVote_Finished(which_available);
		MapVote_Finished(which_available);
		return FALSE;
	}
	
	mapvote_count_real = mapvote_count;

	mapvote_keeptwotime = time + autocvar_sv_vote_gametype_keeptwotime;
	if(mapvote_count_real < 3 || mapvote_keeptwotime <= time)
		mapvote_keeptwotime = 0;
	
	MapVote_Spawn();
	
	return TRUE;
}
