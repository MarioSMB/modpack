#include "sharp_shooter.qh"

#ifdef SVQC
METHOD(SharpShooter, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.sharpshooter_warning = false;
    SUPER(SharpShooter).m_remove(this, actor, removal_type);
}
METHOD(SharpShooter, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(curtime < time + 3 && !actor.sharpshooter_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_SHARPSHOOTER);
        _sound(actor, CH_TRIGGER_SINGLE, "items/sharp2.wav", 1, ATTN_NORM);
        actor.sharpshooter_warning = true;
    }
    SUPER(SharpShooter).m_tick(this, actor);
}
#endif
