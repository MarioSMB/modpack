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
	{
		if(deathmatch)
			return 0.75;
		return 0.5;
	}
	return 1;
}

METHOD(BigJohn, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	Weapon death_weapon = DEATH_WEAPONOF(deathtype);
	if(attacker.m_champion == this)
	{
		if(death_weapon.ammo_type == IT_ROCKETS || death_weapon.ammo_type == IT_MULTI_ROCKETS)
			return 1.5;
		else
			return 1;
	}
	else
		return 1;
}

METHOD(BigJohn, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, SND_BigJohn_Start_Random(), ATTN_NORM);

	actor.skin = bound(0, (etof(actor) % 5) - 1, 4);
}

METHOD(BigJohn, m_playerspawn, void(Champions this, entity actor))
{
	actor.skin = bound(0, (etof(actor) % 5) - 1, 4);
}

METHOD(BigJohn, m_playerthink, void(Champions this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_VOICE, SND_BigJohn_Ability, ATTN_NORM);
		STAT(QCC_ABILITYTIME, actor) = time + 3.25;
	}
}

METHOD(BigJohn, m_cannon_launch, void(Champions this, entity actor, entity cannon))
{
	player_sound(actor, CH_PLAYER_SINGLE, SND_BigJohn_Ability, ATTN_NORM);
	actor.bigjohn_cannon = true;
}

METHOD(BigJohn, m_cannon_land, bool(Champions this, entity actor))
{
	if(!actor.bigjohn_cannon)
		return false;
	stopsound(actor, CH_PLAYER_SINGLE);
	actor.bigjohn_cannon = false;
	return false;
}
#endif
