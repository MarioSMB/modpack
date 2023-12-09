#include "chief.qh"

#ifdef SVQC
METHOD(Chief, m_activate, void(Chief this, entity actor))
{
	player_sound(actor, CH_VOICE, "start.wav", ATTN_NORM);
}

METHOD(Chief, m_pickup_armor, void(Chief this, entity actor, entity item))
{
	actor.field_generator_health = max(actor.field_generator_health, item.armorvalue);
	actor.field_generator_time = -150;
	float ftime = 20;
	float curtime = StatusEffects_gettime(STATUSEFFECT_FieldGen, actor);
	if((time + ftime) > curtime)
		StatusEffects_apply(STATUSEFFECT_FieldGen, actor, time + ftime, 0);
}

bool chief_visible(entity this, entity targ)
{
	traceline(this.origin + this.view_ofs, targ.origin + targ.view_ofs, MOVE_NOMONSTERS, this);
	if(trace_fraction != 1)
		return false;
	return true;
}

METHOD(Chief, m_playerthink, void(Chief this, entity actor))
{
	if(PHYS_INPUT_BUTTON_CROUCH(actor) && QCC_CanCastAbility(actor))
	{
		player_sound(actor, CH_VOICE, "radar.wav", ATTN_NORM);
		int targlimit = 0;
		FOREACH_ENTITY_RADIUS(actor.origin, 750, IS_MONSTER(it) && it.health > 0 && !it.charmed,
		{
			targlimit += 1;
			if(targlimit > 20)
				break;
			if(!chief_visible(actor, it))
				it.enemy_reveal_time = time + 2;
		});
		STAT(QCC_ABILITYTIME, actor) = time + 6;
	}
}
#endif
