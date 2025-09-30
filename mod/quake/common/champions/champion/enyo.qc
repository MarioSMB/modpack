#include "enyo.qh"

#ifdef SVQC
void enyo_WingCharge(entity this, float charge)
{
	if(STAT(WINGCHARGE, this) >= 100)
		return;

	STAT(WINGCHARGE, this) += charge;

	if(STAT(WINGCHARGE, this) >= 100)
	{
		if(random() <= 0.1)
			_sound(this, CH_VOICE, "player_enyo/friesdone.wav", 1, ATTN_NORM);
		else
			_sound(this, CH_VOICE, "player_enyo/wings.wav", 1, ATTN_NORM);
	}
}

METHOD(Enyo, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && STAT(WINGCHARGE, actor) >= 100 && QCC_CanCastAbility(actor))
	{
		_sound(actor, CH_VOICE, "player_enyo/wings_got.wav", 1, ATTN_NORM);
		//te_explosion2(actor.origin, 56, 10);
		te_teleport(actor.origin);
		actor.transform_limited = time + 15;
		actor.transform_health = 100;
		actor.m_transform = CHAMPION_Valkyrie;
		STAT(QCC_ABILITYTIME, actor) = time + 20;
	}

	if(time > actor.last_wingbonus && STAT(WINGCHARGE, actor) < 100)
	{
		actor.last_wingbonus = time + 1;
		int points = 2;
		if(deathmatch)
			points = 4;

		enyo_WingCharge(actor, points);
	}
}

METHOD(Enyo, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && (IS_MONSTER(targ) || (deathmatch && IS_PLAYER(targ))))
	{
		float points = 5;
		if(deathmatch)
			points = 15;
		enyo_WingCharge(attacker, points);
		if(random() < 0.15)
		{
			float r = random();
			if(r < 0.25)
				player_sound(attacker, CH_VOICE, "taunts/downboy.wav", ATTN_NORM);
			else if(r < 0.50)
				player_sound(attacker, CH_VOICE, "taunts/didthathurt.wav", ATTN_NORM);
			else if(r < 0.75)
				player_sound(attacker, CH_VOICE, "taunts/dogethis.wav", ATTN_NORM);
			else
				player_sound(attacker, CH_VOICE, "taunts/maniaclaugh.wav", ATTN_NORM);
		}
	}
}

METHOD(Enyo, m_activate, void(Champions this, entity actor))
{
	STAT(WINGCHARGE, actor) = 0;

	RandomSelection_Init();
	RandomSelection_AddString("taunts/beloved.wav", 1, 1);
	RandomSelection_AddString("taunts/justgettingstarted.wav", 1, 1);
	RandomSelection_AddString("taunts/maniaclaugh.wav", 1, 1);
	//RandomSelection_AddString("taunts/pinkmist.wav", 1, 1);
	RandomSelection_AddString("taunts/scrapeoffthefloor.wav", 1, 1);
	RandomSelection_AddString("taunts/targetlocked.wav", 1, 1);
	player_sound(actor, CH_VOICE, RandomSelection_chosen_string, ATTN_NORM);
}

METHOD(Enyo, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WINGCHARGE, actor) = 0;
}
#endif

#ifdef CSQC
STATIC_INIT(Enyo)
{
	registercvar("sbar_enyo_pos", "0.122 0.955");
	registercvar("sbar_enyo_size", "0.18 0.04");
}

METHOD(Enyo, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/enyo_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}

float enyo_messagetime;
float enyo_prevstatus;
METHOD(Enyo, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) <= 0 || sb_showscores)
		return;

	float oldfont = drawfont;
	drawfont = 8;

	vector panel_pos = stov(cvar_string("sbar_enyo_pos"));
	vector panel_size = stov(cvar_string("sbar_enyo_size"));

	HUD_Panel_ScalePosSize();

	vector pos = panel_pos;

	vector mySize = panel_size;

	vector col = '0 1 1';
	float charge = STAT(WINGCHARGE);
	if(charge)
		charge /= 100;

	if(charge >= 1)
	{
		col.x = time % (M_PI * 2);
		col.y = 1;
		col.z = 1;
		col = hsv_to_rgb(col);
		if(enyo_prevstatus < 1)
			enyo_messagetime = time + 6;
	}

	enyo_prevstatus = charge;

	if(charge >= 1 && time < enyo_messagetime)
	{
		string s;
		s = sprintf(_("Press %s"), getcommandkey(_("(Crouch)"), "+crouch"));
		drawstring_aspect(pos - vec2(0, mySize.y * 0.5), s, vec2(mySize.x, mySize.y * 0.33), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	HUD_Panel_DrawProgressBar(pos + vec2(mySize.x * 0.13, mySize.y * 0.25), vec2(mySize.x * 0.87, mySize.y * 0.5), "progressbar", charge, false, 0, col, 0.6, DRAWFLAG_NORMAL);
	drawpic(pos, "gfx/quake/enyo_wingcharge", mySize, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}
#endif
