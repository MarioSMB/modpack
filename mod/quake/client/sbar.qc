//float autocvar_r_letterbox;
//int autocvar_cl_prydoncursor;
int autocvar_cl_deathscoreboard;
//float autocvar_sbar_alpha_bg;
string autocvar_cl_worldbasename;
string autocvar_cl_worldmessage;
float autocvar_sbar_alpha_fg;
float autocvar_scr_viewsize;

vector HUD_GetFontSize(string cvarname)
{
	vector v = vec2(stov(cvar_string(cvarname)));
	if(v.x == 0)
		v = '8 8 0';
	if(v.y == 0)
		v.y = v.x;
	return v;
}

vector sbar;
int sb_lines;

float deathmatch;
float coop;

const int SBAR_HEIGHT = 24;

void Sbar_DrawString(int dx, int dy, string msg)
{
	drawstring(sbar + vec2(dx, dy), msg, HUD_GetFontSize("hud_fontsize"), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_SoloScoreboard()
{
	float t = (intermission ? completed_time : time);
	//int minutes = rint(t / 60);
	//int seconds = rint(t - 60*floor(t/60));

	// monsters and secrets are now both on the top row
	if (getstati(STAT_TOTALMONSTERS))
		Sbar_DrawString(8, 4, sprintf("Monsters:%d /%d", getstati(STAT_MONSTERS), getstati(STAT_TOTALMONSTERS)));
	else if (getstati(STAT_MONSTERS)) // LA: Display something if monsters_killed is non-zero, but total_monsters is zero
		Sbar_DrawString(8, 4, sprintf("Monsters:%d", getstati(STAT_MONSTERS)));

	if (getstati(STAT_TOTALSECRETS))
		Sbar_DrawString(8+22*8, 4, sprintf("Secrets:%d /%d", getstati(STAT_SECRETS), getstati(STAT_TOTALSECRETS)));
	else if (getstati(STAT_SECRETS)) // LA: And similarly for secrets
		Sbar_DrawString(8+22*8, 4, sprintf("Secrets:%d", getstati(STAT_SECRETS)));

	// format is like this: e1m1:The Sligpate Complex
	string worldstr = sprintf("%s:%s", autocvar_cl_worldbasename, autocvar_cl_worldmessage);

	// if there's a newline character, terminate the string there
	//if (strchr(worldstr, '\n'))
	//	*(strchr(worldstr, '\n')) = 0;

	// make the time string
	string timestr = seconds_tostring(t);
	float timelen = strlen(timestr);

	// truncate the level name if necessary to make room for time
	int maxlen = 38 - timelen;

	float worldlen = strlen(worldstr);
	if(worldlen > maxlen)
		worldstr = substring(worldstr, 0, worldlen - (maxlen - worldlen));

	// print the filename and message
	Sbar_DrawString(8, 12, worldstr);

	// print the time
	Sbar_DrawString(8 + maxlen*8, 12, timestr);
}

void Sbar_DrawScoreboard()
{
	Sbar_SoloScoreboard();
	// LordHavoc: changed to draw the deathmatch overlays in any multiplayer mode
	//if (deathmatch)
		//Sbar_DeathmatchOverlay();
}

void Sbar_Draw()
{
	if(!getproperty(VF_DRAWENGINESBAR)) // drawing in engine turned off, fall back to qc implementation
	{
		// intermission is always full screen
		if (intermission)
			sb_lines = 0;
		else
		{
			if (autocvar_scr_viewsize >= 120)
				sb_lines = 0;		// no status bar at all
			else if (autocvar_scr_viewsize >= 110)
				sb_lines = 24;		// no inventory
			else
				sb_lines = 24+16+8;
		}

		if (sb_showscores)
			Sbar_DrawScoreboard();
		//else if (cl.intermission == 1)
			//Sbar_IntermissionOverlay();
		//else if (cl.intermission == 2)
			//Sbar_FinaleOverlay();
		else // Quake
		{
			sbar.x = (autocvar_vid_conwidth - 320)/2;
			sbar.y = autocvar_vid_conheight - SBAR_HEIGHT;

			if (sb_lines > 24)
			{
				//Sbar_DrawInventory();
				//if (deathmatch)
					//Sbar_DrawFrags();
			}

			if (sb_showscores || (getstatf(STAT_HEALTH) <= 0 && autocvar_cl_deathscoreboard))
			{
				//Sbar_DrawAlphaPic (0, 0, sb_scorebar, autocvar_sbar_alpha_bg);
				//Sbar_DrawScoreboard();
			}
			else if (sb_lines)
			{
				//Sbar_DrawAlphaPic (0, 0, sb_sbar, autocvar_sbar_alpha_bg);

				// keys (hipnotic only)
				//MED 01/04/97 moved keys here so they would not be overwritten
			#if 0
				if (gamemode == GAME_HIPNOTIC || gamemode == GAME_QUOTH)
				{
					if (getstati(STAT_ITEMS) & IT_KEY1)
						Sbar_DrawPic (209, 3, sb_items[0]);
					if (getstati(STAT_ITEMS) & IT_KEY2)
						Sbar_DrawPic (209, 12, sb_items[1]);
				}
			#endif
				// armor
				if (getstati(STAT_ITEMS) & BIT(20)) // IT_INVULNERABILITY
				{
					//Sbar_DrawNum (24, 0, 666, 3, 1);
					//Sbar_DrawPic (0, 0, sb_disc);
				}
				else
				{
				#if 0
					if (gamemode == GAME_ROGUE)
					{
						Sbar_DrawNum (24, 0, getstatf(STAT_ARMOR), 3, getstatf(STAT_ARMOR) <= 25);
						if (getstati(STAT_ITEMS) & RIT_ARMOR3)
							Sbar_DrawPic (0, 0, sb_armor[2]);
						else if (getstati(STAT_ITEMS) & RIT_ARMOR2)
							Sbar_DrawPic (0, 0, sb_armor[1]);
						else if (getstati(STAT_ITEMS) & RIT_ARMOR1)
							Sbar_DrawPic (0, 0, sb_armor[0]);
					}
					else
					{
				#endif
						//Sbar_DrawNum (24, 0, getstatf(STAT_ARMOR), 3, getstatf(STAT_ARMOR) <= 25);
						//if (getstati(STAT_ITEMS) & IT_ARMOR3)
						//	Sbar_DrawPic (0, 0, sb_armor[2]);
						//else if (getstati(STAT_ITEMS) & IT_ARMOR2)
					//		Sbar_DrawPic (0, 0, sb_armor[1]);
					//	else if (getstati(STAT_ITEMS) & IT_ARMOR1)
					//		Sbar_DrawPic (0, 0, sb_armor[0]);
					//}
				}

				// face
				//Sbar_DrawFace();

				// health
				//Sbar_DrawNum(136, 0, getstatf(STAT_HEALTH), 3, getstatf(STAT_HEALTH) <= 25);

				// ammo icon
			#if 0
				if (gamemode == GAME_ROGUE)
				{
					if (getstati(STAT_ITEMS) & RIT_SHELLS)
						Sbar_DrawPic (224, 0, sb_ammo[0]);
					else if (getstati(STAT_ITEMS) & RIT_NAILS)
						Sbar_DrawPic (224, 0, sb_ammo[1]);
					else if (getstati(STAT_ITEMS) & RIT_ROCKETS)
						Sbar_DrawPic (224, 0, sb_ammo[2]);
					else if (getstati(STAT_ITEMS) & RIT_CELLS)
						Sbar_DrawPic (224, 0, sb_ammo[3]);
					else if (getstati(STAT_ITEMS) & RIT_LAVA_NAILS)
						Sbar_DrawPic (224, 0, rsb_ammo[0]);
					else if (getstati(STAT_ITEMS) & RIT_PLASMA_AMMO)
						Sbar_DrawPic (224, 0, rsb_ammo[1]);
					else if (getstati(STAT_ITEMS) & RIT_MULTI_ROCKETS)
						Sbar_DrawPic (224, 0, rsb_ammo[2]);
				}
				else
			#endif
				//{
					//if (getstati(STAT_ITEMS) & IT_SHELLS)
					//	Sbar_DrawPic (224, 0, sb_ammo[0]);
					//else if (getstati(STAT_ITEMS) & IT_NAILS)
				//		Sbar_DrawPic (224, 0, sb_ammo[1]);
				//	else if (getstati(STAT_ITEMS) & IT_ROCKETS)
				//		Sbar_DrawPic (224, 0, sb_ammo[2]);
				//	else if (getstati(STAT_ITEMS) & IT_CELLS)
				//		Sbar_DrawPic (224, 0, sb_ammo[3]);
				//}

				//Sbar_DrawNum (248, 0, getstatf(STAT_AMMO), 3, getstatf(STAT_AMMO) <= 10);

				// LordHavoc: changed to draw the deathmatch overlays in any multiplayer mode
				if (deathmatch || coop)
				{
				//	Sbar_MiniDeathmatchOverlay (sbar.x + 324, autocvar_vid_conheight - 8*8);
				//	Sbar_Score(24);
				}
			}
		}
	}

	//if (autocvar_cl_prydoncursor > 0)
		//draw_cursor_normal(mousepos, '1 1 1', 0.8);
}