// ==============================================
//  CSQC client commands code, written by Samual
//  Last updated: December 28th, 2011
// ==============================================

void DrawDebugModel()
{
	if(time - floor(time) > 0.5)
	{
		PolyDrawModel(self);
		self.drawmask = 0;
	}
	else
	{
		self.renderflags = 0;
		self.drawmask = MASK_NORMAL;
	}
}


// =======================
//  Command Sub-Functions
// =======================

void LocalCommand_blurtest(float request)
{
	// Simple command to work with postprocessing temporarily... possibly completely pointless, the glsl shader is used for a real feature now...
	// Anyway, to enable it, just compile the client with -DBLURTEST and then you can use the command.
	
	#ifdef BLURTEST
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			blurtest_time0 = time;
			blurtest_time1 = time + stof(argv(1));
			blurtest_radius = stof(argv(2));
			blurtest_power = stof(argv(3));
			print("Enabled blurtest\n");
			return; 
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd blurtest\n");
			print("  No arguments required.\n");
			return;
		}
	}
	#else
	if(request)
	{
		print("Blurtest is not enabled on this client.\n");
		return;
	}
	#endif
}

void LocalCommand_create_scrshot_ent(float request)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float fh;
			string filename = strcat(MapInfo_Map_bspname, "_scrshot_ent.txt");
			fh = fopen(filename, FILE_WRITE);
			
			if(fh >= 0)
			{
				fputs(fh, "{\n");
				fputs(fh, strcat("\"classname\" \"info_autoscreenshot\"\n"));
				fputs(fh, strcat("\"origin\" \"", strcat(ftos(view_origin_x), " ", ftos(view_origin_y), " ", ftos(view_origin_z)), "\"\n"));
				fputs(fh, strcat("\"angles\" \"", strcat(ftos(view_angles_x), " ", ftos(view_angles_y), " ", ftos(view_angles_z)), "\"\n"));
				fputs(fh, "}\n");
				
				print("Completed screenshot entity dump in ^2data/data/", MapInfo_Map_bspname, "_scrshot_ent.txt^7.\n");
				
				fclose(fh);
			}
			else
			{
				print("^1Error: ^7Could not dump to file!\n");
			}
			return;
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd create_scrshot_ent\n");
			print("  No arguments required.\n");
			return;
		}
	}
}

void LocalCommand_debugmodel(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			string modelname = argv(1);
			entity debugmodel_entity;
			
			debugmodel_entity = spawn();
			precache_model(modelname);
			setmodel(debugmodel_entity, modelname);
			setorigin(debugmodel_entity, view_origin);
			debugmodel_entity.angles = view_angles;
			debugmodel_entity.draw = DrawDebugModel;
			debugmodel_entity.classname = "debugmodel";
			
			return; 
		}
			
		default:
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd debugmodel model\n");
			print("  Where 'model' is a string of the model name to use for the debug model.\n");
			return;
		}
	}
}

void LocalCommand_handlevote(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			float vote_selection;
			string vote_string;
			
			if(InterpretBoolean(argv(1)))
			{
				vote_selection = 2; 
				vote_string = "yes";
			}
			else
			{
				vote_selection = 1; 
				vote_string = "no"; 
			}
			
			if(vote_selection)
			{
				if(uid2name_dialog) // handled by "uid2name" option
				{
					vote_active = 0;
					vote_prev = 0;
					vote_change = -9999;
					localcmd(strcat("setreport cl_allow_uid2name ", ftos(vote_selection - 1), "\n"));
					uid2name_dialog = 0;
				}
				else { localcmd(strcat("cmd vote ", vote_string, "\n")); }
				
				return;
			}
		}
			
		default:
			print("Incorrect parameters for ^2handlevote^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd handlevote vote\n");
			print("  Where 'vote' is the selection for either the current poll or uid2name.\n");
			return;
		}
	}
}

