// =============================================
//  Server side voting code, reworked by Samual
//  Last updated: December 27th, 2011
// =============================================

//  Nagger for players to know status of voting
float Nagger_SendEntity(entity to, float sendflags)
{
	float nags, i, f, b;
	entity e;
	WriteByte(MSG_ENTITY, ENT_CLIENT_NAGGER);

	// bits:
	//   1 = ready
	//   2 = player needs to ready up
	//   4 = vote
	//   8 = player needs to vote
	//  16 = warmup
	// sendflags:
	//  64 = vote counts
	// 128 = vote string

	nags = 0;
	if(readycount)
	{
		nags |= 1;
		if(to.ready == 0)
			nags |= 2;
	}
	if(vote_called)
	{
		nags |= 4;
		if(to.vote_selection == 0)
			nags |= 8;
	}
	if(warmup_stage)
		nags |= 16;

	if(sendflags & 64)
		nags |= 64;

	if(sendflags & 128)
		nags |= 128;

	if(!(nags & 4)) // no vote called? send no string
		nags &= ~(64 | 128);

	WriteByte(MSG_ENTITY, nags);

	if(nags & 64)
	{
		WriteByte(MSG_ENTITY, vote_accept_count);
		WriteByte(MSG_ENTITY, vote_reject_count);
		WriteByte(MSG_ENTITY, vote_needed_overall);
		WriteChar(MSG_ENTITY, to.vote_selection);
	}

	if(nags & 128)
		WriteString(MSG_ENTITY, vote_called_display);

	if(nags & 1)
	{
		for(i = 1; i <= maxclients; i += 8)
		{
			for(f = 0, e = edict_num(i), b = 1; b < 256; b *= 2, e = nextent(e))
				if(!IS_REAL_CLIENT(e) || e.ready)
					f |= b;
			WriteByte(MSG_ENTITY, f);
		}
	}

	return TRUE;
}

void Nagger_Init()
{
	Net_LinkEntity(nagger = spawn(), FALSE, 0, Nagger_SendEntity);
}

void Nagger_VoteChanged()
{
	if(nagger)
		nagger.SendFlags |= 128;
}

void Nagger_VoteCountChanged()
{
	if(nagger)
		nagger.SendFlags |= 64;
}

void Nagger_ReadyCounted()
{
	if(nagger)
		nagger.SendFlags |= 1;
}


// =======================
//  Game logic for voting
// =======================

void VoteReset()
{
	entity tmp_player;

	FOR_EACH_CLIENT(tmp_player) { tmp_player.vote_selection = 0; }

	if(vote_called)
	{
		strunzone(vote_called_command);
		strunzone(vote_called_display);
	}

	vote_called = VOTE_NULL;
	vote_caller = world;
	vote_endtime = 0;

	vote_called_command = string_null;
	vote_called_display = string_null;

	vote_parsed_command = string_null;
	vote_parsed_display = string_null;

	Nagger_VoteChanged();
}

void VoteStop(entity stopper)
{
	bprint("\{1}^2* ^3", GetCallerName(stopper), "^2 stopped ^3", GetCallerName(vote_caller), "^2's vote\n");
	if(autocvar_sv_eventlog) { GameLogEcho(strcat(":vote:vstop:", ftos(stopper.playerid))); }

	// Don't force them to wait for next vote, this way they can e.g. correct their vote.
	if((vote_caller) && (stopper == vote_caller)) { vote_caller.vote_waittime = time + autocvar_sv_vote_stop; }

	VoteReset();
}

void VoteAccept()
{
	bprint("\{1}^2* ^3", GetCallerName(vote_caller), "^2's vote for ^1", vote_called_display, "^2 was accepted\n");

	if((vote_called == VOTE_MASTER) && vote_caller)
		vote_caller.vote_master = 1;
	else
		localcmd(strcat(vote_called_command, "\n"));

	if(vote_caller) { vote_caller.vote_waittime = 0; } // people like your votes, you don't need to wait to vote again

	VoteReset();
	Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_VOTE_ACCEPT);
}

void VoteReject()
{
	bprint("\{1}^2* ^3", GetCallerName(vote_caller), "^2's vote for ", vote_called_display, "^2 was rejected\n");
	VoteReset();
	Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_VOTE_FAIL);
}

void VoteTimeout()
{
	bprint("\{1}^2* ^3", GetCallerName(vote_caller), "^2's vote for ", vote_called_display, "^2 timed out\n");
	VoteReset();
	Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_VOTE_FAIL);
}

