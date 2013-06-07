// ================================================
//  Unified notification system, written by Samual
//  Last updated: June, 2013
// ================================================

string Get_Notif_TypeName(float net_type)
{
	switch(net_type)
	{
		case MSG_ANNCE: return "MSG_ANNCE";
		case MSG_INFO: return "MSG_INFO";
		case MSG_CENTER: return "MSG_CENTER";
		case MSG_CENTER_CPID: return "MSG_CENTER_CPID";
		case MSG_MULTI: return "MSG_MULTI";
	}
	backtrace(sprintf("Get_Notif_TypeName(%d): Improper net type!\n", net_type));
	return "";
}

entity Get_Notif_Ent(float net_type, float net_name)
{
	switch(net_type)
	{
		case MSG_ANNCE: return msg_annce_notifs[net_name - 1];
		case MSG_INFO: return msg_info_notifs[net_name - 1];
		case MSG_CENTER: return msg_center_notifs[net_name - 1];
		case MSG_MULTI: return msg_multi_notifs[net_name - 1];
	}
	backtrace(sprintf("Get_Notif_Ent(%d, %d): Improper net type!\n", net_type, net_name));
	return world;
}

string Notification_CheckArgs_TypeName(float net_type, float net_name)
{
	// check supplied type and name for errors
	string checkargs = "";
	#define CHECKARG_TYPENAME(type) case MSG_##type##: \
		{ if(!net_name || (net_name > NOTIF_##type##_COUNT)) \
		{ checkargs = sprintf("Improper name: %d!", net_name); } break; }
	switch(net_type)
	{
		CHECKARG_TYPENAME(ANNCE)
		CHECKARG_TYPENAME(INFO)
		CHECKARG_TYPENAME(CENTER)
		CHECKARG_TYPENAME(MULTI)
		default: { checkargs = sprintf("Improper type: %d!", checkargs, net_type); break; }
	}
	#undef CHECKARG_TYPENAME
	return checkargs;
}

#ifdef SVQC
string Notification_CheckArgs(
	float broadcast, entity client,
	float net_type, float net_name)
{
	// check supplied broadcast, target, type, and name for errors
	string checkargs = Notification_CheckArgs_TypeName(net_type, net_name);
	if(checkargs != "") { checkargs = strcat(checkargs, " "); }
	switch(broadcast)
	{
		case NOTIF_ONE:
		case NOTIF_ONE_ONLY:
		{
			if(IS_NOT_A_CLIENT(client))
				{ checkargs = sprintf("%sNo client provided!", checkargs); }
			break;
		}
		
		case NOTIF_ALL_EXCEPT:
		{
			if(IS_NOT_A_CLIENT(client))
				{ checkargs = sprintf("%sException can't be a non-client!", checkargs); }
			break;
		}
		
		case NOTIF_ALL:
		{
			if(client)
				{ checkargs = sprintf("%sEntity provided when world was required!", checkargs); }
			break;
		}
		
		case NOTIF_TEAM:
		case NOTIF_TEAM_EXCEPT:
		{
			if not(teamplay) { checkargs = sprintf("%sTeamplay not active!", checkargs); }
			else if(IS_NOT_A_CLIENT(client))
			{
				if(broadcast == NOTIF_TEAM) { checkargs = sprintf("%sNo client provided!", checkargs); }
				else { checkargs = sprintf("%sException can't be a non-client!", checkargs); }
			}
			break;
		}
		
		default: { checkargs = sprintf("%sImproper broadcast: %d!", checkargs, broadcast); break; }
	}
	return checkargs;
}
#endif

// ===============================
//  Initialization Core Functions
// ===============================

// used by restartnotifs command to initialize notifications
void Destroy_Notification_Entity(entity notif)
{
	if(notif.nent_name != "") { strunzone(notif.nent_name); }
	if(notif.nent_snd != "") { strunzone(notif.nent_snd); }
	if(notif.nent_args != "") { strunzone(notif.nent_args); }
	if(notif.nent_hudargs != "") { strunzone(notif.nent_hudargs); }
	if(notif.nent_icon != "") { strunzone(notif.nent_icon); }
	if(notif.nent_durcnt != "") { strunzone(notif.nent_durcnt); }
	if(notif.nent_string != "") { strunzone(notif.nent_string); }
	remove(notif);
}

void Destroy_All_Notifications(void)
{
	entity notif;
	float i;
	
	#define DESTROY_LOOP(type,count) \
		for(i = 1; i <= count; ++i) \
		{ \
			notif = Get_Notif_Ent(type, i); \
			if not(notif) { backtrace("Destroy_All_Notifications(): Missing notification entity!\n"); return; } \
			Destroy_Notification_Entity(notif); \
		}

	// kill all networked notifications and centerprints
	#ifdef SVQC
	Kill_Notification(NOTIF_ALL, world, 0, 0);
	#else
	reset_centerprint_messages();
	#endif

	// kill all real notification entities
	DESTROY_LOOP(MSG_ANNCE, NOTIF_ANNCE_COUNT)
	DESTROY_LOOP(MSG_INFO, NOTIF_INFO_COUNT)
	DESTROY_LOOP(MSG_CENTER, NOTIF_CENTER_COUNT)
	DESTROY_LOOP(MSG_MULTI, NOTIF_MULTI_COUNT)
	#undef DESTROY_LOOP
}

string Process_Notif_Line(
	float msg_is_info,
	float chat,
	string input,
	string notiftype,
	string notifname,
	string stringtype)
{
	if(msg_is_info)
	{
		#ifdef CSQC
		if((chat && autocvar_notification_allow_chatboxprint)
			|| (autocvar_notification_allow_chatboxprint == 2))
		{
			// pass 1: add ETX char at beginning of line
			input = strcat("\{3}", input);

			// pass 2: add ETX char at end of each new line (so that
			// messages with multiple lines are put through chatbox too)
			input = strreplace("\n", "\n\{3}", input);

			// pass 3: strip trailing ETX char
			if(substring(input, (strlen(input) - 1), 1) == "\{3}")
				{ input = substring(input, 0, (strlen(input) - 1)); }
		}
		#endif
		if(substring(input, (strlen(input) - 1), 1) != "\n")
		{
			print(sprintf(
				strcat(
					"^1MISSING/BROKEN NEW LINE AT END OF NOTIFICATION: ",
					"^7net_type = %s, net_name = %s, string = %s.\n"
				),
				notiftype,
				notifname,
				stringtype
			));
			notif_error = TRUE;
			return strcat(input, "\n");
		}
	}
	return input;
}

string Process_Notif_Args(
	float arg_type,
	string args,
	string notiftype,
	string notifname)
{
	string selected, remaining = args;
	float sel_num = 0;

	for(;(remaining != "");)
	{
		selected = car(remaining); remaining = cdr(remaining);

		switch(arg_type)
		{
			case 1: // normal args
			{
				if(sel_num == NOTIF_MAX_ARGS)
				{
					print(sprintf(
						strcat(
							"^1NOTIFICATION HAS TOO MANY ARGUMENTS: ",
							"^7net_type = %s, net_name = %s, max args = %d.\n"
						),
						notiftype,
						notifname,
						NOTIF_MAX_ARGS
					));
					notif_error = TRUE;
					break;
				}

				switch(strtolower(selected))
				{
					#define ARG_CASE(prog,selected,result) \
						#if (prog != ARG_DC) \
							case selected: { ++sel_num; break; } \
						#endif
					NOTIF_ARGUMENT_LIST
					#undef ARG_CASE
					default:
					{
						print(sprintf(
							strcat(
								"^1NOTIFICATION WITH UNKNOWN TOKEN IN ARGUMENT STRING: ",
								"^7net_type = %s, net_name = %s, args arg = '%s'.\n"
							),
							notiftype,
							notifname,
							selected
						));
						notif_error = TRUE;
						break;
					}
				}
				break;
			}
			case 2: // hudargs
			{
				if(sel_num == NOTIF_MAX_HUDARGS)
				{
					print(sprintf(
						strcat(
							"^1NOTIFICATION HAS TOO MANY ARGUMENTS: ",
							"^7net_type = %s, net_name = %s, max hudargs = %d.\n"
						),
						notiftype,
						notifname,
						NOTIF_MAX_HUDARGS
					));
					notif_error = TRUE;
					break;
				}

				switch(strtolower(selected))
				{
					#define ARG_CASE(prog,selected,result) \
						#if (prog == ARG_CS_SV_HA) \
							case selected: { ++sel_num; break; } \
						#endif
					NOTIF_ARGUMENT_LIST
					#undef ARG_CASE
					default:
					{
						print(sprintf(
							strcat(
								"^1NOTIFICATION WITH UNKNOWN TOKEN IN ARGUMENT STRING: ",
								"^7net_type = %s, net_name = %s, hudargs arg = '%s'.\n"
							),
							notiftype,
							notifname,
							selected
						));
						notif_error = TRUE;
						break;
					}
				}
				break;
			}
			case 3: // durcnt 
			{
				if(sel_num == NOTIF_MAX_DURCNT)
				{
					print(sprintf(
						strcat(
							"^1NOTIFICATION HAS TOO MANY ARGUMENTS: ",
							"^7net_type = %s, net_name = %s, max durcnt = %d.\n"
						),
						notiftype,
						notifname,
						NOTIF_MAX_DURCNT
					));
					notif_error = TRUE;
					break;
				}

				switch(strtolower(selected))
				{
					#define ARG_CASE(prog,selected,result) \
						#if (prog == ARG_CS_SV_DC) || (prog == ARG_DC) \
							case selected: { ++sel_num; break; } \
						#endif
					NOTIF_ARGUMENT_LIST
					#undef ARG_CASE
					default:
					{
						if(ftos(stof(selected)) != "") { ++sel_num; }
						else
						{
							print(sprintf(
								strcat(
									"^1NOTIFICATION WITH UNKNOWN TOKEN IN ARGUMENT STRING: ",
									"^7net_type = %s, net_name = %s, durcnt arg = '%s'.\n"
								),
								notiftype,
								notifname,
								selected
							));
							notif_error = TRUE;
						}
						break;
					}
				}
				break;
			}
		}
	}
	return args;
}

void Create_Notification_Entity(
	float var_default,
	float var_cvar,
	float typeid,
	float nameid,
	string namestring,
	float anncename,
	float infoname,
	float centername,
	float channel,
	string snd,
	float vol,
	float position,
	float strnum,
	float flnum,
	string args,
	string hudargs,
	string icon,
	float cpid,
	string durcnt,
	string normal,
	string gentle,
	float msg_is_info,
	float msg_is_multi)
{
	// =====================
	//  Global Entity Setup
	// =====================
	entity notif = spawn();
	string typestring = "";
	switch(typeid)
	{
		case MSG_ANNCE:
		{
			typestring = "MSG_ANNCE";
			msg_annce_notifs[nameid - 1] = notif;
			notif.classname = "msg_annce_notification";
			break;
		}
		case MSG_INFO:
		{
			typestring = "MSG_INFO";
			msg_info_notifs[nameid - 1] = notif;
			notif.classname = "msg_info_notification";
			break;
		}
		case MSG_CENTER:
		{
			typestring = "MSG_CENTER";
			msg_center_notifs[nameid - 1] = notif;
			notif.classname = "msg_center_notification";
			break;
		}
		case MSG_MULTI:
		{
			typestring = "MSG_MULTI";
			msg_multi_notifs[nameid - 1] = notif;
			notif.classname = "MSG_MULTI_notification";
			break;
		}

		default:
		{
			error(sprintf(
				strcat(
					"^1NOTIFICATION WITH IMPROPER TYPE: ",
					"^7net_type = %d, net_name = %s.\n"
				),
				typeid,
				namestring
			));
			return; // It's not possible to recover from this one
		}
	}
	notif.nent_default = var_default;
	notif.nent_name = strzone(namestring);
	notif.nent_id = nameid;
	notif.nent_enabled = (1 <= var_cvar);

	// Other pre-notif-setup requisites
	notif_error = FALSE;

	// ====================
	//  Notification Setup
	// ====================
	if(msg_is_multi)
	{
		// Set MSG_MULTI string/float counts
		if((anncename == NO_MSG) && (infoname == NO_MSG) && (centername == NO_MSG))
		{
			print(sprintf(
				strcat(
					"^1NOTIFICATION WITH NO SUBCALLS: ",
					"^7net_type = %s, net_name = %s.\n"
				),
				typestring,
				namestring
			));
			notif_error = TRUE;
		}
		else
		{
			// announcements don't actually need any arguments, so lets not even count them.
			if(anncename != NO_MSG) { notif.nent_msgannce = msg_annce_notifs[anncename - 1]; }
			
			float infoname_stringcount = 0, infoname_floatcount = 0;
			float centername_stringcount = 0, centername_floatcount = 0;
			
			if(infoname != NO_MSG)
			{
				notif.nent_msginfo = msg_info_notifs[infoname - 1];
				infoname_stringcount = notif.nent_msginfo.nent_stringcount;
				infoname_floatcount = notif.nent_msginfo.nent_floatcount;
			}
			
			if(centername != NO_MSG)
			{
				notif.nent_msgcenter = msg_center_notifs[centername - 1];
				centername_stringcount = notif.nent_msgcenter.nent_stringcount;
				centername_floatcount = notif.nent_msgcenter.nent_floatcount;
			}
			
			// set the requirements of THIS notification to the totals of its subcalls
			notif.nent_stringcount = max(infoname_stringcount, centername_stringcount);
			notif.nent_floatcount = max(infoname_floatcount, centername_floatcount);
		}
	}
	else if(typeid == MSG_ANNCE)
	{
		// Set MSG_ANNCE information and handle precaching
		#ifdef CSQC
		if not(GENTLE && (var_cvar == 1))
		{
			if(snd != "")
			{
				if(notif.nent_enabled)
				{
					precache_sound(sprintf("announcer/%s/%s.wav", autocvar_cl_announcer, snd));
					notif.nent_channel = channel;
					notif.nent_snd = strzone(snd);
					notif.nent_vol = vol;
					notif.nent_position = position;
				}
			}
			else
			{
				print(sprintf(
					strcat(
						"^1NOTIFICATION WITH NO SOUND: ",
						"^7net_type = %s, net_name = %s.\n"
					),
					typestring,
					namestring
				));
				notif_error = TRUE;
			}
		}
		else { notif.nent_enabled = FALSE; }
		#else
		notif.nent_enabled = FALSE;
		#endif
	}
	else
	{
		// Set MSG_INFO and MSG_CENTER string/float counts
		notif.nent_stringcount = strnum;
		notif.nent_floatcount = flnum;

		// Only initialize arguments if we're either a client or on a dedicated server
		#ifdef SVQC
		float should_process_args = server_is_dedicated;
		#else
		float should_process_args = TRUE;
		#endif

		if(should_process_args)
		{
			// ========================
			//  Process Main Arguments
			// ========================
			if(strnum + flnum)
			{
				if(args != "")
				{
					notif.nent_args = strzone(
						Process_Notif_Args(1, args, typestring, namestring));
				}
				else if((hudargs == "") && (durcnt ==""))
				{
					print(sprintf(
						strcat(
							"^1NOTIFICATION HAS ARG COUNTS BUT NO ARGS OR HUDARGS OR DURCNT: ",
							"^7net_type = %s, net_name = %s, strnum = %d, flnum = %d\n"
						),
						typestring,
						namestring,
						strnum,
						flnum
					));
					notif_error = TRUE;
				}
			}
			else if(args != "")
			{
				notif.nent_args = strzone(
					Process_Notif_Args(1, args, typestring, namestring));
			}


			// =======================================
			//  Process HUD and Centerprint Arguments
			//    Only processed on CSQC, as these
			//    args are only for HUD features.
			// =======================================
			#ifdef CSQC
			if(hudargs != "")
			{
				notif.nent_hudargs = strzone(
					Process_Notif_Args(2, hudargs, typestring, namestring));
					
				if(icon != "") { notif.nent_icon = strzone(icon); }
				else
				{
					print(sprintf(
						strcat(
							"^1NOTIFICATION HAS HUDARGS BUT NO ICON: ",
							"^7net_type = %s, net_name = %s.\n"
						),
						typestring,
						namestring
					));
					notif_error = TRUE;
				}
			}
			else if(icon != "")
			{
				print(sprintf(
					strcat(
						"^1NOTIFICATION HAS ICON BUT NO HUDARGS: ",
						"^7net_type = %s, net_name = %s.\n"
					),
					typestring,
					namestring
				));
				notif_error = TRUE;
			}

			if(durcnt != "")
			{
				notif.nent_durcnt = strzone(
					Process_Notif_Args(3, durcnt, typestring, namestring));
					
				if(cpid != NO_MSG) { notif.nent_cpid = cpid; }
				else
				{
					print(sprintf(
						strcat(
							"^1NOTIFICATION HAS DURCNT BUT NO CPID: ",
							"^7net_type = %s, net_name = %s.\n"
						),
						typestring,
						namestring
					));
					notif_error = TRUE;
				}
			} 
			else if(cpid != NO_MSG) { notif.nent_cpid = cpid; }
			#endif


			// ======================
			//  Process Notif String
			// ======================
			#define SET_NOTIF_STRING(string,stringname) \
				notif.nent_string = strzone(CCR( \
					Process_Notif_Line( \
						msg_is_info, \
						(var_cvar > 1), \
						string, \
						typestring, \
						namestring, \
						stringname \
					)) \
				);

			if(GENTLE)
			{
				if(gentle != "") { SET_NOTIF_STRING(gentle, "GENTLE") }
				else if(normal != "") { SET_NOTIF_STRING(normal, "NORMAL") }
			}
			else if(normal != "") { SET_NOTIF_STRING(normal, "NORMAL") }
			
			#undef SET_NOTIF_STRING

			// Check to make sure a string was chosen
			if(notif.nent_string == "")
			{
				print(sprintf(
					strcat(
						"^1EMPTY NOTIFICATION: ",
						"^7net_type = %s, net_name = %s.\n"
					),
					typestring,
					namestring
				));
				notif_error = TRUE;
			}
		}
	}

	// now check to see if any errors happened 
	if(notif_error)
	{
		notif.nent_enabled = FALSE; // disable the notification so it can't cause trouble
		notif_global_error = TRUE; // throw the red flag that an error happened on init
	}
}


// =========================================
//  Cvar Handling With 'dumpnotifs' Command
// =========================================

void Dump_Notifications(float fh, float alsoprint)
{
	#define NOTIF_WRITE(a) { \
		fputs(fh, a); \
		if(alsoprint) { print(a); } }
	#define NOTIF_WRITE_ENTITY(description) { \
		notif_msg = \
			sprintf( \
				"seta notification_%s \"%d\" \"%s\"\n", \
				e.nent_name, e.nent_default, description \
			); \
		NOTIF_WRITE(notif_msg) }
	#define NOTIF_WRITE_HARDCODED(cvar,default,description) { \
		notif_msg = \
			sprintf( \
				"seta notification_%s \"%s\" \"%s\"\n", \
				cvar, default, description \
			); \
		NOTIF_WRITE(notif_msg) }

	string notif_msg;
	float i;
	entity e;

	// Note: This warning only applies to the notifications.cfg file that is output...

	// You ARE supposed to manually edit this function to add i.e. hard coded
	// notification variables for mutators or game modes or such and then
	// regenerate the notifications.cfg file from the new code.

	NOTIF_WRITE("// ********************************************** //\n");
	NOTIF_WRITE("// ** WARNING - DO NOT MANUALLY EDIT THIS FILE ** //\n");
	NOTIF_WRITE("// **                                          ** //\n");
	NOTIF_WRITE("// **  This file is automatically generated    ** //\n");
	NOTIF_WRITE("// **  by code with the command 'dumpnotifs'.  ** //\n");
	NOTIF_WRITE("// **                                          ** //\n");
	NOTIF_WRITE("// **  If you add a new notification, please   ** //\n");
	NOTIF_WRITE("// **  regenerate this file with that command  ** //\n");
	NOTIF_WRITE("// **  making sure that the output matches     ** //\n");
	NOTIF_WRITE("// **  with the lists and defaults in code.    ** //\n");
	NOTIF_WRITE("// **                                          ** //\n");
	NOTIF_WRITE("// ********************************************** //\n");

	// These notifications will also append their string as a comment...
	// This is not necessary, and does not matter if they vary between config versions,
	// it is just a semi-helpful tool for those who want to manually change their user settings.

	NOTIF_WRITE(sprintf("\n// MSG_ANNCE notifications (count = %d):\n", NOTIF_ANNCE_COUNT));
	for(i = 1; i <= NOTIF_ANNCE_COUNT; ++i)
	{
		e = Get_Notif_Ent(MSG_ANNCE, i);
		if not(e) { backtrace("Dump_Notifications(): Missing notification entity!\n"); return; }
		
		NOTIF_WRITE_ENTITY(
			"Notification control cvar: 0 = disabled, 1 = enabled if gentle mode is off, 2 = always enabled)"
		);
	}

	NOTIF_WRITE(sprintf("\n// MSG_INFO notifications (count = %d):\n", NOTIF_INFO_COUNT));
	for(i = 1; i <= NOTIF_INFO_COUNT; ++i)
	{
		e = Get_Notif_Ent(MSG_INFO, i);
		if not(e) { backtrace("Dump_Notifications(): Missing notification entity!\n"); return; }
		
		NOTIF_WRITE_ENTITY(
			"Notification control cvar: 0 = off, 1 = print to console, "
			"2 = print to console and chatbox (if notification_allow_chatboxprint is enabled)"
		);
	}

	NOTIF_WRITE(sprintf("\n// MSG_CENTER notifications (count = %d):\n", NOTIF_CENTER_COUNT));
	for(i = 1; i <= NOTIF_CENTER_COUNT; ++i)
	{
		e = Get_Notif_Ent(MSG_CENTER, i);
		if not(e) { backtrace("Dump_Notifications(): Missing notification entity!\n"); return; }
		
		NOTIF_WRITE_ENTITY(
			"Notification control cvar: 0 = off, 1 = centerprint"
		);
	}

	NOTIF_WRITE(sprintf("\n// MSG_MULTI notifications (count = %d):\n", NOTIF_MULTI_COUNT));
	for(i = 1; i <= NOTIF_MULTI_COUNT; ++i)
	{
		e = Get_Notif_Ent(MSG_MULTI, i);
		if not(e) { backtrace("Dump_Notifications(): Missing notification entity!\n"); return; }
		
		NOTIF_WRITE_ENTITY(
			"Notification control cvar: 0 = off, 1 = trigger subcalls"
		);
	}

	// edit these to match whichever cvars are used for specific notification options
	NOTIF_WRITE("\n// HARD CODED notification variables:\n");
	
	NOTIF_WRITE_HARDCODED(
		"allow_chatboxprint", "1",
		"Allow notifications to be printed to chat box by setting notification cvar to 2 "
		"(You can also set this cvar to 2 to force ALL notifications to be printed to the chatbox)"
	);
	
	NOTIF_WRITE_HARDCODED(
		"ctf_capture_verbose", "0",
		"Show extra information when someone captures a flag"
	);
	
	NOTIF_WRITE_HARDCODED(
		"ctf_pickup_enemy_verbose", "0",
		"Show extra information if an enemy picks up a flag"
	);
	
	NOTIF_WRITE_HARDCODED(
		"ctf_pickup_team_verbose", "0",
		"Show extra information if a team mate picks up a flag"
	);
	
	NOTIF_WRITE_HARDCODED(
		"debug", "0",
		"Print extra debug information on all notification function calls "
		"(Requires -DNOTIFICATIONS_DEBUG flag to be enabled on QCSRC compilation)... "
		"0 = disabled, 1 = dprint, 2 = print"
	);
	
	NOTIF_WRITE_HARDCODED(
		"errors_are_fatal", "1",
		"If a notification fails upon initialization, cause a Host_Error to stop the program"
	);
	
	NOTIF_WRITE_HARDCODED(
		"frag_verbose", "1",
		"Show extra information when you frag someone (or when you are fragged"
	);
	
	NOTIF_WRITE_HARDCODED(
		"item_centerprinttime", "1.5",
		"How long to show item information centerprint messages (like 'You got the Electro' or such)"
	);
	
	NOTIF_WRITE_HARDCODED(
		"lifetime_mapload", "10",
		"Amount of time that notification entities last immediately at mapload (in seconds) "
		"to help prevent notifications from being lost on early init (like gamestart countdown)"
	);
	
	NOTIF_WRITE_HARDCODED(
		"lifetime_runtime", "0.5",
		"Amount of time that notification entities last on the server during runtime (In seconds)"
	);
	
	NOTIF_WRITE_HARDCODED(
		"server_allows_frag_verbose", "1",
		"Server side cvar for showing extra information in frag messages... 0 = no extra frag information, "
		"1 = frag information only in warmup, 2 = frag information allowed all the time"
	);
	
	NOTIF_WRITE_HARDCODED(
		"server_allows_location", "1",
		"Server side cvar for allowing death messages to show location information too"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_location", "0",
		"Append location information to MSG_INFO death/kill messages"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_location_string", "",
		"Replacement string piped into sprintf, "
		"so you can do different messages like this: ' at the %s' or ' (near %s)'"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_sprees", "1",
		"Print information about sprees in death/kill messages"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_sprees_center", "1",
		"Show spree information in MSG_CENTER messages... "
		"0 = off, 1 = target (but only for first victim) and attacker"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_sprees_center_specialonly", "1",
		"Don't show spree information in MSG_CENTER messages if it isn't an achievement"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_sprees_info", "3",
		"Show spree information in MSG_INFO messages... "
		"0 = off, 1 = target only, 2 = attacker only, 3 = target and attacker"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_sprees_info_newline", "1",
		"Show attacker spree information for MSG_INFO messages on a separate line than the death notification itself"
	);
	
	NOTIF_WRITE_HARDCODED(
		"show_sprees_info_specialonly", "1",
		"Don't show attacker spree information in MSG_INFO messages if it isn't an achievement"
	);

	NOTIF_WRITE(sprintf(
		strcat(
			"\n// Notification counts (total = %d): ",
			"MSG_ANNCE = %d, MSG_INFO = %d, MSG_CENTER = %d, MSG_MULTI = %d\n"
		),
		(
			NOTIF_ANNCE_COUNT +
			NOTIF_INFO_COUNT +
			NOTIF_CENTER_COUNT +
			NOTIF_MULTI_COUNT
		),
		NOTIF_ANNCE_COUNT,
		NOTIF_INFO_COUNT,
		NOTIF_CENTER_COUNT,
		NOTIF_MULTI_COUNT
	));
	
	return;
	#undef NOTIF_WRITE_HARDCODED
	#undef NOTIF_WRITE_ENTITY
	#undef NOTIF_WRITE
}

