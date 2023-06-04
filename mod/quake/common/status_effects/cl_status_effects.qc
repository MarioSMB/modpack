#include "cl_status_effects.qh"

METHOD(StatusEffects, m_active, bool(StatusEffects this, entity actor))
{
	if(!actor) return false;
	TC(StatusEffects, this);
	return (actor.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE);
}

METHOD(StatusEffects, m_tick, void(StatusEffects this, entity actor))
{
	if(this.m_hidden)
		return;

	//float currentTime = bound(0, actor.statuseffect_time[this.m_id] - time, 99);
	//addPowerupItem(this.m_name, this.m_icon, this.m_color, currentTime, this.m_lifetime, (actor.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_PERSISTENT));
}

void status_effects_HUD_Powerups_add()
{
	if(!g_statuseffects) return;

	// NOTE: the passed entity may be null here if we're in configure mode
	StatusEffects_tick(g_statuseffects);
}
