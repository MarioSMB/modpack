#include "confused.qh"

#ifdef SVQC
METHOD(Confused, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    actor.effects &= ~EF_STARDUST;
    SUPER(Confused).m_remove(this, actor, removal_type);
}
METHOD(Confused, m_tick, void(StatusEffects this, entity actor))
{
    actor.effects |= EF_STARDUST;
    SUPER(Confused).m_tick(this, actor);
}
#endif
