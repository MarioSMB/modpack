#ifdef IMPLEMENTATION

#include "../../mplant/system.qc"
#include "../../mplant/io.qc"
#include "../../mplant/networking.qc"

#include "../../mplant/objects/common.qc"
#include "../../mplant/objects/block.qc"

#include "../../mplant/tools/common.qc"
#include "../../mplant/tools/extrude.qc"
#include "../../mplant/tools/place.qc"
#include "../../mplant/tools/rotate.qc"
#include "../../mplant/tools/select.qc"
#include "../../mplant/tools/smart.qc"
#include "../../mplant/tools/rubble.qc"

void mplant_init();

REGISTER_MUTATOR(mdlplant, autocvar_g_modelplanter)
{
	MUTATOR_ONADD
	{
		mplant_init();
	}

	return false;
}

MUTATOR_HOOKFUNCTION(mdlplant, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if (!player.mplant_cursorobject)
	{
		player.mplant_cursorobject = spawn();
		mplant_setmark(player, player.mplant_tool_modelindex);
		player.mplant_cursorobject.effects = EF_FULLBRIGHT;
		player.mplant_cursorobject.owner = player;
		player.mplant_cursorobject.drawonlytoclient = player;
		player.mplant_tool_modelindex = 0;
		player.mplant_cursorobject.solid = SOLID_NOT;
		player.mplant_cursorobject.alpha = 0.5;
		player.mplant_cursorobject.scale = 1;
	}

	player.mplant_cursorobject.effects |= EF_NODRAW;
	if (!player.mplant_active)
		return true;

	switch(PS(player).m_weapon)
	{

	case WEP_BLASTER: // place / remove
		if (player.mplant_tool.mplant_toolfunc)
			player.mplant_tool.mplant_toolfunc(player);
		break;

	case WEP_ARC:
	case WEP_MACHINEGUN:
		player.mplant_cursorobject.effects &= ~EF_NODRAW;
		makevectors(player.v_angle);
		setorigin(player.mplant_cursorobject, player.origin + player.view_ofs + (v_forward * 256));
		if (PHYS_INPUT_BUTTON_ATCK(player) && player.create_refire < time)
		{
			player.mplant_cursorobject.pos1_y += 90;
			if (player.mplant_cursorobject.pos1_y > 360)
				player.mplant_cursorobject.pos1_y = 0;

			player.create_refire = time + 0.25;
		}

		if (PHYS_INPUT_BUTTON_ATCK2(player) && player.create_refire < time)
		{
			player.mplant_cursorobject.pos1_x += 90;
			if (player.mplant_cursorobject.pos1_x > 360)
				player.mplant_cursorobject.pos1_x = 0;

			player.create_refire = time + 0.25;
		}
		player.mplant_cursorobject.angles = player.mplant_cursorobject.pos1;
		PHYS_INPUT_BUTTON_ATCK(player) = PHYS_INPUT_BUTTON_ATCK2(player) = false;
		break;

	case WEP_SHOTGUN:
		player.mplant_cursorobject.effects &= ~EF_NODRAW;
		crosshair_trace(player);
		makevectors(player.v_angle);
		setorigin(player.mplant_cursorobject, player.origin + player.view_ofs + (v_forward * 256));
		player.mplant_cursorobject.angles = vectoangles(normalize(player.mplant_cursorobject.origin - player.origin));
		if (PHYS_INPUT_BUTTON_ATCK(player) && player.create_refire < time)
		{
			mplant_switch_block(player, false);
			player.create_refire = time + 0.25;
		}

		if (PHYS_INPUT_BUTTON_ATCK2(player) && player.create_refire < time)
		{
			player.mplant_set_index += 1;
			if (player.mplant_set_index >= mplant_set_count)
				player.mplant_set_index = 0;
			mplant_load_dir_models(player, sprintf("models/modelplant%s", bufstr_get(mplant_sets, player.mplant_set_index)));
			mplant_setmark(player, 0);
			player.create_refire = time + 0.25;
		}
		PHYS_INPUT_BUTTON_ATCK(player) = PHYS_INPUT_BUTTON_ATCK2(player) = false;
		break;

	case WEP_MORTAR:
		player.mplant_cursorobject.effects &= ~EF_NODRAW;
		crosshair_trace(player);
		makevectors(player.v_angle);
		setorigin(player.mplant_cursorobject, player.origin + player.view_ofs + (v_forward * 256));

		if (_MPLANT_SELECTABLE(trace_ent))
			if (PHYS_INPUT_BUTTON_ATCK(player) && player.create_refire < time)
			{
				_SETMODEL(player.mplant_cursorobject, trace_ent.mdl);
				player.mplant_cursorobject.mplant_org_mins = player.mplant_cursorobject.mins;
				player.mplant_cursorobject.mplant_org_maxs = player.mplant_cursorobject.maxs;

				string _msg = sprintf("^3Block name: ^2%s\n ^3Size: ^2%v",
									  getfiletitle(trace_ent.model),
									  player.mplant_cursorobject.maxs - player.mplant_cursorobject.mins);
				centerprint(player, _msg);
				player.create_refire = time + 0.1;
			}

		if (_MPLANT_SELECTABLE(trace_ent))
			if (PHYS_INPUT_BUTTON_ATCK2(player) && player.create_refire < time)
			{
				player.mplant_cursorobject.pos1 = player.mplant_cursorobject.angles = trace_ent.angles;
				player.create_refire = time + 0.1;
			}
		PHYS_INPUT_BUTTON_ATCK(player) = PHYS_INPUT_BUTTON_ATCK2(player) = false;
		break;
	}
}

