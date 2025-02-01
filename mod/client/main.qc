#include "oregon.qh"

STATIC_INIT(mod_cvars)
{
	localcmd("set hud_panel_minigamemenu 1\n");
}

string mod_scoreboard_getname(entity pl)
{
	string pname = entcs_GetName(pl.sv_entnum);
	string dcname = strtolower(strdecolorize(pname));

	if(ready_waiting && pl.ready)
		sbt_field_icon0 = "gfx/scoreboard/player_ready";
	else if(strstrofs(dcname, "antibody", 0) >= 0)
	{
		int f = entcs_GetClientColors(pl.sv_entnum);
		sbt_field_icon0 = "gfx/menu/luma/icon_mod_newtoys";
		sbt_field_icon0_rgb = colormapPaletteColor(f % 16, 1);
	}
	else if(!teamplay)
	{
		int f = entcs_GetClientColors(pl.sv_entnum);
		sbt_field_icon0 = "gfx/scoreboard/playercolor_base";
		sbt_field_icon1 = "gfx/scoreboard/playercolor_shirt";
		sbt_field_icon1_rgb = colormapPaletteColor(floor(f / 16), 0);
		sbt_field_icon2 = "gfx/scoreboard/playercolor_pants";
		sbt_field_icon2_rgb = colormapPaletteColor(f % 16, 1);
	}
	return pname;
}

STATIC_INIT_LATE(mod_cvars_override)
{
	localcmd("\nset hud_panel_quickmenu_file quickmenu.txt\n");

	localcmd("\nalias itemlist \"cl_cmd itemlist ${* ?}\"\n");
	localcmd("\nalias bufflist \"cl_cmd bufflist ${* ?}\"\n");
	localcmd("\nalias place_item \"cmd placeitem spawn ${* ?}\"\n");
	localcmd("\nalias itemplacer \"cmd placeitem ${* ?}\"\n");
	localcmd("\nalias placeitems \"cl_cmd placeitems ${* ?}\"\n");
	localcmd("\nalias propedit \"cl_cmd propedit ${* ?}\"\n");
	localcmd("\nalias oregon \"cl_cmd oregon ${* ?}\"\n");

	localcmd("\nalias findmap \"cmd findmap ${* ?}\"\n");

	localcmd("\nalias snap \"cmd snap ${* ?}\"\n");
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}

MUTATOR_HOOKFUNCTION(mutator_mod, BuildGameplayTipsString, CBC_ORDER_LAST)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), "\n\n ^7Running the SMB mod pack\n^3https://github.com/MarioSMB/modpack");
}

MUTATOR_HOOKFUNCTION(mutator_mod, CSQC_ConsoleCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	string cmd_name = M_ARGV(0, string);
	//int cmd_argc = M_ARGV(2, int);

	if(cmd_name == "itemlist")
	{
		LOG_INFO("Available items: ");
		FOREACH(Items, true,
		{
			LOG_INFO("    ", it.netname, " (", it.m_name, "^7)");
		});
		return true;
	}

	if(cmd_name == "bufflist")
	{
		LOG_INFO("Buffs:");
		FOREACH(StatusEffects, it.instanceOfBuff,
		{
			LOG_INFO("    ", it.netname, " (", BUFF_NAME(it.m_id), "^7)");
		});
		return true;
	}

	if(cmd_name == "placeitems")
	{
		localcmd("\ncl_cmd hud quickmenu file \"\" placeitems.txt\n");
		return true;
	}

	if(cmd_name == "propedit")
	{
		localcmd("\ncl_cmd hud quickmenu file \"\" props.txt\n");
		return true;
	}

	if(cmd_name == "oregon")
	{
		Oregon_HandleCommand(argv(1));
		return true;
	}
}
