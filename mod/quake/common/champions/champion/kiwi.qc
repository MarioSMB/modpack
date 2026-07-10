#include "kiwi.qh"

#ifdef SVQC

METHOD(KiwiChamp, m_activate, void(Champions this, entity actor))
{
	_sound(actor, CH_VOICE, "kiwi/kiwi.wav", 1, ATTN_NORM);
}

METHOD(KiwiChamp, m_weaponframe, bool(Champions this, entity actor, .entity weaponentity))
{
	// no regular weapon use!
	return true;
}

METHOD(KiwiChamp, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_ATCK(actor) && time > actor.kiwi_shoot_time && !actor.tank && !STAT(CANNON, actor))
	{
		actor.kiwi_shoot_time = time + 1;
		if(actor.spawnsilent)
		{
			float r = random() * (random() * 3);
			sound7(actor, CH_PLAYER_SINGLE, "kiwi/kiwi.wav", 1, ATTN_NORM, 100 / r, 0);
		}
		else
			_sound(actor, CH_PLAYER_SINGLE, "kiwi/kiwi.wav", 1, ATTN_NORM);
	}
}
#endif

METHOD(KiwiChamp, m_playerjump, float(Champions this, entity actor))
{
	return 1;
}

#ifdef CSQC
METHOD(KiwiChamp, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/kiwi_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
