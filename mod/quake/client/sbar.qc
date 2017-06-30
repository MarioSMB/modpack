#define MP_ROGUE 0
#define MP_HIPNOTIC 0

//float autocvar_r_letterbox;
//int autocvar_cl_prydoncursor;
int autocvar_cl_deathscoreboard;
float autocvar_sbar_alpha_bg;
string autocvar_cl_worldbasename;
string autocvar_cl_worldmessage;
float autocvar_sbar_alpha_fg;
float autocvar_scr_viewsize;
bool autocvar_sbar_gametime;
bool autocvar_sbar_scorerank;
float autocvar_sbar_miniscoreboard_size;

string Sbar_PickWeapon_wepname(int wpn)
{
	switch(wpn)
	{
		default:
		case 0: return "shotgun";
		case 1: return "sshotgun";
		case 2: return "nailgun";
		case 3: return "snailgun";
		case 4: return "rlaunch";
		case 5: return "srlaunch";
		case 6: return "lightng";
	}
}

void Sbar_Precache()
{
	precache_pic("gfx/ranking");
	precache_pic("gfx/sbar");
	precache_pic("gfx/scorebar");
	precache_pic("gfx/complete");
	precache_pic("gfx/finale");
	precache_pic("gfx/inter");

	precache_pic("gfx/face_invis");
	precache_pic("gfx/face_invul2");
	precache_pic("gfx/face_inv2");
	precache_pic("gfx/face_quad");

	precache_pic("gfx/sbar");
	precache_pic("gfx/ibar");

#if MP_ROGUE
	precache_pic("gfx/r_invbar1");
	precache_pic("gfx/r_invbar2");
#endif

	for(int j = 0; j < 5; j++)
	{
		for(int k = 0; k < 7; k++)
		{
			precache_pic(sprintf("gfx/inva%d_%s", j + 1, Sbar_PickWeapon_wepname(k)));
		}
	}

	for(int j = 0; j < 10; j++)
	{
		precache_pic(strcat("gfx/num_", itos(j)));
		precache_pic(strcat("gfx/anum_", itos(j)));
	}

	precache_pic("gfx/num_minus");
	precache_pic("gfx/anum_minus");
	precache_pic("gfx/num_slash");
	precache_pic("gfx/num_colon");

	precache_pic("gfx/face1");
	precache_pic("gfx/face_p1");
	precache_pic("gfx/face2");
	precache_pic("gfx/face_p2");
	precache_pic("gfx/face3");
	precache_pic("gfx/face_p3");
	precache_pic("gfx/face4");
	precache_pic("gfx/face_p4");
	precache_pic("gfx/face5");
	precache_pic("gfx/face_p5");

	precache_pic("gfx/sb_sigil1");
	precache_pic("gfx/sb_sigil2");
	precache_pic("gfx/sb_sigil3");
	precache_pic("gfx/sb_sigil4");

	precache_pic("gfx/sb_key1");
	precache_pic("gfx/sb_key2");
	precache_pic("gfx/sb_invis");
	precache_pic("gfx/sb_invuln");
	precache_pic("gfx/sb_suit");
	precache_pic("gfx/sb_quad");

	precache_pic("gfx/disc");

	precache_pic("gfx/sb_armor1");
	precache_pic("gfx/sb_armor2");
	precache_pic("gfx/sb_armor3");

	precache_pic("gfx/sb_shells");
	precache_pic("gfx/sb_nails");
	precache_pic("gfx/sb_rocket");
	precache_pic("gfx/sb_cells");
}

string Sbar_PickWeapon_inva(int cnum)
{
	switch(cnum)
	{
		default:
		case 2: return "inva1";
		case 3: return "inva2";
		case 4: return "inva3";
		case 5: return "inva4";
		case 6: return "inva5";
	}
}

string Sbar_PickWeapon(int cnum, int wpn)
{
	string prefix = ((cnum == 0) ? "inv" : ((cnum == 1) ? "inv2" : Sbar_PickWeapon_inva(cnum)));
	return sprintf("gfx/%s_%s", prefix, Sbar_PickWeapon_wepname(wpn));
}

