#include "sbar.qh"

#include "../common/ent_cs.qh"
#include "../common/champions/_mod.qh"
#include "../common/status_effects/_mod.qh"

string Sbar_PickWeapon_wepname(Weapon wpn)
{
	string img = wpn.model2;
	if(img != "")
		return img;

	// fallback to shotgun icon?
	return "shotgun";
}

PRECACHE(Sbar)
{
	precache_pic("gfx/quake/ranking");
	precache_pic("gfx/quake/sbar");
	precache_pic("gfx/quake/scorebar");
	precache_pic("gfx/quake/complete");
	precache_pic("gfx/quake/finale");
	precache_pic("gfx/quake/inter");
	precache_pic("gfx/quake/inter_horde");

	precache_pic("gfx/quake/ibar");

	precache_pic("gfx/quake/inv_wep");

	FOREACH(Weapons, it != WEP_Null,
	{
		precache_pic(strcat("gfx/quake/inv_", Sbar_PickWeapon_wepname(it)));
	});

	for(int j = 0; j < 10; j++)
	{
		precache_pic(strcat("gfx/quake/num_", itos(j)));
	}

	precache_pic("gfx/quake/num_minus");
	precache_pic("gfx/quake/num_slash");
	precache_pic("gfx/quake/num_colon");

	precache_pic("gfx/quake/sb_sigil1");
	precache_pic("gfx/quake/sb_sigil2");
	precache_pic("gfx/quake/sb_sigil3");
	precache_pic("gfx/quake/sb_sigil4");

	precache_pic("gfx/quake/sb_key1");
	precache_pic("gfx/quake/sb_key2");
	precache_pic("gfx/quake/sb_invis");
	precache_pic("gfx/quake/sb_invuln");
	precache_pic("gfx/quake/sb_suit");
	precache_pic("gfx/quake/sb_quad");

	precache_pic("gfx/quake/disc");

	precache_pic("gfx/quake/sb_armor1");
	precache_pic("gfx/quake/sb_armor2");
	precache_pic("gfx/quake/sb_armor3");

	precache_pic("gfx/quake/sb_shells");
	precache_pic("gfx/quake/sb_nails");
	precache_pic("gfx/quake/sb_rocket");
	precache_pic("gfx/quake/sb_cells");

	precache_pic("gfx/quake/sb_wsuit");
	precache_pic("gfx/quake/sb_eshld");

	precache_pic("gfx/quake/r_shield1");
	precache_pic("gfx/quake/r_agrav1");

	precache_pic("gfx/quake/r_ammolava");
	precache_pic("gfx/quake/r_ammomulti");
	precache_pic("gfx/quake/r_ammoplasma");

	precache_pic("gfx/quake/sb_sharp");

	precache_pic("gfx/hud/old/voteprogress_back");
	precache_pic("gfx/hud/old/voteprogress_voted");
	precache_pic("gfx/hud/old/voteprogress_prog");

	precache_pic("gfx/quake/egg0");
	precache_pic("gfx/quake/egg1");
	precache_pic("gfx/quake/egg2");
	precache_pic("gfx/quake/egg3");
	precache_pic("gfx/quake/egg4");
	precache_pic("gfx/quake/egg5");

	precache_pic("gfx/quake/magic0");
	precache_pic("gfx/quake/magic1");
	precache_pic("gfx/quake/magic2");
}

string Sbar_PickWeapon(Weapon wpn)
{
	string wep = Sbar_PickWeapon_wepname(wpn);
	return strcat("gfx/quake/inv_", wep);
}

string Sbar_FacePrefix(string input)
{
	string prefix = "gfx/quake/";
	if(csqcplayer && csqcplayer.m_champion)
		prefix = csqcplayer.m_champion.m_faceprefix;
	return strcat(prefix, input);
}

string Sbar_PickFace(int frm, bool washurt)
{
	switch(frm)
	{
		default:
		case 4: return Sbar_FacePrefix(((washurt) ? "face_p1" : "face1"));
		case 3: return Sbar_FacePrefix(((washurt) ? "face_p2" : "face2"));
		case 2: return Sbar_FacePrefix(((washurt) ? "face_p3" : "face3"));
		case 1: return Sbar_FacePrefix(((washurt) ? "face_p4" : "face4"));
		case 0: return Sbar_FacePrefix(((washurt) ? "face_p5" : "face5"));
	}
}

string Sbar_PickSigil(int frm)
{
	switch(frm)
	{
		default:
		case 0: return "gfx/quake/sb_sigil1";
		case 1: return "gfx/quake/sb_sigil2";
		case 2: return "gfx/quake/sb_sigil3";
		case 3: return "gfx/quake/sb_sigil4";
	}
}

string Sbar_PickItem(int frm)
{
	switch(frm)
	{
		default:
		case 0: return "gfx/quake/sb_key1";
		case 1: return "gfx/quake/sb_key2";
		case 2: return "gfx/quake/sb_invis";
		case 3: return "gfx/quake/sb_invuln";
		case 4: return "gfx/quake/sb_suit";
		case 5: return "gfx/quake/sb_quad";
	}
}

string Sbar_PickNum(string frm)
{
	return strcat("gfx/quake/num_", frm);
}

vector Sbar_BgColor()
{
	vector bgcolor = '1 1 1';
	if(STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL && STAT(DODGEBALL_TEAM) > 0)
	{
		if(STAT(DODGEBALL_TEAM) == 1)
			bgcolor = '1 0.7 0.1';
		else if(STAT(DODGEBALL_TEAM) == 2)
			bgcolor = '0.1 1 0.1';
	}

	return bgcolor;
}

vector sbar;
int sb_lines;

const int SBAR_HEIGHT = 24;
const int SBAR_MAXWIDTH = 1; // TODO: this is pure guesswork!

