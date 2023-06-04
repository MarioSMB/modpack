#include "status_effects.qh"

#ifdef GAMEQC
bool StatusEffects_active(StatusEffects this, entity actor)
{
	return this.m_active(this, actor);
}

void StatusEffects_tick(entity actor)
{
	FOREACH(StatusEffect, it.m_active(it, actor),
	{
		it.m_tick(it, actor);
	});
}

float StatusEffects_gettime(StatusEffects this, entity actor)
{
	entity store = actor;
#ifdef SVQC
	store = actor.statuseffects;
#endif
	if(!store) return 0;
	return store.statuseffect_time[this.m_id];
}
#endif
#ifdef SVQC
void StatusEffects_apply(StatusEffects this, entity actor, float eff_time, int eff_flags)
{
	this.m_apply(this, actor, eff_time, eff_flags);
}

void StatusEffects_copy(StatusEffects this, entity store, float time_offset)
{
	if(!this || !store)
		return;
	FOREACH(StatusEffect, true,
	{
		if(time_offset)
			store.statuseffect_time[it.m_id] = time + this.statuseffect_time[it.m_id] - time_offset;
		else
			store.statuseffect_time[it.m_id] = this.statuseffect_time[it.m_id];
		store.statuseffect_flags[it.m_id] = this.statuseffect_flags[it.m_id];
	});
}

void StatusEffects_remove(StatusEffects this, entity actor, int removal_type)
{
	this.m_remove(this, actor, removal_type);
}

void StatusEffects_removeall(entity actor, int removal_type)
{
	if(!actor.statuseffects)
		return;
	FOREACH(StatusEffect, true,
	{
		it.m_remove(it, actor, removal_type);
	});
}
#endif
