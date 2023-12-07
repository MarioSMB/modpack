#include "shield.qh"

#ifdef SVQC
METHOD(Shield, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.shield_warning = false;
    actor.effects &= ~EF_DIMLIGHT;
    SUPER(Shield).m_remove(this, actor, removal_type);
}
METHOD(Shield, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.shield_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_SHIELD);
        _sound(actor, CH_TRIGGER_SINGLE, "shield/fadeout.wav", 1, ATTN_NORM);
        actor.shield_warning = true;
    }
    actor.effects |= EF_DIMLIGHT;
    SUPER(Shield).m_tick(this, actor);
}
#endif
