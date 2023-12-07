#include "antigrav.qh"

#ifdef SVQC
METHOD(Antigrav, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.antigrav_warning = false;
    actor.gravity = 1.0;
    SUPER(Antigrav).m_remove(this, actor, removal_type);
}
METHOD(Antigrav, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.antigrav_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_ANTIGRAV);
        _sound(actor, CH_TRIGGER_SINGLE, "belt/fadeout.wav", 1, ATTN_NORM);
        actor.antigrav_warning = true;
    }
    actor.gravity = 0.25;
    SUPER(Antigrav).m_tick(this, actor);
}
#endif