#ifdef SVQC
void Notification_GetCvars()
{
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, FRAG_VERBOSE, "notification_frag_verbose");
}
#endif


// ===============================
//  Frontend Notification Pushing
// ===============================

#ifdef NOTIFICATIONS_DEBUG
void Debug_Notification(string input)
{
	switch(autocvar_notification_debug)
	{
		case 1: { dprint(input); break; }
		case 2: { print(input); break; }
	}
}
#endif

string Local_Notification_sprintf(
	string input, string args, 
	string s1, string s2, string s3, string s4,
	float f1, float f2, float f3, float f4)
{
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification_sprintf('%s^7', '%s', %s, %s);\n",
		MakeConsoleSafe(input),
		args,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif
	
	string selected;
	float sel_num;
	for(sel_num = 0; sel_num < NOTIF_MAX_ARGS; ++sel_num) { arg_slot[sel_num] = ""; }

	string tmp_s;

	for(sel_num = 0;(args != "");)
	{
		selected = car(args); args = cdr(args);
		NOTIF_HIT_MAX(NOTIF_MAX_ARGS, "Local_Notification_sprintf")
		switch(strtolower(selected))
		{
			#define ARG_CASE(prog,selected,result) \
				#ifdef CSQC \
					#if (prog != ARG_SV) && (prog != ARG_DC) \
						case selected: { arg_slot[sel_num] = result; ++sel_num; break; } \
					#endif \
				#else \
					#if (prog != ARG_CS) && (prog != ARG_DC) \
						case selected: { arg_slot[sel_num] = result; ++sel_num; break; } \
					#endif \
				#endif
			NOTIF_ARGUMENT_LIST
			#undef ARG_CASE
			default: NOTIF_HIT_UNKNOWN(NOTIF_MAX_ARGS, "Local_Notification_sprintf")
		}
	}
	return sprintf(input, arg_slot[0], arg_slot[1], arg_slot[2], arg_slot[3], arg_slot[4], arg_slot[5], arg_slot[6]);
}