void VoteSpam(float notvoters, float mincount, string result)
{
	bprint(strcat(
		strcat("\{1}^2* vote results: ^1", ftos(vote_accept_count)),
		strcat("^2:^1", ftos(vote_reject_count)),
		((mincount >= 0) ? strcat("^2 (^1", ftos(mincount), "^2 needed)") : "^2"),
		strcat(", ^1", ftos(vote_abstain_count), "^2 didn't care"),
		strcat(", ^1", ftos(notvoters), strcat("^2 didn't ", ((mincount >= 0) ? "" : "have to "), "vote\n"))));

	if(autocvar_sv_eventlog)
	{
		GameLogEcho(strcat(
			strcat(":vote:v", result, ":", ftos(vote_accept_count)),
			strcat(":", ftos(vote_reject_count)),
			strcat(":", ftos(vote_abstain_count)),
			strcat(":", ftos(notvoters)),
			strcat(":", ftos(mincount))));
	}
}

void VoteCount(float first_count)
{
	// declarations
	vote_accept_count = vote_reject_count = vote_abstain_count = 0;

	float spectators_allowed = ((autocvar_sv_vote_nospectators != 2)
				|| ((autocvar_sv_vote_nospectators == 1) && (warmup_stage || gameover))
				|| (autocvar_sv_vote_nospectators == 0));

	float vote_player_count = 0, notvoters = 0;
	float vote_real_player_count = 0, vote_real_accept_count = 0;
	float vote_real_reject_count = 0, vote_real_abstain_count = 0;
	float vote_needed_of_voted, final_needed_votes;
	float vote_factor_overall, vote_factor_of_voted;

	entity tmp_player;

	Nagger_VoteCountChanged();

	// add up all the votes from each connected client
	FOR_EACH_REALCLIENT(tmp_player)
	{
		++vote_player_count;
		if(IS_PLAYER(tmp_player)) { ++vote_real_player_count; }

		switch(tmp_player.vote_selection)
		{
			case VOTE_SELECT_REJECT: { ++vote_reject_count; { if(IS_PLAYER(tmp_player)) ++vote_real_reject_count; } break; }
			case VOTE_SELECT_ACCEPT: { ++vote_accept_count; { if(IS_PLAYER(tmp_player)) ++vote_real_reject_count; } break; }
			case VOTE_SELECT_ABSTAIN: { ++vote_abstain_count; { if(IS_PLAYER(tmp_player)) ++vote_real_abstain_count; } break; }
			default: break;
		}
	}

	// Check to see if there are enough players on the server to allow master voting... otherwise, vote master could be used for evil.
	if((vote_called == VOTE_MASTER) && autocvar_sv_vote_master_playerlimit > vote_player_count)
	{
		if(vote_caller) { vote_caller.vote_waittime = 0; }
		print_to(vote_caller, "^1There are not enough players on this server to allow you to become vote master.");
		VoteReset();
		return;
	}

	// if spectators aren't allowed to vote and there are players in a match, then only count the players in the vote and ignore spectators.
	if(!spectators_allowed && (vote_real_player_count > 0))
	{
		vote_accept_count = vote_real_accept_count;
		vote_reject_count = vote_real_reject_count;
		vote_abstain_count = vote_real_abstain_count;
		vote_player_count = vote_real_player_count;
	}

	// people who have no opinion in any way :D
	notvoters = (vote_player_count - vote_accept_count - vote_reject_count - vote_abstain_count);

	// determine the goal for the vote to be passed or rejected normally
	vote_factor_overall = bound(0.5, autocvar_sv_vote_majority_factor, 0.999);
	vote_needed_overall = floor((vote_player_count - vote_abstain_count) * vote_factor_overall) + 1;

	// if the vote times out, determine the amount of votes needed of the people who actually already voted
	vote_factor_of_voted = bound(0.5, autocvar_sv_vote_majority_factor_of_voted, 0.999);
	vote_needed_of_voted = floor((vote_accept_count + vote_reject_count) * vote_factor_of_voted) + 1;

	// are there any players at all on the server? it could be an admin vote
	if(vote_player_count == 0 && first_count)
	{
		VoteSpam(0, -1, "yes"); // no players at all, just accept it
		VoteAccept();
		return;
	}

	// since there ARE players, finally calculate the result of the vote
	if(vote_accept_count >= vote_needed_overall)
	{
		VoteSpam(notvoters, -1, "yes"); // there is enough acceptions to pass the vote
		VoteAccept();
		return;
	}

	if(vote_reject_count > vote_player_count - vote_abstain_count - vote_needed_overall)
	{
		VoteSpam(notvoters, -1, "no"); // there is enough rejections to deny the vote
		VoteReject();
		return;
	}

	// there is not enough votes in either direction, now lets just calculate what the voters have said
	if(time > vote_endtime)
	{
		final_needed_votes = vote_needed_overall;

		if(autocvar_sv_vote_majority_factor_of_voted)
		{
			if(vote_accept_count >= vote_needed_of_voted)
			{
				VoteSpam(notvoters, min(vote_needed_overall, vote_needed_of_voted), "yes");
				VoteAccept();
				return;
			}

			if(vote_accept_count + vote_reject_count > 0)
			{
				VoteSpam(notvoters, min(vote_needed_overall, vote_needed_of_voted), "no");
				VoteReject();
				return;
			}

			final_needed_votes = min(vote_needed_overall, vote_needed_of_voted);
		}

		// it didn't pass or fail, so not enough votes to even make a decision.
		VoteSpam(notvoters, final_needed_votes, "timeout");
		VoteTimeout();
	}
}

