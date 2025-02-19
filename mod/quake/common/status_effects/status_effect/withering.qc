#include "withering.qh"

#ifdef SVQC
METHOD(Withering, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    SUPER(Withering).m_remove(this, actor, removal_type);
}
METHOD(Withering, m_tick, void(StatusEffects this, entity actor))
{
    if(StatusEffects_active(STATUSEFFECT_Invulnerability, actor))
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    if(time > actor.withering_time)
    {
        float wither_dmg = 5;
        if(IS_MONSTER(actor))
            wither_dmg = 10;
        T_Damage(actor, NULL, NULL, wither_dmg, DEATH_WITHERING.m_id);
        actor.withering_time = time + 2;
    }
    SUPER(Withering).m_tick(this, actor);
}
#endif
