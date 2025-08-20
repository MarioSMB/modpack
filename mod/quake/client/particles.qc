#include "particles.qh"

const int COP_ERR = 0;
const int COP_REG = 1;
const int COP_SET = 2;
const int COP_CLR = 3;
const int COP_DEL = 4;
void cvar_operation(bool action, string var, string val)
{
	if(action == COP_REG)
	{
		registercvar(var, val);
	}
	else if(action == COP_SET)
	{
		if(!(cvar_type(var) & CVAR_TYPEFLAG_EXISTS))
			return;
		cvar_set(var, val);
	}
	else if(action == COP_CLR)
	{
		if(!(cvar_type(var) & CVAR_TYPEFLAG_EXISTS))
			return;
		cvar_set(var, "");
	}
	else if(action == COP_DEL)
	{
		if(!(cvar_type(var) & CVAR_TYPEFLAG_EXISTS))
			return;
		localcmd(strcat("\nunset ", var, "\n"));
	}
}

void particles_updatecvars(int action, string input)
{
	cvar_operation(action, strcat(input, "_countabsolute"), "0");
	cvar_operation(action, strcat(input, "_count"), "0");
	cvar_operation(action, strcat(input, "_type"), "alphastatic");
	cvar_operation(action, strcat(input, "_blend"), "alpha");
	cvar_operation(action, strcat(input, "_orientation"), "billboard");
	//cvar_operation(action, strcat(input, "_color"), "0xFFFFFF 0xFFFFFF");
	cvar_operation(action, strcat(input, "_color_min"), "1 1 1");
	cvar_operation(action, strcat(input, "_color_max"), "1 1 1");
	cvar_operation(action, strcat(input, "_tex"), "63 63 0");
	cvar_operation(action, strcat(input, "_size"), "1 1 0");
	cvar_operation(action, strcat(input, "_sizeincrease"), "0");
	cvar_operation(action, strcat(input, "_alpha"), "0 256 256");
	cvar_operation(action, strcat(input, "_time"), "16777216 16777216 0");
	cvar_operation(action, strcat(input, "_gravity"), "0");
	cvar_operation(action, strcat(input, "_bounce"), "0");
	cvar_operation(action, strcat(input, "_airfriction"), "0");
	cvar_operation(action, strcat(input, "_liquidfriction"), "0");
	cvar_operation(action, strcat(input, "_originoffset"), "0 0 0");
	cvar_operation(action, strcat(input, "_relativeoriginoffset"), "0 0 0");
	cvar_operation(action, strcat(input, "_velocityoffset"), "0 0 0");
	cvar_operation(action, strcat(input, "_relativevelocityoffset"), "0 0 0");
	cvar_operation(action, strcat(input, "_originjitter"), "0 0 0");
	cvar_operation(action, strcat(input, "_velocityjitter"), "0 0 0");
	cvar_operation(action, strcat(input, "_velocitymultiplier"), "0 0 0");
	cvar_operation(action, strcat(input, "_lightradius"), "0");
	cvar_operation(action, strcat(input, "_lightradiusfade"), "0");
	cvar_operation(action, strcat(input, "_lighttime"), "16777216");
	cvar_operation(action, strcat(input, "_lightcolor"), "1 1 1");
	cvar_operation(action, strcat(input, "_lightshadow"), "1");
	cvar_operation(action, strcat(input, "_lightcubemapnum"), "0");
	cvar_operation(action, strcat(input, "_lightcorona"), "1 0.25 0");
	cvar_operation(action, strcat(input, "_underwater"), "0");
	cvar_operation(action, strcat(input, "_notunderwater"), "0");
	cvar_operation(action, strcat(input, "_trailspacing"), "0");
	cvar_operation(action, strcat(input, "_stretchfactor"), "0");
	cvar_operation(action, strcat(input, "_staincolor_min"), "0 0 0");
	cvar_operation(action, strcat(input, "_staincolor_max"), "0 0 0");
	cvar_operation(action, strcat(input, "_stainalpha"), "1 1 0");
	cvar_operation(action, strcat(input, "_stainsize"), "2 2 0");
	cvar_operation(action, strcat(input, "_staintex"), "-1 -1 0");
	cvar_operation(action, strcat(input, "_stainless"), "0");
	//cvar_operation(action, strcat(input, "_rotate"), "0 360 0 0");
	cvar_operation(action, strcat(input, "_startangle"), "0 360 0");
	cvar_operation(action, strcat(input, "_spin"), "0 0 0");
	cvar_operation(action, strcat(input, "_delayspawn"), "0");
	cvar_operation(action, strcat(input, "_delaycollision"), "0");
	cvar_operation(action, strcat(input, "_teamcolor"), "0");
	cvar_operation(action, strcat(input, "_lightteamcolor"), "0");
}

