#include "sbar.qh"

#include "../common/ent_cs.qh"
#include "../common/champions/_mod.qh"
#include "../common/status_effects/_mod.qh"

float stringwidth(string text, float handleColors, vector sz); // defined in centerprint.qc

#define SET_POS_AND_SZ_Y_ASPECT(allow_colors) MACRO_BEGIN \
	float textaspect, oldsz; \
	vector dfs = drawfontscale; \
	drawfontscale = '1 1 0'; \
	textaspect = stringwidth(text, allow_colors, '1 1 1' * sz.y) / sz.y; \
	drawfontscale = dfs; \
	if(sz.x/sz.y > textaspect) { \
		oldsz = sz.x; \
		sz.x = sz.y * textaspect; \
		pos.x += (oldsz - sz.x) * 0.5; \
	} else { \
		oldsz = sz.y; \
		sz.y = sz.x / textaspect; \
		pos.y += (oldsz - sz.y) * 0.5; \
	} \
MACRO_END

// drawstring wrapper to draw a string as large as possible with preserved aspect ratio into a box
void drawstring_aspect(vector pos, string text, vector sz, vector color, float theAlpha, float drawflag) {
	SET_POS_AND_SZ_Y_ASPECT(false);
	drawstring(pos, text, '1 1 0' * sz.y, color, theAlpha, drawflag);
}

// drawstring wrapper to draw a colorcodedstring as large as possible with preserved aspect ratio into a box
void drawcolorcodedstring_aspect(vector pos, string text, vector sz, float theAlpha, float drawflag) {
	SET_POS_AND_SZ_Y_ASPECT(true);
	drawcolorcodedstring(pos, text, '1 1 0' * sz.y, theAlpha, drawflag);
}

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

vector sbar;
int sb_lines;

const int SBAR_HEIGHT = 24;
const int SBAR_MAXWIDTH = 1; // TODO: this is pure guesswork!

