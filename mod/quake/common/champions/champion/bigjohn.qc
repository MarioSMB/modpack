#include "bigjohn.qh"

METHOD(BigJohn, m_getmovespeed, float(Champions this, entity actor))
{
	if(time < STAT(QCC_ABILITYTIME, actor))
		return 1.33;
	return 0.85;
}

#ifdef SVQC
METHOD(BigJohn, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this)
		return 0.5;
	return 1;
}

METHOD(BigJohn, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, ((random() < 0.5) ? "bigjabl1.wav" : "bigjabl2.wav"), ATTN_NORM);
}

METHOD(BigJohn, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_VOICE, "ability.wav", ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 3.25;
	}
}

METHOD(BigJohn, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "ability.wav", ATTN_NORM);
	actor.bigjohn_cannon = true;
}

METHOD(BigJohn, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.bigjohn_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.bigjohn_cannon = false;
	return false;
}
#endif
