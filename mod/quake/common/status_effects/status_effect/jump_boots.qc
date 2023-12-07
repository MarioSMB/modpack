#include "jump_boots.qh"

#ifdef SVQC
METHOD(JumpBoots, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.jumpboots_warning = false;
    SUPER(JumpBoots).m_remove(this, actor, removal_type);
}
METHOD(JumpBoots, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.jumpboots_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_JUMPBOOTS);
        _sound(actor, CH_TRIGGER_SINGLE, "items/jboots_timed.wav", 1, ATTN_NORM);
        actor.jumpboots_warning = true;
    }
    SUPER(JumpBoots).m_tick(this, actor);
}
#endif
