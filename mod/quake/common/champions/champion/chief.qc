#include "chief.qh"

#ifdef SVQC
METHOD(Chief, m_activate, void(Champions this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Chief, m_pickup_armor, void(Champions this, entity actor, entity item))
{
	actor.field_generator_health = max(actor.field_generator_health, item.armorvalue);
	actor.field_generator_time = -150;
	float ftime = 20;
	float curtime = StatusEffects_gettime(STATUSEFFECT_FieldGen, actor);
	if((time + ftime) > curtime)
		StatusEffects_apply(STATUSEFFECT_FieldGen, actor, time + ftime, 0);
}

METHOD(Chief, m_dealdamage, float(Champions this, entity targ, entity inflictor, entity attacker, float damage, int deathtype))
{
	Weapon death_weapon = DEATH_WEAPONOF(deathtype);
	if(attacker.m_champion == this)
	{
		if(death_weapon.ammo_type == IT_CELLS || death_weapon.ammo_type == IT_PLASMA_AMMO)
			return 1.5;
		else
			return 1;
	}
	else
		return 1;
}
#endif

#ifdef CSQC
METHOD(Chief, m_drawface, bool(Champions this, vector pos, vector icon_size))
{
	string pic = "gfx/quake/chief_face";
	//Sbar_DrawPic('112 0 0', pic);
	drawpic_aspect(pos, pic, icon_size, '1 1 1', autocvar_sbar_alpha_fg, DRAWFLAG_NORMAL);
	return true;
}
#endif
