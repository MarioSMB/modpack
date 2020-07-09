//FEATURE: Moaning Lescue

REGISTER_NET_TEMP(TE_CSQC_MORNINGRESCUE);

#ifdef CSQC
float autocvar_hud_panel_radar_maximised_zoom_scale = 1;
float mr_appeartime;
float mr_fadetime;

void HUD_MorningRescue()
{
	// vectors for top right, bottom right, bottom and bottom left corners
	vector topright = vec2(vid_conwidth, 0);
	//vector bottom = vec2(vid_conwidth / 2, vid_conheight);
	vector bottomright = vec2(vid_conwidth, vid_conheight);
	vector bottomleft = vec2(0, vid_conheight);

	vector mrpos = bottomleft;
	vector offset = '0 0 0';

	float mralpha = 1 - bound(0, 1 - 2 * (time - mr_appeartime), 1);
	if(mralpha >= 1)
		mralpha = bound(0, 1 - 2 * (time - (mr_fadetime - 1)), 1);

	vector mrcolor = vec2(1, random());
	drawfill('0 0 0', bottomright, mrcolor, mralpha * random(), DRAWFLAG_ADDITIVE);

	mrpos_y -= 200 * mralpha;
	drawpic (mrpos, "gfx/morningrescue", '57 200 0', '1 1 1', mralpha, DRAWFLAG_NORMAL);

	mrpos = topright;
	mrpos_y -= 500 * 0.5 * (1 - mralpha);
	offset_y = 3 * cos(mrpos_y + 5 * time) - 5;
	mrpos_x -= 513 * 0.5;
	offset_x = 3 * cos(mrpos_x + 5 * time) + 5;
	drawpic (mrpos + offset, "gfx/morningrescue2", '513 500 0' * 0.5, '1 1 1', mralpha, DRAWFLAG_NORMAL);

	string mycolor = "";
	const string mrstring = _("^xFB0MMorning ^7Rescue");

	draw_beginBoldFont();

	for(int k = 0; k < 2; ++k)
	{
		mrpos_y = vid_conheight / 2 - 12;
		mrpos_x = 0.5 * (vid_conwidth - 0.6025 * strlennocol(mrstring) * 24);
		for(int j = 0; j < _length(mrstring); ++j)
		{
			string mychar = substring(mrstring, j, 1);

			if(mychar == "^")
			{
				if(substring(mrstring, j+1, 1) == "x")
				{
					mycolor = substring(mrstring, j, 5);
					j += 5;
				}
				else
				{
					mycolor = substring(mrstring, j, 2);
					++j;
				}
				continue;
			}

			offset_y = 10 * ((k*10)+1) * cos(mrpos_x + 3 * time) * ((j % 2)? 1 : -1) * (k? 1 : -1);
			offset_x = offset_y * ((j % 2) ? -1 : 1);
			string resultstr = strcat(mycolor, mychar);

			//dummyfunction(0, 0, 0, 0, 0, 0, 0, 0); // work around DP bug (set OFS_PARAM5 to 0)
			mrpos_x += stringwidth(resultstr, true, '24 24 0');
			drawcolorcodedstring(mrpos + offset, resultstr, '24 24 0', mralpha * 0.8, DRAWFLAG_ADDITIVE);
		}
	}
	
	draw_endBoldFont();
}
#elif defined(SVQC)
void MorningRescue(entity e)
{
	if(e == NULL)
		return;

	int accepted = VerifyClientEntity(e, true, false);

	if(accepted > 0) 
	{
		msg_entity = e;
		WriteHeader(MSG_ONE, TE_CSQC_MORNINGRESCUE);
	}
}
#endif

