#include "slowness.qh"

#ifdef SVQC
METHOD(Slowness, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    actor.effects &= ~EF_SHOCK;
    SUPER(Slowness).m_remove(this, actor, removal_type);
}
#if 0
// TODO: some infinite source of stunning? e.g. some electric current
METHOD(Slowness, m_persistent, bool(StatusEffects this, entity actor))
{
    return true;
}
#endif
METHOD(Slowness, m_tick, void(StatusEffects this, entity actor))
{
    if(actor.is_frozen)
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    actor.effects |= EF_SHOCK;
    SUPER(Slowness).m_tick(this, actor);
}
#endif
