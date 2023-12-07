#include "burning.qh"

#ifdef SVQC
METHOD(Burning, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    actor.effects &= ~EF_FLAME;
    actor.burning_time = 0;
    SUPER(Burning).m_remove(this, actor, removal_type);
}
METHOD(Burning, m_tick, void(StatusEffects this, entity actor))
{
    if(StatusEffects_active(STATUSEFFECT_Invulnerability, actor) || StatusEffects_active(STATUSEFFECT_Biosuit, actor) || (actor.waterlevel && actor.watertype != CONTENT_LAVA))
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    if(time > actor.burning_time)
    {
        T_Damage(actor, NULL, NULL, 1, DEATH_BURNING.m_id);
        actor.burning_time = time + 1;
    }
    actor.effects |= EF_FLAME;
    SUPER(Burning).m_tick(this, actor);
}
#endif
