#include "doom.qh"

#ifdef SVQC
METHOD(Doom, m_activate, void(Doom this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Doom, m_takeammo, bool(Doom this, entity actor))
{
	return (random() < 0.2);
}

METHOD(Doom, m_killed, void(Champions this, entity targ, entity inflictor, entity attacker, int deathtype))
{
	if(attacker.m_champion == this && IS_MONSTER(targ))
		targ.health = -100;
}

METHOD(Doom, m_dealdamage, float(Doom this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	Weapon death_weapon = DEATH_WEAPONOF(deathtype);
	if(attacker.m_champion == this)
	{
		if(death_weapon.spawnflags & WEP_FLAG_MELEE)
			return 3;
		else if(death_weapon == WEP_SHOTGUN || death_weapon == WEP_SUPER_SHOTGUN)
			return 1.5;
		else
			return 1;
	}
	else
		return 1;
}
#endif
