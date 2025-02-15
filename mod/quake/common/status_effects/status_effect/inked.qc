#include "inked.qh"

#ifdef SVQC
METHOD(Inked, m_tick, void(StatusEffects this, entity actor))
{
    if(StatusEffects_active(STATUSEFFECT_Biosuit, actor))
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    SUPER(Inked).m_tick(this, actor);
}
#endif

#ifdef CSQC
PRECACHE(Inked_effect)
{
    precache_pic("gfx/blood");
}

METHOD(Inked, m_tick, void(StatusEffects this, entity actor))
{
    drawpic('0 0 0', "gfx/blood", vec2(vid_conwidth, vid_conheight), '0.1 0.1 0.1', 0.99, DRAWFLAG_NORMAL);
    SUPER(Inked).m_tick(this, actor);
}
#endif
