// ====================================================
//  Shared code for server commands, written by Samual
//  Last updated: December 27th, 2011
// ====================================================

// select the proper prefix for usage and other messages
string GetCommandPrefix(entity caller)
{
	if(caller)
		return "cmd";
	else
		return "sv_cmd";
}

// if client return player nickname, or if server return admin nickname
string GetCallerName(entity caller)
{
	if(caller)
		return caller.netname;
	else
		return admin_name(); //((autocvar_sv_adminnick != "") ? autocvar_sv_adminnick : autocvar_hostname);
}

// verify that the client provided is acceptable for use
float VerifyClientEntity(entity client, float must_be_real, float must_be_bots)
{
	if not(IS_CLIENT(client))
		return CLIENT_DOESNT_EXIST;
	else if(must_be_real && !IS_REAL_CLIENT(client))
		return CLIENT_NOT_REAL;
	else if(must_be_bots && !IS_BOT_CLIENT(client))
		return CLIENT_NOT_BOT;
		
	return CLIENT_ACCEPTABLE;
}

// if the client is not acceptable, return a string to be used for error messages
string GetClientErrorString(float clienterror, string original_input)
{
	switch(clienterror)
	{
		case CLIENT_DOESNT_EXIST: { return strcat("Client '", original_input, "' doesn't exist"); }
		case CLIENT_NOT_REAL: { return strcat("Client '", original_input, "' is not real"); }
		case CLIENT_NOT_BOT: { return strcat("Client '", original_input, "' is not a bot"); }
		default: { return "Incorrect usage of GetClientErrorString"; }
	}
}

// is this entity number even in the possible range of entities?
float VerifyClientNumber(float tmp_number)
{
	if((tmp_number < 1) || (tmp_number > maxclients))
		return FALSE;
	else
		return TRUE;
}

entity GetIndexedEntity(float argc, float start_index)
{
	entity tmp_player, selection;
	float tmp_number, index;
	string tmp_string;
	
	next_token = -1;
	index = start_index;
	selection = world;
	
	if(argc > start_index)
	{
		if(substring(argv(index), 0, 1) == "#")
		{
			tmp_string = substring(argv(index), 1, -1);
			++index;
			
			if(tmp_string != "") // is it all one token? like #1
			{
				tmp_number = stof(tmp_string);
			}
			else if(argc > index) // no, it's two tokens? # 1
			{
				tmp_number = stof(argv(index));
				++index;
			}
			else
				tmp_number = 0;
		}
		else // maybe it's ONLY a number?
		{
			tmp_number = stof(argv(index));
			++index;
		}
		
		if(VerifyClientNumber(tmp_number))
		{
			selection = edict_num(tmp_number); // yes, it was a number
		}
		else // no, maybe it's a name?
		{
			FOR_EACH_CLIENT(tmp_player)
				if (strdecolorize(tmp_player.netname) == strdecolorize(argv(start_index)))
					selection = tmp_player;
					
			index = (start_index + 1);
		}
	}
	
	next_token = index;
	//print(strcat("start_index: ", ftos(start_index), ", next_token: ", ftos(next_token), ", edict: ", ftos(num_for_edict(selection)), ".\n"));
	return selection;
}

// find a player which matches the input string, and return their entity
entity GetFilteredEntity(string input)
{
	entity tmp_player, selection;
	float tmp_number;
	
	if(substring(input, 0, 1) == "#")
		tmp_number = stof(substring(input, 1, -1));
	else
		tmp_number = stof(input);
	
	if(VerifyClientNumber(tmp_number))
	{
		selection = edict_num(tmp_number);
	}
	else
	{
		selection = world;
		FOR_EACH_CLIENT(tmp_player)
			if (strdecolorize(tmp_player.netname) == strdecolorize(input))
				selection = tmp_player;
	}
	
	return selection;
}

// same thing, but instead return their edict number
float GetFilteredNumber(string input)
{
	entity selection = GetFilteredEntity(input);
	float output;
	
	output = num_for_edict(selection);

	return output;
}

// switch between sprint and print depending on whether the receiver is the server or a player
void print_to(entity to, string input)
{
    if(to)
        sprint(to, strcat(input, "\n"));
    else
        print(input, "\n");
}

// ==========================================
//  Supporting functions for common commands
// ==========================================

// used by CommonCommand_timeout() and CommonCommand_timein() to handle game pausing and messaging and such.
void timeout_handler_reset()
{
	timeout_caller = world;
	timeout_time = 0;
	timeout_leadtime = 0;
				
	remove(self);
}

