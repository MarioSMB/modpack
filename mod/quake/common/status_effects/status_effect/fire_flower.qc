#include "fire_flower.qh"

#ifdef SVQC
METHOD(FireFlower, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.fireflower_warning = false;
    SUPER(FireFlower).m_remove(this, actor, removal_type);
}
METHOD(FireFlower, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.fireflower_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_FIREFLOWER);
        _sound(actor, CH_TRIGGER_SINGLE, "items/powerdown_mario.wav", 1, ATTN_NORM);
        actor.fireflower_warning = true;
    }
    SUPER(FireFlower).m_tick(this, actor);
}
#endif
