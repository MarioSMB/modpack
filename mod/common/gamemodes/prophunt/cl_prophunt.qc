#include "cl_prophunt.qh"

REGISTER_MUTATOR(cl_ph, true);

void HUD_HunterEyes()
{
	vector screenVector = vec2(vid_conwidth, vid_conheight);
	drawfill('0 0 0', screenVector, '0.01 0.01 0.01', 1, DRAWFLAG_NORMAL);

	draw_beginBoldFont();
	vector pos = screenVector * 0.5;
	string s = _("Round will start soon, no peeking!");
	pos.x -= stringwidth_colors(s, hud_fontsize) * 0.5;
	drawstring(pos, s, hud_fontsize, '1 1 1', 1, DRAWFLAG_NORMAL);
	draw_endBoldFont();
}

MUTATOR_HOOKFUNCTION(cl_ph, HUD_Draw_overlay)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	bool inround = (STAT(ROUNDSTARTTIME) != -1 && time < STAT(ROUNDSTARTTIME));

	if(myteam != NUM_SPECTATOR && (myteam + 1) != STAT(PROPHUNT_PROPTEAM) && !warmup_stage && inround)
		HUD_HunterEyes();
}

MUTATOR_HOOKFUNCTION(cl_ph, DrawInfoMessages)
{
	return (ISGAMETYPE(PROPHUNT) && entcs_GetSpecState(player_localnum) == ENTCS_SPEC_IN_SCOREBOARD);
}

MUTATOR_HOOKFUNCTION(cl_ph, ForcePlayercolors_Skip)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	// let's keep things simple
	return true;
}

MUTATOR_HOOKFUNCTION(cl_ph, TagIndex_Update)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	entity player = M_ARGV(0, entity);

	if(!(player.isplayermodel & ISPLAYER_PLAYER))
		return;

	if(!(player.isplayermodel & ISPLAYER_MODEL))
	{
		player.glowmod = '0 0 0';
		player.colormap = 0;
	}
	else
	{
		entity e = entcs_receiver(player.entnum - 1);
		if(e && e.colormap)
		{
			player.colormap = 1024 + e.colormap;
			if(player.colormap > 0)
				player.glowmod = colormapPaletteColor(((player.colormap >= 1024) ? player.colormap : entcs_GetClientColors(player.colormap - 1)) & 0x0F, true);
			else
				player.glowmod = '1 1 1';
		}
	}
}

MUTATOR_HOOKFUNCTION(cl_ph, ForcePlayermodels_Skip)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	// let's keep things simple
	return true;
}

MUTATOR_HOOKFUNCTION(cl_ph, ShowNames_Draw)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	// let's keep things simple
	return true;
}

MUTATOR_HOOKFUNCTION(cl_ph, CustomizeEventchase)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	entity player = M_ARGV(0, entity);

	if(spectatee_status)
		player = CSQCModel_server2csqc(player_localentnum - 1);

	if(!(player.isplayermodel & ISPLAYER_MODEL))
	{
		M_ARGV(0, vector) = player.origin;
		M_ARGV(1, vector) = '0 0 1' * (player.maxs_z * 0.9);
		M_ARGV(0, float) = max(100, vlen(player.mins - player.maxs) * 0.5);
		return true;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(cl_ph, WantEventchase)
{
	if(!ISGAMETYPE(PROPHUNT))
		return false;

	entity player = M_ARGV(0, entity);
	if(spectatee_status)
	{
		player = CSQCModel_server2csqc(player_localentnum - 1);
		return !(player.isplayermodel & ISPLAYER_MODEL);
	}
	// TODO? may play better to only force 3rd person when actually hiding!
	//(player.isplayermodel & ISPLAYER_MODEL)
	return (player.team == STAT(PROPHUNT_PROPTEAM));
}

void HUD_Mod_PH_Draw(vector myPos, vector mySize, int layout)
{
	int rows, columns;
	float aspect_ratio;
	aspect_ratio = (layout) ? 2 : 1;
	rows = HUD_GetRowCount(team_count, mySize, aspect_ratio);
	columns = ceil(team_count/rows);

	int i;
	float row = 0, column = 0;
	vector pos = '0 0 0', itemSize;
	itemSize = vec2(mySize.x / columns, mySize.y / rows);
	for(i=0; i<team_count; ++i)
	{
		pos.x = myPos.x + column * itemSize.x;
		pos.y = myPos.y + row * itemSize.y;

		DrawCAItem(pos, itemSize, aspect_ratio, layout, i);

		++row;
		if(row >= rows)
		{
			row = 0;
			++column;
		}
	}
}

// Prop Hunt HUD modicons
void HUD_Mod_PH(vector myPos, vector mySize)
{
	mod_active = 1; // required in each mod function that always shows something

	HUD_Mod_PH_Draw(myPos, mySize, autocvar_hud_panel_modicons_ca_layout);
}
