#include "squire.qh"

METHOD(Squire, m_getmovespeed, float(Champions this, entity actor))
{
	if(actor.skin == 1)
		return 1.33;
	return 0.8;
}

#ifdef SVQC
METHOD(Squire, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this)
		return 0.75;
	return 1;
}

METHOD(Squire, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(attacker.m_champion == this && attacker.skin == 1)
		return 1.5;
	return 1;
}

METHOD(Squire, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Squire_Start_Random(), ATTN_NORM);

	STAT(RAGECHARGE, actor) = 0;
}

METHOD(Squire, m_footsteps, bool(Champions this, entity actor))
{
	sound(actor, CH_PLAYER, SND_Squire_Step_Random(), 0.5, ATTN_NORM);
	return true;
}

METHOD(Squire, m_playerthink, void(Champions this, entity actor))
{
	if(actor.skin == 0 && PHYS_INPUT_BUTTON_CROUCH(actor) && STAT(RAGECHARGE, actor) <= 0 && QCC_CanCastAbility(actor))
	{
		if(random() < 0.15)
			sound(actor, CH_PLAYER, SND_Squire_Rage_Reee, 1, ATTN_NORM);
		else
			sound(actor, CH_PLAYER, SND_Squire_Rage_Start, 1, ATTN_NORM);
		actor.skin = 1;
		STAT(QCC_ABILITYTIME, actor) = time + 20; // incase the player tries to cheese swap
		STAT(RAGECHARGE, actor) = 100;
		actor.last_rageloss = time + 0.2;
	}

	if(actor.skin == 1 && time > actor.last_ragesound)
	{
		actor.last_ragesound = time + 2.5;
		sound(actor, CH_PLAYER_SINGLE, SND_Squire_Rage_Loop, 1, ATTN_NORM);
	}

	if(actor.skin == 1 && time > actor.last_rageloss && STAT(RAGECHARGE, actor) > 0)
	{
		actor.last_rageloss = time + 0.2;
		int points = 1;
		if(deathmatch)
			points = 2;

		STAT(RAGECHARGE, actor) -= points;
		if(STAT(RAGECHARGE, actor) <= 0)
		{
			sound(actor, CH_PLAYER, SND_Squire_Rage_End, 1, ATTN_NORM);
			STAT(RAGECHARGE, actor) = 0;
			STAT(QCC_ABILITYTIME, actor) = time + 20;
			actor.skin = 0;
			stopsound(actor, CH_PLAYER_SINGLE);
		}
	}
}

METHOD(Squire, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && attacker.skin == 1 && (IS_MONSTER(targ) || (deathmatch && IS_PLAYER(targ))))
	{
		float points = 5;
		if(deathmatch)
			points = 15;
		STAT(RAGECHARGE, attacker) = min(STAT(RAGECHARGE, attacker) + points, 100);
	}
}

METHOD(Squire, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Squire_Start4, ATTN_NORM);
	actor.squire_cannon = true;
}

METHOD(Squire, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.squire_cannon)
		return false;
	stopsound(actor, CH_PLAYER_SINGLE);
	actor.squire_cannon = false;
	actor.jump_flag = 0;
	return false;
}

METHOD(Squire, m_playerspawn, void(Champions this, entity actor))
{
	STAT(RAGECHARGE, actor) = 0;
}

METHOD(Squire, m_clear, void(Champions this, entity actor))
{
	if(actor.skin == 1)
		stopsound(actor, CH_PLAYER_SINGLE);
	STAT(RAGECHARGE, actor) = 0;
}
#endif

#ifdef CSQC
METHOD(Squire, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/squire_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}

METHOD(Squire, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) <= 0)
		return;

	if(csqcplayer.skin == 1)
		drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '1 0 0', 0.075, DRAWFLAG_NORMAL);

	if(sb_showscores)
		return;

	float oldfont = drawfont;
	drawfont = 8;

	// NOTE: relies on enyo champion loading cvars
	// TODO: generic charge bar position
	vector panel_pos = stov(cvar_string("sbar_enyo_pos"));
	vector panel_size = stov(cvar_string("sbar_enyo_size"));

	HUD_Panel_ScalePosSize();

	vector pos = panel_pos;

	vector mySize = panel_size;

	vector col = '1 0 0';
	float charge = STAT(RAGECHARGE);
	if(charge)
		charge /= 100;

	if(csqcplayer.skin == 0 && STAT(QCC_ABILITYTIME) > time)
	{
		string s;
		s = ftos(max(0, rint(STAT(QCC_ABILITYTIME) - time)));
		drawstring_aspect(pos - vec2(0, mySize.y * 0.5), s, vec2(mySize.x, mySize.y * 0.7), '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	}

	HUD_Panel_DrawProgressBar(pos + vec2(mySize.x * 0.08, mySize.y * 0.25), vec2(mySize.x * 0.92, mySize.y * 0.5), "progressbar", charge, false, 0, col, 0.6, DRAWFLAG_NORMAL);
	drawpic(pos, "gfx/quake/squire_ragecharge", mySize, '1 1 1', 1 * autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}
#endif