void VoteThink()
{
	if(vote_endtime > 0) // a vote was called
	if(time > vote_endtime) // time is up
	{
		VoteCount(FALSE);
	}

	return;
}


// =======================
//  Game logic for warmup
// =======================

// Resets the state of all clients, items, weapons, waypoints, ... of the map.
void reset_map(float dorespawn)
{
	entity oldself;
	oldself = self;

	if(time <= game_starttime && round_handler_IsActive())
		round_handler_Reset(game_starttime);

	MUTATOR_CALLHOOK(reset_map_global);

	for(self = world; (self = nextent(self)); )
	if(IS_NOT_A_CLIENT(self))
	{
		if(self.reset)
		{
			self.reset();
			continue;
		}

		if(self.team_saved)
			self.team = self.team_saved;

		if(self.flags & FL_PROJECTILE) // remove any projectiles left
			remove(self);
	}

	// Waypoints and assault start come LAST
	for(self = world; (self = nextent(self)); )
	if(IS_NOT_A_CLIENT(self))
	{
		if(self.reset2)
		{
			self.reset2();
			continue;
		}
	}

	FOR_EACH_PLAYER(self)
	if(self.frozen)
		Unfreeze(self);

	// Moving the player reset code here since the player-reset depends
	// on spawnpoint entities which have to be reset first --blub
	if(dorespawn)
	if(!MUTATOR_CALLHOOK(reset_map_players))
	FOR_EACH_CLIENT(self) // reset all players
	{
		/*
		only reset players if a restart countdown is active
		this can either be due to cvar sv_ready_restart_after_countdown having set
		restart_mapalreadyrestarted to 1 after the countdown ended or when
		sv_ready_restart_after_countdown is not used and countdown is still running
		*/
		if (restart_mapalreadyrestarted || (time < game_starttime))
		{
			//NEW: changed behaviour so that it prevents that previous spectators/observers suddenly spawn as players
			if (IS_PLAYER(self)) {
				//PlayerScore_Clear(self);
				self.killcount = 0;
				//stop the player from moving so that he stands still once he gets respawned
				self.velocity = '0 0 0';
				self.avelocity = '0 0 0';
				self.movement = '0 0 0';
				PutClientInServer();
			}
		}
	}

	self = oldself;
}

// Restarts the map after the countdown is over (and cvar sv_ready_restart_after_countdown is set)
void ReadyRestart_think()
{
	restart_mapalreadyrestarted = 1;
	reset_map(TRUE);
	Score_ClearAll();
	remove(self);

	return;
}

// Forces a restart of the game without actually reloading the map // this is a mess...
void ReadyRestart_force()
{
	entity tmp_player, restart_timer;

	bprint("^1Server is restarting...\n");

	VoteReset();

	// clear overtime, we have to decrease timelimit to its original value again.
	if (checkrules_overtimesadded > 0 && g_race_qualifying != 2) { cvar_set("timelimit", ftos(autocvar_timelimit - (checkrules_overtimesadded * autocvar_timelimit_overtime))); }

	checkrules_suddendeathend = checkrules_overtimesadded = checkrules_suddendeathwarning = 0;

	readyrestart_happened = 1;
	game_starttime = time + RESTART_COUNTDOWN;

	// clear player attributes
	FOR_EACH_CLIENT(tmp_player)
	{
		tmp_player.alivetime = 0;
		tmp_player.killcount = 0;
		PS_GR_P_ADDVAL(tmp_player, PLAYERSTATS_ALIVETIME, -PS_GR_P_ADDVAL(tmp_player, PLAYERSTATS_ALIVETIME, 0));
	}

	restart_mapalreadyrestarted = 0; // reset this var, needed when cvar sv_ready_restart_repeatable is in use

	// disable the warmup global for the server
	warmup_stage = 0; // once the game is restarted the game is in match stage

	// reset the .ready status of all players (also spectators)
	FOR_EACH_REALCLIENT(tmp_player) { tmp_player.ready = 0; }
	readycount = 0;
	Nagger_ReadyCounted(); // NOTE: this causes a resend of that entity, and will also turn off warmup state on the client

	// lock teams with lockonrestart
	if(autocvar_teamplay_lockonrestart && teamplay)
	{
		lockteams = 1;
		bprint("^1The teams are now locked.\n");
	}

	//initiate the restart-countdown-announcer entity
	if(autocvar_sv_ready_restart_after_countdown)
	{
		restart_timer = spawn();
		restart_timer.think = ReadyRestart_think;
		restart_timer.nextthink = game_starttime;
	}

	// after a restart every players number of allowed timeouts gets reset, too
	if(autocvar_sv_timeout) { FOR_EACH_REALPLAYER(tmp_player) { tmp_player.allowed_timeouts = autocvar_sv_timeout_number; } }

	//reset map immediately if this cvar is not set
	if (!autocvar_sv_ready_restart_after_countdown) { reset_map(TRUE); }

	if(autocvar_sv_eventlog) { GameLogEcho(":restart"); }
}

