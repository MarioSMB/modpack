#include "galena.qh"

bool galena_canblock(entity actor)
{
#ifdef SVQC
	.entity weaponentity = weaponentities[0];
	if(actor.(weaponentity).m_weapon.spawnflags & WEP_FLAG_TWOHANDED)
		return false;
#endif
#ifdef CSQC
	if(viewmodels[0].activeweapon.spawnflags & WEP_FLAG_TWOHANDED)
		return false;
#endif
	return true;
}

METHOD(Galena, m_getmovespeed, float(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_ATCK2(actor) && galena_canblock(actor))
		return 0.25;
	return 0.9;
}

#ifdef SVQC
METHOD(Galena, m_takedamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	if(targ.m_champion == this && PHYS_INPUT_BUTTON_ATCK2(targ) && galena_canblock(targ))
		return 0.25;
	return 1;
}

METHOD(Galena, m_activate, void(Champions this, entity actor))
{
	float r = random();
	if(r < 0.33)
		player_sound(actor, CH_VOICE, "abl1.wav", ATTN_NORM);
	else if(r < 0.66)
		player_sound(actor, CH_VOICE, "abl2.wav", ATTN_NORM);
	else
		player_sound(actor, CH_VOICE, "abl3.wav", ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 5) - 1, 4);
}
#endif