string Sbar_PickFace(int frm, bool washurt)
{
	switch(frm)
	{
		default:
		case 4: return ((washurt) ? "gfx/face_p1" : "gfx/face1");
		case 3: return ((washurt) ? "gfx/face_p2" : "gfx/face2");
		case 2: return ((washurt) ? "gfx/face_p3" : "gfx/face3");
		case 1: return ((washurt) ? "gfx/face_p4" : "gfx/face4");
		case 0: return ((washurt) ? "gfx/face_p5" : "gfx/face5");
	}
}

string Sbar_PickSigil(int frm)
{
	switch(frm)
	{
		default:
		case 0: return "gfx/sb_sigil1";
		case 1: return "gfx/sb_sigil2";
		case 2: return "gfx/sb_sigil3";
		case 3: return "gfx/sb_sigil4";
	}
}

string Sbar_PickItem(int frm)
{
	switch(frm)
	{
		default:
		case 0: return "gfx/sb_key1";
		case 1: return "gfx/sb_key2";
		case 2: return "gfx/sb_invis";
		case 3: return "gfx/sb_invuln";
		case 4: return "gfx/sb_suit";
		case 5: return "gfx/sb_quad";
	}
}

string Sbar_PickNum(bool col, string frm)
{
	return sprintf("gfx/%snum_%s", ((col) ? "a" : ""), frm);
}

vector sbar;
int sb_lines;

const int SBAR_HEIGHT = 24;
const int SBAR_MAXWIDTH = 1; // TODO: this is pure guesswork!

