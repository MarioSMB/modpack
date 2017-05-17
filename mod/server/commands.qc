AUTOCVAR(g_maplist_max_perpage, int, 200, "Maximum maps per maplist page (shouldn't be too low or too high, as last page will be filled with the remainder)");
AUTOCVAR(g_maplist_generate_lists, bool, false, "Generate a new list for maps using paged design (may cause crashes)");

STATIC_INIT(mod_cmds)
{
	localcmd("\nalias ircmsg \"sv_cmd ircmsg ${* ?}\"\n");
	localcmd("\nalias _ircmessage \"ircmsg ${* ?}\"\n");
	localcmd("\nalias chlevel \"sv_cmd chlevel ${* ?}\"\n");
	localcmd("\nalias stufftoall \"sv_cmd stufftoall ${* ?}\"\n");
	localcmd("\nalias dumpmodcvars \"sv_cmd dumpmodcvars ${* ?}\"\n");
	localcmd("\nalias gotorandom \"sv_cmd gotorandom ${* ?}\"\n");
}

const int MAX_MAPLISTS = 8;
string newmaplist[MAX_MAPLISTS];
STATIC_INIT(mod_buildmaplist)
{
	if(!autocvar_g_maplist_generate_lists)
		return;

	// to make absolutely sure:
	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);

	int page = 0;
	for(int j = 0; j < MapInfo_count; ++j)
	{
		newmaplist[page] = strcat(newmaplist[page], " ", _MapInfo_GlobItem(MapInfo_FilterList_Lookup(j)));
		if((j % 10) && page < MAX_MAPLISTS)
			page += 1; // fills up last page
	}

	for(int j = 0; j < MAX_MAPLISTS; ++j)
	{
		newmaplist[j] = strzone(newmaplist[j]);
	}
}