#ifdef CSQC
void Local_Notification_sound(
	float soundchannel, string soundfile,
	float soundvolume, float soundposition)
{
	if((soundfile != prev_soundfile) || (time >= (prev_soundtime + autocvar_cl_announcer_antispam)))
	{
		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			"Local_Notification_sound(world, %f, '%s', %f, %f);\n",
			soundchannel,
			sprintf(
				"announcer/%s/%s.wav",
				autocvar_cl_announcer,
				soundfile
			),
			soundvolume,
			soundposition
		));
		#endif
		
		sound(
			world,
			soundchannel,
			sprintf(
				"announcer/%s/%s.wav",
				autocvar_cl_announcer,
				soundfile
			),
			soundvolume,
			soundposition
		);
		
		if(prev_soundfile) { strunzone(prev_soundfile); }
		prev_soundfile = strzone(soundfile);
		prev_soundtime = time;
	}
	else
	{
		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			strcat(
				"Local_Notification_sound(world, %f, '%s', %f, %f) ",
				"^1BLOCKED BY ANTISPAM:^7 prevsnd: '%s', timediff: %f, limit: %f\n"
			 ),
			soundchannel,
			sprintf(
				"announcer/%s/%s.wav",
				autocvar_cl_announcer,
				soundfile
			),
			soundvolume,
			soundposition,
			prev_soundfile,
			(time - prev_soundtime),
			autocvar_cl_announcer_antispam
		));
		#endif
	}
}

