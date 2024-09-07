#include "vote.qh"

#include "command/banning.qh"

// =============================================
//  Server side voting code, reworked by Samual
//  Last updated: December 27th, 2011
// =============================================

//  Nagger for players to know status of voting
bool Nagger_SendEntity(entity this, entity to, float sendflags)
{
	int nags = 0;
	WriteHeader(MSG_ENTITY, ENT_CLIENT_NAGGER);

	// bits:
	//   1 = ready
	//   2 = player needs to ready up
	//   4 = vote
	//   8 = player needs to vote
	//  16 = warmup
	// sendflags:
	//  64 = vote counts
	// 128 = vote string

	if (vote_called)
	{
		nags |= BIT(2);
		if (to.vote_selection == 0) nags |= BIT(3);
		nags |= sendflags & BIT(6);
		nags |= sendflags & BIT(7);
	}

	WriteByte(MSG_ENTITY, nags);

	if (nags & BIT(6))
	{
		WriteByte(MSG_ENTITY, vote_accept_count);
		WriteByte(MSG_ENTITY, vote_reject_count);
		WriteByte(MSG_ENTITY, vote_needed_overall);
		WriteChar(MSG_ENTITY, to.vote_selection);
	}

	if (nags & BIT(7)) WriteString(MSG_ENTITY, vote_called_display);

	return true;
}

void Nagger_Init()
{
	Net_LinkEntity(nagger = new_pure(nagger), false, 0, Nagger_SendEntity);
}

void Nagger_VoteChanged()
{
	if (nagger) nagger.SendFlags |= BIT(7);
}

void Nagger_VoteCountChanged()
{
	if (nagger) nagger.SendFlags |= BIT(6);
}

void Nagger_ReadyCounted()
{
	if (nagger) nagger.SendFlags |= BIT(0);
}

STATIC_INIT_LATE(Nagger)
{
	Nagger_Init();
}

// If the vote_caller is still here, return their name, otherwise vote_caller_name
string OriginalCallerName()
{
	if (IS_REAL_CLIENT(vote_caller)) return vote_caller.netname;
	return vote_caller_name;
}

// if client return player nickname, or if server return admin nickname
string GetCallerName(entity caller)
{
	if (caller) return caller.netname;
	else return "SERVER ADMIN"; // autocvar_hostname
}

// select the proper prefix for usage and other messages
string GetCommandPrefix(entity caller)
{
	if (caller) return "cmd";
	else return "sv_cmd";
}

// switch between sprint and print depending on whether the receiver is the server or a player
void print_to(entity to, string input)
{
	if (to) sprint(to, strcat(input, "\n"));
	else print(input, "\n");
}

// =======================
//  Game logic for voting
// =======================

void VoteStop(entity stopper, bool show_name);
void VoteReset(bool verbose)
{
	if (verbose && vote_called)
	{
		VoteStop(NULL, true);
		return;
	}

	FOREACH_CLIENT(true, { it.vote_selection = 0; });

	if (vote_called)
	{
		strfree(vote_called_command);
		strfree(vote_called_display);
		strfree(vote_caller_name);
	}

	vote_called = VOTE_NULL;
	vote_caller = NULL;
	vote_endtime = 0;

	vote_parsed_command = string_null;
	vote_parsed_display = string_null;

	Nagger_VoteChanged();
}

void VoteStop(entity stopper, bool canceled)
{
	if (canceled)
		bprint("\{1}^2* ^3", OriginalCallerName(), "^2's vote was canceled\n");
	else
		bprint("\{1}^2* ^3", GetCallerName(stopper), "^2 stopped ^3", OriginalCallerName(), "^2's vote\n");
	if (autocvar_sv_eventlog)   GameLogEcho(strcat(":vote:vstop:", ftos(stopper.playerid)));
	// Don't force them to wait for next vote, this way they can e.g. correct their vote.
	if ((vote_caller) && (stopper == vote_caller))   vote_caller.vote_waittime = time + autocvar_sv_vote_stop;
	VoteReset(false);
}