MUTATOR_HOOKFUNCTION(mdlplant, SV_ParseClientCommand)
{
	if (MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	bool _silence = false;

	entity player = M_ARGV(0, entity);
	string cmd_name = M_ARGV(1, string);
	int cmd_argc = M_ARGV(2, int);

#define CMDHELP(helpmsg) \
	if (argv(1) == "help" && !_silence) \
		{ centerprint(player, helpmsg); return true; } _silence = _silence

#define STATUS(status) do { \
	if (!_silence) { \
		centerprint(player, status); \
		sprint(player, strcat(status, "\n")); \
	} \
} while(0)


	if (cmd_name == "mplant_help")
	{
		centerprint(player, "^7list of avaiable commands for modelplant's cmd interface:\n"
"^2 mplant_tool \n^2 mplant_switch \n^2 mplant_export \n^2 mplant_save \n^2 mplant_load \n^2 mplant_clear \n^2 mplant_active \n^2 mplant_snap \n^2 mplant_rot \n^2 mplant_grid \n"
"^7Use ^3cmd ^5<command_name> help ^7 for more info");

		return true;
	}

	if (cmd_name == "mplant_tool")
	{
		CMDHELP("Switch active tool.\nUsage: ^3cmd^2 mplant_tool^5 next|prev|#");
		if (cmd_argc == 2)
		{
			if (argv(1) == "next")
				mplant_selecttool(player, player.mplant_tool.mplant_tool_index + 1);
			else if (argv(1) == "prev")
				mplant_selecttool(player, player.mplant_tool.mplant_tool_index - 1);
			else
			{
				float _idx = stof(argv(1));

				if (_idx >= MPT_FIRST && _idx <= MPT_LAST)
					mplant_selecttool(player, _idx);
				else
				{
					STATUS(sprintf("^1Invalid tool index^3 %i", _idx));
					return true;
				}
			}
		}
		STATUS(sprintf("Active tool is now^3 %s", player.mplant_tool.mplant_tool_name));// mplant_toolname(player.mplant_tool.mplant_tool_index)));
		return true;
	}

	if (cmd_name == "mplant_switch")
	{
		CMDHELP("Switch active block.\nUsage: ^3cmd^2 mplant_switch^5 [next|prev]");
		if (cmd_argc == 1)
			mplant_switch_block(player, false);

		if (cmd_argc == 2)
			if (argv(1) == "next")
				mplant_switch_block(player, false);
			else if (argv(1) == "prev")
				mplant_switch_block(player, true);

		return true;
	}

	if (cmd_name == "mplant_grid")
	{
		CMDHELP("Set / Show NULL gridsize.\nUsage: ^3cmd^2 mplant_grid^5 [#]");

		if (cmd_argc == 1)
			if (player.mplant_snaptions & MPS_GRID)
				STATUS(sprintf("Current grid is: %d", player.mplant_grid));
			else
				STATUS(sprintf("Grid is ^1OFF (%d)", player.mplant_grid));

		if (cmd_argc == 2)
		{
			player.mplant_grid = bound(2, stof(argv(1)), 1024);
			STATUS(sprintf("Grid is now: %d", player.mplant_grid));
		}

		return true;
	}
	/*
	.float mplant_cursor_pushback;
	.float mplant_cursor_privatespace;
	.float mplant_random_scale_min;
	.float mplant_random_scale_max;
	.vector mplant_random_rot_min;
	.vector mplant_random_rot_max;
	*/
//#define TEST(ss,s1,s2) if(s1 == ss || s2 == ss)
	if (cmd_name == "mplant_settings")
	{
		CMDHELP("General modelplant settings.\nUsage: ^3cmd^2 mplant_settings^5 [option] [value]");
#define OPSHOW(store,long,short,val,desc)\
	store=sprintf("%s\n^5%s^7 or ^2%s^7: ^3%s^8  -  %s",store,long,short,val,desc)

		if (argv(1) == "show" || cmd_argc == 1)
		{
			string options = "Current options are:\n";
			OPSHOW(options, "cursor_placedist", "cpd", ftos(player.mplant_cursor_placedist), "forward offset for object creation (from player)");
			OPSHOW(options, "cursor_pushback", "cpb", ftos(player.mplant_cursor_pushback), "push object back this much along surface normal (-1 for auto)");
			OPSHOW(options, "cursor_privatespace", "cps", ftos(player.mplant_cursor_privatespace), "disalow placeing objects closer togetehr then this");
			OPSHOW(options, "cursor_select_maxdistance", "cpd", ftos(player.mplant_cursor_select_maxdistance), "dont select/snap to objects further away then this");

			OPSHOW(options, "random_scale_min", "rsmin", ftos(player.mplant_random_scale_min), "Mininum random scale, for randomized tools");
			OPSHOW(options, "random_scale_max", "rsmax", ftos(player.mplant_random_scale_max), "Maximum random scale, for randomized tools");

			OPSHOW(options, "random_rot_min", "rrmin", vtos(player.mplant_random_rot_min), "Minimum random rotation, for randomized tools");
			OPSHOW(options, "random_rot_max", "rrmax", vtos(player.mplant_random_rot_max), "Maximum random rotation, for randomized tools");

			STATUS(options);
		}
		else
		{
			float i;
			for(i = 1; i < cmd_argc; i += 2)
			{
				dprint("argv(i)", argv(i), " argv(i+1)", argv(i + 1), "\n");
				if (argv(i) == "cursor_placedist" || argv(i) == "cpd")
					player.mplant_cursor_placedist = stof(argv(i + 1));

				if (argv(i) == "cursor_pushback" || argv(i) == "cpb")
					player.mplant_cursor_pushback = stof(argv(i + 1));

				if (argv(i) == "cursor_privatespace" || argv(i) == "cps")
					player.mplant_cursor_privatespace = stof(argv(i + 1));

				if (argv(i) == "cursor_select_maxdistance" || argv(i) == "csmd")
					player.mplant_cursor_select_maxdistance = stof(argv(i + 1));

				if (argv(i) == "random_scale_min" || argv(i) == "rsmin")
					player.mplant_random_scale_min = stof(argv(i + 1));

				if (argv(i) == "random_scale_max" || argv(i) == "rsmax")
					player.mplant_random_scale_max = stof(argv(i + 1));

				if (argv(i) == "random_rot_min" || argv(i) == "rrmin")
					player.mplant_random_rot_min = stov(argv(i + 1));

				if (argv(i) == "random_rot_max" || argv(i) == "rrmax")
					player.mplant_random_rot_max = stov(argv(i + 1));

			}
		}
		return true;
	}

	if (cmd_name == "mplant_rot")
	{
		vector _add = '0 0 0';

		CMDHELP("Set tool rotation.\nUsage: ^3cmd^2 mplant_rot^5 [get|set] [# [# [#]]]\n^'get'^7 tool copy angles of object under cursor.\n'set' apply the rotation, else its added to current rotation.\n");

		if (cmd_argc == 5 && argv(1) == "set")
		{
			player.mplant_cursorobject.pos1_x = bound(-360, stof(argv(2)), 360);
			player.mplant_cursorobject.pos1_y = bound(-360, stof(argv(3)), 360);
			player.mplant_cursorobject.pos1_z = bound(-360, stof(argv(4)), 360);
			return true;
		}

		if (cmd_argc == 1)
		{
			_add = '0 90 0';
		}
		else if (cmd_argc == 2) // x
		{
			if (argv(1) == "get")
			{
				crosshair_trace(player);
				if (_MPLANT_SELECTABLE(trace_ent))
					player.mplant_cursorobject.pos1 = trace_ent.angles;
				else
					STATUS("^3Object under cursor is ^1NOT^3 a mplant object!");
				return true;
			}
			_add_x = stof(argv(1));
		}
		else if (cmd_argc == 3) // x y
		{
			_add_x = stof(argv(1));
			_add_y = stof(argv(2));
		}
		else if (cmd_argc == 4) // x y z
		{
			_add_x = stof(argv(1));
			_add_y = stof(argv(2));
			_add_z = stof(argv(3));
		}

		player.mplant_cursorobject.pos1_x = bound(-360, _add_x + player.mplant_cursorobject.pos1_x, 360);
		player.mplant_cursorobject.pos1_y = bound(-360, _add_y + player.mplant_cursorobject.pos1_y, 360);
		player.mplant_cursorobject.pos1_z = bound(-360, _add_z + player.mplant_cursorobject.pos1_z, 360);

		return true;
	}

	if (cmd_name == "mplant_snap")
	{
		string _snap;
		if (cmd_argc > 1)
		{
			CMDHELP("^2Enable^7 or^3 Disable^7 snapping options\nUsage: ^3cmd ^2mplant_snap^5 [clear] option1 option2 ^2on ^5option3 ^1off^7");

			_snap = "^3 Snap options are now:\n";
#define STRING2FLAG(str,flg) if (argv(i) == str) _bits |= flg
			float i, _bits = 0, _start = 1;
			if (argv(1) == "clear")
			{
				player.mplant_snaptions = 0;
				_start = 2;
			}

			for(i = _start; i < cmd_argc; ++i)
			{
				if (argv(i) == "on" || argv(i) == "1")
				{
					player.mplant_snaptions |= _bits;
					_bits = 0;
				}
				else if (argv(i) == "off" || argv(i) == "0")
				{
					if (_start == 1)
						player.mplant_snaptions &= ~_bits;

					_bits = 0;
				}
				else
				{
					STRING2FLAG("corners", MPS_CORNER);
					STRING2FLAG("sides", MPS_CENTER);
					STRING2FLAG("edges", MPS_EDGE);
					STRING2FLAG("grid", MPS_GRID);
					STRING2FLAG("target-angles", MPS_SRCANGLE);
					STRING2FLAG("tool-angles", MPS_TOOLANGLE);
					STRING2FLAG("surface-angles", MPS_NORMANGLE);
					STRING2FLAG("blocks", MPS_BLOCKS);
				}
			}
		}
		else
			_snap = "^3Current snap options are:\n\n";
#undef STRING2FLAG

#define MPLANT_SNAPCLR(var,test,text) \
	var = strcat(var, ((player.mplant_snaptions & test) ? "^2" : "^1")); \
	var = strcat(var,text)
		MPLANT_SNAPCLR(_snap, MPS_CORNER, "corners\n");
		MPLANT_SNAPCLR(_snap, MPS_CENTER, "sides\n");
		MPLANT_SNAPCLR(_snap, MPS_EDGE, "edges\n");
		MPLANT_SNAPCLR(_snap, MPS_GRID, "grid\n");
		MPLANT_SNAPCLR(_snap, MPS_SRCANGLE, "target-angles\n");
		MPLANT_SNAPCLR(_snap, MPS_TOOLANGLE, "tool-angles\n");
		MPLANT_SNAPCLR(_snap, MPS_NORMANGLE, "surface-angles\n");
		MPLANT_SNAPCLR(_snap, MPS_BLOCKS, "blocks\n");
#undef MPLANT_SNAPCLR

		STATUS(_snap);
		return true;
	}

	if (cmd_name == "mplant_active")
	{
		float _on;
		CMDHELP("^2Enable^7 or^3 Disable^7 ingame editor\nUsage: ^3cmd ^2mplant_active^5 [1|0]");

		if (cmd_argc == 1)
			_on = player.mplant_active ? false : true;
		else
			_on = stof(argv(1));

		mplant_set_buildmode(player, _on);

		return true;
	}

	if (cmd_name == "mplant_clear")
	{
		CMDHELP("Clears all blocks, ^1Cannot^7 be undone!\nUsage: ^3cmd ^2mplant_clear");
		mplant_clear();
	}

	if (cmd_name == "mplant_load")
	{
		CMDHELP("Loads blocks from disc\nUsage: ^3cmd ^2mplant_load ^5[filename]");

		if (cmd_argc == 1)
			mplant_load(player, "");
		else
			mplant_load(player, argv(1));

		return true;
	}

	if (cmd_name == "mplant_save")
	{
		CMDHELP("Saves blocks to disc\nusage: ^3cmd ^2mplant_save ^5[filename]");

		if (cmd_argc == 1)
			mplant_save("");
		else
			mplant_save(argv(1));

		return true;
	}

	if (cmd_name == "mplant_export")
	{
		CMDHELP("Exports blocks as a .map (using misc_models)\nusage: ^3cmd ^2mplant_export ^5[filename]");
		if (cmd_argc == 1)
			mplant_export("");
		else
			mplant_export(argv(1));

		return true;
	}

	if (cmd_name == "mdsave")
	{
		STATUS("cmd mdsave is ^1deprecated^7 and will soon disaper.\nUse ^2mplant_save^7 [filename] insted");
		mplant_save("");
		return true;
	}

	if (cmd_name == "mdload")
	{
		STATUS("cmd mdload is ^1deprecated^7 and will soon disaper.\nUse ^2mplant_load^7 [filename] insted");
		mplant_load(player, "");
		return true;
	}

	if (cmd_name == "mdexport")
	{
		STATUS("cmd mdexport is ^1deprecated^7 and will soon disaper.\nUse ^2mplant_export^7 [filename] insted");
		mplant_export("");
		return true;
	}

	if (cmd_name == "mdclear")
	{
		STATUS("cmd mdclear is ^1deprecated^7 and will soon disaper.\nUse ^2mplant_clear insted");

		return true;
	}

	if (cmd_name == "mdset_next")
	{
		player.mplant_set_index += 1;
		if (player.mplant_set_index >= mplant_set_count)
			player.mplant_set_index = 0;

		mplant_load_dir_models(player, sprintf("models/modelplant%s", bufstr_get(mplant_sets, player.mplant_set_index)));
		mplant_setmark(player, 0);
		return true;
	}

	if (cmd_name == "mdset_prev")
	{
		player.mplant_set_index -= 1;
		if (player.mplant_set_index == 0)
			player.mplant_set_index = mplant_set_count;

		mplant_load_dir_models(player, sprintf("models/modelplant%s", bufstr_get(mplant_sets, player.mplant_set_index)));
		mplant_setmark(player, 0);
		return true;
	}

	if (cmd_name == "mdclean")
	{
		float _rad = 0;

		if (cmd_argc >= 2)
			_rad = stof(argv(1));

		if (_rad < 4)
			_rad = 32;

		mplant_clean(_rad);
		return true;
	}

	return false;

#undef CMDHELP
#undef STATUS
}

