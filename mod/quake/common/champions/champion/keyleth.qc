#include "keyleth.qh"

#include "demon.qh"

#ifdef SVQC
METHOD(Keyleth, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		_sound(actor, CH_PLAYER_SINGLE, "demon/dhit2.wav", 1, ATTN_NORM);
		Send_Effect(EFFECT_QCC_GIB, actor.origin, '0 0 0', 4);
		actor.transform_limited = time + 20;
		actor.transform_health = 300;
		actor.m_transform = CHAMPION_Demon;
		STAT(QCC_ABILITYTIME, actor) = time + 30;
	}
}

METHOD(Keyleth, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
	STAT(WEAPONS, actor) |= WEP_MUSHROOM.m_wepset;
}

METHOD(Keyleth, m_playerspawn, void(Champions this, entity actor))
{
	STAT(WEAPONS, actor) |= WEP_MUSHROOM.m_wepset;
}

METHOD(Keyleth, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_TRIGGER_SINGLE, "death4.wav", ATTN_NORM);
	actor.keyleth_cannon = true;
}

METHOD(Keyleth, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.keyleth_cannon)
		return false;
	stopsound(actor, CH_TRIGGER_SINGLE);
	actor.keyleth_cannon = false;
	return false;
}
#endif

#ifdef CSQC
METHOD(Keyleth, m_drawplayer, void(Champions this, entity actor))
{
	if(actor.csqcmodel_isdead)
		return;
	if(!SpawnParticles_list_full(strcat("cl_particle_", EFFECT_QCC_HEALING.eent_eff_name), actor.absmin, actor.absmax, actor.velocity, actor.velocity, bound(0, frametime, 0.1), false, 0))
		boxparticles(particleeffectnum(EFFECT_QCC_HEALING), actor, actor.absmin, actor.absmax, actor.velocity, actor.velocity, bound(0, frametime, 0.1), 0);
}
#endif
