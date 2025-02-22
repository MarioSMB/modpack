#include "poop.qh"

#ifdef SVQC
METHOD(Poop, m_activate, void(Poop this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Poop, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "falling.wav", ATTN_NORM);
	actor.poop_cannon = true;
}

METHOD(Poop, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.poop_cannon)
		return false;
	player_sound(actor, CH_TRIGGER_SINGLE, "land2.wav", ATTN_NORM);
	actor.poop_cannon = false;
	actor.jump_flag = 0;
	return true;
}
#endif

#ifdef CSQC
METHOD(Poop, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/poop_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
