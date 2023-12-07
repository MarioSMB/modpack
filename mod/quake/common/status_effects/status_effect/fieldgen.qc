#include "fieldgen.qh"

#ifdef SVQC
METHOD(FieldGen, m_remove, void(StatusEffects this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(wasactive)
        _sound(actor, CHAN_AUTO, "weapons/field/genstop.wav", 1, ATTN_NORM);
    actor.field_generator_time = 0;
    actor.field_generator_health = 0;
    actor.effects &= ~EF_BRIGHTFIELD;
    SUPER(FieldGen).m_remove(this, actor, removal_type);
}
METHOD(FieldGen, m_tick, void(StatusEffects this, entity actor))
{
    if(actor.field_generator_health <= 0)
    {
        this.m_remove(this, actor, STATUSEFFECT_REMOVE_NORMAL);
        return;
    }
    float curtime = StatusEffects_gettime(this, actor);
    if(actor.field_generator_sound < time)
    {
        _sound(actor, CHAN_AUTO, "weapons/field/genpulse.wav", 1, ATTN_NORM);
        actor.field_generator_sound = time + 1.8;
    }
    if(curtime < time + 10)
    {
        if(actor.field_generator_time <= 1)
        {
            _sound(actor, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
            actor.field_generator_time = time + 1;
        }
        if(actor.field_generator_time < time)
            actor.field_generator_time = time + 1;
    }
    else if(actor.field_generator_health <= 10 && actor.field_generator_time <= -10)
    {
        _sound(actor, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
        actor.field_generator_time = 1;
    }
    else if(actor.field_generator_health <= 50 && actor.field_generator_time <= -50)
    {
        _sound(actor, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
        actor.field_generator_time = -10;
    }
    else if(actor.field_generator_health <= 150 && actor.field_generator_time == -150)
    {
        _sound(actor, CHAN_AUTO, "weapons/field/genlev.wav", 1, ATTN_NORM);
        actor.field_generator_time = -50;
    }
    else
    {
         if(actor.field_generator_health <= 100 && random() > (actor.field_generator_health / 50))
            actor.effects |= EF_BRIGHTFIELD;
        else if(curtime < (time + 10) && random() > ((curtime - time) / 5))
            actor.effects |= EF_BRIGHTFIELD;
        else
            actor.effects &= ~EF_BRIGHTFIELD;
    }
    SUPER(FieldGen).m_tick(this, actor);
}
#endif
