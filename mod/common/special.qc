REGISTER_NET_TEMP(TE_CSQC_MORNINGRESCUE);

#ifdef CSQC
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
				Unfreeze(it);

				float hp = GetResourceAmount(it, RESOURCE_HEALTH);
				if(hp > 0)
					SetResourceAmount(it, RESOURCE_HEALTH, max(hp, 100));
			}
		});
		return true;
	}
}
#elif defined(CSQC)
bool morningrescue;

REGISTER_MUTATOR(cl_morningrescue, true);

MUTATOR_HOOKFUNCTION(cl_morningrescue, DrawScoreboard)
{
	return morningrescue;
}

MUTATOR_HOOKFUNCTION(cl_morningrescue, HUD_Draw_overlay)
{
	if(!morningrescue)
		return false;

	if(time <= mr_fadetime)
	{
		HUD_MorningRescue();
		return true;
	}
	else
		morningrescue = false;

	return false;
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