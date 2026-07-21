#include "weakness.qh"

#ifdef SVQC
METHOD(Weakness, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    actor.weakness_strength = 0;
    actor.effects &= ~EF_SHOCK;
    SUPER(Weakness).m_remove(this, actor, removal_type);
}
METHOD(Weakness, m_tick, void(StatusEffects this, entity actor))
{
    actor.effects |= EF_SHOCK;
    SUPER(Weakness).m_tick(this, actor);
}
#endif