MUTATOR_HOOKFUNCTION(mdlplant, BuildMutatorsString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ":MDP");
}

MUTATOR_HOOKFUNCTION(mdlplant, BuildMutatorsPrettyString)
{
	M_ARGV(0, string) = strcat(M_ARGV(0, string), ", Model Planter");
}

MUTATOR_HOOKFUNCTION(mdlplant, FilterItem)
{
	// Items stay?
	if (autocvar_g_modelplanter_withitems)
		return false;

	//entity item = M_ARGV(0, entity);

	// Keep spawnpoints (yo tZork, this is an ITEM hook, not a general spawn hook)
	/*
	if (item.classname == "info_player_deathmatch")
		return false;
	if (item.classname == "info_player_team1")
		return false;
	if (item.classname == "info_player_team2")
		return false;
	if (item.classname == "info_player_team3")
		return false;
	if (item.classname == "info_player_team4")
		return false;
	if (item.classname == "info_player_attacker")
		return false;
	if (item.classname == "info_player_defender")
		return false;
	if (item.classname == "info_player_race")
		return false;*/

	// Get rid of everything else
	return true;
}

MUTATOR_HOOKFUNCTION(mdlplant, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	mplant_set_buildmode(player, player.mplant_active);
}

MUTATOR_HOOKFUNCTION(mdlplant, ClientConnect)
{
	entity player = M_ARGV(0, entity);

	mplant_client_init(player);
}

MUTATOR_HOOKFUNCTION(mdlplant, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	mplant_client_shutdown(player);
}

void mplant_init()
{
	mplant_root = spawn();
	mplant_load_dirs();
	mplant_tool_register("Create",     MPT_PLACE,        mplant_tool_place,   mplant_tool_place_com);
	mplant_tool_register("Rotate",     MPT_ROTATE,       mplant_tool_rotate,  mplant_tool_rotate_com);
	mplant_tool_register("Extrude",    MPT_EXTRUDE,      mplant_tool_extrude, mplant_tool_extrude_com);
	mplant_tool_register("Select",     MPT_MODEL_SELECT, mplant_tool_select,  mplant_tool_select_com);
	mplant_tool_register("Smart tool", MPT_SMART,        mplant_tool_smart,   mplant_tool_smart_com);
	mplant_tool_register("Rubble",     MPT_RUBBLE,       mplant_tool_rubble,  mplant_tool_rubble_com);
}

#undef _SETMODEL

#endif