void Local_Notification_HUD_Notify_Push(
	string icon, string hudargs,
	string s1, string s2, string s3, string s4)
{
	string selected;
	float sel_num;
	arg_slot[0] = ""; arg_slot[1] = "";

	for(sel_num = 0;(hudargs != "");)
	{
		selected = car(hudargs); hudargs = cdr(hudargs);
		NOTIF_HIT_MAX(NOTIF_MAX_HUDARGS, "Local_Notification_HUD_Notify_Push")
		switch(strtolower(selected))
		{
			#define ARG_CASE(prog,selected,result) \
				#if (prog == ARG_CS_SV_HA) \
					case selected: { arg_slot[sel_num] = result; ++sel_num; break; } \
				#endif
			NOTIF_ARGUMENT_LIST
			#undef ARG_CASE
			default: NOTIF_HIT_UNKNOWN(NOTIF_MAX_HUDARGS, "Local_Notification_HUD_Notify_Push")
		}
	}
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification_HUD_Notify_Push('%s^7', '%s', %s, %s);\n",
		icon,
		hudargs,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		MakeConsoleSafe(sprintf("'%s^7', '%s^7'", stof(arg_slot[0]), stof(arg_slot[1])))
	));
	#endif
	HUD_Notify_Push(icon, arg_slot[0], arg_slot[1]);
}

