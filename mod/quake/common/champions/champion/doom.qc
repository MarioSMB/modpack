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

METHOD(Doom, m_damage, float(Doom this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	Weapon death_weapon = DEATH_WEAPONOF(deathtype);
	if(death_weapon.spawnflags & WEP_FLAG_MELEE)
		return 3;
	else
		return 1;
}
#endif