void Sbar_DrawString(vector thepos, string msg)
{
	drawstring(sbar + vec2(thepos.x + 4, thepos.y), msg, '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
}

void Sbar_DrawCharacter(vector thepos, int num)
{
	Sbar_DrawString(thepos, sprintf("%c", num));
}

void Sbar_DrawAlphaPic_Color(vector thepos, string pic, float thealpha, vector thecolor)
{
	drawpic(sbar + thepos, pic, drawgetimagesize(pic), thecolor, thealpha, DRAWFLAG_NORMAL);
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
			drawpic(sbar + thepos, thepic, letterscale, thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

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
void Sbar_SoloScoreboard()
{
	float t = (intermission ? completed_time : time);
	//int minutes = rint(t / 60);
	//int seconds = rint(t - 60*floor(t/60));

	int totalmonsters = STAT(MONSTERS_TOTAL);
	if(STAT(HORDE) && STAT(TOP_SCORE))
		totalmonsters = STAT(TOP_SCORE);

	// monsters and secrets are now both on the top row
	if(totalmonsters)
		Sbar_DrawString('8 4 0', sprintf("Monsters:%3d /%d", STAT(MONSTERS_KILLED), totalmonsters));
	else if(STAT(MONSTERS_KILLED)) // LA: Display something if monsters_killed is non-zero, but total_monsters is zero
		Sbar_DrawString('8 4 0', sprintf("Monsters:%3d", STAT(MONSTERS_KILLED)));

	if(STAT(SECRETS_TOTAL))
		Sbar_DrawString(vec2(8+22*8, 4), sprintf("Secrets:%3d /%3d", STAT(SECRETS_FOUND), STAT(SECRETS_TOTAL)));
	else if(STAT(SECRETS_FOUND)) // LA: And similarly for secrets
		Sbar_DrawString(vec2(8+22*8, 4), sprintf("Secrets:%3d", STAT(SECRETS_FOUND)));

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
	Sbar_DrawString('8 12 0', worldstr);

	// print the time
	Sbar_DrawString(vec2(8 + maxlen*8, 12), timestr);

	// port of the intermission display of monster kills
	if(STAT(HORDE))
	{
		vector oldsbar = sbar;
		sbar.x = (vid_conwidth - 320) >> 1;
		sbar.y = (vid_conheight - 200) >> 1;

		drawpic(vec2(sbar.x, sbar.y + 56), "gfx/quake/inter_horde", drawgetimagesize("gfx/quake/inter_horde"), '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		Sbar_DrawNum('180 64 0', timestr, strlen(timestr), '1 1 1');

	// LA: Display as "a" instead of "a/b" if b is 0
		Sbar_DrawNum('240 104 0', itos(STAT(MONSTERS_KILLED)), 3, '1 1 1');

		Sbar_DrawNum('240 144 0', itos(STAT(TOP_SCORE)), 3, '1 1 1');

		sbar = oldsbar;
	}
}

/*
==================
Sbar_DeathmatchOverlay

==================
*/
float Sbar_PrintScoreboardItem(int fscore, vector thepos)
{
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

void Sbar_Score(int margin)
{
	vector sbar_save = sbar;

	sbar.y = (vid_conheight - (32 + 12));
	sbar.x -= margin;

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

/*
===============
Sbar_DrawInventory
===============
*/
WepSet oldweapons;
float weapon_gettime[72];
void Sbar_DrawInventory()
{
	// set flash times
	float oldfont = drawfont;
	int myitems = STAT(ITEMS);
	//int mypowerups = STAT(POWERUPS);
	WepSet myweapons = STAT(WEAPONS);
	entity thiswep = viewmodels[0]; // TODO: unhardcode

	if(oldweapons != myweapons && time > 5) // time check to prevent initial load showing new weapons
	{
		FOREACH(Weapons, it != WEP_Null,
		{
			if((myweapons & it.m_wepset) != (oldweapons & it.m_wepset))
				weapon_gettime[it.m_id] = time;
		});
	}
	oldweapons = myweapons;

	Sbar_DrawAlphaPic('0 -24 0', "gfx/quake/ibar", autocvar_sbar_alpha_bg);

	// weapons
	if(!(myitems & IT_TANK))
	{
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
				FOREACH(Weapons, it != WEP_Null && it.impulse == imp && (myweapons & it.m_wepset),
				{
					wep = it;
					if(it.spawnflags & WEP_FLAG_HUDFALLBACK)
						break;
				});
			}
			if(wep != WEP_Null)
			{
				float thetime = weapon_gettime[wep.m_id];
				int flashon = rint(max(0, time - thetime) * 10);
				if(flashon >= 10)
					flashon = (thiswep.activeweapon == wep);
				else
					flashon = (flashon % 5) + 2;
				drawpic(sbar + vec2(wep_pos * 24, -16), "gfx/quake/inv_wep", '24 16 0', '1 1 1', autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				if(flashon)
					drawfill(sbar + vec2(wep_pos * 24, -16), '24 16 0', '1 1 0', 0.33 * autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
				drawpic(sbar + vec2(wep_pos * 24, -16), Sbar_PickWeapon(wep), '24 16 0', '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				vector col;
				if(WeaponIsFromRogue(wep))
					col = '1 0 0';
				else if(flashon)//(thiswep.activeweapon == wep)
					col = '1 1 0';
				else
					col = '0.6 0.2 0';
				drawfont = 8; // FONT_USER
				drawstring_aspect(sbar + vec2(wep_pos * 24, -8), ftos(imp), '8 8 0', col, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				drawfont = oldfont;
				wep_pos += 1;
			}
		}

		// ammo counts
		for(int j = 0; j < 7; j++)
		{
			int itemstat;
			int offset;
			switch(j)
			{
				default:
				case 0: itemstat = getstati(STAT_SHELLS); break;
				case 1: itemstat = getstati(STAT_NAILS); break;
				case 2: itemstat = getstati(STAT_ROCKETS); break;
				case 3: itemstat = getstati(STAT_CELLS); break;
				case 4: itemstat = STAT(LAVA_NAILS); break;
				case 5: itemstat = STAT(MULTI_ROCKETS); break;
				case 6: itemstat = STAT(PLASMA_AMMO); break;
			}
			// hack: only render mission pack ammo if we have ammo
			if(j > 3 && itemstat <= 0)
				continue;
			//int oldf = drawfont;
			//drawfont = 11;
			//drawstring(sbar + vec2(48 * j, -24), ftos(itemstat), '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			//drawfont = oldf;
			Sbar_DrawString(vec2(48 * j, -24), ftos(itemstat));
		}
	}

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
		Sbar_DrawPic(vec2(192 + 4 * 16, -16), "gfx/quake/sb_key2");
		if(STAT(KEYS_PLATINUM) > 0)
		{
			drawfont = 8; // FONT_USER
			drawstring_aspect(sbar + vec2(192 + 5 * 16, -8) - '2 0 0', ftos(STAT(KEYS_PLATINUM)), '8 8 0', '0.6 0.2 0', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
			drawfont = oldfont;
		}
	}
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

	// sigils
	for(int j = 0; j < 4; ++j)
	{
		if(STAT(SERVERFLAGS) & BIT(j))
			Sbar_DrawPic(vec2(320 - 32 + j * 8, -16), Sbar_PickSigil(j));
	}
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
		int fcolor = entcs_GetClientColors(k);

		thecolor = colormapPaletteColor(fcolor % 16, 1);
		pos = sbar + vec2(dx + 10, -23);
		drawfill(pos, '28 4 0', thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		thecolor = colormapPaletteColor(floor(fcolor / 16), 0);
		pos = sbar + vec2(dx + 10, 4 - 23);
		drawfill(pos, '28 3 0', thecolor, autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

		// draw number
		int f = entcs_GetClientFrags(k);
		string num = sprintf("%3d", f);

		if(k == player_localnum)
		{
			Sbar_DrawCharacter(vec2(dx      + 2, -24), 16);
			Sbar_DrawCharacter(vec2(dx + 32 - 4, -24), 17);
		}
		Sbar_DrawCharacter(vec2(dx +  8, -24), str2chr(num, 0));
		Sbar_DrawCharacter(vec2(dx + 16, -24), str2chr(num, 1));
		Sbar_DrawCharacter(vec2(dx + 24, -24), str2chr(num, 2));
		dx += 32;
	}
}

/*
===============
Sbar_DrawVotes
===============
*/

void Sbar_DrawVotes()
{
	string s;
	float a;
	if(vote_active != vote_prev) {
		vote_change = time;
		vote_prev = vote_active;
	}

	if(vote_active)
		vote_alpha = bound(0, (time - vote_change) * 2, 1);
	else
		vote_alpha = bound(0, 1 - (time - vote_change) * 2, 1);

	a = vote_alpha * (vote_highlighted ? 0.7 : 1);
	if(a <= 0)
		return;
	//panel_fade_alpha *= a;

	float oldfont = drawfont; // since this is a modern panel, it can use modern fonts
	drawfont = 8; // FONT_USER

	vector panel_pos = vec2(0.73 * vid_conwidth, 0.80 * vid_conheight);
	vector panel_size = vec2(0.19 * vid_conwidth, 0.09 * vid_conheight);

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	// always force 3:1 aspect
	vector newSize = '0 0 0';
	if(mySize.x/mySize.y > 3)
	{
		newSize.x = 3 * mySize.y;
		newSize.y = mySize.y;

		pos.x = pos.x + (mySize.x - newSize.x) / 2;
	}
	else
	{
		newSize.y = 1/3 * mySize.x;
		newSize.x = mySize.x;

		pos.y = pos.y + (mySize.y - newSize.y) / 2;
	}
	mySize = newSize;

	s = _("A vote has been called for:");
	drawstring_aspect(pos, s, vec2(mySize.x, (2/8) * mySize.y), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	s = textShortenToWidth(vote_called_vote, mySize.x, '1 1 0' * mySize.y * (1/8), stringwidth_colors);
	drawcolorcodedstring_aspect(pos + eY * (2/8) * mySize.y, s, vec2(mySize.x, (1.75/8) * mySize.y), autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// print the yes/no counts
	s = sprintf("^2%s ^7(%d)", getcommandkey_forcename(_("Yes"), "vyes"), vote_yescount);
	drawcolorcodedstring_aspect(pos + eY * (4/8) * mySize.y, s, vec2(0.5 * mySize.x, (1.5/8) * mySize.y), autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	s = sprintf("^1%s ^7(%d)", getcommandkey_forcename(_("No"), "vno"), vote_nocount);
	drawcolorcodedstring_aspect(pos + vec2(0.5 * mySize.x, (4/8) * mySize.y), s, vec2(0.5 * mySize.x, (1.5/8) * mySize.y), autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	pos.y += (5/8) * mySize.y;
	vector tmp_size = vec2(mySize.x, (3/8) * mySize.y);
	// draw the progress bar backgrounds
	drawpic(pos, "gfx/hud/old/voteprogress_back", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	// draw the highlights
	if(vote_highlighted == 1) {
		drawsetcliparea_builtin(pos.x, pos.y, mySize.x * 0.5, mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_voted", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}
	else if(vote_highlighted == -1) {
		drawsetcliparea_builtin(pos.x + 0.5 * mySize.x, pos.y, mySize.x * 0.5, mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_voted", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	// draw the progress bars
	if(vote_yescount && vote_needed)
	{
		drawsetcliparea_builtin(pos.x, pos.y, mySize.x * 0.5 * (vote_yescount/vote_needed), mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_prog", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	if(vote_nocount && vote_needed)
	{
		drawsetcliparea_builtin(pos.x + mySize.x - mySize.x * 0.5 * (vote_nocount/vote_needed), pos.y, mySize.x * 0.5, mySize.y);
		drawpic(pos, "gfx/hud/old/voteprogress_prog", tmp_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	drawresetcliparea();

	drawfont = oldfont;
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
	int myitems = STAT(ITEMS); // changed field due to reaching bit limit
	//int mypowerups = STAT(POWERUPS);
	string pic;

	if(myitems & IT_TANK)
		return;

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
		
	Sbar_DrawPic('112 0 0', pic);
}

void Sbar_DrawHealth()
{
	int myhealth = rint(STAT(HEALTH));
	vector hpcolor = (STAT(HEALTH) <= 25) ? '1 0 0' : '1 1 1';
	bool have_fieldgen = (StatusEffects_active(STATUSEFFECT_FieldGen, g_statuseffects) && STAT(FIELDGEN_HEALTH) > 0);
	if(have_fieldgen)
	{
		myhealth += rint(STAT(FIELDGEN_HEALTH));
		hpcolor = '0 1 1';
	}
	Sbar_DrawNum('136 0 0', itos(myhealth), 3, hpcolor);
}

void Sbar_DrawShieldOverlay()
{
	if(time > STAT(SHIELD_TIME) || !StatusEffects_active(STATUSEFFECT_Shield, g_statuseffects))
		return;

	drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '1 0 0', bound(0, 0.5 * (STAT(SHIELD_TIME) - time), 0.025), DRAWFLAG_NORMAL);
}

void Sbar_DrawChampionNotice()
{
	float oldfont = drawfont; // since this is a modern panel, it can use modern fonts
	drawfont = 8; // FONT_USER

	vector panel_pos = vec2(0.45 * vid_conwidth, 0.85 * vid_conheight);
	vector panel_size = vec2(0.09 * vid_conwidth, 0.09 * vid_conheight);

	vector pos, mySize;
	pos = panel_pos;
	mySize = panel_size;

	// always force 3:1 aspect
	vector newSize = '0 0 0';
	if(mySize.x/mySize.y > 3)
	{
		newSize.x = 3 * mySize.y;
		newSize.y = mySize.y;

		pos.x = pos.x + (mySize.x - newSize.x) / 2;
	}
	else
	{
		newSize.y = 1/3 * mySize.x;
		newSize.x = mySize.x;

		pos.y = pos.y + (mySize.y - newSize.y) / 2;
	}
	mySize = newSize;

	string s;
	s = sprintf(_("Champion: %s"), csqcplayer.m_champion.m_name);
	drawstring_aspect(pos, s, vec2(mySize.x, (2/8) * mySize.y), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	s = sprintf(_("Press %s to swap"), getcommandkey(_("quickmenu"), "quickmenu"));
	drawstring_aspect(pos + eY * (4/8) * mySize.y, s, vec2(mySize.x, (2/8) * mySize.y), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}

entity oldchampion;
float champion_messagetime;
void Sbar_DrawChampionOverlay()
{
	if(csqcplayer && csqcplayer.m_champion != oldchampion && !csqcplayer.m_champion.qcc_noselect)
	{
		oldchampion = csqcplayer.m_champion;
		champion_messagetime = time + 6;
	}
	if(csqcplayer && csqcplayer.m_champion && csqcplayer.m_champion.m_overlay)
		csqcplayer.m_champion.m_overlay(csqcplayer.m_champion);

	if(csqcplayer.m_champion && time < champion_messagetime)
	{
		Sbar_DrawChampionNotice();
	}
}

void Sbar_Draw()
{
	if(!getproperty(VF_DRAWENGINESBAR)) // drawing in engine turned off, fall back to qc implementation
	{
		if(sbar == '0 0 0')
		{
			sbar.x = (vid_conwidth - 320)/2;
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

		Sbar_DrawShieldOverlay();

		Sbar_DrawChampionOverlay();

		// always draw push notifications?
		Sbar_DrawNotify();

		Sbar_DrawVotes();

		if(cursor_active)
			{} // no special handling
		if(sb_showscores || STAT(HEALTH) == -666) // hacky check to see if we're spectating
			Sbar_DrawScoreboard();
		else if(intermission == 1)
			Sbar_IntermissionOverlay();
		else if(intermission == 2)
			Sbar_FinaleOverlay();
		else // Quake
		{
			sbar.x = (vid_conwidth - 320)/2;
			sbar.y = vid_conheight - SBAR_HEIGHT;
			sbar.z = 0;

			if(sb_lines > 24)
			{
				Sbar_DrawInventory();
				//if(maxclients > 1)
					//Sbar_DrawFrags();
			}

			if(sb_showscores || (STAT(HEALTH) <= 0 && autocvar_cl_deathscoreboard))
			{
				Sbar_DrawAlphaPic('0 0 0', "gfx/quake/scorebar", autocvar_sbar_alpha_bg);
				Sbar_DrawScoreboard();
			}
			else if(sb_lines)
			{
				vector bgcolor = '1 1 1';
				if(STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL && STAT(DODGEBALL_TEAM) > 0)
				{
					if(STAT(DODGEBALL_TEAM) == 1)
						bgcolor = '1 0.7 0.1';
					else if(STAT(DODGEBALL_TEAM) == 2)
						bgcolor = '0.1 1 0.1';
				}
				Sbar_DrawAlphaPic_Color('0 0 0', "gfx/quake/sbar", autocvar_sbar_alpha_bg, bgcolor);

				// keys (hipnotic only)
				//MED 01/04/97 moved keys here so they would not be overwritten
				// armor
				if(StatusEffects_active(STATUSEFFECT_Invulnerability, g_statuseffects) && !(STAT(ITEMS) & IT_TANK))
				{
					Sbar_DrawNum('24 0 0', itos(666), 3, '0 1 1');
					Sbar_DrawPic('0 0 0', "gfx/quake/disc");
				}
				else
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
						Sbar_DrawPic('0 0 0', apic);
						Sbar_DrawNum('24 0 0', itos(getstati(STAT_ARMOR)), 3, ((getstati(STAT_ARMOR) <= 25) ? '1 0 0' : '1 1 1'));
					}
				}

				// face
				Sbar_DrawFace();

				// health
				Sbar_DrawHealth();

				entity thiswep = viewmodels[0]; // TODO: unhardcode
				if(STAT(SKATING) || (STAT(ITEMS) & IT_TANK))
					{ /* nothing */}
				else if(STAT(WORLDTYPE) == WORLDTYPE_DODGEBALL)
					Sbar_DrawNum('248 0 0', itos(ceil(STAT(STAMINA))), 3, ((STAT(STAMINA) <= 10) ? '1 0 0' : '1 1 1'));
				else if(thiswep.activeweapon.spawnflags & WEP_FLAG_MANA)
					Sbar_DrawNum('248 0 0', itos(ceil(STAT(MANA))), 3, ((STAT(MANA) <= 10) ? '1 0 0' : '1 1 1'));
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
					// need to call drawpic directly here as the original ammo size is 24 pixels...
					drawpic(sbar + '224 0 0', strcat("gfx/quake/", pic), '24 24 0', '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
				}
				else
				{
					// ammo icon
					int ammotype = thiswep.activeweapon.ammo_type;
					string pic = Sbar_ItemIcon(ammotype);

					if(pic)
					{
						Sbar_DrawPic('224 0 0', strcat("gfx/quake/", pic));
						Sbar_DrawNum('248 0 0', itos(Sbar_ItemStat(ammotype)), 3, ((Sbar_ItemStat(ammotype) <= 10) ? '1 0 0' : '1 1 1'));
					}
				}

				// LordHavoc: changed to draw the deathmatch overlays in any multiplayer mode
				if(maxclients > 1 || !coop)
				{
					Sbar_MiniDeathmatchOverlay(vec2(sbar.x + 324, vid_conheight - 8 * 8));
					Sbar_Score(24);
				}
			}
		}
	}

	//if(autocvar_cl_prydoncursor > 0)
		//draw_cursor_normal(mousepos, '1 1 1', 0.8);
}