void LocalCommand_hud(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			switch(argv(1))
			{
				case "configure":
				{
					cvar_set("_hud_configure", ftos(!autocvar__hud_configure));
					return;
				}
				
				case "save":
				{
					if(argv(2))
					{
						HUD_Panel_ExportCfg(argv(2));
						return;
					}
					else
					{
						break; // go to usage, we're missing the paramater needed here.
					}
				}
				
				case "scoreboard_columns_set":
				{
					Cmd_HUD_SetFields(argc); 
					return;
				}

				case "scoreboard_columns_help":
				{
					Cmd_HUD_Help();
					return;
				}
				
				case "radar":
				{
					if(argv(2))
						hud_panel_radar_maximized = InterpretBoolean(argv(2));
					else
						hud_panel_radar_maximized = !hud_panel_radar_maximized;
					return;
				}
			}
		}
			
		default:
			print("Incorrect parameters for ^2hud^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd hud action [configname | radartoggle | layout]\n");
			print("  Where 'action' is the command to complete,\n");
			print("  'configname' is the name to save to for \"save\" action,\n");
			print("  'radartoggle' is to control hud_panel_radar_maximized for \"radar\" action,\n");
			print("  and 'layout' is how to organize the scoreboard columns for the set action.\n");
			print("  Full list of commands here: \"configure, save, scoreboard_columns_help, scoreboard_columns_set, radar.\"\n");
			return;
		}
	}
}

void LocalCommand_localprint(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(1))
			{
				centerprint_hud(argv(1));
				return; 
			}
		}
			
		default:
			print("Incorrect parameters for ^2localprint^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd localprint \"message\"\n");
			print("  'message' is the centerprint message to send to yourself.\n");
			return;
		}
	}
}

void LocalCommand_mv_download(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(1))
			{
				Cmd_MapVote_MapDownload(argc);
				return; 
			}
		}
			
		default:
			print("Incorrect parameters for ^2mv_download^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd mv_download mapid\n");
			print("  Where 'mapid' is the id number of the map to request an image of on the map vote selection menu.\n");
			return;
		}
	}
}

void LocalCommand_sendcvar(float request, float argc)
{
	switch(request)
	{
		case CMD_REQUEST_COMMAND:
		{
			if(argv(1))
			{
				// W_FixWeaponOrder will trash argv, so save what we need.
				string thiscvar = strzone(argv(1));
				string s = cvar_string(thiscvar);
				
				if(thiscvar == "cl_weaponpriority")
					s = W_FixWeaponOrder(W_NumberWeaponOrder(s), 1);
				else if(substring(thiscvar, 0, 17) == "cl_weaponpriority" && strlen(thiscvar) == 18)
					s = W_FixWeaponOrder(W_NumberWeaponOrder(s), 0);
					
				localcmd("cmd sentcvar ", thiscvar, " \"", s, "\"\n");
				strunzone(thiscvar);
				return; 
			}
		}
			
		default:
			print("Incorrect parameters for ^2sendcvar^7\n");
		case CMD_REQUEST_USAGE:
		{
			print("\nUsage:^3 cl_cmd sendcvar <cvar>\n");
			print("  Where 'cvar' is the cvar plus arguments to send to the server.\n");
			return;
		}
	}
}

/* use this when creating a new command, making sure to place it in alphabetical order... also,
** ADD ALL NEW COMMANDS TO commands.cfg WITH PROPER ALIASES IN THE SAME FASHION!
void LocalCommand_(float request)
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
			print("\nUsage:^3 cl_cmd \n");
			print("  No arguments required.\n");
			return;
		}
	}
}
*/


// ==================================
//  Macro system for client commands
// ==================================