void Local_Notification_centerprint_generic(
	string input, string durcnt,
	float cpid, float f1, float f2)
{
	string selected;
	float sel_num;
	arg_slot[0] = ""; arg_slot[1] = "";

	for(sel_num = 0;(durcnt != "");)
	{
		selected = car(durcnt); durcnt = cdr(durcnt);
		NOTIF_HIT_MAX(NOTIF_MAX_DURCNT, "Local_Notification_centerprint_generic")
		switch(strtolower(selected))
		{
			#define ARG_CASE(prog,selected,result) \
				#if (prog == ARG_CS_SV_DC) || (prog == ARG_DC) \
					case selected: { arg_slot[sel_num] = result; ++sel_num; break; } \
				#endif
			NOTIF_ARGUMENT_LIST
			#undef ARG_CASE
			default:
			{
				if(ftos(stof(selected)) != "") { arg_slot[sel_num] = selected; ++sel_num; }
				else { NOTIF_HIT_UNKNOWN(NOTIF_MAX_DURCNT, "Local_Notification_centerprint_generic") }
				break;
			}
		}
	}
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification_centerprint_generic('%s^7', '%s', %d, %d, %d, %d);\n",
		MakeConsoleSafe(input),
		durcnt,
		f1, f2,
		stof(arg_slot[0]), stof(arg_slot[1])
	));
	#endif
	centerprint_generic(cpid, input, stof(arg_slot[0]), stof(arg_slot[1]));
}
#endif