void timeout_handler_think() 
{
	entity tmp_player;
	
	switch(timeout_status)
	{
		case TIMEOUT_ACTIVE:
		{
			if(timeout_time > 0) // countdown is still going
			{
				Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_TIMEOUT_ENDING, timeout_time);

				if(timeout_time == autocvar_sv_timeout_resumetime) // play a warning sound when only <sv_timeout_resumetime> seconds are left
					Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_PREPARE);

				self.nextthink = time + TIMEOUT_SLOWMO_VALUE; // think again in one second
				timeout_time -= 1; // decrease the time counter
			}
			else // time to end the timeout
			{
				timeout_status = TIMEOUT_INACTIVE;
				
				// reset the slowmo value back to normal
				cvar_set("slowmo", ftos(orig_slowmo));
				
				// unlock the view for players so they can move around again
				FOR_EACH_REALPLAYER(tmp_player) 
					tmp_player.fixangle = FALSE;
					
				timeout_handler_reset();
			}
			
			return;
		}
		
		case TIMEOUT_LEADTIME:
		{
			if(timeout_leadtime > 0) // countdown is still going
			{
				Send_Notification(NOTIF_ALL, world, MSG_CENTER, CENTER_TIMEOUT_BEGINNING, timeout_leadtime);
				
				self.nextthink = time + 1; // think again in one second
				timeout_leadtime -= 1; // decrease the time counter
			}
			else // time to begin the timeout
			{
				timeout_status = TIMEOUT_ACTIVE;
				
				// set the slowmo value to the timeout default slowmo value
				cvar_set("slowmo", ftos(TIMEOUT_SLOWMO_VALUE));
				
				// reset all the flood variables
				FOR_EACH_CLIENT(tmp_player)
					tmp_player.nickspamcount = tmp_player.nickspamtime = tmp_player.floodcontrol_chat =
					tmp_player.floodcontrol_chatteam = tmp_player.floodcontrol_chattell = 
					tmp_player.floodcontrol_voice = tmp_player.floodcontrol_voiceteam = 0;
					
				// copy .v_angle to .lastV_angle for every player in order to fix their view during pause (see PlayerPreThink)
				FOR_EACH_REALPLAYER(tmp_player) 
					tmp_player.lastV_angle = tmp_player.v_angle;
				
				self.nextthink = time; // think again next frame to handle it under TIMEOUT_ACTIVE code
			}
			
			return;
		}
		
		
		case TIMEOUT_INACTIVE:
		default:
		{
			timeout_handler_reset();
			return;
		}
	}
}



// ===================================================
//  Common commands used in both sv_cmd.qc and cmd.qc
// ===================================================

void CommonCommand_cvar_changes(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, cvar_changes);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " cvar_changes"));
			print_to(caller, "  No arguments required.");
			print_to(caller, "See also: ^2cvar_purechanges^7");
			return;
		}
	}
}

void CommonCommand_cvar_purechanges(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, cvar_purechanges);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " cvar_purechanges"));
			print_to(caller, "  No arguments required.");
			print_to(caller, "See also: ^2cvar_changes^7");
			return;
		}
	}
}

void CommonCommand_info(float request, entity caller, float argc) 
{	
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			string command = builtin_cvar_string(strcat("sv_info_", argv(1))); 
			
			if(command)
				wordwrap_sprint(command, 1000); 
			else
				print_to(caller, "ERROR: unsupported info command");
				
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " info request"));
			print_to(caller, "  Where 'request' is the suffixed string appended onto the request for cvar.");
			return;
		}
	}
}

