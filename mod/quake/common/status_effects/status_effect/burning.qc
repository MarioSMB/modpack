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
        float damage = (IS_PLAYER(actor) ? 1 : 10);
        T_Damage(actor, NULL, NULL, damage, DEATH_BURNING.m_id);
        actor.burning_time = time + 1;
    }

    if(!IS_PLAYER(actor))
    {
        float mytime = StatusEffects_gettime(STATUSEFFECT_Burning, actor) - time;
        mytime *= 0.75; // so it won't be infinite looping
        if(mytime > 0)
        {
            FOREACH_ENTITY_RADIUS(actor.origin, 100, it.takedamage,
            {
                if(IS_PLAYER(it))
                    continue;
                if(it.charmed && actor.charmed)
                    continue;
                if(StatusEffects_active(STATUSEFFECT_Burning, it))
                    continue;
                StatusEffects_apply(STATUSEFFECT_Burning, it, time + mytime, 0);
            });
        }
    }

    actor.effects |= EF_FLAME;
    SUPER(Burning).m_tick(this, actor);
}
#endif
