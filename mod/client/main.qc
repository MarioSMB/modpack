STATIC_INIT(mod_cvars)
{
	localcmd("set hud_panel_minigamemenu 1\n");
}

string mod_scoreboard_getname(entity pl)
{
	string pname = entcs_GetName(pl.sv_entnum);
	string dcname = strtolower(strdecolorize(pname));

	if(strstrofs(dcname, "antibody", 0) >= 0)
	{
		int f = entcs_GetClientColors(pl.sv_entnum);
		sbt_field_icon0 = "gfx/menu/luma/icon_mod_newtoys";
		sbt_field_icon0_rgb = colormapPaletteColor(f % 16, 1);
	}
	else if(ready_waiting && pl.ready)
		sbt_field_icon0 = "gfx/scoreboard/player_ready";
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

	localcmd("\nalias ignore \"cmd ignore ${* ?}\"\n");
	localcmd("\nalias unignore \"cmd unignore ${* ?}\"\n");
}

REGISTER_MUTATOR(mutator_mod, true);

MUTATOR_HOOKFUNCTION(mutator_mod, BuildMutatorsString)
{
    M_ARGV(0, string) = strcat(M_ARGV(0, string), ":mod");
}
