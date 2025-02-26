#include "monkey.qh"

#ifdef SVQC
METHOD(Monkey, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "monkey_start.wav", ATTN_NORM);

	STAT(WEAPONS, actor) |= WEP_MAGIC.m_wepset;
}

METHOD(Monkey, m_weaponframe, bool(Champions this, entity actor, .entity weaponentity))
{
	// no regular weapon use!
	return true;
}

METHOD(Monkey, m_playerthink, void(Champions this, entity actor))
{
	if(actor.m_transform == this && PHYS_INPUT_BUTTON_CROUCH(actor) && time >= STAT(QCC_ABILITYTIME, actor)) //&& QCC_CanCastAbility(actor))
	{
		actor.shantae_transformtime = time + 0.5; // prevent player voices on transform
		_sound(actor, CH_VOICE, "player_shantae/player_transform.wav", 1, ATTN_NORM);
		QCC_ClearTransform(actor);
		te_explosion2(actor.origin, 40, 7);
		STAT(QCC_ABILITYTIME, actor) = time + 1;
	}
}

METHOD(Monkey, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	_sound(actor, CH_TRIGGER_SINGLE, "shantae/h2odeath.wav", 1, ATTN_NORM);
	actor.monkey_cannon = true;
}

METHOD(Monkey, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.monkey_cannon)
		return false;
	_sound(actor, CH_TRIGGER_SINGLE, "shantae/land2.wav", 1, ATTN_NORM);
	actor.monkey_cannon = false;
	return false;
}
#endif
#ifdef CSQC
METHOD(Monkey, m_drawface, bool(Champions this))
{
	string pic = "gfx/quake/monkey_face";
	Sbar_DrawPic('112 0 0', pic);
	return true;
}
#endif