void ReadyRestart()
{
	// no arena, assault support yet...
	if(g_assault | gameover | intermission_running | race_completing)
		localcmd("restart\n");
	else
		localcmd("\nsv_hook_gamerestart\n");

	// Reset ALL scores, but only do that at the beginning of the countdown if sv_ready_restart_after_countdown is off!
	// Otherwise scores could be manipulated during the countdown.
	if (!autocvar_sv_ready_restart_after_countdown) { Score_ClearAll(); }

	ReadyRestart_force();

	return;
}

// Count the players who are ready and determine whether or not to restart the match
void ReadyCount()
{
	entity tmp_player;
	float ready_needed_factor, ready_needed_count;
	float t_ready = 0, t_players = 0;

	FOR_EACH_REALCLIENT(tmp_player)
	{
		if(IS_PLAYER(tmp_player) || tmp_player.caplayer == 1)
		{
			++t_players;
			if(tmp_player.ready) { ++t_ready; }
		}
	}

	readycount = t_ready;

	Nagger_ReadyCounted();

	ready_needed_factor = bound(0.5, cvar("g_warmup_majority_factor"), 0.999);
	ready_needed_count = floor(t_players * ready_needed_factor) + 1;

	if(readycount >= ready_needed_count)
	{
		ReadyRestart();
	}

	return;
}


// ======================================
//  Supporting functions for VoteCommand
// ======================================

float Votecommand_check_assignment(entity caller, float assignment)
{
	float from_server = (!caller);

	if((assignment == VC_ASGNMNT_BOTH)
		|| ((!from_server && assignment == VC_ASGNMNT_CLIENTONLY)
		|| (from_server && assignment == VC_ASGNMNT_SERVERONLY)))
	{
		return TRUE;
	}

	return FALSE;
}

string VoteCommand_extractcommand(string input, float startpos, float argc)
{
	string output;

	if((argc - 1) < startpos)
		output = "";
	else
		output = substring(input, argv_start_index(startpos), argv_end_index(-1) - argv_start_index(startpos));

	return output;
}

float VoteCommand_checknasty(string vote_command)
{
	if((strstrofs(vote_command, ";", 0) >= 0)
		|| (strstrofs(vote_command, "\n", 0) >= 0)
		|| (strstrofs(vote_command, "\r", 0) >= 0)
		|| (strstrofs(vote_command, "$", 0) >= 0))
		return FALSE;

	return TRUE;
}

float VoteCommand_checkinlist(string vote_command, string list)
{
	string l = strcat(" ", list, " ");

	if(strstrofs(l, strcat(" ", vote_command, " "), 0) >= 0)
		return TRUE;

	return FALSE;
}

string ValidateMap(string validated_map, entity caller)
{
	validated_map = MapInfo_FixName(validated_map);

	if (!validated_map)
	{
		print_to(caller, "This map is not available on this server.");
		return string_null;
	}

	if(!autocvar_sv_vote_override_mostrecent && caller)
	{
		if(Map_IsRecent(validated_map))
		{
			print_to(caller, "This server does not allow for recent maps to be played again. Please be patient for some rounds.");
			return string_null;
		}
	}

	if(!MapInfo_CheckMap(validated_map))
	{
		print_to(caller, strcat("^1Invalid mapname, \"^3", validated_map, "^1\" does not support the current game mode."));
		return string_null;
	}

	return validated_map;
}