void particles_copycvars(string from, string to)
{
	string s;
#define PCVAR(in) \
	s = strcat(from, (in)); if(cvar_type(s) & CVAR_TYPEFLAG_EXISTS) cvar_operation(COP_SET, strcat(to, (in)), cvar_string(s))

	PCVAR("_countabsolute");
	PCVAR("_count");
	PCVAR("_type");
	PCVAR("_blend");
	PCVAR("_orientation");
	PCVAR("_color");
	PCVAR("_color_min");
	PCVAR("_color_max");
	PCVAR("_tex");
	PCVAR("_size");
	PCVAR("_sizeincrease");
	PCVAR("_alpha");
	PCVAR("_time");
	PCVAR("_gravity");
	PCVAR("_bounce");
	PCVAR("_airfriction");
	PCVAR("_liquidfriction");
	PCVAR("_originoffset");
	PCVAR("_relativeoriginoffset");
	PCVAR("_velocityoffset");
	PCVAR("_relativevelocityoffset");
	PCVAR("_originjitter");
	PCVAR("_velocityjitter");
	PCVAR("_velocitymultiplier");
	PCVAR("_lightradius");
	PCVAR("_lightradiusfade");
	PCVAR("_lighttime");
	PCVAR("_lightcolor");
	PCVAR("_lightshadow");
	PCVAR("_lightcubemapnum");
	PCVAR("_lightcorona");
	PCVAR("_underwater");
	PCVAR("_notunderwater");
	PCVAR("_trailspacing");
	PCVAR("_stretchfactor");
	PCVAR("_staincolor_min");
	PCVAR("_staincolor_max");
	PCVAR("_stainalpha");
	PCVAR("_stainsize");
	PCVAR("_staintex");
	PCVAR("_stainless");
	PCVAR("_rotate");
	PCVAR("_startangle");
	PCVAR("_spin");
	PCVAR("_delayspawn");
	PCVAR("_delaycollision");
	PCVAR("_teamcolor");
	PCVAR("_lightteamcolor");

#undef PCVAR
}

bool cvar_inlist(string input, string list)
{
	if(list == "")
		return false;

	for (string _s = list; _s != ""; _s = cdr(_s))
	{
		string s = car(_s);
		if(s == substring(input, 0, strlen(s)))
			return true;
	}

	return false;
}

#ifdef CSQC
void(float bufhandle, string pattern, string antipattern) buf_cvarlist = #517;
#endif

