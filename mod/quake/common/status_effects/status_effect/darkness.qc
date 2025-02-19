#include "inked.qh"

#ifdef SVQC
METHOD(Darkness, m_tick, void(StatusEffects this, entity actor))
{
    if(StatusEffects_active(STATUSEFFECT_Biosuit, actor))
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    SUPER(Darkness).m_tick(this, actor);
}
#endif

#ifdef CSQC
METHOD(Darkness, m_tick, void(StatusEffects this, entity actor))
{
    if(StatusEffects_active(STATUSEFFECT_Biosuit, actor))
        return;
    drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), '0 0 0', bound(0.2, sin(time * 2), 0.6), DRAWFLAG_NORMAL);
    SUPER(Darkness).m_tick(this, actor);
}
#endif