float VoteCommand_checkargs(float startpos, float argc)
{
	float p, q, check, minargs;
	string cvarname = strcat("sv_vote_command_restriction_", argv(startpos));
	string cmdrestriction = cvar_string(cvarname); // note: this warns on undefined cvar. We want that.
	string charlist, arg;
	float checkmate;

	if(cmdrestriction == "")
		return TRUE;

	++startpos; // skip command name

	// check minimum arg count

	// 0 args: argc == startpos
	// 1 args: argc == startpos + 1
	// ...

	minargs = stof(cmdrestriction);
	if(argc - startpos < minargs)
		return FALSE;

	p = strstrofs(cmdrestriction, ";", 0); // find first semicolon

	for(;;)
	{
		// we know that at any time, startpos <= argc - minargs
		// so this means: argc-minargs >= startpos >= argc, thus
		// argc-minargs >= argc, thus minargs <= 0, thus all minargs
		// have been seen already

		if(startpos >= argc) // all args checked? GOOD
			break;

		if(p < 0) // no more args? FAIL
		{
			// exception: exactly minargs left, this one included
			if(argc - startpos == minargs)
				break;

			// otherwise fail
			return FALSE;
		}

		// cut to next semicolon
		q = strstrofs(cmdrestriction, ";", p+1); // find next semicolon
		if(q < 0)
			charlist = substring(cmdrestriction, p+1, -1);
		else
			charlist = substring(cmdrestriction, p+1, q - (p+1));

		// in case we ever want to allow semicolons in VoteCommand_checknasty
		// charlist = strreplace("^^", ";", charlist);

		if(charlist != "")
		{
			// verify the arg only contains allowed chars
			arg = argv(startpos);
			checkmate = strlen(arg);
			for(check = 0; check < checkmate; ++check)
				if(strstrofs(charlist, substring(arg, check, 1), 0) < 0)
					return FALSE; // not allowed character
			// all characters are allowed. FINE.
		}

		++startpos;
		--minargs;
		p = q;
	}

	return TRUE;
}

float VoteCommand_parse(entity caller, string vote_command, string vote_list, float startpos, float argc)
{
	string first_command;

	first_command = argv(startpos);

	/*printf("VoteCommand_parse(): Command: '%s', Length: %f.\n",
		substring(vote_command, argv_start_index(startpos), strlen(vote_command) - argv_start_index(startpos)),
		strlen(substring(vote_command, argv_start_index(startpos), strlen(vote_command) - argv_start_index(startpos)))
	);*/

	if(
		(autocvar_sv_vote_limit > 0)
		&&
		(strlen(substring(vote_command, argv_start_index(startpos), strlen(vote_command) - argv_start_index(startpos))) > autocvar_sv_vote_limit)
	)
		return FALSE;

	if (!VoteCommand_checkinlist(first_command, vote_list))
		return FALSE;

	if (!VoteCommand_checkargs(startpos, argc))
		return FALSE;

	switch(first_command) // now go through and parse the proper commands to adjust as needed.
	{
		case "kick":
		case "kickban": // catch all kick/kickban commands
		{
			entity victim = GetIndexedEntity(argc, (startpos + 1));
			float accepted = VerifyClientEntity(victim, TRUE, FALSE);

			if(accepted > 0)
			{
				string reason = ((argc > next_token) ? substring(vote_command, argv_start_index(next_token), strlen(vote_command) - argv_start_index(next_token)) : "No reason provided");
				string command_arguments;

				if(first_command == "kickban")
					command_arguments = strcat(ftos(autocvar_g_ban_default_bantime), " ", ftos(autocvar_g_ban_default_masksize), " ~");
				else
					command_arguments = reason;

				vote_parsed_command = strcat(first_command, " # ", ftos(num_for_edict(victim)), " ", command_arguments);
				vote_parsed_display = strcat("^1", vote_command, " (^7", victim.netname, "^1): ", reason);
			}
			else { print_to(caller, strcat("vcall: ", GetClientErrorString(accepted, argv(startpos + 1)), ".\n")); return FALSE; }

			break;
		}

		case "map":
		case "chmap":
		case "gotomap": // re-direct all map selection commands to gotomap
		{
			vote_command = ValidateMap(argv(startpos + 1), caller);
			if (!vote_command) { return FALSE; }
			vote_parsed_command = strcat("gotomap ", vote_command);
			vote_parsed_display = strzone(strcat("^1", vote_parsed_command));

			break;
		}

		default:
		{
			vote_parsed_command = vote_command;
			vote_parsed_display = strzone(strcat("^1", vote_command));

			break;
		}
	}

	return TRUE;
}


// =======================
//  Command Sub-Functions
// =======================

