#include "corrosion.qh"

#ifdef SVQC
METHOD(Corrosion, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    SUPER(Corrosion).m_remove(this, actor, removal_type);
}
METHOD(Corrosion, m_tick, void(StatusEffects this, entity actor))
{
    if(time > actor.corrosion_time)
    {
        particle(actor.origin, '0 0 0', 57, 10);
        actor.corrosion_time = time + 0.25;
    }
    SUPER(Corrosion).m_tick(this, actor);
}
#endif

#ifdef CSQC
METHOD(Corrosion, m_tick, void(StatusEffects this, entity actor))
{
    drawfill('0 0 0', vec2(vid_conwidth, vid_conheight), this.m_color, 0.1, DRAWFLAG_NORMAL);
    SUPER(Corrosion).m_tick(this, actor);
}
#endif
