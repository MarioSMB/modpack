#include "poisoned.qh"

#ifdef SVQC
METHOD(Poisoned, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    SUPER(Poisoned).m_remove(this, actor, removal_type);
}
METHOD(Poisoned, m_tick, void(StatusEffects this, entity actor))
{
    if(StatusEffects_active(STATUSEFFECT_Invulnerability, actor) || StatusEffects_active(STATUSEFFECT_Biosuit, actor))
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    if(time > actor.poisoned_time)
    {
        float poison_dmg = 1;
        if(IS_MONSTER(actor))
            poison_dmg = 5;
        T_Damage(actor, NULL, NULL, poison_dmg, DEATH_POISONED.m_id);
        actor.poisoned_time = time + 1;
    }
    SUPER(Poisoned).m_tick(this, actor);
}
#endif

#ifdef CSQC
METHOD(Poisoned, m_tick, void(StatusEffects this, entity actor))
{
    drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '0.56 0.99 0.55', 0.1, DRAWFLAG_NORMAL);
    SUPER(Poisoned).m_tick(this, actor);
}
#endif