void VoteCommand_abstain(float request, entity caller) // CLIENT ONLY
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if(caller.vote_selection != VOTE_SELECT_NULL && !autocvar_sv_vote_change) { print_to(caller, "^1You have already voted."); }

			else // everything went okay, continue changing vote
			{
				print_to(caller, "^1You abstained from your vote.");
				caller.vote_selection = VOTE_SELECT_ABSTAIN;
				msg_entity = caller;
				if(!autocvar_sv_vote_singlecount) { VoteCount(FALSE); }
			}

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote abstain"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void VoteCommand_call(float request, entity caller, float argc, string vote_command) // BOTH
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float spectators_allowed = ((autocvar_sv_vote_nospectators != 2)
				|| ((autocvar_sv_vote_nospectators == 1) && warmup_stage)
				|| (autocvar_sv_vote_nospectators == 0));

			float tmp_playercount = 0;
			entity tmp_player;

			vote_command = VoteCommand_extractcommand(vote_command, 2, argc);

			if(!autocvar_sv_vote_call && caller) { print_to(caller, "^1Vote calling is not allowed."); }
			else if(!autocvar_sv_vote_gamestart && time < game_starttime) { print_to(caller, "^1Vote calling is not allowed before the match has started."); }
			else if(vote_called) { print_to(caller, "^1There is already a vote called."); }
			else if(!spectators_allowed && (caller && !IS_PLAYER(caller))) { print_to(caller, "^1Only players can call a vote."); }
			else if(caller && !IS_CLIENT(caller)) { print_to(caller, "^1Only connected clients can vote."); }
			else if(timeout_status) { print_to(caller, "^1You can not call a vote while a timeout is active."); }
			else if(caller && (time < caller.vote_waittime)) { print_to(caller, strcat("^1You have to wait ^2", ftos(ceil(caller.vote_waittime - time)), "^1 seconds before you can again call a vote.")); }
			else if (!VoteCommand_checknasty(vote_command)) { print_to(caller, "^1Syntax error in command, see 'vhelp' for more info."); }
			else if (!VoteCommand_parse(caller, vote_command, autocvar_sv_vote_commands, 2, argc)) { print_to(caller, "^1This command is not acceptable, see 'vhelp' for more info."); }

			else // everything went okay, continue with calling the vote
			{
				vote_caller = caller; // remember who called the vote
				vote_called = VOTE_NORMAL;
				vote_called_command = strzone(vote_parsed_command);
				vote_called_display = strzone(vote_parsed_display);
				vote_endtime = time + autocvar_sv_vote_timeout;

				if(caller)
				{
					caller.vote_selection = VOTE_SELECT_ACCEPT;
					caller.vote_waittime = time + autocvar_sv_vote_wait;
					msg_entity = caller;
				}

				FOR_EACH_REALCLIENT(tmp_player) { ++tmp_playercount; }
				if(tmp_playercount > 1) { Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_VOTE_CALL); } // don't announce a "vote now" sound if player is alone

				bprint("\{1}^2* ^3", GetCallerName(vote_caller), "^2 calls a vote for ", vote_called_display, "\n");
				if(autocvar_sv_eventlog) { GameLogEcho(strcat(":vote:vcall:", ftos(vote_caller.playerid), ":", vote_called_display)); }
				Nagger_VoteChanged();

				if(autocvar_sv_vote_auto)
				FOR_EACH_REALCLIENT(tmp_player) if(tmp_player != vote_caller)
				switch(tmp_player.cvar_cl_autovote)
				{
					case "yes": tmp_player.vote_selection = VOTE_SELECT_ACCEPT; print_to(tmp_player, "You automatically accepted the vote\n"); break;
					case "no": tmp_player.vote_selection = VOTE_SELECT_REJECT; print_to(tmp_player, "You automatically rejected the vote\n"); break;
					case "abstain": tmp_player.vote_selection = VOTE_SELECT_ABSTAIN; print_to(tmp_player, "You automatically abstained from the vote\n"); break;
					default: break;
				}

				VoteCount(TRUE); // needed if you are the only one
			}

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote call command"));
			print_to(caller, "  Where 'command' is the command to request a vote upon.");
			print_to(caller, strcat("Examples: ", GetCommandPrefix(caller), " vote call gotomap dance"));
			print_to(caller, strcat("          ", GetCommandPrefix(caller), " vote call endmatch"));
			return;
		}
	}
}