void Particle_HandleCommand(int argc)
{
	string cmd = argv(1);

	switch(cmd)
	{
		case "create": case "set":
		case "reset":
		case "clear":
		case "delete": case "unset":
		{
			string eff = argv(2);
			string list = argv(3);
			if(eff == "")
			{
				LOG_INFO("You need to provide an existing particle effect name as the first parameter");
				break;
			}
			if(list == "")
			{
				LOG_INFO("A list needs to be provided for effect cvar population");
				break;
			}

			string eff_list = strcat("cl_particle_", eff);
			string input = strcat(eff_list, "_", list);
			int action = COP_ERR;
			if(cmd == "create" || cmd == "set")
				action = COP_REG;
			else if(cmd == "reset")
				action = COP_SET;
			else if(cmd == "clear")
				action = COP_CLR;
			else if(cmd == "delete" || cmd == "unset")
				action = COP_DEL;
			if(action == COP_ERR)
			{
				LOG_INFO("You somehow did the impossible, you win");
				return;
			}
			if(list == "all")
			{
				if(!(cvar_type(eff_list) & CVAR_TYPEFLAG_EXISTS))
				{
					LOG_INFO("Given effect does not exist as cvars");
					return;
				}
				string eff_listvar = cvar_string(eff_list);
				FOREACH_WORD(eff_listvar, true,
				{
					particles_updatecvars(action, strcat(eff_list, "_", it));
				});

				// doesn't delete the main effect cvar, just clears it so it can be reused
				if(action == COP_DEL)
					cvar_set(eff_list, "");
			}
			else
				particles_updatecvars(action, input);

			LOG_INFO("Successfully applied action to all particle cvars for ", eff_list);
			break;
		}
		case "copy":
		{
			string eff_from = argv(2);
			string list_from = argv(3);
			string eff_to = argv(4);
			string list_to = argv(5);
			if(eff_from == "" || list_from == "" || eff_to == "" || list_to == "")
			{
				LOG_INFO("You need to provide an effect and list to copy from, and an effect and list to copy to");
				LOG_INFO("Example: ^3particle copy eff_from list_from eff_to list_to");
				return;
			}
			// first register AND clear the destination to make sure all cvars exist with empty values
			string targ = strcat("cl_particle_", eff_to, "_", list_to);
			particles_updatecvars(COP_REG, targ);
			particles_updatecvars(COP_CLR, targ);

			string source = strcat("cl_particle_", eff_from, "_", list_from);
			particles_copycvars(source, targ);
			LOG_INFO("Copied all particlde cvars from ^3", source, " ^7to ^3", targ);
			break;
		}
		case "test":
		{
			string eff = argv(2);
			if(eff == "")
			{
				LOG_INFO("A valid particle effect name is needed");
				break;
			}
			string dist_arg = argv(3);
			float eff_dist = (dist_arg == "") ? 256 : stof(dist_arg);
			traceline(view_origin, view_origin + view_forward * eff_dist, MOVE_NORMAL, NULL);
			float tcolors = entcs_GetClientColors(player_localentnum - 1);
			particles_colormin = colormapPaletteColor(tcolors & 0x0F, false);
			particles_colormax = colormapPaletteColor(tcolors & 0x0F, true);
			if(!SpawnParticles_list(strcat("cl_particle_", eff), trace_endpos, trace_plane_normal * 150, false))
				__pointparticles(_particleeffectnum(eff), trace_endpos, trace_plane_normal * 150, 1);
			break;
		}
		case "clean":
		{
			int cleaned = 0;
			int h = buf_create();
			buf_cvarlist(h, "cl_particle_", "_"); // exclude all _ cvars as they are temporary
			int n = buf_getsize(h);
			FOREACH(Effects, true,
			{
				string eff = strcat("cl_particle_", it.eent_eff_name);
				bool listexists = (cvar_type(eff) & CVAR_TYPEFLAG_EXISTS);
				string eff_list = strcat(eff, "_");
				int eff_len = strlen(eff_list);
				string eff_listvar = (listexists) ? cvar_string(eff) : "";
				// not gonna check if the cvar itself exists, as it may have been cleared already
				// HOWEVER: if it does exist, let's not delete the needed cvars for it!
				for(int j = 0; j < n; ++j)
				{
					string k = bufstr_get(h, j);
					if(substring(k, 0, eff_len) != eff_list)
						continue;
					if(listexists && cvar_inlist(substring(k, eff_len, -1), eff_listvar))
						continue;
					LOG_INFO("Deleting ", k, " \"", cvar_string(k), "\"");
					localcmd(strcat("\nunset ", k, "\n"));
					cleaned += 1;
				}

			});
			buf_del(h);
			LOG_INFO("Cleaned up ", ftos(cleaned), " dangling effect cvars");
			break;
		}
		case "save":
		{
			string file = argv(2);
			if(file == "")
				file = "particles_save.cfg";

			int fh = fopen(file, FILE_WRITE);
			if(fh < 0)
			{
				LOG_INFO("Couldn't open the file for writing");
				return;
			}

			int h = buf_create();
			buf_cvarlist(h, "cl_particle_", "_"); // exclude all _ cvars as they are temporary
			int n = buf_getsize(h);

			fputs(fh, sprintf("// Particle effects config, saved %s\n\n", strftime(false, "%Y-%m-%d %H:%M:%S")));

			for(int j = 0; j < n; ++j)
			{
				string k = bufstr_get(h, j);
				if(k == "cl_particle_disable")
					continue;
				fputs(fh, sprintf("seta %s \"%s\"\n", k, cvar_string(k)));
			}
			fclose(fh);
			buf_del(h);
			LOG_INFO("Wrote particle effects to data/", file);
			break;
		}
		case "info":
		{
			LOG_HELP("Available parameters:");
			LOG_HELP("^3countabsolute (\"0\") ^7- absolute number of particles to spawn, unaffected by quality reduction and such (useful for decals)");
			LOG_HELP("^3count (\"0\") ^7- multiplier for the number of particles to spawn at a time");
			LOG_INFO("^1This section is unfinished, sorry about that!");
			break;
		}
		default:
		case "help":
		{
			LOG_HELP("Currently available commands:");
			LOG_HELP("help - Display this information");
			LOG_HELP("test <effect> [distance] - Plays the given effect at an optionally provided distance in front of the player");
			LOG_HELP("copy <effect_from> <list_from> <effect_to> <list_to> - Copies all particle cvars from the provided effect and list to the target effect and list");
			LOG_HELP("save [filename] - Saves all existing particle cvars into a config file, a filename can be provided or \"particles_save.cfg\" will be the default");
			//LOG_HELP("info - Lists information about each of the particle effect parameters");
			LOG_HELP("clean - Attempts to remove all unused effect cvars, ^1use with caution");
			// put these at the bottom or separated
			LOG_HELP("\nSome operations allow you to modify all the effect cvars at once:");
			LOG_HELP("- create <effect> <list> - Creates all the needed cvars with default values, e.g. \"particle create laser_impact spark\"");
			LOG_HELP("- reset <effect> <list> - Resets all cvars in the given list to their default values");
			LOG_HELP("- clear <effect> <list> - Sets all cvars in the given list to \"\" for easier editing");
			LOG_HELP("- delete <effect> <list> - Deletes all cvars for the list to ease removal");
			LOG_HELP("You may also set list to \"all\" to apply these actions all the cvars associated with the effect");
			break;
		}
	}
}