void Local_Notification(float net_type, float net_name, ...count)
{
	// check supplied type and name for errors
	string checkargs = Notification_CheckArgs_TypeName(net_type, net_name);
	if(checkargs != "") { backtrace(sprintf("Incorrect usage of Local_Notification: %s\n", checkargs)); return; }

	entity notif = Get_Notif_Ent(net_type, net_name);
	if not(notif) { backtrace("Local_Notification: Could not find notification entity!\n"); return; }
	if not(notif.nent_enabled)
	{
		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			"Local_Notification(%s, %s): Entity was disabled...\n",
			Get_Notif_TypeName(net_type),
			notif.nent_name
		));
		#endif
		return;
	}
	
	if((notif.nent_stringcount + notif.nent_floatcount) > count)
	{
		backtrace(sprintf(
			strcat(
				"Not enough arguments for Local_Notification(%s, %s, ...)! ",
				"stringcount(%d) + floatcount(%d) > count(%d)\n", 
				"Check the definition and function call for accuracy...?\n"
			),
			Get_Notif_TypeName(net_type), notif.nent_name,
			notif.nent_stringcount, notif.nent_floatcount, count
		));
		return;
	}
	else if((notif.nent_stringcount + notif.nent_floatcount) < count)
	{
		backtrace(sprintf(
			strcat(
				"Too many arguments for Local_Notification(%s, %s, ...)! ",
				"stringcount(%d) + floatcount(%d) < count(%d)\n",
				"Check the definition and function call for accuracy...?\n"
			),
			Get_Notif_TypeName(net_type), notif.nent_name,
			notif.nent_stringcount, notif.nent_floatcount, count
		));
		return;
	}

	string s1 = ((0 < notif.nent_stringcount) ? ...(0, string) : "");
	string s2 = ((1 < notif.nent_stringcount) ? ...(1, string) : "");
	string s3 = ((2 < notif.nent_stringcount) ? ...(2, string) : "");
	string s4 = ((3 < notif.nent_stringcount) ? ...(3, string) : "");
	float f1 = ((0 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 0), float) : 0);
	float f2 = ((1 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 1), float) : 0);
	float f3 = ((2 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 2), float) : 0);
	float f4 = ((3 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 3), float) : 0);

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Local_Notification(%s, %s, %s, %s);\n",
		Get_Notif_TypeName(net_type),
		notif.nent_name,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif
	
	switch(net_type)
	{
		case MSG_ANNCE:
		{
			#ifdef CSQC
			Local_Notification_sound(
				notif.nent_channel,
				notif.nent_snd,
				notif.nent_vol,
				notif.nent_position
			);
			#else
			backtrace("MSG_ANNCE on server?... Please notify Samual immediately!\n");
			#endif
			break;
		}
		
		case MSG_INFO:
		{
			print(
				Local_Notification_sprintf(
					notif.nent_string,
					notif.nent_args, 
					s1, s2, s3, s4,
					f1, f2, f3, f4)
			);
			#ifdef CSQC 
			if(notif.nent_icon != "")
			{
				Local_Notification_HUD_Notify_Push(
					notif.nent_icon,
					notif.nent_hudargs,
					s1, s2, s3, s4);
			} 
			#endif 
			break;
		}
		
		#ifdef CSQC
		case MSG_CENTER:
		{
			Local_Notification_centerprint_generic(
				Local_Notification_sprintf(
					notif.nent_string,
					notif.nent_args, 
					s1, s2, s3, s4,
					f1, f2, f3, f4),
				notif.nent_durcnt,
				notif.nent_cpid,
				f1, f2);
			break;
		}
		#endif
		
		case MSG_MULTI:
		{
			if(notif.nent_msginfo)
			if(notif.nent_msginfo.nent_enabled)
			{
				Local_Notification_WOVA(
					MSG_INFO,
					notif.nent_msginfo.nent_id, 
					notif.nent_msginfo.nent_stringcount, 
					notif.nent_msginfo.nent_floatcount, 
					s1, s2, s3, s4,
					f1, f2, f3, f4);
			}
			#ifdef CSQC
			if(notif.nent_msgannce)
			if(notif.nent_msgannce.nent_enabled)
			{
				Local_Notification_WOVA(
					MSG_ANNCE,
					notif.nent_msgannce.nent_id, 
					0, 0, 
					"", "", "", "",
					0, 0, 0, 0);
			}
			if(notif.nent_msgcenter)
			if(notif.nent_msgcenter.nent_enabled)
			{
				Local_Notification_WOVA(
					MSG_CENTER,
					notif.nent_msgcenter.nent_id, 
					notif.nent_msgcenter.nent_stringcount, 
					notif.nent_msgcenter.nent_floatcount, 
					s1, s2, s3, s4,
					f1, f2, f3, f4); 
			}
			#endif
			break;
		}
	}
}

// WOVA = Without Variable Arguments 
void Local_Notification_WOVA(
	float net_type, float net_name,
	float stringcount, float floatcount,
	string s1, string s2, string s3, string s4,
	float f1, float f2, float f3, float f4)
{
	#define VARITEM(stringc,floatc,args) \
		if((stringcount == stringc) && (floatcount == floatc)) \
			{ Local_Notification(net_type, net_name, args); return; }
	EIGHT_VARS_TO_VARARGS_VARLIST
	#undef VARITEM
	Local_Notification(net_type, net_name); // some notifications don't have any arguments at all
}


// =========================
//  Notification Networking
// =========================