#ifdef CSQC
const int MAX_QUADRATIC = 25;
vector quadratic_slots[MAX_QUADRATIC];
vector quadratic_dirs[MAX_QUADRATIC];
const float QUADRATIC_SPEED = 150;
const float QUADRATIC_TURNSPEED = 0.35;
const float QUADRATIC_SIZE = 24;
const float QUADRATIC_CHANCE = 0.35;
float quadratic_spawntime, quadratic_fadetime;
bool quadratic;
void HUD_Quadratic()
{
	for(int j = MAX_QUADRATIC - 1; j >= 0; --j)
	{
		vector slot = quadratic_slots[j];
		vector dirs = quadratic_dirs[j];
		float oldz = slot.z;
		if(slot)
			slot += quadratic_dirs[j] * QUADRATIC_SPEED * frametime;
		slot.z = oldz;
		//if(slot.z)
			//slot.z = sin(QUADRATIC_TURNSPEED * M_PI * time);
		if(slot.y > vid_conheight || slot.x > vid_conwidth)
			slot = '0 0 0';

		if(slot == '0 0 0')
		{
			if(time > quadratic_spawntime && random() <= QUADRATIC_CHANCE) // low chance to spawn!
			{
				slot.x = bound(0, (random() * vid_conwidth + 1), vid_conwidth);
				slot.y = bound(0, (random() * vid_conheight + 1), vid_conheight);
				slot.z = 0;
				dirs = vec2(randomvec());
				quadratic_spawntime = time + bound(0.05, random() * 0.5, 0.4); // prevent spawning another one for this amount of time!
			}
		}
		else
		{
			vector splash_size = vec2(QUADRATIC_SIZE, QUADRATIC_SIZE);
			if(time > dirs.z)
			{
				if(random() <= 0.05)
					slot.z = -1;
				else
					slot.z = floor(random() * 9) + 1;
				dirs.z = time + QUADRATIC_TURNSPEED;
			}
			string chosen_number = ((slot.z == -1) ? "NOOB" : ftos(rint(slot.z)));
			draw_beginBoldFont();
			drawcolorcodedstring(vec2(slot), chosen_number, splash_size, 0.95, DRAWFLAG_NORMAL);
			draw_endBoldFont();
		}

		quadratic_slots[j] = slot;
		quadratic_dirs[j] = dirs;
	}
}
#endif

#ifdef SVQC
REGISTER_MUTATOR(sv_morningrescue, true);

MUTATOR_HOOKFUNCTION(sv_morningrescue, SV_ParseServerCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return false;

	string cmd_name = M_ARGV(0, string);

	if(cmd_name == "supermentalrescue")
	{
		FOREACH_CLIENT(true,
		{
			if(IS_REAL_CLIENT(it))
				MorningRescue(it);
			if(IS_PLAYER(it))
			{
				Unfreeze(it, true);

				float hp = GetResource(it, RES_HEALTH);
				if(hp > 0)
					SetResource(it, RES_HEALTH, max(hp, 100));
			}
		});
		return true;
	}
}
#elif defined(CSQC)
bool morningrescue;

STATIC_INIT_LATE(cl_morningrescue_override)
{
	localcmd("\nalias solve_quadratic \"cl_cmd solve_quadratic ${* ?}\"\n");
}

REGISTER_MUTATOR(cl_morningrescue, true);

MUTATOR_HOOKFUNCTION(cl_morningrescue, DrawScoreboard)
{
	return morningrescue;
}

MUTATOR_HOOKFUNCTION(cl_morningrescue, HUD_Draw_overlay)
{
	if(!morningrescue && !quadratic)
		return false;

	if(time <= mr_fadetime && autocvar_hud_panel_radar_maximised_zoom_scale == 1)
	{
		HUD_MorningRescue();
		return true;
	}
	else
		morningrescue = false;

	if(time <= quadratic_fadetime)
	{
		HUD_Quadratic();
		// don't return true, we want regular HUD effects!
	}
	else
		quadratic = false;

	return false;
}

MUTATOR_HOOKFUNCTION(cl_morningrescue, CSQC_ConsoleCommand)
{
	if(MUTATOR_RETURNVALUE) // command was already handled?
		return;

	string cmd_name = M_ARGV(0, string);
	//int cmd_argc = M_ARGV(2, int);

	if(cmd_name == "solve_quadratic")
	{
		quadratic = true;
		quadratic_fadetime = time + 5;
		return true;
	}
}

NET_HANDLE(TE_CSQC_MORNINGRESCUE, bool isNew)
{
	return = true;

	if(morningrescue)
		return;

	localcmd("play2 sound/misc/morningrescue\n");
	morningrescue = true;
	mr_appeartime = time;
	mr_fadetime = time + 9;
}
#endif