void VoteCommand_master(float request, entity caller, float argc, string vote_command) // CLIENT ONLY
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(autocvar_sv_vote_master)
			{
				switch(strtolower(argv(2)))
				{
					case "do":
					{
						vote_command = VoteCommand_extractcommand(vote_command, 3, argc);

						if (!caller.vote_master) { print_to(caller, "^1You do not have vote master privelages."); }
						else if (!VoteCommand_checknasty(vote_command)) { print_to(caller, "^1Syntax error in command, see 'vhelp' for more info."); }
						else if (!VoteCommand_parse(caller, vote_command, strcat(autocvar_sv_vote_commands, " ", autocvar_sv_vote_master_commands), 3, argc)) { print_to(caller, "^1This command is not acceptable, see 'vhelp' for more info."); }

						else // everything went okay, proceed with command
						{
							localcmd(strcat(vote_parsed_command, "\n"));
							print_to(caller, strcat("Executing command '", vote_parsed_display, "' on server."));
							bprint("\{1}^2* ^3", GetCallerName(caller), "^2 used their ^3master^2 status to do \"^2", vote_parsed_display, "^2\".\n");
							if(autocvar_sv_eventlog) { GameLogEcho(strcat(":vote:vdo:", ftos(caller.playerid), ":", vote_parsed_display)); }
						}

						return;
					}

					case "login":
					{
						if(autocvar_sv_vote_master_password == "") { print_to(caller, "^1Login to vote master is not allowed."); }
						else if(caller.vote_master) { print_to(caller, "^1You are already logged in as vote master."); }
						else if(autocvar_sv_vote_master_password != argv(3)) { print_to(caller, strcat("Rejected vote master login from ", GetCallerName(caller))); }

						else // everything went okay, proceed with giving this player master privilages
						{
							caller.vote_master = TRUE;
							print_to(caller, strcat("Accepted vote master login from ", GetCallerName(caller)));
							bprint("\{1}^2* ^3", GetCallerName(caller), "^2 logged in as ^3master^2\n");
							if(autocvar_sv_eventlog) { GameLogEcho(strcat(":vote:vlogin:", ftos(caller.playerid))); }
						}

						return;
					}

					default: // calling a vote for master
					{
						float spectators_allowed = ((autocvar_sv_vote_nospectators != 2)
							|| ((autocvar_sv_vote_nospectators == 1) && warmup_stage)
							|| (autocvar_sv_vote_nospectators == 0));

						if (!autocvar_sv_vote_master_callable) { print_to(caller, "^1Vote to become vote master is not allowed."); }
						else if(vote_called) { print_to(caller, "^1There is already a vote called."); }
						else if(!spectators_allowed && (caller && !IS_PLAYER(caller))) { print_to(caller, "^1Only players can call a vote."); }
						else if(timeout_status) { print_to(caller, "^1You can not call a vote while a timeout is active."); }

						else // everything went okay, continue with creating vote
						{
							vote_caller = caller;
							vote_called = VOTE_MASTER;
							vote_called_command = strzone("XXX");
							vote_called_display = strzone("^3master");
							vote_endtime = time + autocvar_sv_vote_timeout;

							caller.vote_selection = VOTE_SELECT_ACCEPT;
							caller.vote_waittime = time + autocvar_sv_vote_wait;

							bprint("\{1}^2* ^3", GetCallerName(vote_caller), "^2 calls a vote to become ^3master^2.\n");
							if(autocvar_sv_eventlog) { GameLogEcho(strcat(":vote:vcall:", ftos(vote_caller.playerid), ":", vote_called_display)); }
							Nagger_VoteChanged();
							VoteCount(TRUE); // needed if you are the only one
						}

						return;
					}
				}
			}
			else { print_to(caller, "^1Master control of voting is not allowed."); }

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote master [action [command | password]]"));
			print_to(caller, "  If action is left blank, it calls a vote for you to become master.");
			print_to(caller, "  Otherwise the actions are either 'do' a command or 'login' as master.");
			return;
		}
	}
}

void VoteCommand_no(float request, entity caller) // CLIENT ONLY
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if(caller.vote_selection != VOTE_SELECT_NULL && !autocvar_sv_vote_change) { print_to(caller, "^1You have already voted."); }
			else if(((caller == vote_caller) || caller.vote_master) && autocvar_sv_vote_no_stops_vote) { VoteStop(caller); }

			else // everything went okay, continue changing vote
			{
				print_to(caller, "^1You rejected the vote.");
				caller.vote_selection = VOTE_SELECT_REJECT;
				msg_entity = caller;
				if(!autocvar_sv_vote_singlecount) { VoteCount(FALSE); }
			}

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote no"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void VoteCommand_status(float request, entity caller) // BOTH
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(vote_called)
				print_to(caller, strcat("^7Vote for ", vote_called_display, "^7 called by ^7", GetCallerName(vote_caller), "^7."));
			else
				print_to(caller, "^1No vote called.");

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote status"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void VoteCommand_stop(float request, entity caller) // BOTH
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if((caller == vote_caller) || !caller || caller.vote_master) { VoteStop(caller); }
			else { print_to(caller, "^1You are not allowed to stop that vote."); }

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote stop"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void VoteCommand_yes(float request, entity caller) // CLIENT ONLY
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if(caller.vote_selection != VOTE_SELECT_NULL && !autocvar_sv_vote_change) { print_to(caller, "^1You have already voted."); }

			else // everything went okay, continue changing vote
			{
				print_to(caller, "^1You accepted the vote.");
				caller.vote_selection = VOTE_SELECT_ACCEPT;
				msg_entity = caller;
				if(!autocvar_sv_vote_singlecount) { VoteCount(FALSE); }
			}

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote yes"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