void VoteAccept()
{
	bprint("\{1}^2* ^3", OriginalCallerName(), "^2's vote for ^1", vote_called_display, "^2 was accepted\n");

	if ((vote_called == VOTE_MASTER) && vote_caller) vote_caller.vote_master = true;
	else localcmd(strcat(vote_called_command, "\n"));

	if (vote_caller)   vote_caller.vote_waittime = 0;  // people like your votes, you don't need to wait to vote again

	VoteReset(false);
}

void VoteReject()
{
	bprint("\{1}^2* ^3", OriginalCallerName(), "^2's vote for ", vote_called_display, "^2 was rejected\n");
	VoteReset(false);
}

void VoteTimeout()
{
	bprint("\{1}^2* ^3", OriginalCallerName(), "^2's vote for ", vote_called_display, "^2 timed out\n");
	VoteReset(false);
}

void VoteSpam(float notvoters, float mincount, string result)
{
	bprint(strcat(
		strcat("\{1}^2* vote results: ^1", ftos(vote_accept_count)),
		strcat("^2:^1", ftos(vote_reject_count)),
		((mincount >= 0) ? strcat("^2 (^1", ftos(mincount), "^2 needed)") : "^2"),
		strcat(", ^1", ftos(vote_abstain_count), "^2 didn't care"),
		strcat(", ^1", ftos(notvoters), strcat("^2 didn't ", ((mincount >= 0) ? "" : "have to "), "vote\n"))));

	if (autocvar_sv_eventlog)
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
	vote_accept_count = vote_reject_count = vote_abstain_count = 0;

	float vote_player_count = 0, notvoters = 0;
	float vote_real_player_count = 0, vote_real_accept_count = 0;
	float vote_real_reject_count = 0, vote_real_abstain_count = 0;
	float vote_needed_of_voted, final_needed_votes;
	float vote_factor_overall, vote_factor_of_voted;

	Nagger_VoteCountChanged();

	// add up all the votes from each connected client
	FOREACH_CLIENT(IS_REAL_CLIENT(it) || autocvar_sv_vote_debug, {
		++vote_player_count;
		if (IS_PLAYER(it)) ++vote_real_player_count;
		switch (it.vote_selection)
		{
			case VOTE_SELECT_REJECT:
				++vote_reject_count;
				if (IS_PLAYER(it)) ++vote_real_reject_count;
				break;
			case VOTE_SELECT_ACCEPT:
				++vote_accept_count;
				if (IS_PLAYER(it)) ++vote_real_accept_count;
				break;
			case VOTE_SELECT_ABSTAIN:
				++vote_abstain_count;
				if (IS_PLAYER(it)) ++vote_real_abstain_count;
				break;
			default: break;
		}
	});

	// Check to see if there are enough players on the server to allow master voting... otherwise, vote master could be used for evil.
	if ((vote_called == VOTE_MASTER) && autocvar_sv_vote_master_playerlimit > vote_player_count)
	{
		if (vote_caller)   vote_caller.vote_waittime = 0;
		print_to(vote_caller, "^1There are not enough players on this server to allow you to become vote master.");
		VoteReset(false);
		return;
	}

	// people who have no opinion in any way :D
	notvoters = (vote_player_count - vote_accept_count - vote_reject_count - vote_abstain_count);

	// determine the goal for the vote to be passed or rejected normally
	vote_factor_overall = bound(0.5, autocvar_sv_vote_majority_factor, 1);
	vote_needed_overall = ceil((vote_player_count - vote_abstain_count) * vote_factor_overall);

	// if the vote times out, determine the amount of votes needed of the people who actually already voted
	vote_factor_of_voted = bound(0.5, autocvar_sv_vote_majority_factor_of_voted, 1);
	vote_needed_of_voted = ceil((vote_accept_count + vote_reject_count) * vote_factor_of_voted);

	// are there any players at all on the server? it could be an admin vote
	if (vote_player_count == 0 && first_count)
	{
		VoteSpam(0, -1, "yes");  // no players at all, just accept it
		VoteAccept();
		return;
	}

	// since there ARE players, finally calculate the result of the vote
	if (vote_accept_count >= vote_needed_overall)
	{
		VoteSpam(notvoters, -1, "yes");  // there is enough acceptions to pass the vote
		VoteAccept();
		return;
	}

	// NOTE: VERY simple rejection technique used, likely doesn't work with a majority factor below 1!
	if (vote_reject_count >= vote_needed_overall)
	{
		VoteSpam(notvoters, -1, "no");  // there is enough rejections to deny the vote
		VoteReject();
		return;
	}

	// there is not enough votes in either direction, now lets just calculate what the voters have said
	if (time > vote_endtime)
	{
		final_needed_votes = vote_needed_overall;

		if (autocvar_sv_vote_majority_factor_of_voted)
		{
			if (vote_accept_count >= vote_needed_of_voted)
			{
				VoteSpam(notvoters, min(vote_needed_overall, vote_needed_of_voted), "yes");
				VoteAccept();
				return;
			}

			if (vote_accept_count + vote_reject_count > 0)
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
	if (vote_endtime > 0)        // a vote was called
	{
		if (time > vote_endtime) // time is up
			VoteCount(false);
	}
}

// ======================================
//  Supporting functions for VoteCommand
// ======================================

bool Votecommand_check_assignment(entity caller, float assignment)
{
	bool from_server = (!caller);

	if ((assignment == VC_ASGNMNT_BOTH)
	    || ((!from_server && assignment == VC_ASGNMNT_CLIENTONLY)
	    || (from_server && assignment == VC_ASGNMNT_SERVERONLY))) return true;

	return false;
}

string VoteCommand_extractcommand(string input, float startpos, int argc)
{
	string output;

	if ((argc - 1) < startpos) output = "";
	else output = substring(input, argv_start_index(startpos), argv_end_index(-1) - argv_start_index(startpos));

	return output;
}

bool VoteCommand_checknasty(string vote_command)
{
	return !((strstrofs(vote_command, ";", 0) >= 0)
	    || (strstrofs(vote_command, "\n", 0) >= 0)
	    || (strstrofs(vote_command, "\r", 0) >= 0)
	    || (strstrofs(vote_command, "$", 0) >= 0));
}

// NOTE: requires input to be surrounded by spaces
string VoteCommand_checkreplacements(string input)
{
	// add a space around the input so the start and end of the list is captured
	string output = strcat(" ", input, " ");
	// allow gotomap replacements
	output = strreplace(" map ", " gotomap ", output);
	output = strreplace(" chmap ", " gotomap ", output);
	return output;
}

bool VoteCommand_checkinlist(string vote_command, string list)
{
	if (vote_command == "" || list == "")
		return false;

	string l = VoteCommand_checkreplacements(list);
	return (strstrofs(l, VoteCommand_checkreplacements(vote_command), 0) >= 0);
}

float VoteCommand_checkargs(float startpos, int argc)
{
	float p, q, check, minargs;
	string cvarname = strcat("sv_vote_command_restriction_", argv(startpos));
	string cmdrestriction = "";  // No we don't.
	string charlist, arg;
	float checkmate;

	if(cvar_type(cvarname) & CVAR_TYPEFLAG_EXISTS)
		cmdrestriction = cvar_string(cvarname);
	else
		LOG_INFO("NOTE: ", cvarname, " does not exist, no restrictions will be applied.");

	if (cmdrestriction == "") return true;

	++startpos;  // skip command name

	// check minimum arg count

	// 0 args: argc == startpos
	// 1 args: argc == startpos + 1
	// ...

	minargs = stof(cmdrestriction);
	if (argc - startpos < minargs) return false;

	p = strstrofs(cmdrestriction, ";", 0);  // find first semicolon

	for ( ; ; )
	{
		// we know that at any time, startpos <= argc - minargs
		// so this means: argc-minargs >= startpos >= argc, thus
		// argc-minargs >= argc, thus minargs <= 0, thus all minargs
		// have been seen already

		if (startpos >= argc) // all args checked? GOOD
			break;

		if (p < 0)            // no more args? FAIL
		{
			// exception: exactly minargs left, this one included
			if (argc - startpos == minargs) break;

			// otherwise fail
			return false;
		}

		// cut to next semicolon
		q = strstrofs(cmdrestriction, ";", p + 1);  // find next semicolon
		if (q < 0) charlist = substring(cmdrestriction, p + 1, -1);
		else charlist = substring(cmdrestriction, p + 1, q - (p + 1));

		// in case we ever want to allow semicolons in VoteCommand_checknasty
		// charlist = strreplace("^^", ";", charlist);

		if (charlist != "")
		{
			// verify the arg only contains allowed chars
			arg = argv(startpos);
			checkmate = strlen(arg);
			for (check = 0; check < checkmate; ++check)
				if (strstrofs(charlist, substring(arg, check, 1), 0) < 0) return false;
			// not allowed character
			// all characters are allowed. FINE.
		}

		++startpos;
		--minargs;
		p = q;
	}

	return true;
}

int VoteCommand_parse(entity caller, string vote_command, string vote_list, float startpos, int argc)
{
	string first_command = argv(startpos);
	int missing_chars = argv_start_index(startpos);

	if (autocvar_sv_vote_limit > 0 && strlen(vote_command) > autocvar_sv_vote_limit)
		return 0;

	if (!VoteCommand_checkinlist(first_command, vote_list)) return 0;

	if (!VoteCommand_checkargs(startpos, argc)) return 0;

	switch (first_command) // now go through and parse the proper commands to adjust as needed.
	{
		case "kick":
		case "kickban":    // catch all kick/kickban commands
		{
			entity victim = GetIndexedEntity(argc, (startpos + 1));
			float accepted = VerifyClientEntity(victim, true, false);

			if (accepted > 0)
			{
				string reason = "No reason provided";
				if(argc > next_token)
					reason = substring(vote_command, argv_start_index(next_token) - missing_chars, -1);

				string command_arguments = reason;
				if (first_command == "kickban")
					command_arguments = strcat(ftos(autocvar_g_ban_default_bantime), " ", ftos(autocvar_g_ban_default_masksize), " ~");

				vote_parsed_command = strcat(first_command, " # ", ftos(etof(victim)), " ", command_arguments);
				vote_parsed_display = sprintf("^1%s #%d ^7%s^1 %s", first_command, etof(victim), victim.netname, reason);
			}
			else
			{
				print_to(caller, strcat("vcall: ", "client not valid: ", argv(startpos + 1), ".\n"));
				return 0;
			}

			break;
		}

		case "restart":
		{
			// add a delay so that vote result can be seen and announcer can be heard
			// if the vote is accepted
			vote_parsed_command = strcat("defer 1 ", vote_command);
			vote_parsed_display = strzone(strcat("^1", vote_command));

			break;
		}

		default:
		{
			vote_parsed_command = vote_command;
			vote_parsed_display = strzone(strcat("^1", vote_command));

			break;
		}
	}

	return 1;
}


// =======================
//  Command Sub-Functions
// =======================

void VoteCommand_abstain(int request, entity caller)  // CLIENT ONLY
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (PlayerInList(caller, autocvar_g_voteban_list)) // voteban
			{
				print_to(caller, "^1You are banned from voting.");
				return;
			}

			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if (caller.vote_selection != VOTE_SELECT_NULL && !autocvar_sv_vote_change)
			{
				print_to(caller, "^1You have already voted.");
			}

			else  // everything went okay, continue changing vote
			{
				print_to(caller, "^1You abstained from your vote.");
				caller.vote_selection = VOTE_SELECT_ABSTAIN;
				msg_entity = caller;
				if (!autocvar_sv_vote_singlecount)
					VoteCount(false);
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

void print_available_commands_to(entity caller)
{
	print_to(caller, strcat("You can call a vote for or execute these commands: ^3", autocvar_sv_vote_commands, "^7 and maybe further ^3arguments^7"));
}

void VoteCommand_call(int request, entity caller, int argc, string vote_command)  // BOTH
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float tmp_playercount = 0;
			int parse_error;

			if (PlayerInList(caller, autocvar_g_voteban_list)) // voteban
			{
				print_to(caller, "^1You are banned from calling a vote.");
				return;
			}

			vote_command = VoteCommand_extractcommand(vote_command, 2, argc);

			if (!autocvar_sv_vote_call && caller)
			{
				print_to(caller, "^1Vote calling is not allowed.");
			}
			else if (!autocvar_sv_vote_gamestart && time < 10)
			{
				print_to(caller, "^1Vote calling is not allowed within 10 seconds of the map loading.");
			}
			else if (vote_called)
			{
				print_to(caller, "^1There is already a vote called.");
			}
			else if (caller && !IS_CLIENT(caller))
			{
				print_to(caller, "^1Only connected clients can vote.");
			}
			else if (caller && (time < caller.vote_waittime))
			{
				print_to(caller, strcat("^1You have to wait ^2", ftos(ceil(caller.vote_waittime - time)), "^1 seconds before you can again call a vote."));
			}
			else if (!VoteCommand_checknasty(vote_command))
			{
				print_to(caller, "^1Syntax error in command.");
			}
			else if ((parse_error = VoteCommand_parse(caller, vote_command, autocvar_sv_vote_commands, 2, argc)) <= 0)
			{
				if(parse_error == 0)
				{
					if (vote_called_command == "")
						VoteCommand_call(CMD_REQUEST_USAGE, caller, argc, vote_command);
					else
						print_to(caller, "^1This command is not acceptable or not available.");
				}
			}
			else  // everything went okay, continue with calling the vote
			{
				vote_caller = caller;  // remember who called the vote
				vote_caller_name = strzone(GetCallerName(vote_caller));
				vote_called = VOTE_NORMAL;
				vote_called_command = strzone(vote_parsed_command);
				vote_called_display = strzone(vote_parsed_display);
				vote_endtime = time + autocvar_sv_vote_timeout;

				if (caller)
				{
					caller.vote_selection = VOTE_SELECT_ACCEPT;
					caller.vote_waittime = time + autocvar_sv_vote_wait;
					msg_entity = caller;
				}

				FOREACH_CLIENT(IS_REAL_CLIENT(it), { ++tmp_playercount; });

				bprint("\{1}^2* ^3", OriginalCallerName(), "^2 calls a vote for ", vote_called_display, "\n");
				if (autocvar_sv_vote_debug)
					bprint("\{1}^2* ^3", "^6DEBUG MODE ACTIVE: bots can vote too\n"); // so servers don't forget it on
				if (autocvar_sv_eventlog)
					GameLogEcho(strcat(":vote:vcall:", ftos(vote_caller.playerid), ":", vote_called_display));
				Nagger_VoteChanged();
				VoteCount(true);  // needed if you are the only one
			}

			return;
		}

		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote call <command>"));
			print_to(caller, "  Where <command> is the command to request a vote upon.");
			print_to(caller, strcat("Examples: ", GetCommandPrefix(caller), " vote call gotomap dance"));
			print_to(caller, strcat("          ", GetCommandPrefix(caller), " vote call endmatch"));
			print_available_commands_to(caller);
			print_to(caller, "Shortcuts: ^2vcall <command>, vend, vmap, vkick, ...");
			return;
		}
	}
}