void CommonCommand_ladder(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, ladder_reply);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " ladder"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_lsmaps(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, lsmaps_reply);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " lsmaps"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_printmaplist(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, maplist_reply);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " printmaplist"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_rankings(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, rankings_reply);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " rankings"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_records(float request, entity caller)
{	
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float i;
			
			for(i = 0; i < 10; ++i)
				if(records_reply[i] != "")
					print_to(caller, records_reply[i]);
				
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " records"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_teamstatus(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			Score_NicePrint(caller);
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " teamstatus"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_time(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			print_to(caller, strcat("time = ", ftos(time)));
			print_to(caller, strcat("frame start = ", ftos(gettime(GETTIME_FRAMESTART))));
			print_to(caller, strcat("realtime = ", ftos(gettime(GETTIME_REALTIME))));
			print_to(caller, strcat("hires = ", ftos(gettime(GETTIME_HIRES))));
			print_to(caller, strcat("uptime = ", ftos(gettime(GETTIME_UPTIME))));
			print_to(caller, strcat("localtime = ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y")));
			print_to(caller, strcat("gmtime = ", strftime(FALSE, "%a %b %e %H:%M:%S %Z %Y")));
			return;
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " time"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_timein(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(!caller || autocvar_sv_timeout)
			{
				if not(timeout_status) { print_to(caller, "^7Error: There is no active timeout called."); }
				else if(caller && (caller != timeout_caller)) { print_to(caller, "^7Error: You are not allowed to stop the active timeout."); }
					
				else // everything should be okay, continue aborting timeout
				{
					switch(timeout_status)
					{
						case TIMEOUT_LEADTIME:
						{
							timeout_status = TIMEOUT_INACTIVE;
							timeout_time = 0;
							timeout_handler.nextthink = time; // timeout_handler has to take care of it immediately
							bprint(strcat("^7The timeout was aborted by ", GetCallerName(caller), " !\n"));
							return;
						}
						
						case TIMEOUT_ACTIVE:
						{
							timeout_time = autocvar_sv_timeout_resumetime;
							timeout_handler.nextthink = time; // timeout_handler has to take care of it immediately
							bprint(strcat("^1Attention: ^7", GetCallerName(caller), " resumed the game! Prepare for battle!\n"));
							return;
						}
						
						default: dprint("timeout status was inactive, but this code was executed anyway?"); return;
					}
				}
			}
			else { print_to(caller, "^1Timeins are not allowed to be called, enable them with sv_timeout 1.\n"); }
			
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " timein"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_timeout(float request, entity caller) // DEAR GOD THIS COMMAND IS TERRIBLE.
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(!caller || autocvar_sv_timeout)
			{
				float last_possible_timeout = ((autocvar_timelimit * 60) - autocvar_sv_timeout_leadtime - 1);
				
				if(timeout_status) { print_to(caller, "^7Error: A timeout is already active."); }
				else if(vote_called) { print_to(caller, "^7Error: You can not call a timeout while a vote is active."); }
				else if(warmup_stage && !g_warmup_allow_timeout) { print_to(caller, "^7Error: You can not call a timeout in warmup-stage."); }
				else if(time < game_starttime) { print_to(caller, "^7Error: You can not call a timeout while the map is being restarted."); }
				else if(caller && (caller.allowed_timeouts < 1)) { print_to(caller, "^7Error: You already used all your timeout calls for this map."); }
				else if(caller && !IS_PLAYER(caller)) { print_to(caller, "^7Error: You must be a player to call a timeout."); }
				else if((autocvar_timelimit) && (last_possible_timeout < time - game_starttime)) { print_to(caller, "^7Error: It is too late to call a timeout now!"); }
				
				else // everything should be okay, proceed with starting the timeout
				{					
					if(caller) { caller.allowed_timeouts -= 1; }
					
					bprint(GetCallerName(caller), " ^7called a timeout", (caller ? strcat(" (", ftos(caller.allowed_timeouts), " timeout(s) left)") : ""), "!\n"); // write a bprint who started the timeout (and how many they have left)
					
					timeout_status = TIMEOUT_LEADTIME;
					timeout_caller = caller;
					timeout_time = autocvar_sv_timeout_length;
					timeout_leadtime = autocvar_sv_timeout_leadtime;
					
					timeout_handler = spawn();
					timeout_handler.think = timeout_handler_think;
					timeout_handler.nextthink = time; // always let the entity think asap

					Send_Notification(NOTIF_ALL, world, MSG_ANNCE, ANNCE_TIMEOUT);
				}
			}
			else { print_to(caller, "^1Timeouts are not allowed to be called, enable them with sv_timeout 1.\n"); }
			
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " timeout"));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}

void CommonCommand_who(float request, entity caller, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float total_listed_players, is_bot;
			entity tmp_player;
			
			float privacy = (caller && autocvar_sv_status_privacy);
			string separator = strreplace("%", " ", strcat((argv(1) ? argv(1) : " "), "^7"));
			string tmp_netaddress, tmp_crypto_idfp;
			
			print_to(caller, strcat("List of client information", (privacy ? " (some data is hidden for privacy)" : ""), ":"));
			print_to(caller, sprintf(strreplace(" ", separator, " %-4s %-20s %-5s %-3s %-9s %-16s %s "), 
				"ent", "nickname", "ping", "pl", "time", "ip", "crypto_id"));
			
			total_listed_players = 0;
			FOR_EACH_CLIENT(tmp_player)
			{
				is_bot = (IS_BOT_CLIENT(tmp_player));
				
				if(is_bot)
				{
					tmp_netaddress = "null/botclient";
					tmp_crypto_idfp = "null/botclient";
				}
				else if(privacy)
				{
					tmp_netaddress = "hidden";
					tmp_crypto_idfp = "hidden";
				}
				else
				{
					tmp_netaddress = tmp_player.netaddress;
					tmp_crypto_idfp = tmp_player.crypto_idfp;
				}

				print_to(caller, sprintf(strreplace(" ", separator, " #%-3d %-20.20s %-5d %-3d %-9s %-16s %s "), 
					num_for_edict(tmp_player), 
					tmp_player.netname,
					tmp_player.ping, 
					tmp_player.ping_packetloss, 
					process_time(1, time - tmp_player.jointime),
					tmp_netaddress,
					tmp_crypto_idfp));
				
				++total_listed_players;
			}
			
			print_to(caller, strcat("Finished listing ", ftos(total_listed_players), " client(s) out of ", ftos(maxclients), " slots."));
			
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " who [separator]"));
			print_to(caller, "  Where 'separator' is the optional string to separate the values with, default is a space.");
			return;
		}
	}
}