/* use this when creating a new command, making sure to place it in alphabetical order... also,
** ADD ALL NEW COMMANDS TO commands.cfg WITH PROPER ALIASES IN THE SAME FASHION!
void VoteCommand_(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote ");
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}
*/


// ================================
//  Macro system for vote commands
// ================================

// Do not hard code aliases for these, instead create them in commands.cfg... also: keep in alphabetical order, please ;)
#define VOTE_COMMANDS(request,caller,arguments,command) \
	VOTE_COMMAND("abstain", VoteCommand_abstain(request, caller), "Abstain your vote in current vote", VC_ASGNMNT_CLIENTONLY) \
	VOTE_COMMAND("call", VoteCommand_call(request, caller, arguments, command), "Create a new vote for players to decide on", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("help", VoteCommand_macro_help(caller, arguments), "Shows this information", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("master", VoteCommand_master(request, caller, arguments, command), "Full control over all voting and vote commands", VC_ASGNMNT_CLIENTONLY) \
	VOTE_COMMAND("no", VoteCommand_no(request, caller), "Select no in current vote", VC_ASGNMNT_CLIENTONLY) \
	VOTE_COMMAND("status", VoteCommand_status(request, caller), "Prints information about current vote", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("stop", VoteCommand_stop(request, caller), "Immediately end a vote", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("yes", VoteCommand_yes(request, caller), "Select yes in current vote", VC_ASGNMNT_CLIENTONLY) \
	/* nothing */

void VoteCommand_macro_help(entity caller, float argc)
{
	string command_origin = GetCommandPrefix(caller);

	if(argc == 2 || argv(2) == "1" || argv(2) == "help") // help display listing all commands
	{
		print_to(caller, "\nVoting commands:\n");
		#define VOTE_COMMAND(name,function,description,assignment) \
			{ if(Votecommand_check_assignment(caller, assignment)) { print_to(caller, strcat("  ^2", name, "^7: ", description)); } }

		VOTE_COMMANDS(0, caller, 0, "")
		#undef VOTE_COMMAND

		string vote_list = autocvar_sv_vote_commands;
		if(argv(2) == "1") vote_list = strreplace(" ", "\n^3", vote_list);

		print_to(caller, strcat("\nUsage:^3 ", command_origin, " vote COMMAND...^7, where possible commands are listed above.\n"));
		print_to(caller, strcat("For help about a specific command, type ", command_origin, " vote help COMMAND"));
		print_to(caller, "\n^7You can call a vote for or execute these commands (and maybe further ^3arguments^7):");
		print_to(caller, strcat("\n^3", vote_list, "^7\n"));
	}
	else // usage for individual command
	{
		#define VOTE_COMMAND(name,function,description,assignment) \
			{ if(Votecommand_check_assignment(caller, assignment)) { if(name == strtolower(argv(2))) { function; return; } } }

		VOTE_COMMANDS(CMD_REQUEST_USAGE, caller, argc, "")
		#undef VOTE_COMMAND
	}

	return;
}

float VoteCommand_macro_command(entity caller, float argc, string vote_command)
{
	#define VOTE_COMMAND(name,function,description,assignment) \
		{ if(Votecommand_check_assignment(caller, assignment)) { if(name == strtolower(argv(1))) { function; return TRUE; } } }

	VOTE_COMMANDS(CMD_REQUEST_COMMAND, caller, argc, vote_command)
	#undef VOTE_COMMAND

	return FALSE;
}


// ======================================
//  Main function handling vote commands
// ======================================

void VoteCommand(float request, entity caller, float argc, string vote_command)
{
	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(VoteCommand_macro_command(caller, argc, vote_command))
				return;
		}

		default:
			print_to(caller, strcat(((argv(1) != "") ? strcat("Unknown vote command \"", argv(1), "\"") : "No command provided"), ". For a list of supported commands, try ", GetCommandPrefix(caller), " vote help.\n"));
		case CMD_REQUEST_USAGE:
		{
			VoteCommand_macro_help(caller, argc);
			return;
		}
	}
}
