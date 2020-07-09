//FEATURE: Command to add locations to maps for callouts in chat, useful for mappers who don't want to work from the editor

#ifdef GAMEQC
REGISTER_MUTATOR(location_ent, true);

bool add_location(string locname, vector position, string themap)
{
	string filename = strcat("location/", themap, "_location_ent.txt");
	int fh = fopen(filename, FILE_APPEND);

	if (fh >= 0)
	{
		fputs(fh, "{\n");
		fputs(fh, 		("\"classname\" \"info_location\"\n"));
		fputs(fh, strcat("\"origin\" \"", strcat(ftos(position.x), " ", ftos(position.y), " ", ftos(position.z)), "\"\n"));
		fputs(fh, strcat("\"netname\" \"", locname, "\"\n"));
		fputs(fh, "}\n");

		fclose(fh);
		return true;
	}
	else
	{
		// couldn't access the file!
		return false;
	}
}
#endif

#ifdef SVQC
AUTOCVAR(sv_location_editor, bool, false, "Allow players to place location entities in the map (use with caution, can't be removed once placed!)");

MUTATOR_HOOKFUNCTION(location_ent, SetModname)
{
	string filename = strcat("data/location/", mapname, "_location_ent.txt"); // doesn't support custom paths
	if(fexists(filename))
		loadfromfile(filename);
}

MUTATOR_HOOKFUNCTION(location_ent, SV_ParseClientCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	int cmd_argc = M_ARGV(2, int);
	string command = M_ARGV(3, string);

	if(cmd_name == "addloc")
	{
		if(!autocvar_sv_location_editor)
		{
			sprint(player, "^1Error: ^7Location entity creation is not enabled!\n");
			return true;
		}
		if(cmd_argc < 2)
		{
			sprint(player, "^1Error: ^7Need to set a name for the location!\n");
			return true;
		}
		string s = strdecolorize(substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
		if(add_location(s, player.origin, mapname))
			sprint(player, "Successfully created location entity.\n");
		else
			sprint(player, "^1Error: ^7Unable to place a location entity!\n");
		return true;
	}
}
#endif

#ifdef CSQC
STATIC_INIT_LATE(location_ent_alias)
{
	localcmd("\nalias create_loc_ent \"cl_cmd create_loc_ent ${* ?}\"\n");
	localcmd("\nalias addloc \"cmd addloc ${* ?}\"\n");
}

MUTATOR_HOOKFUNCTION(location_ent, CSQC_ConsoleCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	string cmd_name = M_ARGV(0, string);
	int cmd_argc = M_ARGV(2, int);
	string command = M_ARGV(3, string);

	if(cmd_name == "create_loc_ent")
	{
		if(cmd_argc < 2)
		{
			LOG_INFO("^1Error: ^7Need to set a name for the location!");
			return true;
		}
		string s = strdecolorize(substring(command, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
		if(add_location(s, view_origin, MapInfo_Map_bspname))
			LOG_INFO("Completed location entity dump in ^2data/data/", MapInfo_Map_bspname, "_location_ent.txt^7.");
		else
			LOG_INFO("^1Error: ^7Could not dump to file!");
		return true;
	}
}
#endif
