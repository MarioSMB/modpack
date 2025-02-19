#include "levitation.qh"

#ifdef SVQC
METHOD(Levitation, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    actor.gravity = 1.0;
    SUPER(Levitation).m_remove(this, actor, removal_type);
}
METHOD(Levitation, m_tick, void(StatusEffects this, entity actor))
{
    actor.gravity = 0.25;
    actor.velocity_z += 0.33 * PHYS_GRAVITY(this) * PHYS_INPUT_FRAMETIME;
    UNSET_ONGROUND(actor);
    SUPER(Levitation).m_tick(this, actor);
}
#endif
