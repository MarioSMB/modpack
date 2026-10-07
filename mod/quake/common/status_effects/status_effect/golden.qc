#include "golden.qh"

#ifdef SVQC
METHOD(Golden, m_persistent, bool(StatusEffects this, entity actor))
{
    return actor.is_golden;
}

METHOD(Golden, m_tick, void(StatusEffects this, entity actor))
{
    if(time > actor.golden_time)
    {
        Send_Effect(EFFECT_GOLDEN, (actor.absmin + actor.absmax) * 0.5, '0 0 0', 1);
        actor.golden_time = time + 1;
    }

    SUPER(Golden).m_tick(this, actor);
}
#endif
