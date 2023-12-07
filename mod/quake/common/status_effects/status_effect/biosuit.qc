#include "biosuit.qh"

#ifdef SVQC
METHOD(Biosuit, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.biosuit_warning = false;
    SUPER(Biosuit).m_remove(this, actor, removal_type);
}
METHOD(Biosuit, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.biosuit_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_BIOSUIT);
        _sound(actor, CH_TRIGGER_SINGLE, "items/suit2.wav", 1, ATTN_NORM);
        actor.biosuit_warning = true;
    }
    actor.air_finished = time + 12;
    SUPER(Biosuit).m_tick(this, actor);
}
#endif
