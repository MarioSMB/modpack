#include "bigjohn.qh"

METHOD(BigJohn, m_getmovespeed, float(BigJohn this, entity actor))
{
	if(time < STAT(QCC_ABILITYTIME, actor))
		return 1.33;
	return 0.66;
}

#ifdef SVQC
METHOD(BigJohn, m_damage, float(BigJohn this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this)
	{
		if(time < STAT(QCC_ABILITYTIME, targ))
			return 0.33;
		else
			return 1.66;
	}
	if(attacker.m_champion == this)
	{
		if(time < STAT(QCC_ABILITYTIME, targ))
			return 1.2;
		else
			return 0.8;
	}
	return 1;
}

METHOD(BigJohn, m_activate, void(BigJohn this, entity actor))
{
	player_sound(actor, CH_VOICE, ((random() < 0.5) ? "bigjabl1.wav" : "bigjabl2.wav"), ATTN_NORM);
}

METHOD(BigJohn, m_playerthink, void(BigJohn this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_VOICE, "ability.wav", ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 3.25;
	}
	actor.armorvalue = min(actor.armorvalue, 50); 
}
#endif
