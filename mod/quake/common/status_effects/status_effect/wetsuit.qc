#include "wetsuit.qh"

#ifdef SVQC
METHOD(Wetsuit, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.wetsuit_warning = false;
    SUPER(Wetsuit).m_remove(this, actor, removal_type);
}
METHOD(Wetsuit, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.wetsuit_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_WETSUIT);
        _sound(actor, CH_TRIGGER_SINGLE, "items/suit2.wav", 1, ATTN_NORM);
        actor.wetsuit_warning = true;
    }
    actor.air_finished = time + 12;
    SUPER(Wetsuit).m_tick(this, actor);
}
#endif