#ifdef CSQC
void Read_Notification(float is_new)
{
	float net_type = ReadByte();
	float net_name = ReadShort();

	entity notif;

	if(net_type == MSG_CENTER_CPID)
	{
		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			"Read_Notification(%d) at %f: net_type = %s, net_name = %d\n",
			is_new,
			time,
			Get_Notif_TypeName(net_type),
			net_name
		));
		#endif
		
		if(is_new)
		{
			if(net_name == 0) { reset_centerprint_messages(); }
			else if(net_name != NO_CPID)
			{
				// in this case, net_name IS the cpid we want to kill
				centerprint_generic(net_name, "", 0, 0);
			}
			else
			{
				backtrace(sprintf(
					"Read_Notification(%d) at %f: ^1TRIED TO KILL NO_CPID CENTERPRINT!\n",
					is_new,
					time
				));
			} 
		}
	}
	else
	{
		notif = Get_Notif_Ent(net_type, net_name);
		if not(notif) { backtrace("Read_Notification: Could not find notification entity!\n"); return; }

		#ifdef NOTIFICATIONS_DEBUG
		Debug_Notification(sprintf(
			"Read_Notification(%d) at %f: net_type = %s, net_name = %s\n",
			is_new,
			time,
			Get_Notif_TypeName(net_type),
			notif.nent_name
		));
		#endif

		string s1 = ((0 < notif.nent_stringcount) ? ReadString() : "");
		string s2 = ((1 < notif.nent_stringcount) ? ReadString() : "");
		string s3 = ((2 < notif.nent_stringcount) ? ReadString() : "");
		string s4 = ((3 < notif.nent_stringcount) ? ReadString() : "");
		float f1 = ((0 < notif.nent_floatcount) ? ReadLong() : 0);
		float f2 = ((1 < notif.nent_floatcount) ? ReadLong() : 0);
		float f3 = ((2 < notif.nent_floatcount) ? ReadLong() : 0);
		float f4 = ((3 < notif.nent_floatcount) ? ReadLong() : 0);
	
		if(is_new)
		{
			Local_Notification_WOVA(
				net_type, net_name,
				notif.nent_stringcount,
				notif.nent_floatcount,
				s1, s2, s3, s4,
				f1, f2, f3, f4);
		}
	}
}
#endif

#ifdef SVQC
void Net_Notification_Remove()
{
	if not(self) { backtrace(sprintf("Net_Notification_Remove() at %f: Missing self!?\n", time)); return; }
	
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Net_Notification_Remove() at %f: %s '%s - %s' notification\n",
		time,
		((self.nent_net_name == -1) ? "Killed" : "Removed"),
		Get_Notif_TypeName(self.nent_net_type),
		self.owner.nent_name
	));
	#endif
	
	float i;
	for(i = 0; i < 4; ++i) { if(self.nent_strings[i]) { strunzone(self.nent_strings[i]); } }
	remove(self);
}

float Net_Write_Notification(entity client, float sf)
{
	float i, send = FALSE;
	
	switch(self.nent_broadcast)
	{
		case NOTIF_ONE: // send to one client and their spectator
		{
			if(
				(client == self.nent_client)
				||
				(
					IS_SPEC(client)
					&&
					(client.enemy == self.nent_client)
				)
			) { send = TRUE; }
			break;
		}
		case NOTIF_ONE_ONLY: // send ONLY to one client
		{
			if(client == self.nent_client) { send = TRUE; }
			break;
		}
		case NOTIF_TEAM: // send only to X team and their spectators
		{
			if(
				(client.team == self.nent_client.team)
				||
				(
					IS_SPEC(client)
					&&
					(client.enemy.team == self.nent_client.team)
				)
			) { send = TRUE; }
			break;
		}
		case NOTIF_TEAM_EXCEPT: // send only to X team and their spectators, except for Y person and their spectators
		{
			if(
				(client != self.nent_client)
				&&
				(
					(client.team == self.nent_client.team)
					||
					(
						IS_SPEC(client)
						&&
						(
							(client.enemy != self.nent_client)
							&&
							(client.enemy.team == self.nent_client.team)
						)
					)
				)
			) { send = TRUE; }
			break;
		}
		case NOTIF_ALL: // send to everyone
		{
			send = TRUE;
			break;
		}
		case NOTIF_ALL_EXCEPT: // send to everyone except X person and their spectators
		{
			if(
				(client != self.nent_client)
				&&
				!(
					IS_SPEC(client)
					&&
					(client.enemy == self.nent_client)
				)
			) { send = TRUE; }
			break;
		}
		default: { send = FALSE; break; }
	}

	if(send)
	{		
		WriteByte(MSG_ENTITY, ENT_CLIENT_NOTIFICATION);
		WriteByte(MSG_ENTITY, self.nent_net_type);
		WriteShort(MSG_ENTITY, self.nent_net_name);
		for(i = 0; i < self.nent_stringcount; ++i) { WriteString(MSG_ENTITY, self.nent_strings[i]); } 
		for(i = 0; i < self.nent_floatcount; ++i) { WriteLong(MSG_ENTITY, self.nent_floats[i]); }
	}

	return send; 
}

void Kill_Notification(
	float broadcast, entity client,
	float net_type, float net_name)
{
	string checkargs = Notification_CheckArgs(broadcast, client, 1, 1);
	if(checkargs != "") { backtrace(sprintf("Incorrect usage of Kill_Notification: %s\n", checkargs)); return; }

	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Kill_Notification(%d, '%s', %s, %d);\n",
		broadcast,
		client.netname,
		(net_type ? Get_Notif_TypeName(net_type) : "0"),
		net_name
	));
	#endif

	entity notif, net_notif;
	float killed_cpid = NO_CPID;
	
	switch(net_type)
	{
		case 0:
		{
			killed_cpid = 0; // kill ALL centerprints
			break;
		}
		
		case MSG_CENTER:
		{
			if(net_name)
			{
				entity notif = Get_Notif_Ent(net_type, net_name);
				if not(notif) { backtrace("Kill_Notification: Could not find notification entity!\n"); return; }
				
				if(notif.nent_cpid)
					killed_cpid = notif.nent_cpid;
				else
					killed_cpid = NO_CPID;
			}
			else
			{
				killed_cpid = 0; // kill ALL centerprints
			}
			break;
		}

		case MSG_CENTER_CPID:
		{
			killed_cpid = net_name;
			break;
		}
	}

	if(killed_cpid != NO_CPID)
	{
		net_notif = spawn();
		net_notif.classname = "net_kill_notification";
		net_notif.nent_broadcast = broadcast;
		net_notif.nent_client = client;
		net_notif.nent_net_type = MSG_CENTER_CPID;
		net_notif.nent_net_name = killed_cpid;
		Net_LinkEntity(net_notif, FALSE, autocvar_notification_lifetime_runtime, Net_Write_Notification);
	}

	for(notif = world; (notif = find(notif, classname, "net_notification"));)
	{
		if(net_type)
		{
			if((killed_cpid != NO_CPID) && (notif.nent_net_type == MSG_CENTER))
			{
				if(notif.owner.nent_cpid == killed_cpid)
				{
					notif.nent_net_name = -1;
					notif.nextthink = time;
				}
				else { continue; } // we ARE looking for a specific CPID, don't kill everything else too
			}
			else if(notif.nent_net_type == net_type)
			{
				if(net_name)
				{
					if(notif.nent_net_name == net_name) { notif.nent_net_name = -1; notif.nextthink = time; }
					else { continue; } // we ARE looking for a certain net_name, don't kill everything else too
				}
				else { notif.nent_net_name = -1; notif.nextthink = time; }
			}
			else { continue; } // we ARE looking for a certain net_type, don't kill everything else too
		}
		else { notif.nent_net_name = -1; notif.nextthink = time; }
	}
}

