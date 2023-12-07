#include "invisibility.qh"

#ifdef SVQC
void invis_loseaggro(entity this)
{
    FOREACH_ENTITY_FLAGS(flags, FL_MONSTER,
    {
        if(it.enemy == this && it.health > 0 && !it.elec)
            invis_enemy_dropaggro(it);
    });
}

METHOD(Invisibility, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    actor.invisible_warning = false;
    actor.alpha = 1;
    SUPER(Invisibility).m_remove(this, actor, removal_type);
}
METHOD(Invisibility, m_apply, void(StatusEffects this, entity actor, float eff_time, float eff_flags))
{
    if(IS_PLAYER(actor))
        invis_loseaggro(actor);
    SUPER(Invisibility).m_apply(this, actor, eff_time, eff_flags);
}
METHOD(Invisibility, m_tick, void(StatusEffects this, entity actor))
{
    float curtime = StatusEffects_gettime(this, actor);
    if(actor.invisible_sound < time && !actor.invisible_warning)
    {
        _sound(actor, CH_TRIGGER_SINGLE, "items/inv3.wav", 0.5, ATTN_IDLE);
        actor.invisible_sound = time + ((random() * 3) + 1);
    }
    if(curtime < time + 3 && !actor.invisible_warning)
    {
        if(!horde_ent)
            Send_Notification(NOTIF_ONE, actor, MSG_MULTI, POWERDOWN_INVISIBLE);
        _sound(actor, CH_TRIGGER_SINGLE, "items/inv2.wav", 1, ATTN_NORM);
        actor.invisible_warning = true;
    }
    actor.alpha = 0.25;
    SUPER(Invisibility).m_tick(this, actor);
}
#endif
