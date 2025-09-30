#include "quad.qh"

#ifdef SVQC
METHOD(Quad, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.quad_warning = false;
    actor.effects &= ~EF_DIMLIGHT;
    SUPER(Quad).m_remove(this, actor, removal_type);
}
METHOD(Quad, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.quad_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_QUAD_DAMAGE);
        _sound(actor, CH_TRIGGER_SINGLE, "items/damage2.wav", 1, ATTN_NORM);
        actor.quad_warning = true;
    }
    actor.effects |= EF_DIMLIGHT;
    SUPER(Quad).m_tick(this, actor);
}
#endif
#ifdef CSQC
METHOD(Quad, m_tick, void(StatusEffects this, entity actor))
{
    if(this.m_hidden)
        return;

    float currentTime = (autocvar_sbar_edit) ? 27 : bound(0, actor.statuseffect_time[this.m_id] - time, 99);
    addPowerupItem(this.m_name, this.m_icon, this.m_color, currentTime, this.m_lifetime, (actor.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_PERSISTENT));
}
#endif