void Send_Notification(
	float broadcast, entity client,
	float net_type, float net_name,
	...count)
{
	// check supplied broadcast, target, type, and name for errors
	string checkargs = Notification_CheckArgs(broadcast, client, net_type, net_name);
	if(checkargs != "") { backtrace(sprintf("Incorrect usage of Send_Notification: %s\n", checkargs)); return; }

	// retreive counts for the arguments of this notification
	entity notif = Get_Notif_Ent(net_type, net_name);
	if not(notif) { backtrace("Send_Notification: Could not find notification entity!\n"); return; }

	if((notif.nent_stringcount + notif.nent_floatcount) > count)
	{
		backtrace(sprintf(
			strcat(
				"Not enough arguments for Send_Notification(%d, %s, %s, ...)! ",
				"stringcount(%d) + floatcount(%d) > count(%d)\n", 
				"Check the definition and function call for accuracy...?\n"
			),
			broadcast, Get_Notif_TypeName(net_type), notif.nent_name,
			notif.nent_stringcount, notif.nent_floatcount, count
		));
		return;
	}
	else if((notif.nent_stringcount + notif.nent_floatcount) < count)
	{
		backtrace(sprintf(
			strcat(
				"Too many arguments for Send_Notification(%d, %s, %s, ...)! ",
				"stringcount(%d) + floatcount(%d) < count(%d)\n",
				"Check the definition and function call for accuracy...?\n"
			),
			broadcast, Get_Notif_TypeName(net_type), notif.nent_name,
			notif.nent_stringcount, notif.nent_floatcount, count
		));
		return;
	}

	#ifdef NOTIFICATIONS_DEBUG
	string s1 = ((0 < notif.nent_stringcount) ? ...(0, string) : "");
	string s2 = ((1 < notif.nent_stringcount) ? ...(1, string) : "");
	string s3 = ((2 < notif.nent_stringcount) ? ...(2, string) : "");
	string s4 = ((3 < notif.nent_stringcount) ? ...(3, string) : "");
	float f1 = ((0 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 0), float) : 0);
	float f2 = ((1 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 1), float) : 0);
	float f3 = ((2 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 2), float) : 0);
	float f4 = ((3 < notif.nent_floatcount) ? ...((notif.nent_stringcount + 3), float) : 0);
	Debug_Notification(sprintf(
		"Send_Notification(%d, %s, %s, %s, %s);\n",
		broadcast,
		Get_Notif_TypeName(net_type),
		notif.nent_name,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif

	entity net_notif = spawn();
	net_notif.owner = notif;
	net_notif.classname = "net_notification";
	net_notif.nent_broadcast = broadcast;
	net_notif.nent_client = client;
	net_notif.nent_net_type = net_type;
	net_notif.nent_net_name = net_name;
	net_notif.nent_stringcount = notif.nent_stringcount;
	net_notif.nent_floatcount = notif.nent_floatcount;
	
	float i;
	for(i = 0; i < net_notif.nent_stringcount; ++i)
		{ net_notif.nent_strings[i] = strzone(...(i, string)); }
	for(i = 0; i < net_notif.nent_floatcount; ++i)
		{ net_notif.nent_floats[i] = ...((net_notif.nent_stringcount + i), float); }

	net_notif.think = Net_Notification_Remove;
	net_notif.nextthink =
		((time > autocvar_notification_lifetime_mapload)
		?
			(time + autocvar_notification_lifetime_runtime)
			:
			autocvar_notification_lifetime_mapload
		); 

	Net_LinkEntity(net_notif, FALSE, 0, Net_Write_Notification);

	if(
		server_is_dedicated
		&&
		(
			broadcast == NOTIF_ALL
			||
			broadcast == NOTIF_ALL_EXCEPT
		)
		&&
		!(
			net_type == MSG_ANNCE
			||
			net_type == MSG_CENTER
		)
	)
	{
		Local_Notification_WOVA(
			net_type, net_name,
			notif.nent_stringcount,
			notif.nent_floatcount,
			IFSTR(0), IFSTR(1), IFSTR(2), IFSTR(3),
			IFFL(0), IFFL(1), IFFL(2), IFFL(3));
	}
}

// WOVA = Without Variable Arguments 
void Send_Notification_WOVA(
	float broadcast, entity client,
	float net_type, float net_name,
	string s1, string s2, string s3, string s4,
	float f1, float f2, float f3, float f4)
{
	entity notif = Get_Notif_Ent(net_type, net_name);
	
	#ifdef NOTIFICATIONS_DEBUG
	Debug_Notification(sprintf(
		"Send_Notification_WOVA(%d, %s, %s, %s, %s);\n",
		broadcast,
		Get_Notif_TypeName(net_type),
		notif.nent_name,
		MakeConsoleSafe(sprintf("'%s^7', '%s^7', '%s^7', '%s^7'", s1, s2, s3, s4)),
		sprintf("%d, %d, %d, %d", f1, f2, f3, f4)
	));
	#endif
	
	#define VARITEM(stringc,floatc,args) \
		if((notif.nent_stringcount == stringc) && (notif.nent_floatcount == floatc)) \
			{ Send_Notification(broadcast, client, net_type, net_name, args); return; }
	EIGHT_VARS_TO_VARARGS_VARLIST
	#undef VARITEM
	Send_Notification(broadcast, client, net_type, net_name); // some notifications don't have any arguments at all
}
#endif // ifdef SVQC