void IRCSay(string msgstr)
{
	if(msgstr == "")
		return;

	string prefix;
	if(substring(msgstr, 0, 3) == "^4*") // actions
		prefix = "\{3}";
	else
		prefix = "\{1}";

	msgstr = strcat(prefix, strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint

	FOREACH_CLIENTSLOT(true,
	{
		if(!intermission_running)
		if((autocvar_g_chat_nospectators == 1) || (autocvar_g_chat_nospectators == 2 && !(warmup_stage || game_stopped)))
		if(IS_PLAYER(it))
			continue;
		if(IS_REAL_CLIENT(it))
			sprint(it, msgstr);
	});
}

float mod_cvar_file;
void RegisterModCvars_Set(string name, string def, string desc, bool archive, string file)
{
	if(substring(file, 0, 10) != "../../mod/" && substring(file, 0, 21) != "../../../modpack/mod/")
		return;

	// NOTE: the file must be opened beforehand, or this will implode!
    string thecvar = sprintf("\n%s %s \"%s\" \"%s\"", (archive ? "seta" : "set"), name, def, desc);
    fputs(mod_cvar_file, thecvar);
}

void print_maplist(entity player, string nmaplist, float nargc)
{
	// note: requires command parameters

	string param = strtolower(argv(1));
	string col;
	if(param == "new")
	{
		if(!g_race && !g_cts)
		{
			print_to(player, "This command only works in CTS and Race.");
			return;
		}
		FOREACH_WORD(nmaplist, !race_readTime(it, 1),
		{
			col = ((i % 2) ? "^2" : "^3");
			print_to(player, strcat(col, it));
		});
	}
	else if(param == "any" && nargc > 2)
	{
		param = strtolower(argv(2));
		FOREACH_WORD(nmaplist, strstrofs(strtolower(it), param, 0) >= 0,
		{
			if((g_race || g_cts) && !race_readTime(it, 1))
				col = ((i % 2) ? "^4*" : "^5*");
			else
				col = ((i % 2) ? "^2" : "^3");
			print_to(player, strcat(col, it));
		});
	}
	else
	{
		FOREACH_WORD(nmaplist, startsWithNocase(strdecolorize(it), param),
		{
			if((g_race || g_cts) && !race_readTime(it, 1))
				col = ((i % 2) ? "^4*" : "^5*");
			else
				col = ((i % 2) ? "^2" : "^3");
			print_to(player, strcat(col, it));
		});
	}
}

.float mapquery_antispam;
MUTATOR_HOOKFUNCTION(mutator_mod, SV_ParseClientCommand)
{
	if (MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	int cmd_argc = M_ARGV(2, int);

	if(cmd_name == "findmap")
	{
		if(cmd_argc > 1)
		{
			if(time < player.mapquery_antispam)
			{
				print_to(player, "You can only use this command once every 5 seconds.");
				return true;
			}

			if(!autocvar_g_maplist_generate_lists)
			{
				string themaplist = ((autocvar_g_maplist == "") ? strdecolorize(strreplace("^7Maps in list: ", "", maplist_reply)) : autocvar_g_maplist);
				print_maplist(player, themaplist, cmd_argc);
			}
			else
			{
				for(int j = 0; j < MAX_MAPLISTS; ++j)
				{
					string themaplist = newmaplist[j];
					print_maplist(player, themaplist, cmd_argc);
				}
			}

			player.mapquery_antispam = time + 5; // prevent using this command too often, to avoid lag issues
		}
		else
			print_to(player, maplist_reply);
		return true;
	}
}

MUTATOR_HOOKFUNCTION(mutator_mod, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	string cmd_name = M_ARGV(0, string);
	string cmd_string = M_ARGV(2, string);

	if(cmd_name == "chlevel")
	{
		string m = MapInfo_FixName(argv(1));
		localcmd(strcat("\nchangelevel ", m, "\n"));
		LOG_INFO("Switching to ", m, "\n");
		return true;
	}

	if(cmd_name == "gotorandom")
	{
		if(autocvar_g_maplist == "")
		{
			localcmd("\nendmatch\n");
			LOG_INFO("g_maplist is empty, ending match...\n");
		}

		Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");
		Map_Current = bound(0, GetMaplistPosition(), Map_Count - 1);
		int pos = MaplistMethod_Random();
		if(pos == -1)
		{
			LOG_INFO("Failed to select a map, try again.\n");
			return true;
		}

		string themap = argv(pos);
		localcmd(strcat("\nchangelevel ", themap, "\n"));
		LOG_INFO("Switching to ", themap, "\n");
		return true;
	}

	if(cmd_name == "ircmsg")
	{
		IRCSay(substring(cmd_string, strlen(argv(0))+1, strlen(cmd_string)));
		return true;
	}

#ifdef STUFFTO_ENABLED
	if(cmd_name == "stufftoall")
	{
		FOREACH_CLIENT(IS_REAL_CLIENT(it), LAMBDA(
			bool accepted = VerifyClientEntity(it, true, false);
			if(accepted > 0)
			{
				stuffcmd(it, strcat("\n", argv(1), "\n"));
				LOG_INFO(strcat("Command: \"", argv(1), "\" sent to ", GetCallerName(it), ".\n"));
				continue;
			}
			else
			{
				LOG_INFO("stuffto failed on ", GetCallerName(it), ".\n");
				continue;
			}
		));
		return true;
	}
#endif

	if(cmd_name == "dumpmodcvars")
	{
		mod_cvar_file = fopen("mod_cvars.cfg", FILE_WRITE);
		if(mod_cvar_file >= 0)
		{
			fputs(mod_cvar_file, "// DO NOT MODIFY THIS FILE!!");
			fputs(mod_cvar_file, "\n// Put your changes in server.cfg, this file is automatically generated!");
			fputs(mod_cvar_file, "\n\n\n// Mod Cvars:\n");
			RegisterCvars(RegisterModCvars_Set);
			fputs(mod_cvar_file, "\n");
			LOG_INFO("Dumping mod cvars... File located in ^2data/data/mod_cvars.cfg^7.\n");
			fclose(mod_cvar_file);
		}
		else
			LOG_INFO("^1Error: ^7Could not open file 'mod_cvars.cfg'!\n");
			
		return true;
	}
}