void Sbar_DrawString(int dx, int dy, string msg)
{
	drawstring(sbar + vec2(dx + 4, dy), msg, '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_DrawCharacter(int dx, int dy, int num)
{
	Sbar_DrawString(dx, dy, sprintf("%c", num));
}

void Sbar_DrawAlphaPic(int dx, int dy, string pic, float thealpha)
{
	drawpic(sbar + vec2(dx, dy), pic, drawgetimagesize(pic), '1 1 1', thealpha, DRAWFLAG_NORMAL);
}

void Sbar_DrawPic(int dx, int dy, string pic)
{
	Sbar_DrawAlphaPic(dx, dy, pic, 1 * autocvar_sbar_alpha_fg);
}

const int STAT_MINUS = 10; // num frame for '-' stats digit
void Sbar_DrawNum_lettersize(int dx, int dy, string num, int digits, bool thecolor, int lettersize, vector letterscale)
{
	int numlen = strlen(num);
	if(numlen < digits)
		dx += (digits - numlen) * lettersize;

	FOREACH_CHAR(num, true,
	{
		string theframe;
		if(it == '-')
			theframe = "minus";
		else if(it == ':')
			theframe = "colon";
		else
			theframe = chr2str(it);
		string thepic = Sbar_PickNum(thecolor, theframe);
		if(!letterscale)
			Sbar_DrawPic(dx, dy, thepic);
		else
			drawpic(sbar + vec2(dx, dy), thepic, letterscale, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		dx += lettersize;
	});
}

void Sbar_DrawNum(int dx, int dy, string num, int digits, bool thecolor)
{
	Sbar_DrawNum_lettersize(dx, dy, num, digits, thecolor, 24, '0 0 0');
}

void Sbar_DrawXNum(int dx, int dy, int num, int digits, int lettersize, vector col)
{
	string l;
	if(digits < 0)
	{
		digits = -digits;
		l = sprintf("%0*d", digits, num);
	}
	else
		l = sprintf("%d", num);

	int numlen = strlen(l);
	if(numlen < digits)
		dx += (digits - numlen) * lettersize;

	FOREACH_CHAR(l, true,
	{
		string theframe;
		if(it == '-')
			theframe = "minus";
		else if(it == ':')
			theframe = "colon";
		else
			theframe = chr2str(it);
		drawpic(sbar + vec2(dx, dy), Sbar_PickNum(false, theframe), vec2(lettersize, lettersize), col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		dx += lettersize;
	});
}

/*
===============
Sbar_SortFrags
===============
*/
int fragsort[255];
int scoreboardlines;

void Sbar_SortFrags()
{
	// sort by frags
	scoreboardlines = 0;
	for(int j = 0; j < maxclients; j++)
	{
		if(getplayerkeyvalue(j, "name"))
		{
			fragsort[scoreboardlines] = j;
			scoreboardlines++;
		}
	}

	for(int k = 0; k < scoreboardlines; k++)
	{
		for(int j = 0; j < scoreboardlines - 1 - k; j++)
		{
			int ffs = stof(getplayerkeyvalue(j, "frags"));
			int ff2 = stof(getplayerkeyvalue(j + 1, "frags"));
			if(ffs < ff2)
			{
				k = fragsort[j];
				fragsort[j] = fragsort[j + 1];
				fragsort[j + 1] = k;
			}
		}
	}
}

/*
===============
Sbar_SoloScoreboard
===============
*/
void Sbar_SoloScoreboard()
{
	float t = (intermission ? completed_time : time);
	//int minutes = rint(t / 60);
	//int seconds = rint(t - 60*floor(t/60));

	// monsters and secrets are now both on the top row
	if(getstati(STAT_TOTALMONSTERS))
		Sbar_DrawString(8, 4, sprintf("Monsters:%3d /%d", getstati(STAT_MONSTERS), getstati(STAT_TOTALMONSTERS)));
	else if(getstati(STAT_MONSTERS)) // LA: Display something if monsters_killed is non-zero, but total_monsters is zero
		Sbar_DrawString(8, 4, sprintf("Monsters:%3d", getstati(STAT_MONSTERS)));

	if(getstati(STAT_TOTALSECRETS))
		Sbar_DrawString(8+22*8, 4, sprintf("Secrets:%3d /%3d", getstati(STAT_SECRETS), getstati(STAT_TOTALSECRETS)));
	else if(getstati(STAT_SECRETS)) // LA: And similarly for secrets
		Sbar_DrawString(8+22*8, 4, sprintf("Secrets:%3d", getstati(STAT_SECRETS)));

	// format is like this: e1m1:The Sligpate Complex
	string worldstr = sprintf("%s:%s", autocvar_cl_worldbasename, autocvar_cl_worldmessage);
	worldstr = strreplace("\n", "", worldstr); // if there's a newline character, terminate the string there

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

/*
==================
Sbar_DeathmatchOverlay

==================
*/
float Sbar_PrintScoreboardItem(int fscore, float dx, float dy)
{
	bool myself = false;
	float thescore = stof(getplayerkeyvalue(fscore, "frags"));

	if(fscore == player_localnum) // - 1 or + 1, idk
		myself = true;

	// draw colors behind score
	vector thecolor;
	vector pos;

	thecolor = stov(getplayerkeyvalue(fscore, "bottomcolor"));
	pos = vec2(dx + 9 * 8 * SBAR_MAXWIDTH, dy + 1);
	drawfill(pos, vec2(40 * SBAR_MAXWIDTH, 3), thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	thecolor = stov(getplayerkeyvalue(fscore, "topcolor"));
	pos = vec2(dx + 9 * 8 * SBAR_MAXWIDTH, dy + 4);
	drawfill(pos, vec2(40 * SBAR_MAXWIDTH, 3), thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// print the text
	float theping = stof(getplayerkeyvalue(fscore, "ping"));
	float thepl = stof(getplayerkeyvalue(fscore, "pl"));
	string thename = getplayerkeyvalue(fscore, "name");
	if(theping || thepl)
		drawcolorcodedstring2(vec2(dx, dy), sprintf("%4d %3d %5d %c%s", bound(0, theping, 9999), bound(0, thepl, 99), thescore, ((myself) ? 13 : ' '), thename), '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	else
		drawcolorcodedstring2(vec2(dx, dy), sprintf("         %5d %c%s", thescore, ((myself) ? 13 : ' '), thename), '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	return 8;
}

/*
==================
Sbar_MiniDeathmatchOverlay

==================
*/
void Sbar_MiniDeathmatchOverlay(int dx, int dy)
{
	// do not draw this if sbar_miniscoreboard_size is zero
	if(autocvar_sbar_miniscoreboard_size == 0)
		return;
	// adjust the given dy if sbar_miniscoreboard_size doesn't indicate default (< 0)
	if(autocvar_sbar_miniscoreboard_size > 0)
		dy = (autocvar_vid_conheight - autocvar_sbar_miniscoreboard_size * 8);

	// scores
	Sbar_SortFrags();

	// decide where to print
	int numlines = (autocvar_vid_conheight - dy + 7) / 8;

	// give up if there isn't room
	if(dx >= autocvar_vid_conwidth || dy >= autocvar_vid_conheight || numlines < 1)
		return;

	//find us
	int found;
	for(found = 0; found < scoreboardlines; found++)
	{
		if(fragsort[found] == player_localnum) // was - 1
			break;
	}

	int range_begin = 0;
	int range_end = scoreboardlines;

	// figure out start
	found -= numlines/2;
	found = min(found, range_end - numlines);
	found = max(found, range_begin);

	if(range_end - found < numlines) // won't draw to bottom?
	{
		dy += 8 * (numlines - (range_end - found)); // bottom align
		dy -= 8; // text size (b0rked)
	}

	for(; found < range_end && dy < autocvar_vid_conheight; found++)
	{
		dy += Sbar_PrintScoreboardItem(fragsort[found], dx, dy);
	}
}

void Sbar_Score(int margin)
{
	vector sbar_save = sbar;

	sbar.y = (autocvar_vid_conheight - (32 + 12));
	sbar.x -= margin;

	int me = player_localnum; // was -1
	if(autocvar_sbar_scorerank && me >= 0 && me < maxclients)
	{
		// Layout:
		//
		//   leading  place
		//
		//        FRAGS
		//
		// find leading score other than ourselves, to calculate distribution
		// find our place in the scoreboard
		int score = stoi(getplayerkeyvalue(me, "frags"));
		int j = 0, otherleader = -1, place = 1;
		for(j = 0, otherleader = -1, place = 1; j < maxclients; j++)
		{
			if(getplayerkeyvalue(j, "name") && j != me)
			{
				int ts = stoi(getplayerkeyvalue(j, "frags"));
				if(otherleader == -1 || ts > stoi(getplayerkeyvalue(otherleader, "frags")))
					otherleader = j;
				if(score < ts || (score == ts && j < me))
					place++;
			}
		}
		int distribution = otherleader >= 0 ? score - stoi(getplayerkeyvalue(otherleader, "frags")) : 0;
		if(place == 1)
			Sbar_DrawXNum(-3*12, -12, place, 3, 12, '1 1 1');
		else if(place == 2)
			Sbar_DrawXNum(-3*12, -12, place, 3, 12, '1 1 0');
		else
			Sbar_DrawXNum(-3*12, -12, place, 3, 12, '1 0 0');
		if(otherleader < 0)
			Sbar_DrawXNum(-32*4,   0, score, 4, 32, '1 1 1');
		if(distribution >= 0)
		{
			Sbar_DrawXNum(-7*12, -12, distribution, 4, 12, '1 1 1');
			Sbar_DrawXNum(-32*4,   0, score, 4, 32, '1 1 1');
		}
		else if(distribution >= -5)
		{
			Sbar_DrawXNum(-7*12, -12, distribution, 4, 12, '1 1 0');
			Sbar_DrawXNum(-32*4,   0, score, 4, 32, '1 1 0');
		}
		else
		{
			Sbar_DrawXNum(-7*12, -12, distribution, 4, 12, '1 0 0');
			Sbar_DrawXNum(-32*4,   0, score, 4, 32, '1 0 0');
		}
	}

	if(autocvar_sbar_gametime && STAT(TIMELIMIT))
	{
	#if 0
		float timeleft = max(0, STAT(TIMELIMIT) * 60 - time);
		int minutes = (int)floor(timeleft / 60);
		int seconds = (int)(floor(timeleft) - minutes * 60);
		if(minutes >= 5)
		{
			Sbar_DrawXNum(-12*6, 32, minutes,  3, 12, 1, 1, 1, 1, 0);
			if(sb_colon && sb_colon->tex != r_texture_notexture)
				DrawQ_Pic(sbar_x + -12*3, sbar_y + 32, sb_colon, 12, 12, 1, 1, 1, sbar_alpha_fg.value, 0);
			Sbar_DrawXNum(-12*2, 32, seconds, -2, 12, 1, 1, 1, 1, 0);
		}
		else if(minutes >= 1)
		{
			Sbar_DrawXNum(-12*6, 32, minutes,  3, 12, 1, 1, 0, 1, 0);
			if(sb_colon && sb_colon->tex != r_texture_notexture)
				DrawQ_Pic(sbar_x + -12*3, sbar_y + 32, sb_colon, 12, 12, 1, 1, 0, sbar_alpha_fg.value, 0);
			Sbar_DrawXNum(-12*2, 32, seconds, -2, 12, 1, 1, 0, 1, 0);
		}
		else if((int)(timeleft * 4) & 1)
			Sbar_DrawXNum(-12*2, 32, seconds, -2, 12, 1, 1, 1, 1, 0);
		else
			Sbar_DrawXNum(-12*2, 32, seconds, -2, 12, 1, 0, 0, 1, 0);
	#else
		string timestr = seconds_tostring(STAT(TIMELIMIT));
		Sbar_DrawNum_lettersize(-12 * 3, 32, timestr, strlen(timestr), false, 12, '12 12 0');
	#endif
	}
	else if(autocvar_sbar_gametime)
	{
	#if 0
		minutes = (int)floor(time / 60);
		seconds = (int)(floor(time) - minutes * 60);
		Sbar_DrawXNum(-12*6, 32, minutes,  3, 12, 1, 1, 1, 1, 0);
		if(sb_colon && sb_colon->tex != r_texture_notexture)
			DrawQ_Pic(sbar_x + -12*3, sbar_y + 32, sb_colon, 12, 12, 1, 1, 1, sbar_alpha_fg.value, 0);
		Sbar_DrawXNum(-12*2, 32, seconds, -2, 12, 1, 1, 1, 1, 0);
	#else
		string timestr = seconds_tostring(time);
		Sbar_DrawNum_lettersize(-12 * 3, 32, timestr, strlen(timestr), false, 12, '12 12 0');
	#endif
	}

	sbar = sbar_save;
}

float last_ping_request;

void Sbar_DeathmatchOverlay()
{
	if(time >= last_ping_request)
	{
		last_ping_request = time + 5; // not frequently
		localcmd("pings\n");
	}

	// scores
	Sbar_SortFrags();

	// 16 characters until name, then we assume 25 character names (they can be longer but usually aren't)
	float xmin = (autocvar_vid_conwidth - (16 + 25) * 8 * SBAR_MAXWIDTH) / 2; // TODO
	//float xmax = autocvar_vid_conwidth - xmin;

	vector pz = drawgetimagesize("gfx/ranking");
	drawpic(vec2((autocvar_vid_conwidth - pz.x) / 2, 8), "gfx/ranking", pz, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// draw the text
	int dy = 40;
	drawstring(vec2(xmin, dy), "ping pl% frags  name", '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	dy += 8;

	for(int j = 0; j < scoreboardlines && dy < autocvar_vid_conheight; j++)
		dy += Sbar_PrintScoreboardItem(fragsort[j], xmin, dy);
}

void Sbar_DrawScoreboard()
{
	Sbar_SoloScoreboard();
	// LordHavoc: changed to draw the deathmatch overlays in any multiplayer mode
	if(maxclients > 1) // singleplayer
		Sbar_DeathmatchOverlay();
}

/*
==================
Sbar_IntermissionOverlay

==================
*/
void Sbar_IntermissionOverlay()
{
	if(deathmatch)
	{
		Sbar_DeathmatchOverlay();
		return;
	}

	sbar.x = (autocvar_vid_conwidth - 320) >> 1;
	sbar.y = (autocvar_vid_conheight - 200) >> 1;

	drawpic(vec2(sbar.x + 64, sbar.y + 24), "gfx/complete", drawgetimagesize("gfx/complete"), '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawpic(vec2(sbar.x, sbar.y + 56), "gfx/inter", drawgetimagesize("gfx/inter"), '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

// time
	/*int dig = rint(completed_time / 60);
	Sbar_DrawNum(160, 64, dig, 3, 0);
	int num = rint(completed_time - dig * 60);
	Sbar_DrawPic(234, 64, "gfx/num_colon");
	Sbar_DrawNum(246, 64, num / 10, 2, false);
	Sbar_DrawNum(266, 64, num % 10, 2, false);*/
	string timestr = seconds_tostring(completed_time);
	Sbar_DrawNum(180, 64, timestr, strlen(timestr), 0);

// LA: Display as "a" instead of "a/b" if b is 0
	if(getstati(STAT_TOTALSECRETS))
	{
		Sbar_DrawNum(160, 104, itos(getstati(STAT_SECRETS)), 3, 0);
		Sbar_DrawPic(232, 104, "gfx/num_slash");
		Sbar_DrawNum(240, 104, itos(getstati(STAT_TOTALSECRETS)), 3, 0);
	}
	else
		Sbar_DrawNum(240, 104, itos(getstati(STAT_SECRETS)), 3, 0);

	if(getstati(STAT_TOTALMONSTERS))
	{
		Sbar_DrawNum(160, 144, itos(getstati(STAT_MONSTERS)), 3, 0);
		Sbar_DrawPic(232, 144, "gfx/num_slash");
		Sbar_DrawNum(240, 144, itos(getstati(STAT_TOTALMONSTERS)), 3, 0);
	}
	else
		Sbar_DrawNum(240, 144, itos(getstati(STAT_MONSTERS)), 3, 0);
}

/*
==================
Sbar_FinaleOverlay

==================
*/
void Sbar_FinaleOverlay()
{
	vector pz = drawgetimagesize("gfx/finale");
	drawpic(vec2((autocvar_vid_conwidth - pz.x) / 2, 16), "gfx/finale", pz, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

/*
===============
Sbar_DrawInventory
===============
*/
int olditems;
float item_gettime[32];
void Sbar_DrawInventory()
{
	int flashon;

	// set flash times
	int myitems = STAT(ITEMS);
	if(olditems != myitems)
	{
		for(int j = 0; j < 32; j++)
		{
			if((myitems & BIT(j)) != (olditems & BIT(j)))
				item_gettime[j] = time;
		}
	}
	olditems = myitems;



#if MP_ROGUE
	if(STAT(ACTIVEWEAPON) >= RIT_LAVA_NAILGUN)
		Sbar_DrawAlphaPic(0, -24, "gfx/r_invbar1", autocvar_sbar_alpha_bg);
	else
		Sbar_DrawAlphaPic(0, -24, "gfx/r_invbar2", autocvar_sbar_alpha_bg);
#else
	Sbar_DrawAlphaPic(0, -24, "gfx/ibar", autocvar_sbar_alpha_bg);
#endif

	// weapons
	for(int j = 0; j < 7; j++)
	{
		if(myitems & (IT_SHOTGUN << j))
		{
			float thetime = item_gettime[j];
			flashon = rint(max(0, time - thetime) * 10);
			if(flashon >= 10)
			{
				if(getstati(STAT_ACTIVEWEAPON) == (IT_SHOTGUN << j))
					flashon = 1;
				else
					flashon = 0;
			}
			else
				flashon = (flashon % 5) + 2;

			Sbar_DrawPic(j * 24, -16, Sbar_PickWeapon(flashon, j));
		}
	}

	// MED 01/04/97
	// hipnotic weapons
#if MP_HIPNOTIC
	int grenadeflashing = 0;
	for(int j = 0; j < 4; j++)
	{
		if(myitems & (1<<hipweapons[j]) )
		{
			time = max(0, cl.item_gettime[hipweapons[j]]);
			flashon = rint((time - thetime)*10);
			if(flashon >= 10)
			{
				if(STAT(ACTIVEWEAPON) == (1<<hipweapons[j]))
					flashon = 1;
				else
					flashon = 0;
			}
			else
				flashon = (flashon%5) + 2;

			// check grenade launcher
			if(j==2)
			{
				if(myitems & HIT_PROXIMITY_GUN)
				{
					if(flashon)
					{
						grenadeflashing = 1;
						Sbar_DrawPic (96, -16, hsb_weapons[flashon][2]);
					}
				}
			}
			else if(j==3)
			{
				if(myitems & (IT_SHOTGUN<<4))
				{
					if(!grenadeflashing)
						Sbar_DrawPic (96, -16, hsb_weapons[flashon][3]);
				}
				else
					Sbar_DrawPic (96, -16, hsb_weapons[flashon][4]);
			}
			else
				Sbar_DrawPic (176 + (j*24), -16, hsb_weapons[flashon][j]);
		}
	}
#endif


#if MP_ROGUE
	// check for powered up weapon.
	if(STAT(ACTIVEWEAPON) >= RIT_LAVA_NAILGUN)
	{
		for(int j = 0; j < 5; j++)
		{
			if(STAT(ACTIVEWEAPON) == (RIT_LAVA_NAILGUN << j))
				Sbar_DrawPic((j+2)*24, -16, rsb_weapons[j]);
		}
	}
#endif

	// ammo counts
	for(int j = 0; j < 4; j++)
	{
		int itemstat;
		switch(j)
		{
			default:
			case 0: itemstat = getstati(STAT_SHELLS); break;
			case 1: itemstat = getstati(STAT_NAILS); break;
			case 2: itemstat = getstati(STAT_ROCKETS); break;
			case 3: itemstat = getstati(STAT_CELLS); break;
		}
		/*string theitem = sprintf("%4d", itemstat);
		FOREACH_CHAR(theitem, it != ' ',
		{
			Sbar_DrawCharacter((6 * j + iter_i) * 8 - 2, -24, 18 + it - '0');
		});*/

		Sbar_DrawString((6 * j) * 8 - 2, -24, ftos(itemstat));
	}

	// items
#if !(MP_HIPNOTIC)
	for(int j = 0; j < 6; j++)
	{
		if(myitems & BIT(17 + j))
		{
			//MED 01/04/97 changed keys
			if(j > 1)
				Sbar_DrawPic(192 + j * 16, -16, Sbar_PickItem(j));
		}
	}
#endif

#if MP_HIPNOTIC
	//MED 01/04/97 added hipnotic items
	// hipnotic items
	for(int j = 0; j < 2; j++)
	{
		if(myitems & BIT(24 + j))
			Sbar_DrawPic(288 + j * 16, -16, hsb_items[j]);
	}
#endif

#if MP_ROGUE
	// new rogue items
	for(int j = 0; j < 2; j++)
	{
		if(myitems & BIT(29 + j))
			Sbar_DrawPic(288 + j * 16, -16, rsb_items[j]);
	}
#else
	// sigils
	for(int j = 0; j < 4; j++)
	{
		if(myitems & BIT(28 + j));
			Sbar_DrawPic(320 - 32 + j * 8, -16, Sbar_PickSigil(j));
	}
#endif
}

/*
===============
Sbar_DrawFrags
===============
*/
void Sbar_DrawFrags()
{
	Sbar_SortFrags();

	// draw the text
	int l = min(scoreboardlines, 4);

	int dx = 23 * 8;

	for(int j = 0; j < l; j++)
	{
		int k = fragsort[j];

		// draw background
		vector thecolor;
		vector pos;

		thecolor = stov(getplayerkeyvalue(k, "bottomcolor"));
		pos = sbar + vec2(dx + 10, -23);
		drawfill(pos, vec2(28, 4), thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		thecolor = stov(getplayerkeyvalue(k, "topcolor"));
		pos = sbar + vec2(dx + 10, 4 - 23);
		drawfill(pos, vec2(28, 3), thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		// draw number
		int f = stoi(getplayerkeyvalue(k, "frags"));
		string num = sprintf("%3d", f);

		if(k == player_localnum)
		{
			Sbar_DrawCharacter(dx      + 2, -24, 16);
			Sbar_DrawCharacter(dx + 32 - 4, -24, 17);
		}
		Sbar_DrawCharacter(dx +  8, -24, str2chr(num, 0));
		Sbar_DrawCharacter(dx + 16, -24, str2chr(num, 1));
		Sbar_DrawCharacter(dx + 24, -24, str2chr(num, 2));
		dx += 32;
	}
}

/*
===============
Sbar_DrawFace
===============
*/
int oldhealth;
float health_gettime;
void Sbar_DrawFace()
{
	int myitems = STAT(ITEMS);
	string pic;

	int myhealth = STAT(HEALTH);
	if(oldhealth != myhealth && myhealth < oldhealth)
		health_gettime = time + 0.2;
	oldhealth = myhealth;

	if((myitems & IT_INVISIBILITY) && (myitems & IT_INVULNERABILITY))
		pic = "gfx/face_inv2";
	else if(myitems & IT_QUAD)
		pic = "gfx/face_quad";
	else if(myitems & IT_INVISIBILITY)
		pic = "gfx/face_invis";
	else if(myitems & IT_INVULNERABILITY)
		pic = "gfx/face_invul2";
	else
	{
		int f = rint(STAT(HEALTH) / 20);
		f = bound(0, f, 4);
		bool washurt = (time <= health_gettime);
		pic = Sbar_PickFace(f, washurt);
	}
		
	Sbar_DrawPic(112, 0, pic);
}

void Sbar_Draw()
{
	if(!getproperty(VF_DRAWENGINESBAR)) // drawing in engine turned off, fall back to qc implementation
	{
		// intermission is always full screen
		if(intermission)
			sb_lines = 0;
		else
		{
			if(autocvar_scr_viewsize >= 120)
				sb_lines = 0;		// no status bar at all
			else if(autocvar_scr_viewsize >= 110)
				sb_lines = 24;		// no inventory
			else
				sb_lines = 24+16+8;
		}

		if(sb_showscores)
			Sbar_DrawScoreboard();
		else if(intermission == 1)
			Sbar_IntermissionOverlay();
		else if(intermission == 2)
			Sbar_FinaleOverlay();
		else // Quake
		{
			sbar.x = (autocvar_vid_conwidth - 320)/2;
			sbar.y = autocvar_vid_conheight - SBAR_HEIGHT;
			sbar.z = 0;

			if(sb_lines > 24)
			{
				Sbar_DrawInventory();
				if(maxclients > 1)
					Sbar_DrawFrags();
			}

			if(sb_showscores || (STAT(HEALTH) <= 0 && autocvar_cl_deathscoreboard))
			{
				Sbar_DrawAlphaPic(0, 0, "gfx/scorebar", autocvar_sbar_alpha_bg);
				Sbar_DrawScoreboard();
			}
			else if(sb_lines)
			{
				Sbar_DrawAlphaPic(0, 0, "gfx/sbar", autocvar_sbar_alpha_bg);

				// keys (hipnotic only)
				//MED 01/04/97 moved keys here so they would not be overwritten
				// armor
				if(STAT(ITEMS) & IT_INVULNERABILITY)
				{
					Sbar_DrawNum(24, 0, itos(666), 3, 1);
					Sbar_DrawPic(0, 0, "gfx/disc");
				}
				else
				{
				#if MP_ROGUE
					Sbar_DrawNum(24, 0, itos(getstati(STAT_ARMOR)), 3, getstati(STAT_ARMOR) <= 25);
					if(STAT(ITEMS) & RIT_ARMOR3)
						Sbar_DrawPic(0, 0, "gfx/sb_armor3");
					else if(STAT(ITEMS) & RIT_ARMOR2)
						Sbar_DrawPic(0, 0, "gfx/sb_armor2");
					else if(STAT(ITEMS) & RIT_ARMOR1)
						Sbar_DrawPic(0, 0, "gfx/sb_armor1");
				#else
					Sbar_DrawNum(24, 0, itos(getstati(STAT_ARMOR)), 3, getstati(STAT_ARMOR) <= 25);
					if(STAT(ITEMS) & IT_ARMOR3)
						Sbar_DrawPic(0, 0, "gfx/sb_armor3");
					else if(STAT(ITEMS) & IT_ARMOR2)
						Sbar_DrawPic(0, 0, "gfx/sb_armor2");
					else if(STAT(ITEMS) & IT_ARMOR1)
						Sbar_DrawPic(0, 0, "gfx/sb_armor1");
				#endif
				}

				// face
				Sbar_DrawFace();

				// health
				Sbar_DrawNum(136, 0, itos(rint(STAT(HEALTH))), 3, STAT(HEALTH) <= 25);

				// ammo icon
				if(STAT(ITEMS) & IT_SHELLS)
					Sbar_DrawPic(224, 0, "gfx/sb_shells");
				else if(STAT(ITEMS) & IT_NAILS)
					Sbar_DrawPic(224, 0, "gfx/sb_nails");
				else if(STAT(ITEMS) & IT_ROCKETS)
					Sbar_DrawPic(224, 0, "gfx/sb_rocket");
				else if(STAT(ITEMS) & IT_CELLS)
					Sbar_DrawPic(224, 0, "gfx/sb_cells");

				Sbar_DrawNum(248, 0, itos(getstati(STAT_AMMO)), 3, getstati(STAT_AMMO) <= 10);

				// LordHavoc: changed to draw the deathmatch overlays in any multiplayer mode
				if(maxclients > 1 || !coop)
				{
					Sbar_MiniDeathmatchOverlay(sbar.x + 324, autocvar_vid_conheight - 8 * 8);
					Sbar_Score(24);
				}
			}
		}
	}

	//if(autocvar_cl_prydoncursor > 0)
		//draw_cursor_normal(mousepos, '1 1 1', 0.8);
}