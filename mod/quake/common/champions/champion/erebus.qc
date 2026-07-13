#include "erebus.qh"

#ifdef SVQC
METHOD(Erebus, m_updatestats, void(Champions this, entity actor))
{
	// rough copy of Xonotic's physicsX.cfg
	STAT(MOVEVARS_MAXSPEED, actor) = 360;

	STAT(MOVEVARS_AIRACCEL_QW, actor) = -0.8;
	STAT(MOVEVARS_AIRSTRAFEACCEL_QW, actor) = -0.95;
	STAT(MOVEVARS_AIRSPEEDLIMIT_NONQW, actor) = 900;

	STAT(MOVEVARS_AIRACCEL_QW_STRETCHFACTOR, actor) = 2;
	STAT(MOVEVARS_MAXAIRSTRAFESPEED, actor) = 100;
	STAT(MOVEVARS_MAXAIRSPEED, actor) = 360;

	STAT(MOVEVARS_AIRSTRAFEACCELERATE, actor) = 18;
	STAT(MOVEVARS_WARSOWBUNNY_TURNACCEL, actor) = 0;
	STAT(MOVEVARS_AIRACCEL_SIDEWAYS_FRICTION, actor) = 0;
	STAT(MOVEVARS_AIRCONTROL, actor) = 100;
	STAT(MOVEVARS_AIRCONTROL_FLAGS, actor) = 0;
	STAT(MOVEVARS_AIRCONTROL_POWER, actor) = 2;
	STAT(MOVEVARS_AIRCONTROL_PENALTY, actor) = 0;
	STAT(MOVEVARS_WARSOWBUNNY_AIRFORWARDACCEL, actor) = 1.00001;
	STAT(MOVEVARS_WARSOWBUNNY_TOPSPEED, actor) = 925;
	STAT(MOVEVARS_WARSOWBUNNY_ACCEL, actor) = 0.1593;
	STAT(MOVEVARS_WARSOWBUNNY_BACKTOSIDERATIO, actor) = 0.8;
	STAT(MOVEVARS_FRICTION, actor) = 6;
	STAT(MOVEVARS_ACCELERATE, actor) = 15;
	STAT(MOVEVARS_STOPSPEED, actor) = 100;
	STAT(MOVEVARS_AIRACCELERATE, actor) = 2;
	STAT(MOVEVARS_AIRSTOPACCELERATE, actor) = 3;
	STAT(MOVEVARS_AIRSTOPACCELERATE_FULL, actor) = 0;
}

METHOD(Erebus, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_Erebus_Start_Random(), ATTN_NORM);
}

METHOD(Erebus, m_playerspawn, void(Champions this, entity actor))
{

}

METHOD(Erebus, m_clear, void(Champions this, entity actor))
{

}

METHOD(Erebus, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_Erebus_Falling, ATTN_NORM);
	actor.erebus_cannon = true;
}

METHOD(Erebus, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.erebus_cannon)
		return false;
	// NOTE: disabled as his voice clip is short!
	stopsound(actor, CH_PLAYER_SINGLE);
	actor.erebus_cannon = false;
	return false;
}
#endif

#ifdef CSQC
METHOD(Erebus, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/erebus_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