/* use this when creating a new command, making sure to place it in alphabetical order... also,
** ADD ALL NEW COMMANDS TO commands.cfg WITH PROPER ALIASES IN THE SAME FASHION!
void CommonCommand_(float request, entity caller)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			
			return; // never fall through to usage
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print_to(caller, strcat("\nUsage:^3 ", GetCommandPrefix(caller), " "));
			print_to(caller, "  No arguments required.");
			return;
		}
	}
}
*/


// ==================================
//  Macro system for common commands
// ==================================

// Do not hard code aliases for these, instead create them in commands.cfg... also: keep in alphabetical order, please ;)
#define COMMON_COMMANDS(request,caller,arguments,command) \
	COMMON_COMMAND("cvar_changes", CommonCommand_cvar_changes(request, caller), "Prints a list of all changed server cvars") \
	COMMON_COMMAND("cvar_purechanges", CommonCommand_cvar_purechanges(request, caller), "Prints a list of all changed gameplay cvars") \
	COMMON_COMMAND("info", CommonCommand_info(request, caller, arguments), "Request for unique server information set up by admin") \
	COMMON_COMMAND("ladder", CommonCommand_ladder(request, caller), "Get information about top players if supported") \
	COMMON_COMMAND("lsmaps", CommonCommand_lsmaps(request, caller), "List maps which can be used with the current game mode") \
	COMMON_COMMAND("printmaplist", CommonCommand_printmaplist(request, caller), "Display full server maplist reply") \
	COMMON_COMMAND("rankings", CommonCommand_rankings(request, caller), "Print information about rankings") \
	COMMON_COMMAND("records", CommonCommand_records(request, caller), "List top 10 records for the current map") \
	COMMON_COMMAND("teamstatus", CommonCommand_teamstatus(request, caller), "Show information about player and team scores") \
	COMMON_COMMAND("time", CommonCommand_time(request, caller), "Print different formats/readouts of time") \
	COMMON_COMMAND("timein", CommonCommand_timein(request, caller), "Resume the game from being paused with a timeout") \
	COMMON_COMMAND("timeout", CommonCommand_timeout(request, caller), "Call a timeout which pauses the game for certain amount of time unless unpaused") \
	COMMON_COMMAND("vote", VoteCommand(request, caller, arguments, command), "Request an action to be voted upon by players") \
	COMMON_COMMAND("who", CommonCommand_who(request, caller, arguments), "Display detailed client information about all players") \
	/* nothing */

void CommonCommand_macro_help(entity caller)
{
	#define COMMON_COMMAND(name,function,description) \
		{ print_to(caller, strcat("  ^2", name, "^7: ", description)); }
		
	COMMON_COMMANDS(0, caller, 0, "")
	#undef COMMON_COMMAND
	
	return;
}

float CommonCommand_macro_command(float argc, entity caller, string command)
{
	#define COMMON_COMMAND(name,function,description) \
		{ if(name == strtolower(argv(0))) { function; return TRUE; } }
		
	COMMON_COMMANDS(CMD_REQUEST_COMMAND, caller, argc, command)
	#undef COMMON_COMMAND
	
	return FALSE;
}

float CommonCommand_macro_usage(float argc, entity caller)
{
	#define COMMON_COMMAND(name,function,description) \
		{ if(name == strtolower(argv(1))) { function; return TRUE; } }
		
	COMMON_COMMANDS(CMD_REQUEST_USAGE, caller, argc, "")
	#undef COMMON_COMMAND
	
	return FALSE;
}

void CommonCommand_macro_write_aliases(float fh)
{
	#define COMMON_COMMAND(name,function,description) \
		{ CMD_Write_Alias("qc_cmd_svcmd", name, description); }
		
	COMMON_COMMANDS(0, world, 0, "")
	#undef COMMON_COMMAND
	
	return;
}
