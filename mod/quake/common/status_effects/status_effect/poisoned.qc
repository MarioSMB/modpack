#include "poisoned.qh"

#ifdef SVQC
METHOD(Poisoned, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    SUPER(Poisoned).m_remove(this, actor, removal_type);
}
METHOD(Poisoned, m_tick, void(StatusEffects this, entity actor))
{
    if((actor.powerups & POWERUP_INVULNERABILITY) || (actor.powerups & POWERUP_SUIT))
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    if(time > actor.poisoned_time)
    {
        T_Damage(actor, NULL, NULL, 1, DEATH_POISONED.m_id);
        actor.poisoned_time = time + 1;
    }
    SUPER(Poisoned).m_tick(this, actor);
}
#endif