// Normally do not hard code aliases for these, instead create them in commands.cfg... also: keep in alphabetical order, please ;)
#define CLIENT_COMMANDS(request,arguments) \
	CLIENT_COMMAND("blurtest", LocalCommand_blurtest(request), "Feature for testing blur postprocessing") \
	CLIENT_COMMAND("create_scrshot_ent", LocalCommand_create_scrshot_ent(request), "Create an entity at this location for automatic screenshots") \
	CLIENT_COMMAND("debugmodel", LocalCommand_debugmodel(request, arguments), "Spawn a debug model manually") \
	CLIENT_COMMAND("handlevote", LocalCommand_handlevote(request, arguments), "System to handle selecting a vote or option") \
	CLIENT_COMMAND("hud", LocalCommand_hud(request, arguments), "Commands regarding/controlling the HUD system") \
	CLIENT_COMMAND("localprint", LocalCommand_localprint(request, arguments), "Create your own centerprint sent to yourself") \
	CLIENT_COMMAND("mv_download", LocalCommand_mv_download(request, arguments), "Retrieve mapshot picture from the server") \
	CLIENT_COMMAND("sendcvar", LocalCommand_sendcvar(request, arguments), "Send a cvar to the server (like weaponpriority)") \
	/* nothing */
	
void LocalCommand_macro_help()
{
	#define CLIENT_COMMAND(name,function,description) \
		{ if(strtolower(description) != "") { print("  ^2", name, "^7: ", description, "\n"); } }
		
	CLIENT_COMMANDS(0, 0)
	#undef CLIENT_COMMAND
	
	return;
}

float LocalCommand_macro_command(float argc)
{
	#define CLIENT_COMMAND(name,function,description) \
		{ if(name == strtolower(argv(0))) { function; return TRUE; } }
		
	CLIENT_COMMANDS(CMD_REQUEST_COMMAND, argc)
	#undef CLIENT_COMMAND
	
	return FALSE;
}

float LocalCommand_macro_usage(float argc)
{
	#define CLIENT_COMMAND(name,function,description) \
		{ if(name == strtolower(argv(1))) { function; return TRUE; } }
		
	CLIENT_COMMANDS(CMD_REQUEST_USAGE, argc)
	#undef CLIENT_COMMAND
	
	return FALSE;
}

void LocalCommand_macro_write_aliases(float fh)
{
	#define CLIENT_COMMAND(name,function,description) \
		{ if(strtolower(description) != "") { CMD_Write_Alias("qc_cmd_cl", name, description); } }
		
	CLIENT_COMMANDS(0, 0)
	#undef CLIENT_COMMAND
	
	return;
}


// =========================================
//  Main Function Called By Engine (cl_cmd)
// =========================================
// If this function exists, client code handles gamecommand instead of the engine code.

void GameCommand(string command)
{
	float argc = tokenize_console(command);

	// Guide for working with argc arguments by example:
	// argc:   1    - 2      - 3     - 4
	// argv:   0    - 1      - 2     - 3 
	// cmd     vote - master - login - password

	if(strtolower(argv(0)) == "help") 
	{
		if(argc == 1) 
		{
			print("\nClient console commands:\n");
			LocalCommand_macro_help();

			print("\nGeneric commands shared by all programs:\n");
			GenericCommand_macro_help();
			
			print("\nUsage:^3 cl_cmd COMMAND...^7, where possible commands are listed above.\n");
			print("For help about a specific command, type cl_cmd help COMMAND\n");
			
			return;
		} 
		else if(GenericCommand_macro_usage(argc)) // Instead of trying to call a command, we're going to see detailed information about it
		{
			return;
		}
		else if(LocalCommand_macro_usage(argc)) // now try for normal commands too
		{
			return;
		}
	} 
	else if(GenericCommand(command)) 
	{
		return; // handled by common/command/generic.qc
	}
	else if(LocalCommand_macro_command(argc)) // continue as usual and scan for normal commands
	{
		return; // handled by one of the above LocalCommand_* functions
	}
	
	// nothing above caught the command, must be invalid
	print(((command != "") ? strcat("Unknown client command \"", command, "\"") : "No command provided"), ". For a list of supported commands, try cl_cmd help.\n");
	
	return;
}