void VoteCommand_master(int request, entity caller, int argc, string vote_command)  // CLIENT ONLY
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (autocvar_sv_vote_master)
			{
				switch (strtolower(argv(2)))
				{
					case "do":
					{
						int parse_error;
						vote_command = VoteCommand_extractcommand(vote_command, 3, argc);

						if (!caller.vote_master)
							print_to(caller, "^1You do not have vote master privileges.");
						else if (!VoteCommand_checknasty(vote_command))
						{
							print_to(caller, "^1Syntax error in command.");
						}
						else if ((parse_error = VoteCommand_parse(caller, vote_command, strcat(autocvar_sv_vote_commands, " ", autocvar_sv_vote_master_commands), 3, argc)) <= 0)
						{
							if(parse_error == 0)
							{
								if (vote_called_command == "")
									VoteCommand_master(CMD_REQUEST_USAGE, caller, argc, vote_command);
								else
									print_to(caller, "^1This command is not acceptable or not available.");
							}
						}
						else  // everything went okay, proceed with command
						{
							localcmd(strcat(vote_parsed_command, "\n"));
							print_to(caller, strcat("Executing command '", vote_parsed_display, "' on server."));
							bprint("\{1}^2* ^3", GetCallerName(caller), "^2 used their ^3master^2 status to do \"^2", vote_parsed_display, "^2\".\n");
							if (autocvar_sv_eventlog)
								GameLogEcho(strcat(":vote:vdo:", ftos(caller.playerid), ":", vote_parsed_display));
						}

						return;
					}

					case "login":
					{
						if (autocvar_sv_vote_master_password == "") { print_to(caller, "^1Login to vote master is not allowed."); }
						else if (caller.vote_master)
						{
							print_to(caller, "^1You are already logged in as vote master.");
						}
						else if (autocvar_sv_vote_master_password != argv(3))
						{
							print_to(caller, strcat("Rejected vote master login from ", GetCallerName(caller)));
						}
						else  // everything went okay, proceed with giving this player master privilages
						{
							caller.vote_master = true;
							print_to(caller, strcat("Accepted vote master login from ", GetCallerName(caller)));
							bprint("\{1}^2* ^3", GetCallerName(caller), "^2 logged in as ^3master^2\n");
							if (autocvar_sv_eventlog)
								GameLogEcho(strcat(":vote:vlogin:", ftos(caller.playerid)));
						}

						return;
					}

					default:  // calling a vote for master
					{
						if (!autocvar_sv_vote_master_callable) { print_to(caller, "^1Vote to become vote master is not allowed."); }
						else if (vote_called)
						{
							print_to(caller, "^1There is already a vote called.");
						}
						else  // everything went okay, continue with creating vote
						{
							vote_caller = caller;
							vote_caller_name = strzone(GetCallerName(vote_caller));
							vote_called = VOTE_MASTER;
							vote_called_command = strzone("XXX");
							vote_called_display = strzone("^3master");
							vote_endtime = time + autocvar_sv_vote_timeout;

							caller.vote_selection = VOTE_SELECT_ACCEPT;
							caller.vote_waittime = time + autocvar_sv_vote_wait;

							bprint("\{1}^2* ^3", OriginalCallerName(), "^2 calls a vote to become ^3master^2.\n");
							if (autocvar_sv_eventlog)
								GameLogEcho(strcat(":vote:vcall:", ftos(vote_caller.playerid), ":", vote_called_display));
							Nagger_VoteChanged();
							VoteCount(true);  // needed if you are the only one
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
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " vote master [<action> [<command> | <password>]]"));
			print_to(caller, "  If <action> is left blank, it calls a vote for you to become master.");
			print_to(caller, "  Otherwise it can be either 'do' (to run <command>) or 'login' as master.");
			return;
		}
	}
}

