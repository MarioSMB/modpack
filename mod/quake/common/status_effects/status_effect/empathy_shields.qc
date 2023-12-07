#include "empathy_shields.qh"

#ifdef SVQC
METHOD(EmpathyShields, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.empathyshields_warning = false;
    actor.effects &= ~EF_DIMLIGHT;
    SUPER(EmpathyShields).m_remove(this, actor, removal_type);
}
METHOD(EmpathyShields, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.empathyshields_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_EMPATHY);
        _sound(actor, CH_TRIGGER_SINGLE, "items/suit2.wav", 1, ATTN_NORM);
        actor.empathyshields_warning = true;
    }
    actor.effects |= EF_DIMLIGHT;
    SUPER(EmpathyShields).m_tick(this, actor);
}
#endif