#if 0
void Sbar_DrawString(vector thepos, string msg)
{
	drawstring(sbar + vec2(thepos.x + 4, thepos.y), msg, '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_DrawCharacter(vector thepos, int num)
{
	Sbar_DrawString(thepos, sprintf("%c", num));
}
#endif

void Sbar_DrawAlphaPic_Color(vector thepos, string pic, float thealpha, vector thecolor)
{
	drawpic_aspect(sbar + thepos, pic, drawgetimagesize(pic), thecolor, thealpha, DRAWFLAG_NORMAL);
}

void Sbar_DrawAlphaPic(vector thepos, string pic, float thealpha)
{
	Sbar_DrawAlphaPic_Color(thepos, pic, thealpha, '1 1 1');
}

void Sbar_DrawPic(vector thepos, string pic)
{
	Sbar_DrawAlphaPic(thepos, pic, 1 * autocvar_sbar_alpha_fg);
}

void Sbar_DrawPic_Color(vector thepos, string pic, vector thecolor)
{
	Sbar_DrawAlphaPic_Color(thepos, pic, 1 * autocvar_sbar_alpha_fg, thecolor);
}

const int STAT_MINUS = 10; // num frame for '-' stats digit
void Sbar_DrawNum_lettersize(vector thepos, string num, int digits, vector thecolor, int lettersize, vector letterscale)
{
	int numlen = strlen(num);
	if(numlen < digits)
		thepos.x += (digits - numlen) * lettersize;

	FOREACH_CHAR(num, true,
	{
		string theframe;
		if(it == '-')
			theframe = "minus";
		else if(it == ':')
			theframe = "colon";
		else
			theframe = chr2str(it);
		string thepic = Sbar_PickNum(theframe);
		if(!letterscale)
			Sbar_DrawPic_Color(thepos, thepic, thecolor);
		else
			drawpic_aspect(sbar + thepos, thepic, letterscale, thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		thepos.x += lettersize;
	});
}

void Sbar_DrawNum(vector thepos, string num, int digits, vector thecolor)
{
	Sbar_DrawNum_lettersize(thepos, num, digits, thecolor, 24, '0 0 0');
}

void Sbar_DrawXNum(vector thepos, int num, int digits, int lettersize, vector col)
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
		thepos.x += (digits - numlen) * lettersize;

	FOREACH_CHAR(l, true,
	{
		string theframe;
		if(it == '-')
			theframe = "minus";
		else if(it == ':')
			theframe = "colon";
		else
			theframe = chr2str(it);
		drawpic(sbar + thepos, Sbar_PickNum(theframe), vec2(lettersize, lettersize), col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		thepos.x += lettersize;
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
		if(entcs_GetName(j) != "")
		{
			fragsort[scoreboardlines] = j;
			scoreboardlines++;
		}
	}

	for(int k = 0; k < scoreboardlines; k++)
	{
		for(int j = 0; j < scoreboardlines - 1 - k; j++)
		{
			int ffs = entcs_GetClientFrags(j);
			int ff2 = entcs_GetClientFrags(j + 1);
			if(ffs < ff2)
			{
				int currentscore = fragsort[j];
				fragsort[j] = fragsort[j + 1];
				fragsort[j + 1] = currentscore;
			}
		}
	}
}

/*
===============
Sbar_SoloScoreboard
===============
*/
void Sbar_SoloScoreboard(vector pos, vector mySize)
{
	int oldfont = drawfont;
	drawfont = 8 + 1; // FONT_USER

	vector text_size = vec2(mySize.x * 0.35, mySize.y * 0.35);
	vector offset = (text_size * 0.25 * 0.5);

	vector text_pos = pos + offset;

	vector col = '0.6 0.2 0';
	float t = (intermission ? completed_time : time);
	//int minutes = rint(t / 60);
	//int seconds = rint(t - 60*floor(t/60));

	int totalmonsters = STAT(MONSTERS_TOTAL);
	if(STAT(HORDE) && STAT(TOP_SCORE))
		totalmonsters = STAT(TOP_SCORE);

	// monsters and secrets are now both on the top row
	if(totalmonsters)
		drawstring_aspect(text_pos, sprintf("Monsters:%3d /%d", STAT(MONSTERS_KILLED), totalmonsters), text_size, col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	else if(STAT(MONSTERS_KILLED)) // LA: Display something if monsters_killed is non-zero, but total_monsters is zero
		drawstring_aspect(text_pos, sprintf("Monsters:%3d", STAT(MONSTERS_KILLED)), text_size, col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	if(!deathmatch)
	{
		string skill_text;
		int skill = STAT(SKILL);
		vector dcol = col;
		switch(skill)
		{
			default:
			case 0: skill_text = "Easy"; break;
			case 1: skill_text = "Normal"; break;
			case 2: skill_text = "Hard"; break;
			case 3: skill_text = "Nightmare"; dcol = '1 0 0'; break;
		}
		drawstring_aspect(text_pos + vec2(mySize.x * 0.25, 0), skill_text, text_size, dcol, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	if(STAT(SECRETS_TOTAL))
		drawstring_aspect(text_pos + vec2(mySize.x * 0.5, 0), sprintf("Secrets:%3d /%3d", STAT(SECRETS_FOUND), STAT(SECRETS_TOTAL)), text_size, col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	else if(STAT(SECRETS_FOUND)) // LA: And similarly for secrets
		drawstring_aspect(text_pos + vec2(mySize.x * 0.5, 0), sprintf("Secrets:%3d", STAT(SECRETS_FOUND)), text_size, col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

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
	drawstring_aspect(text_pos + vec2(0, mySize.y * 0.5), worldstr, vec2(text_size.x * 2, text_size.y), col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// print the time
	drawstring_aspect(text_pos + vec2(mySize.x * 0.5, mySize.y * 0.5), timestr, text_size, col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// port of the intermission display of monster kills
	if(STAT(HORDE))
	{
		vector oldsbar = sbar;
		sbar.x = (vid_conwidth - 320) >> 1;
		sbar.y = (vid_conheight - 200) >> 1;

		drawpic(vec2(sbar.x, sbar.y + 56), "gfx/quake/inter_horde", drawgetimagesize("gfx/quake/inter_horde"), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		Sbar_DrawNum('180 64 0', timestr, strlen(timestr), '1 1 1');

	// LA: Display as "a" instead of "a/b" if b is 0
		Sbar_DrawNum('240 104 0', itos(STAT(MONSTERS_KILLED)), 3, '1 1 1');

		Sbar_DrawNum('240 144 0', itos(STAT(TOP_SCORE)), 3, '1 1 1');

		sbar = oldsbar;
	}

	drawfont = oldfont;
}

/*
==================
Sbar_DeathmatchOverlay

==================
*/
float Sbar_PrintScoreboardItem(int fscore, vector thepos)
{
	//float oldfont = drawfont; // since this is a modern panel, it can use modern fonts
	//drawfont = 8 + 1; // FONT_USER
	bool myself = false;
	float thescore = entcs_GetClientFrags(fscore);

	if(fscore == player_localnum) // - 1 or + 1, idk
		myself = true;

	// draw colors behind score
	vector thecolor;
	vector pos;
	int f = entcs_GetClientColors(fscore);

	thecolor = colormapPaletteColor(f % 16, 1);
	pos = vec2(thepos.x + 9 * 8 * SBAR_MAXWIDTH, thepos.y + 1);
	drawfill(pos, vec2(40 * SBAR_MAXWIDTH, 3), thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	thecolor = colormapPaletteColor(floor(f / 16), 0);
	pos = vec2(thepos.x + 9 * 8 * SBAR_MAXWIDTH, thepos.y + 4);
	drawfill(pos, vec2(40 * SBAR_MAXWIDTH, 3), thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// print the text
	bool have_playerslots = (playerslots[fscore] != NULL);
	float theping = ((have_playerslots) ? playerslots[fscore].ping : 0);
	float thepl = ((have_playerslots) ? playerslots[fscore].ping_packetloss : 0);
	string thename = entcs_GetName(fscore);
	if(theping || thepl)
		drawcolorcodedstring2(thepos, sprintf("%4d %3d %5d %c%s", bound(0, theping, 9999), bound(0, thepl, 99), thescore, ((myself) ? 13 : ' '), thename), '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	else
		drawcolorcodedstring2(thepos, sprintf("         %5d %c%s", thescore, ((myself) ? 13 : ' '), thename), '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	//drawfont = oldfont;

	return 8;
}

/*
==================
Sbar_MiniDeathmatchOverlay

==================
*/
void Sbar_MiniDeathmatchOverlay(vector thepos)
{
	// do not draw this if sbar_miniscoreboard_size is zero
	if(autocvar_sbar_miniscoreboard_size == 0)
		return;
	// adjust the given dy if sbar_miniscoreboard_size doesn't indicate default (< 0)
	if(autocvar_sbar_miniscoreboard_size > 0)
		thepos.y = (vid_conheight - autocvar_sbar_miniscoreboard_size * 8);

	// scores
	Sbar_SortFrags();

	// decide where to print
	int numlines = (vid_conheight - thepos.y + 7) / 8;

	// give up if there isn't room
	if(thepos.x >= vid_conwidth || thepos.y >= vid_conheight || numlines < 1)
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
		thepos.y += 8 * (numlines - (range_end - found)); // bottom align
		thepos.y -= 8; // text size (b0rked)
	}

	for(; found < range_end && thepos.y < vid_conheight; found++)
	{
		thepos.y += Sbar_PrintScoreboardItem(fragsort[found], thepos);
	}
}

void Sbar_Score(vector thepos, int margin)
{
	vector sbar_save = sbar;

	// TODO
	sbar.y = (vid_conheight - (32 + 12));
	sbar.x = thepos.x - margin;

	int me = player_localnum; // was -1
	if(STAT(HORDE))
	{
		int score = entcs_GetClientFrags(me);
		Sbar_DrawXNum(vec2(-3*12, -12), score, 3, 12, '1 1 1');
		Sbar_DrawXNum(vec2(-32*4, 0), STAT(HORDE_WAVE), 4, 32, (((STAT(HORDE_WAVE) % 3) == 0) ? '1 0 0 ' : '1 1 1'));
	}
	else if(STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL)
	{
		int dteam = STAT(DODGEBALL_TEAM);
		if(dteam > 0)
		{
			int myscore = (dteam == 1) ? STAT(DODGEBALL_SCORE_TEAM1) : STAT(DODGEBALL_SCORE_TEAM2);
			int scorelimit = STAT(DODGEBALL_SCORE_LIMIT);
			Sbar_DrawXNum(vec2(-3*12, -12), scorelimit, 3, 12, '1 1 1');
			Sbar_DrawXNum(vec2(-32*4, 0), myscore, 4, 32, '1 1 1');
		}
	}
	else if(autocvar_sbar_scorerank && deathmatch && me >= 0 && me < maxclients)
	{
		// Layout:
		//
		//   leading  place
		//
		//        FRAGS
		//
		// find leading score other than ourselves, to calculate distribution
		// find our place in the scoreboard
		int score = entcs_GetClientFrags(me);
		int j = 0, otherleader = -1, place = 1;
		for(j = 0, otherleader = -1, place = 1; j < maxclients; j++)
		{
			if(entcs_GetName(j) != "" && j != me)
			{
				int ts = entcs_GetClientFrags(j);
				if(otherleader == -1 || ts > entcs_GetClientFrags(otherleader))
					otherleader = j;
				if(score < ts || (score == ts && j < me))
					place++;
			}
		}
		int distribution = otherleader >= 0 ? score - entcs_GetClientFrags(otherleader) : 0;
		if(place == 1)
			Sbar_DrawXNum(vec2(-3*12, -12), place, 3, 12, '1 1 1');
		else if(place == 2)
			Sbar_DrawXNum(vec2(-3*12, -12), place, 3, 12, '1 1 0');
		else
			Sbar_DrawXNum(vec2(-3*12, -12), place, 3, 12, '1 0 0');
		if(otherleader < 0)
			Sbar_DrawXNum(vec2(-32*4, 0), score, 4, 32, '1 1 1');
		if(distribution >= 0)
		{
			Sbar_DrawXNum(vec2(-7*12, -12), distribution, 4, 12, '1 1 1');
			Sbar_DrawXNum(vec2(-32*4, 0), score, 4, 32, '1 1 1');
		}
		else if(distribution >= -5)
		{
			Sbar_DrawXNum(vec2(-7*12, -12), distribution, 4, 12, '1 1 0');
			Sbar_DrawXNum(vec2(-32*4, 0), score, 4, 32, '1 1 0');
		}
		else
		{
			Sbar_DrawXNum(vec2(-7*12, -12), distribution, 4, 12, '1 0 0');
			Sbar_DrawXNum(vec2(-32*4, 0), score, 4, 32, '1 0 0');
		}
	}

	if(autocvar_sbar_gametime && (deathmatch || STAT(SKATING) || STAT(WORLDTYPE) == WORLDTYPE_SLIDE || STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL))
	{
		if((deathmatch || STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL) && STAT(TIMELIMIT))
		{
			string timestr = seconds_tostring(max(0, STAT(TIMELIMIT) * 60 - time));
			Sbar_DrawNum_lettersize(vec2(-12 * 3, 32), timestr, strlen(timestr), '1 1 1', 12, '12 12 0');
		}
		else
		{
			string timestr = seconds_tostring(time);
			Sbar_DrawNum_lettersize(vec2(-12 * 3, 32), timestr, strlen(timestr), '1 1 1', 12, '12 12 0');
		}
	}

#if 0
	if(autocvar_sbar_gametime && !deathmatch && STAT(TIMELIMIT))
	{
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
	}
	else if(autocvar_sbar_gametime)
	{
		minutes = (int)floor(time / 60);
		seconds = (int)(floor(time) - minutes * 60);
		Sbar_DrawXNum(-12*6, 32, minutes,  3, 12, 1, 1, 1, 1, 0);
		if(sb_colon && sb_colon->tex != r_texture_notexture)
			DrawQ_Pic(sbar_x + -12*3, sbar_y + 32, sb_colon, 12, 12, 1, 1, 1, sbar_alpha_fg.value, 0);
		Sbar_DrawXNum(-12*2, 32, seconds, -2, 12, 1, 1, 1, 1, 0);
	}
#endif

	sbar = sbar_save;
}

void Sbar_DeathmatchOverlay()
{
	// scores
	Sbar_SortFrags();

	// 16 characters until name, then we assume 25 character names (they can be longer but usually aren't)
	float xmin = (vid_conwidth - (16 + 25) * 8 * SBAR_MAXWIDTH) / 2; // TODO
	//float xmax = vid_conwidth - xmin;

	vector pz = drawgetimagesize("gfx/quake/ranking");
	drawpic(vec2((vid_conwidth - pz.x) / 2, 8), "gfx/quake/ranking", pz, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// draw the text
	int dy = 40;
	drawstring(vec2(xmin, dy), "ping pl% frags  name", '8 8 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	dy += 8;

	for(int j = 0; j < scoreboardlines && dy < vid_conheight; j++)
		dy += Sbar_PrintScoreboardItem(fragsort[j], vec2(xmin, dy));
}

string Sbar_ItemIcon(int item)
{
	switch(item)
	{
		case IT_SHELLS: return "sb_shells";
		case IT_NAILS: return "sb_nails";
		case IT_ROCKETS: return "sb_rocket";
		case IT_CELLS: return "sb_cells";
		case IT_LAVA_NAILS: return "r_ammolava";
		case IT_MULTI_ROCKETS: return "r_ammomulti";
		case IT_PLASMA_AMMO: return "r_ammoplasma";
		case IT_DRILLS: return "sb_drills";
	}
	return string_null;
}

string Sbar_ItemName(int item)
{
	switch(item)
	{
		case IT_SHELLS: return "shells";
		case IT_NAILS: return "nails";
		case IT_ROCKETS: return "rockets";
		case IT_CELLS: return "cells";
		case IT_LAVA_NAILS: return "lava nails";
		case IT_MULTI_ROCKETS: return "multi rockets";
		case IT_PLASMA_AMMO: return "plasma";
		case IT_DRILLS: return "drills";
	}
	return string_null;
}

int Sbar_ItemStat(int item)
{
	switch(item)
	{
		case IT_SHELLS: return getstati(STAT_SHELLS);
		case IT_NAILS: return getstati(STAT_NAILS);
		case IT_ROCKETS: return getstati(STAT_ROCKETS);
		case IT_CELLS: return getstati(STAT_CELLS);
		case IT_LAVA_NAILS: return STAT(LAVA_NAILS);
		case IT_MULTI_ROCKETS: return STAT(MULTI_ROCKETS);
		case IT_PLASMA_AMMO: return STAT(PLASMA_AMMO);
		case IT_DRILLS: return STAT(DRILLS);
	}
	return 0;
}

void Sbar_Notify_Push(float amount, int item)
{
	string icon = Sbar_ItemIcon(item);
	if(!icon)
		return;
	string fullname = cons(ftos(amount), Sbar_ItemName(item));

	++notify_count;
	--notify_index;

	if (notify_index == -1)
		notify_index = NOTIFY_MAX_ENTRIES-1;

	// Free old strings
	if (notify_items[notify_index])
		strunzone(notify_items[notify_index]);
	if (notify_icons[notify_index])
		strunzone(notify_icons[notify_index]);

	// Allocate new strings
	notify_items[notify_index] = strzone(fullname);
	notify_icons[notify_index] = strzone(icon);
	notify_times[notify_index] = time;
}

void Sbar_DrawNotify()
{
	if(notify_count == 0)
		return;

	vector pos, size;
	// hardcoded values from Xonotic, TODO
	vector panel_pos = vec2(0.73 * vid_conwidth, 0.80 * vid_conheight);
	vector panel_size = vec2(0.265 * vid_conwidth, 0.20 * vid_conheight);
	pos  = panel_pos;
	size = panel_size;

	float fade_start = max(0, autocvar_sbar_notify_time);
	if(intermission) // fade out in half the time
		fade_start -= (time - intermission_time);
	float fade_time = max(0, autocvar_sbar_notify_fadetime);
	float icon_aspect = 1;

	int entry_count = bound(1, floor(NOTIFY_MAX_ENTRIES * size.y / size.x), NOTIFY_MAX_ENTRIES);
	float entry_height = size.y / entry_count;

	float panel_width_half = size.x * 0.5;
	float icon_width_half = entry_height * icon_aspect / 2;
	float name_maxwidth = panel_width_half - icon_width_half - size.x * NOTIFY_ICON_MARGIN;

	vector font_size = '0.5 0.5 0' * entry_height * autocvar_sbar_notify_fontsize;
	vector icon_size = vec2(icon_aspect, 1) * entry_height;
	vector icon_left = eX * (panel_width_half - icon_width_half);
	vector item_left = eX * (size.x - name_maxwidth);

	vector item_pos, icon_pos;
	string item, icon;
	int i, j, count, step, limit;
	float alpha;

	// Order items from the bottom up
	i = entry_count - 1;
	step = -1;
	limit = -1;

	for(j = notify_index, count = 0; i != limit; i += step, ++j, ++count)
	{
		if (j == NOTIFY_MAX_ENTRIES)
			j = 0;

		if(notify_times[j] + fade_start > time)
			alpha = 1;
		else if(fade_time != 0)
		{
			alpha = bound(0, (notify_times[j] + fade_start + fade_time - time) / fade_time, 1);
			if (alpha == 0)
				break;
		}
		else
			break;

		item = notify_items[j];
		icon = notify_icons[j];

		if (icon != "" && item != "")
		{
			vector name_top = eY * (i * entry_height + 0.5 * (entry_height - font_size.y));

			icon_pos = pos + icon_left + eY * i * entry_height;
			drawpic(icon_pos, strcat("gfx/quake/", icon), icon_size, '1 1 1', alpha, DRAWFLAG_NORMAL);

			item = textShortenToWidth(item, name_maxwidth, font_size, stringwidth_colors);
			item_pos = pos + item_left + name_top;
			float oldfont = drawfont; // since this is a modern panel, it can use modern fonts
			drawfont = 8; // FONT_USER
			drawcolorcodedstring(item_pos, item, font_size, alpha, DRAWFLAG_NORMAL);
			drawfont = oldfont;
		}
	}

	notify_count = count;
}

void Sbar_DrawScoreboard(vector pos, vector mySize)
{
	Sbar_SoloScoreboard(pos, mySize);
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

	sbar.x = (vid_conwidth - 320) >> 1;
	sbar.y = (vid_conheight - 200) >> 1;

	drawpic(vec2(sbar.x + 64, sbar.y + 24), "gfx/quake/complete", drawgetimagesize("gfx/quake/complete"), '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	drawpic(vec2(sbar.x, sbar.y + 56), "gfx/quake/inter", drawgetimagesize("gfx/quake/inter"), '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

// time
	/*int dig = rint(completed_time / 60);
	Sbar_DrawNum(160, 64, dig, 3, 0);
	int num = rint(completed_time - dig * 60);
	Sbar_DrawPic(234, 64, "gfx/quake/num_colon");
	Sbar_DrawNum(246, 64, num / 10, 2, false);
	Sbar_DrawNum(266, 64, num % 10, 2, false);*/
	string timestr = seconds_tostring(completed_time);
	Sbar_DrawNum('180 64 0', timestr, strlen(timestr), '1 1 1');

// LA: Display as "a" instead of "a/b" if b is 0
	if(STAT(SECRETS_TOTAL))
	{
		Sbar_DrawNum('160 104 0', itos(STAT(SECRETS_FOUND)), 3, '1 1 1');
		Sbar_DrawPic('232 104 0', "gfx/quake/num_slash");
		Sbar_DrawNum('240 104 0', itos(STAT(SECRETS_TOTAL)), 3, '1 1 1');
	}
	else
		Sbar_DrawNum('240 104 0', itos(STAT(SECRETS_FOUND)), 3, '1 1 1');

	int totalmonsters = STAT(MONSTERS_TOTAL);
	if(STAT(HORDE) && STAT(TOP_SCORE))
		totalmonsters = STAT(TOP_SCORE);

	if(totalmonsters)
	{
		Sbar_DrawNum('160 144 0', itos(STAT(MONSTERS_KILLED)), 3, '1 1 1');
		Sbar_DrawPic('232 144 0', "gfx/quake/num_slash");
		Sbar_DrawNum('240 144 0', itos(totalmonsters), 3, '1 1 1');
	}
	else
		Sbar_DrawNum('240 144 0', itos(STAT(MONSTERS_KILLED)), 3, '1 1 1');
}

/*
==================
Sbar_FinaleOverlay

==================
*/
void Sbar_FinaleOverlay()
{
	vector pz = drawgetimagesize("gfx/quake/finale");
	drawpic(vec2((vid_conwidth - pz.x) / 2, 16), "gfx/quake/finale", pz, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

bool WeaponIsFromRogue(Weapon wep)
{
	// temporary hack to switch inventory bars
	return (wep.spawnflags & WEP_FLAG_ROGUE);
}

Weapon GetDrawWeapon(Weapon wep, Weapon awep)
{
	if(awep == WEP_Null)
		return wep;

	if(wep != awep && wep.impulse == awep.impulse)
		return awep;

	return wep;
}

void Sbar_DrawKeys()
{
	int oldfont = drawfont;
	drawfont = 8 + 1;

	vector panel_pos = stov(cvar_string("sbar_keys_pos"));
	vector panel_size = stov(cvar_string("sbar_keys_size"));

	HUD_Panel_ScalePosSize();

	vector pos = panel_pos;
	vector mySize = panel_size;

	if(autocvar_sbar_edit)
		drawfill(panel_pos, panel_size, '1 0 0', 0.25, DRAWFLAG_NORMAL);

	int rows = 7; // 2 vanilla, 1 copper, 4 ad
	int columns = 1;
	vector icon_size = mySize;
	icon_size.x = mySize.x / rows;
	icon_size.y = mySize.y / columns;

	int keys_drawn = 0;
	int myitems = STAT(ITEMS);

	for(int j = 0; j < 3; ++j)
	{
		string pic;
		int keycount;
		int keyitem;

		switch(j)
		{
			default:
			case 0: pic = "sb_key1"; keyitem = IT_KEY1; keycount = STAT(KEYS_SILVER); break;
			case 1: pic = "sb_key2"; keyitem = IT_KEY2; keycount = STAT(KEYS_GOLD); break;
			// TODO: custom icon!
			case 2: pic = "sba3_key1"; keyitem = IT_KEY3; keycount = STAT(KEYS_PLATINUM); break;
		}

		if(!(myitems & keyitem))
			continue;

		vector key_pos = pos + vec2(icon_size.x * keys_drawn, 0);

		drawpic_aspect(key_pos, strcat("gfx/quake/", pic), icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
		if(keycount > 0)
			drawstring_aspect(key_pos + vec2(icon_size.x * 0.1, icon_size.y * 0.5), ftos(keycount), vec2(icon_size.x * 0.25, icon_size.y * 0.5), '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
		//DrawNumIcon(pos + vec2(icon_size.x * keys_drawn, 0), icon_size, keycount, pic, false, false, 0, col, 1);

		keys_drawn += 1;
	}

	drawfont = oldfont;
}

/*
===============
Sbar_DrawInventory
===============
*/
WepSet oldweapons;
float weapon_gettime[72];
void Sbar_DrawInventory(vector pos, vector mySize)
{
	// set flash times
	float oldfont = drawfont;
	int myitems = STAT(ITEMS);
	//int mypowerups = STAT(POWERUPS);
	WepSet myweapons = STAT(WEAPONS);
	entity thiswep = viewmodels[0]; // TODO: unhardcode
	vector bgcolor = Sbar_BgColor();

	bool hideweapons = false;
	// disabled as it looks kinda ugly!
#if 0
	Champions champ = (csqcplayer) ? csqcplayer.m_champion : NULL;
	if(champ && champ.qcc_noselect)
		hideweapons = true;
#endif

	int rows = 12; // 10 weapons plus space for the sigils
	int columns = 2;
	vector icon_size = mySize;
	icon_size.x = mySize.x / rows;
	icon_size.y = mySize.y / columns;

	if(oldweapons != myweapons && time > 5) // time check to prevent initial load showing new weapons
	{
		FOREACH(Weapons, it != WEP_Null,
		{
			if((myweapons & it.m_wepset) != (oldweapons & it.m_wepset))
				weapon_gettime[it.m_id] = time;
		});
	}
	oldweapons = myweapons;

	//Sbar_DrawAlphaPic('0 -24 0', "gfx/quake/ibar", autocvar_sbar_alpha_bg);
	//drawpic(pos, "gfx/quake/scorebar", mySize, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);

	// weapons
	if(!(myitems & IT_TANK) && !hideweapons)
	{
		// NOTE: Xonotic uses the impulse order, but we only want to show one weapon anyway...
		string s = W_NumberWeaponOrder(autocvar_cl_quake_weaponpriority);
		string weporder = W_NameWeaponOrder(W_FixWeaponOrder(s, 1));
		int wep_pos = 0;
		for(int j = 1; j <= 10; ++j)
		{
			int imp = j;
			if(j == 10)
				imp = 0; // we want special 0 weapons to show on slot 10!
			Weapon wep = WEP_Null;
			if(thiswep.activeweapon.impulse == imp)
				wep = thiswep.activeweapon;
			else
			{
				FOREACH_WORD(weporder, true,
				{
					Weapon wepent = Weapon_from_name(it);
					if(wepent == WEP_Null || wepent.impulse != imp || !(myweapons & wepent.m_wepset))
						continue;
					wep = wepent;
					// TODO: the hud has no idea if the weapon has ammo
					break; // stop at first? TODO: champion weapons! (they usually have top priority anyway)
				});
			}
			// draw a background for each weapon slot
			vector wep_icon_pos = pos + vec2((j - 1) * icon_size.x, icon_size.y);
			drawpic_aspect(wep_icon_pos, "gfx/quake/inv_wep", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);

			if(wep != WEP_Null)
			{
				float thetime = weapon_gettime[wep.m_id];
				int flashon = rint(max(0, time - thetime) * 10);
				if(flashon >= 10)
					flashon = (thiswep.activeweapon == wep);
				else
					flashon = (flashon % 5) + 2;
				vector wep_icon_pos = pos + vec2(wep_pos * icon_size.x, icon_size.y);

				//drawpic(wep_icon_pos, "gfx/quake/inv_wep", icon_size, '1 1 1', autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				if(flashon)
					drawfill(wep_icon_pos, icon_size, '1 1 0', 0.33 * autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				drawpic_aspect(wep_icon_pos, Sbar_PickWeapon(wep), icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				vector col;
				if(WeaponIsFromRogue(wep))
					col = '1 0 0';
				else if(wep.spawnflags & WEP_FLAG_SWAB)
					col = '0.4 0.2 1';
				else if(wep.spawnflags & WEP_FLAG_CHAMPION)
				{
					if(thiswep.activeweapon == wep)
						col = '0 1 1';
					else
						col = '0.2 0.4 0.9';
				}
				else if(flashon)//(thiswep.activeweapon == wep)
					col = '1 1 0';
				else
					col = '0.6 0.2 0';
				drawfont = 8 + 1; // FONT_USER
				drawstring_aspect(wep_icon_pos + vec2(0, icon_size.y * 0.5), ftos(imp), vec2(icon_size.x * 0.25, icon_size.y * 0.5), col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				drawfont = oldfont;
				wep_pos += 1;
			}
		}

		rows = 8; // increase with ammo types

		// ammo counts
		for(int j = 0; j < 8; j++)
		{
			int ammotype;
			switch(j)
			{
				default:
				case 0: ammotype = IT_SHELLS; break;
				case 1: ammotype = IT_NAILS; break;
				case 2: ammotype = IT_ROCKETS; break;
				case 3: ammotype = IT_CELLS; break;
				case 4: ammotype = IT_LAVA_NAILS; break;
				case 5: ammotype = IT_MULTI_ROCKETS; break;
				case 6: ammotype = IT_PLASMA_AMMO; break;
				case 7: ammotype = IT_DRILLS; break;
			}
			int itemstat = Sbar_ItemStat(ammotype);
			// hack: only render mission pack ammo if we have ammo
			bool doshow = true;
			if(j > 3 && itemstat <= 0)
				doshow = false;
			vector ammo_icon_pos = pos + vec2(icon_size.x * j * 1.5, 0);
			string pic = Sbar_ItemIcon(ammotype);
			float alph = autocvar_sbar_alpha_fg;
			if(!doshow)
				alph *= 0.5;
			if(pic)
				drawpic_aspect(ammo_icon_pos, strcat("gfx/quake/", pic), icon_size, '1 1 1', alph, DRAWFLAG_NORMAL);
			else
				drawpic(ammo_icon_pos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);

			if(!doshow)
				continue;
			//int oldf = drawfont;
			//drawfont = 11;
			//drawstring(sbar + vec2(48 * j, -24), ftos(itemstat), '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			//drawfont = oldf;
			drawfont = 8 + 2; // FONT_USER
			drawstring_aspect(ammo_icon_pos + vec2(icon_size.x * 0.5, 0), ftos(itemstat), icon_size, '0.5 0.2 0', 0.7 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			drawfont = oldfont;
		}
	}

	Sbar_DrawKeys(); // sets their own position

#if 0
	// items
	// TODO: cleanup this mess
	// keys
	if(myitems & IT_KEY1)
	{
		Sbar_DrawPic(vec2(192 + 3 * 16, -16), "gfx/quake/sb_key1");
		if(STAT(KEYS_SILVER) > 0)
		{
			drawfont = 8; // FONT_USER
			drawstring_aspect(sbar + vec2(192 + 3 * 16, -8) - '2 0 0', ftos(STAT(KEYS_SILVER)), '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			drawfont = oldfont;
		}
	}
	if(myitems & IT_KEY2)
	{
		Sbar_DrawPic(vec2(192 + 4 * 16, -16), "gfx/quake/sb_key2");
		if(STAT(KEYS_GOLD) > 0)
		{
			drawfont = 8; // FONT_USER
			drawstring_aspect(sbar + vec2(192 + 4 * 16, -8) - '2 0 0', ftos(STAT(KEYS_GOLD)), '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			drawfont = oldfont;
		}
	}
	if(myitems & IT_KEY3)
	{
		// TODO: custom icon
		Sbar_DrawPic(vec2(192 + 5 * 16, -16), "gfx/quake/sb_key2");
		if(STAT(KEYS_PLATINUM) > 0)
		{
			drawfont = 8; // FONT_USER
			drawstring_aspect(sbar + vec2(192 + 5 * 16, -8) - '2 0 0', ftos(STAT(KEYS_PLATINUM)), '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			drawfont = oldfont;
		}
	}
#endif
#if 0
	// base powerups
	for(int j = 2; j < 6; ++j)
	{
		if(mypowerups & BIT(j - 2))
		{
			if(j > 1)
				Sbar_DrawPic(vec2(192 + j * 16, -16), Sbar_PickItem(j));
		}
	}
#endif

	// doing powerups outside the sbar now
#if 0
	if(!(myitems & IT_TANK))
	{
		int pcount = 0;
		FOREACH(StatusEffect, it.instanceOfPowerups,
		{
			if(StatusEffects_active(it, g_statuseffects) && it.m_icon && it.m_icon != "")
			{
				Sbar_DrawPic(vec2(192 + (5 + pcount) * 16, -16), strcat("gfx/quake/", it.m_icon));
				pcount += 1;
			}
			if(pcount >= 1)
				break; // we have limited HUD space unfortunately!
		});
	}
#endif

#if 0
	// TODO: unique positions for multiple powerups?
	if(mypowerups & POWERUP_WETSUIT)
		Sbar_DrawPic('288 -16 0', "gfx/quake/sb_wsuit");
	if(mypowerups & POWERUP_EMPATHY_SHIELDS)
		Sbar_DrawPic(vec2(288 + 16, -16), "gfx/quake/sb_eshld");

	if(mypowerups & POWERUP_SHIELD)
		Sbar_DrawPic('288 -16 0', "gfx/quake/r_shield1");
	if(mypowerups & POWERUP_ANTIGRAV)
		Sbar_DrawPic(vec2(288 + 16, -16), "gfx/quake/r_agrav1");

	if(mypowerups & POWERUP_SHARPSHOOTER)
		Sbar_DrawPic('288 -16 0', "gfx/quake/sb_sharp");
#endif

	vector sigil_pos = pos + vec2(icon_size.x * 10.5, icon_size.y);
	icon_size.x *= 0.35;

	// sigils
	for(int j = 0; j < 4; ++j)
	{
		vector spos = sigil_pos + vec2(icon_size.x * j, 0);
		if(STAT(SERVERFLAGS) & BIT(j))
			drawpic_aspect(spos, Sbar_PickSigil(j), icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
		else
			drawpic_aspect(spos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
	}
}

/*
===============
Sbar_DrawFace
===============
*/
int oldhealth;
float health_gettime;
void Sbar_DrawFace(vector pos, vector icon_size)
{
	int myitems = STAT(ITEMS); // changed field due to reaching bit limit
	//int mypowerups = STAT(POWERUPS);
	string pic;

	if(myitems & IT_TANK)
		return;

	Champions champ = (csqcplayer) ? csqcplayer.m_champion : NULL;
	if(champ && champ.m_drawface)
	{
		if(champ.m_drawface(champ, pos, icon_size))
			return; // drawn by champion
	}

	int myhealth = STAT(HEALTH);
	if(oldhealth != myhealth && myhealth < oldhealth && (oldhealth - myhealth) >= 3)
		health_gettime = time + 0.2;
	oldhealth = myhealth;

	if(StatusEffects_active(STATUSEFFECT_Invisibility, g_statuseffects) && StatusEffects_active(STATUSEFFECT_Invulnerability, g_statuseffects))
		pic = Sbar_FacePrefix("face_inv2");
	else if(StatusEffects_active(STATUSEFFECT_Quad, g_statuseffects))
		pic = Sbar_FacePrefix("face_quad");
	else if(StatusEffects_active(STATUSEFFECT_Invisibility, g_statuseffects) || (StatusEffects_active(STATUSEFFECT_FieldGen, g_statuseffects) && STAT(FIELDGEN_HEALTH) > 0))
		pic = Sbar_FacePrefix("face_invis");
	else if(StatusEffects_active(STATUSEFFECT_Invulnerability, g_statuseffects))
		pic = Sbar_FacePrefix("face_invul2");
	else
	{
		int f = rint(STAT(HEALTH) / 20);
		f = bound(0, f, 4);
		bool washurt = (time <= health_gettime);
		pic = Sbar_PickFace(f, washurt);
	}
		
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_DrawHealth(vector pos, vector icon_size)
{
	int myhealth = rint(STAT(HEALTH));
	vector hpcolor = (STAT(HEALTH) <= 25) ? '1 0 0' : '1 1 1';
	bool have_fieldgen = (StatusEffects_active(STATUSEFFECT_FieldGen, g_statuseffects) && STAT(FIELDGEN_HEALTH) > 0);
	if(have_fieldgen)
	{
		myhealth += rint(STAT(FIELDGEN_HEALTH));
		hpcolor = '0 1 1';
	}
	if(StatusEffects_active(STATUSEFFECT_Withering, g_statuseffects))
		hpcolor = '0.1 0.1 0.1';

	//Sbar_DrawNum('136 0 0', itos(myhealth), 3, hpcolor);
	vector oldsbar = sbar;
	sbar = '0 0 0';
	Sbar_DrawNum_lettersize(pos + vec2(icon_size.x, 0), itos(myhealth), 3, hpcolor, icon_size.x, icon_size);
	sbar = oldsbar;
}

STATIC_INIT(Sbar)
{
	//registercvar("sbar_pos", "0.378 0.9398");
	registercvar("sbar_size", "0.32 0.08");

	registercvar("sbar_keys_pos", "0.34 0.88");
	registercvar("sbar_keys_size", "0.2 0.035");
}

void Sbar_Draw()
{
	if(autocvar_r_letterbox)
		return;

	if(!getproperty(VF_DRAWENGINESBAR)) // drawing in engine turned off, fall back to qc implementation
	{
		//vector panel_pos = stov(cvar_string("sbar_pos"));
		vector panel_pos = vec2(vid_conwidth, vid_conheight); // we'll fix it later!
		vector panel_size = stov(cvar_string("sbar_size"));

		HUD_Panel_ScalePosSize();

		// let's make sure it's always at the bottom though!
		panel_pos.x = vid_conwidth * 0.5;
		panel_pos.x -= (panel_size.x * 0.5);
		panel_pos.y = vid_conheight - panel_size.y;

		vector pos = panel_pos;
		vector mySize = panel_size;

		vector bgcolor = Sbar_BgColor();
		if(!intermission && !sb_showscores && STAT(HEALTH) > 0)
		{
			Draw_BorderPicture(
				pos - '1 1 0' * 2,
				"gfx/quake/scorebar",
				mySize + '1 1 0' * 2 * 2,
				bgcolor, autocvar_sbar_alpha_bg,
				'1 1 0' * 4 * 2
			);
		}

		sbar = panel_pos;
		sbar.y += (panel_size.y * 0.5);
		//sbar.x *= 0.5;
		//sbar.y -= (panel_size.y * 0.5);

		// hacky quake fallback TODO: remove!
		if(sbar == '0 0 0')
		{
			sbar.x = (vid_conwidth - 320) * 0.5;
			sbar.y = vid_conheight - SBAR_HEIGHT;
			sbar.z = 0;
		}

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

		// always draw push notifications?
		Sbar_DrawNotify();

		if(cursor_active)
			{} // no special handling
		if(sb_showscores || STAT(HEALTH) == -666 || (STAT(HEALTH) <= 0 && autocvar_cl_deathscoreboard)) // hacky check to see if we're spectating
		{
			//Sbar_DrawAlphaPic('0 0 0', "gfx/quake/scorebar", autocvar_sbar_alpha_bg);
			mySize.y *= 0.5;
			pos.y += mySize.y;
			//drawpic(pos, "gfx/quake/scorebar", mySize, '1 1 1', autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);

			Draw_BorderPicture(
				pos - '1 1 0' * 2,
				"gfx/quake/scorebar",
				mySize + '1 1 0' * 2 * 2,
				bgcolor, autocvar_sbar_alpha_bg,
				'1 1 0' * 4 * 2
			);
			Sbar_DrawScoreboard(pos, mySize);
		}
		else if(intermission == 1)
			Sbar_IntermissionOverlay();
		else if(intermission == 2)
			Sbar_FinaleOverlay();
		else // Quake
		{
			sbar.x = (vid_conwidth - 320) * 0.5;
			sbar.y = vid_conheight - SBAR_HEIGHT;
			sbar.z = 0;

			// upper half

			mySize.y *= 0.5;

			if(!intermission)
			{
				Sbar_DrawInventory(pos, mySize);
				// NOTE: disabled as it seems unnecessary with the frags shown on the side already
				//if(maxclients > 1)
					//Sbar_DrawFrags();
			}

			if(sb_lines)
			{
				//Sbar_DrawAlphaPic_Color('0 0 0', "gfx/quake/scorebar", autocvar_sbar_alpha_bg, bgcolor);
				//Draw_BorderPicture(
					//panel_pos - '1 1 0' * 2,
					//"gfx/quake/scorebar",
					//panel_size + '1 1 0' * 2 * 2,
					//bgcolor, autocvar_sbar_alpha_bg,
					//'1 1 0' * 4 * 2
				//);

				// lower half
				pos.y += mySize.y;
				//drawpic(pos, "gfx/quake/scorebar", mySize, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);

				int rows = 15;
				vector icon_size = mySize;
				icon_size.x = mySize.x / rows;
				vector oldsbar = sbar; // TODO

				//drawpic(sbar + '0 0 0', "gfx/quake/backtile", '24 24 0', bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				if(StatusEffects_active(STATUSEFFECT_Invulnerability, g_statuseffects) && !(STAT(ITEMS) & IT_TANK))
				{
					sbar = '0 0 0';
					//Sbar_DrawNum('24 0 0', itos(666), 3, '0 1 1');
					//Sbar_DrawPic('0 0 0', "gfx/quake/disc");
					Sbar_DrawNum_lettersize(pos + vec2(icon_size.x, 0), "666", 3, '0 1 1', icon_size.x, icon_size);
					drawpic_aspect(pos, "gfx/quake/disc", icon_size, bgcolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
					sbar = oldsbar;
				}
				else if(!(STAT(ITEMS) & IT_TANK))
				{
					string apic = string_null;
					if(STAT(ITEMS) & IT_ARMOR3)
						apic = "gfx/quake/sb_armor3";
					else if(STAT(ITEMS) & IT_ARMOR2)
						apic = "gfx/quake/sb_armor2";
					else if(STAT(ITEMS) & IT_ARMOR1)
						apic = "gfx/quake/sb_armor1";

					if(apic)
					{
						//Sbar_DrawPic('0 0 0', apic);
						drawpic_aspect(pos, apic, icon_size, bgcolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
						//Sbar_DrawNum('24 0 0', itos(getstati(STAT_ARMOR)), 3, ((getstati(STAT_ARMOR) <= 25) ? '1 0 0' : '1 1 1'));
						sbar = '0 0 0';
						Sbar_DrawNum_lettersize(pos + vec2(icon_size.x, 0), itos(getstati(STAT_ARMOR)), 3, ((getstati(STAT_ARMOR) <= 25) ? '1 0 0' : '1 1 1'), icon_size.x, icon_size);
						sbar = oldsbar;
					}
					else
						drawpic_aspect(pos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				}

				vector face_pos = pos + vec2(icon_size.x * 6, 0);
				if(STAT(ITEMS) & IT_TANK)
					face_pos = pos + vec2(icon_size.x * 5, 0); // roughly half way

				// face
				Sbar_DrawFace(face_pos, icon_size);

				// health
				Sbar_DrawHealth(face_pos, icon_size);

				vector ammo_pos = pos + vec2(icon_size.x * 11, 0);

				entity thiswep = viewmodels[0]; // TODO: unhardcode
				if(STAT(SKATING) || (STAT(ITEMS) & IT_TANK))
					{ /* nothing */}
				else if(STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL)
				{
					//Sbar_DrawNum('248 0 0', itos(ceil(STAT(STAMINA))), 3, ((STAT(STAMINA) <= 10) ? '1 0 0' : '1 1 1'));
					sbar = '0 0 0';
					drawpic_aspect(pos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
					Sbar_DrawNum_lettersize(pos + vec2(icon_size.x, 0), itos(ceil(STAT(STAMINA))), 3, ((STAT(STAMINA) <= 10) ? '1 0 0' : '1 1 1'), icon_size.x, icon_size);
					sbar = oldsbar;
				}
				else if(thiswep.activeweapon.spawnflags & WEP_FLAG_MANA)
				{
					//Sbar_DrawNum('248 0 0', itos(ceil(STAT(MANA))), 3, ((STAT(MANA) <= 10) ? '1 0 0' : '1 1 1'));
					//sbar = '0 0 0';
					// TODO: mana icon / draw bar instead?
					//Sbar_DrawNum_lettersize(pos + vec2(icon_size.x, 0), itos(ceil(STAT(STAMINA))), 3, ((STAT(STAMINA) <= 10) ? '1 0 0' : '1 1 1'), icon_size.x, icon_size);
					//sbar = oldsbar;
					float mana = STAT(MANA);
					if(mana)
						mana /= 100;

					drawpic_aspect(ammo_pos, "gfx/quake/backtile", vec2(icon_size.x * 4 * 0.85, icon_size.y * 0.85), bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
					HUD_Panel_DrawProgressBar(ammo_pos + (icon_size * 0.15 * 0.5), vec2(icon_size.x * 4 * 0.85, icon_size.y * 0.85), "progressbar", mana, false, 0, '0 1 1', 0.6, DRAWFLAG_NORMAL);
				}
				else if(thiswep.activeweapon == WEP_BREEGULLBLASTER)
				{
					string pic = "";
					switch(STAT(BREEGULL_EGGTYPE))
					{
						default:
						case 0: pic = "egg0"; break;
						case 1: pic = "egg1"; break;
						case 2: pic = "egg2"; break;
						case 3: pic = "egg3"; break;
						case 4: pic = "egg4"; break;
						case 5: pic = "egg5"; break;
					}
					drawpic_aspect(ammo_pos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
					drawpic_aspect(ammo_pos, strcat("gfx/quake/", pic), icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				}
				else if(thiswep.activeweapon == WEP_MAGIC)
				{
					string pic = "";
					switch(STAT(MAGIC_TYPE))
					{
						default:
						case 0: pic = "magic0"; break;
						case 1: pic = "magic1"; break;
						case 2: pic = "magic2"; break;
					}
					drawpic_aspect(ammo_pos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
					drawpic_aspect(ammo_pos, strcat("gfx/quake/", pic), icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				}
				else
				{
					// ammo icon
					int ammotype = thiswep.activeweapon.ammo_type;
					string pic = Sbar_ItemIcon(ammotype);

					if(pic)
					{
						//Sbar_DrawPic('224 0 0', strcat("gfx/quake/", pic));
						//Sbar_DrawNum('248 0 0', itos(Sbar_ItemStat(ammotype)), 3, ((Sbar_ItemStat(ammotype) <= 10) ? '1 0 0' : '1 1 1'));
						sbar = '0 0 0';
						drawpic_aspect(ammo_pos, strcat("gfx/quake/", pic), icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
						Sbar_DrawNum_lettersize(ammo_pos + vec2(icon_size.x, 0), itos(Sbar_ItemStat(ammotype)), 3, ((Sbar_ItemStat(ammotype) <= 10) ? '1 0 0' : '1 1 1'), icon_size.x, icon_size);
						sbar = oldsbar;
					}
					else
						drawpic_aspect(ammo_pos, "gfx/quake/backtile", icon_size, bgcolor, autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				}

				// LordHavoc: changed to draw the deathmatch overlays in any multiplayer mode
				if(maxclients > 1 || !coop)
				{
					Sbar_MiniDeathmatchOverlay(vec2(panel_pos.x + mySize.x, panel_pos.y));
					Sbar_Score(panel_pos, 24);
				}
			}
		}
	}

	//if(autocvar_cl_prydoncursor > 0)
		//draw_cursor_normal(mousepos, '1 1 1', 0.8);
}