void VoteCommand_no(int request, entity caller)  // CLIENT ONLY
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (PlayerInList(caller, autocvar_g_voteban_list)) // voteban
			{
				print_to(caller, "^1You are banned from voting.");
				return;
			}

			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if (caller.vote_selection != VOTE_SELECT_NULL && !autocvar_sv_vote_change)
			{
				print_to(caller, "^1You have already voted.");
			}
			else if (((caller == vote_caller) || caller.vote_master) && autocvar_sv_vote_no_stops_vote)
			{
				VoteStop(caller, true);
			}

			else  // everything went okay, continue changing vote
			{
				print_to(caller, "^1You rejected the vote.");
				caller.vote_selection = VOTE_SELECT_REJECT;
				msg_entity = caller;
				if (!autocvar_sv_vote_singlecount)
					VoteCount(false);
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

void VoteCommand_status(int request, entity caller)  // BOTH
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (vote_called) print_to(caller, strcat("^7Vote for ", vote_called_display, "^7 called by ^7", OriginalCallerName(), "^7."));
			else print_to(caller, "^1No vote called.");

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

void VoteCommand_stop(int request, entity caller)  // BOTH
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (!vote_called)   print_to(caller, "^1No vote called.");
			else if ((caller == vote_caller) || !caller || caller.vote_master)   VoteStop(caller, false);
			else   print_to(caller, "^1You are not allowed to stop that vote.");
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

void VoteCommand_yes(int request, entity caller)  // CLIENT ONLY
{
	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (PlayerInList(caller, autocvar_g_voteban_list)) // voteban
			{
				print_to(caller, "^1You are banned from voting.");
				return;
			}

			if (!vote_called) { print_to(caller, "^1No vote called."); }
			else if (caller.vote_selection != VOTE_SELECT_NULL && !autocvar_sv_vote_change)
			{
				print_to(caller, "^1You have already voted.");
			}
			else  // everything went okay, continue changing vote
			{
				print_to(caller, "^1You accepted the vote.");
				caller.vote_selection = VOTE_SELECT_ACCEPT;
				msg_entity = caller;
				if (!autocvar_sv_vote_singlecount)
					VoteCount(false);
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
void VoteCommand_(int request)
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
#define VOTE_COMMANDS(request, caller, arguments, command) \
	VOTE_COMMAND("abstain", VoteCommand_abstain(request, caller), "Abstain your vote in current vote", VC_ASGNMNT_CLIENTONLY) \
	VOTE_COMMAND("call", VoteCommand_call(request, caller, arguments, command), "Create a new vote for players to decide on", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("help", VoteCommand_macro_help(caller, arguments), "Shows this information", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("master", VoteCommand_master(request, caller, arguments, command), "Full control over all voting and vote commands", VC_ASGNMNT_CLIENTONLY) \
	VOTE_COMMAND("no", VoteCommand_no(request, caller), "Select no in current vote", VC_ASGNMNT_CLIENTONLY) \
	VOTE_COMMAND("status", VoteCommand_status(request, caller), "Prints information about current vote", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("stop", VoteCommand_stop(request, caller), "Immediately end a vote", VC_ASGNMNT_BOTH) \
	VOTE_COMMAND("yes", VoteCommand_yes(request, caller), "Select yes in current vote", VC_ASGNMNT_CLIENTONLY) \
	/* nothing */

void VoteCommand_macro_help(entity caller, int argc)
{
	string command_origin = GetCommandPrefix(caller);

	if (argc == 2 || argv(2) == "help")  // help display listing all commands
	{
		print_to(caller, "\nVoting commands:\n");
		#define VOTE_COMMAND(name, function, description, assignment) \
			{ if (Votecommand_check_assignment(caller, assignment)) { print_to(caller, strcat("  ^2", name, "^7: ", description)); } }

		VOTE_COMMANDS(0, caller, 0, "");
		#undef VOTE_COMMAND

		print_to(caller, strcat("\nUsage:^3 ", command_origin, " vote <command>^7, where possible commands are listed above.\n"));
		print_to(caller, strcat("For help about a specific command, type ", command_origin, " vote help <command>"));
		print_available_commands_to(caller);
	}
	else  // usage for individual command
	{
		#define VOTE_COMMAND(name, function, description, assignment) \
			{ if (Votecommand_check_assignment(caller, assignment)) { if (name == strtolower(argv(2))) { function; return; } } }

		VOTE_COMMANDS(CMD_REQUEST_USAGE, caller, argc, "");
		#undef VOTE_COMMAND

		string cvarname = strcat("sv_vote_command_help_", argv(2));
		if(cvar_type(cvarname) & CVAR_TYPEFLAG_EXISTS)
			wordwrap_sprint(caller, cvar_string(cvarname), 1000);
		else if (argv(2) != "")
			print_to(caller, "No documentation exists for this vote");
	}
}

float VoteCommand_macro_command(entity caller, int argc, string vote_command)
{
	#define VOTE_COMMAND(name, function, description, assignment) \
		{ if (Votecommand_check_assignment(caller, assignment)) { if (name == strtolower(argv(1))) { function; return true; } } }

	VOTE_COMMANDS(CMD_REQUEST_COMMAND, caller, argc, vote_command);
	#undef VOTE_COMMAND

	return false;
}


// ======================================
//  Main function handling vote commands
// ======================================

void VoteCommand(int request, entity caller, int argc, string vote_command)
{
	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3
	// cmd     vote - master - login - password

	switch (request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if (VoteCommand_macro_command(caller, argc, vote_command)) return;
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