// ===================================
//  Macro system for console commands
// ===================================

// These functions are here specifically to add special + - commands to the game, and are not really normal commands.
// Please add client commands to the function above this, as this is only for special reasons.
#define CONSOLE_COMMANDS_NORMAL \
	CONSOLE_COMMAND("+showscores", { scoreboard_showscores = TRUE; }) \
	CONSOLE_COMMAND("-showscores", { scoreboard_showscores = FALSE; }) \
	CONSOLE_COMMAND("+showaccuracy", { scoreboard_showaccuracy = TRUE; }) \
	CONSOLE_COMMAND("-showaccuracy", { scoreboard_showaccuracy = FALSE; }) \
	/* nothing */
	
#define CONSOLE_COMMANDS_MOVEMENT \
	CONSOLE_COMMAND("+forward", { ++camera_direction_x; }) \
	CONSOLE_COMMAND("-forward", { --camera_direction_x; }) \
	CONSOLE_COMMAND("+back", { --camera_direction_x; }) \
	CONSOLE_COMMAND("-back", { ++camera_direction_x; }) \
	CONSOLE_COMMAND("+moveup", { ++camera_direction_z; }) \
	CONSOLE_COMMAND("-moveup", { --camera_direction_z; }) \
	CONSOLE_COMMAND("+movedown", { --camera_direction_z; }) \
	CONSOLE_COMMAND("-movedown", { ++camera_direction_z; }) \
	CONSOLE_COMMAND("+moveright", { --camera_direction_y; }) \
	CONSOLE_COMMAND("-moveright", { ++camera_direction_y; }) \
	CONSOLE_COMMAND("+moveleft", { ++camera_direction_y; }) \
	CONSOLE_COMMAND("-moveleft", { --camera_direction_y; }) \
	CONSOLE_COMMAND("+roll_right", { ++camera_roll; }) \
	CONSOLE_COMMAND("-roll_right", { --camera_roll; }) \
	CONSOLE_COMMAND("+roll_left", { --camera_roll; }) \
	CONSOLE_COMMAND("-roll_left", { ++camera_roll; }) \
	/* nothing */

void ConsoleCommand_macro_init()
{
	// first init normal commands
	#define CONSOLE_COMMAND(name,execution) \
		{ registercommand(name); }

	CONSOLE_COMMANDS_NORMAL
	#undef CONSOLE_COMMAND
	
	// then init movement commands
	#ifndef CAMERATEST
	if(isdemo())
	{
	#endif
		#define CONSOLE_COMMAND(name,execution) \
			{ registercommand(name); }

		CONSOLE_COMMANDS_MOVEMENT
		#undef CONSOLE_COMMAND
	#ifndef CAMERATEST
	}
	#endif
	
	return;
}

float ConsoleCommand_macro_normal(float argc)
{
	#define CONSOLE_COMMAND(name,execution) \
		{ if(name == strtolower(argv(0))) { { execution } return TRUE; } }
		
	CONSOLE_COMMANDS_NORMAL
	#undef CONSOLE_COMMAND
	
	return FALSE;
}

float ConsoleCommand_macro_movement(float argc)
{
	if(camera_active)
	{
		#define CONSOLE_COMMAND(name,execution) \
			{ if(name == strtolower(argv(0))) { { execution } return TRUE; } }

		CONSOLE_COMMANDS_MOVEMENT
		#undef CONSOLE_COMMAND
	}
	
	return FALSE;
}


// ======================================================
//  Main Function Called By Engine (registered commands)
// ======================================================
// Used to parse commands in the console that have been registered with the "registercommand" function

float CSQC_ConsoleCommand(string command)
{
	float argc = tokenize_console(command);

	if(ConsoleCommand_macro_normal(argc))
	{
		return TRUE;
	}
	else if(ConsoleCommand_macro_movement(argc))
	{
		return TRUE;
	}
	
	// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.

	return FALSE;
}
