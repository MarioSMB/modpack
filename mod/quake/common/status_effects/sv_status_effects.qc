#include "sv_status_effects.qh"

METHOD(StatusEffects, m_active, bool(StatusEffects this, entity actor))
{
	TC(StatusEffects, this);
	if(!actor.statuseffects)
		return false; // safety net
	return (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE);
}

METHOD(StatusEffects, m_tick, void(StatusEffects this, entity actor))
{
	StatusEffects data = actor.statuseffects;
	.int flg = statuseffect_flags[this.m_id];
	int oldflag = data.(flg);
	data.(flg) = BITSET(data.(flg), STATUSEFFECT_FLAG_PERSISTENT, this.m_persistent(this, actor));
	if(oldflag != data.(flg))
		StatusEffects_update(actor);

	if(data.(flg) & STATUSEFFECT_FLAG_PERSISTENT)
		return;
	if(time > actor.statuseffects.statuseffect_time[this.m_id])
	{
		this.m_remove(this, actor, STATUSEFFECT_REMOVE_TIMEOUT);
		return;
	}
}

METHOD(StatusEffects, m_apply, void(StatusEffects this, entity actor, float eff_time, float eff_flags))
{
	if(!actor.statuseffects)
		StatusEffects_new(actor);

	eff_flags |= STATUSEFFECT_FLAG_ACTIVE; // automatically enable active flag if applied (TODO?)
	actor.statuseffects.statuseffect_time[this.m_id] = eff_time; // TODO: add onto the existing time rather than replacing it?
	actor.statuseffects.statuseffect_flags[this.m_id] = eff_flags;
	StatusEffects_update(actor);
}

METHOD(StatusEffects, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
	StatusEffects data = actor.statuseffects;
	if(!data)
		return;
	// NOTE: persistent effects do not make a sound on removal, this is intended as a workaround for #2620
	if(removal_type == STATUSEFFECT_REMOVE_NORMAL && !(data.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_PERSISTENT) && this.m_active(this, actor))
		sound(actor, CH_TRIGGER, this.m_sound_rm, VOL_BASE, ATTEN_NORM);
	data.statuseffect_time[this.m_id] = 0;
	data.statuseffect_flags[this.m_id] = 0;
	StatusEffects_update(actor);
}

void status_effects_SV_StartFrame()
{
	if(gameover || intermission_running)
		return;
	// TODO: explicitly only loop through entities with a valid statuseffects object
	// NOTE: due to the way vehicles work currently, this does not function correctly! effect does not tick while inside a vehicle
	IL_EACH(g_damagedbycontents, it.damagedbycontents,
	{
		if (it.move_movetype == MOVETYPE_NOCLIP || !it.statuseffects) continue;
		StatusEffects_tick(it);
	});
}

void status_effects_PlayerDies(entity this)
{
	entity frag_target = this;

	StatusEffects_removeall(frag_target, STATUSEFFECT_REMOVE_NORMAL);
}

bool status_effects_ClientDisconnect(entity this)
{
	entity player = this;

	StatusEffects_removeall(player, STATUSEFFECT_REMOVE_NORMAL); // just to get rid of the pickup sound
	return true;
}

void status_effects_PutClientInServer(entity this)
{
	entity player = this;

	if(player.statuseffects && player.statuseffects.owner == player)
	{
		StatusEffects_clearall(player.statuseffects);
		StatusEffects_update(player);
	}
	else
	{
		StatusEffects_clearall(player.statuseffects_store);
		player.statuseffects = NULL;
	}
}
