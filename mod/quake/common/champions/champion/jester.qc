#include "jester.qh"

#include "squire.qh"

METHOD(Jester, m_getmovespeed, float(Champions this, entity actor))
{
	return 1.2;
}

#ifdef SVQC
METHOD(Jester, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Jester_Start_Random(), ATTN_NORM);
	Inventory_add(WEP_BISHOP, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
	{
		W_SwitchWeapon(actor, WEP_BISHOP, weaponentity);
		actor.(weaponentity).cnt = WEP_AXE.m_id;
	}
}

METHOD(Jester, m_playerspawn, void(Champions this, entity actor))
{
	Inventory_add(WEP_BISHOP, actor, ITEM_OWNED);

	.entity weaponentity = weaponentities[0]; // TODO?
	if(actor.(weaponentity).m_weapon == WEP_SHOTGUN)
	{
		W_SwitchWeapon(actor, WEP_BISHOP, weaponentity);
		actor.(weaponentity).cnt = WEP_AXE.m_id;
	}
}

METHOD(Jester, m_playerthink, void(Champions this, entity actor))
{
	if(!deathmatch && PHYS_INPUT_BUTTON_CROUCH(actor) && !PHYS_INPUT_BUTTON_MINIGAME(actor) && QCC_CanCastAbility(actor))
	{
		wheel_start(actor);
		STAT(QCC_ABILITYTIME, actor) = time + 1; // slight cooldown but not major yet!
	}
}

METHOD(Jester, m_footsteps, bool(Champions this, entity actor))
{
	sound(actor, CH_PLAYER, SND_Jester_Step_Random(), 1, ATTN_NORM);
	return true;
}

METHOD(Jester, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(attacker.m_champion == this && (deathtype & HITTYPE_MAGIC))
		return 1.5;
	return 1;
}

METHOD(Jester, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Jester_Falling, ATTN_NORM);
	actor.jester_cannon = true;
}

METHOD(Jester, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.jester_cannon)
		return false;
	player_sound(actor, CH_PLAYER_SINGLE, SND_Jester_Cannon_Land, ATTN_NORM);
	actor.jester_cannon = false;
	actor.jump_flag = 0;
	return false;
}
#endif

#ifdef CSQC
METHOD(Jester, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/jester_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, "gfx/quake/backtile", icon_size, '1 1 1', autocvar_sbar_alpha_bg, DRAWFLAG_NORMAL);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}

METHOD(Jester, m_overlay, void(Champions this))
{
	if(intermission || STAT(HEALTH) <= 0)
		return;

	if(sb_showscores)
		return;
	if(time >= STAT(QCC_ABILITYTIME))
		return;

	float oldfont = drawfont;
	drawfont = 8;

	// NOTE: relies on enyo champion loading cvars
	// TODO: generic charge bar position
	vector panel_pos = stov(cvar_string("sbar_enyo_pos"));
	vector panel_size = stov(cvar_string("sbar_enyo_size"));

	HUD_Panel_ScalePosSize();

	if(autocvar_sbar_edit)
		drawfill(panel_pos, panel_size, '1 0 0', 0.25, DRAWFLAG_NORMAL);

	vector pos = panel_pos;
	vector mySize = panel_size;

	vector icon_size = vec2(mySize.x * 0.2, mySize.y);
	vector icon_pos = pos + vec2(mySize.x - icon_size.x, 0);
	vector text_pos = icon_pos - vec2(0, mySize.y);
	vector text_size = vec2(icon_size.x, mySize.y * 0.8);

	if(autocvar_sbar_edit)
		drawfill(icon_pos, icon_size, '0 1 0', 0.2, DRAWFLAG_NORMAL);

	if(autocvar_sbar_edit)
		drawfill(text_pos, text_size, '0 1 1', 0.1, DRAWFLAG_NORMAL);

	string s;
	s = ftos(max(0, rint(STAT(QCC_ABILITYTIME) - time)));
	drawstring_aspect(text_pos, s, text_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawpic_aspect(icon_pos, "gfx/quake/wheel_icon", icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);

	drawfont = oldfont;
}
#endif
