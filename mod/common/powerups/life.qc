#include "life.qh"

#ifdef SVQC
METHOD(Life, m_remove, void(StatusEffect this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(removal_type == STATUSEFFECT_REMOVE_TIMEOUT && wasactive && IS_PLAYER(actor))
    {
        //Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_POWERDOWN_LIFE, actor.netname);
        Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_POWERDOWN_LIFE);
    }
    if(wasactive)
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
    SUPER(Life).m_remove(this, actor, removal_type);
}
METHOD(Life, m_apply, void(StatusEffect this, entity actor, float eff_time, float eff_flags))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(!wasactive && IS_PLAYER(actor))
    {
        if(!g_cts)
            Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_POWERUP_LIFE, actor.netname);
        Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_POWERUP_LIFE);

        Heal(actor, actor, 100, RES_LIMIT_NONE);
    }
    SUPER(Life).m_apply(this, actor, eff_time, eff_flags);
}
METHOD(Life, m_tick, void(StatusEffect this, entity actor))
{
    play_countdown(actor, StatusEffects_gettime(this, actor), SND_POWEROFF);
    SUPER(Life).m_tick(this, actor);
}
#endif
#ifdef CSQC
AUTOCVAR_SAVE(hud_progressbar_life_color,   vector,   '0.8 0.2 0.2',   "");

METHOD(Life, m_tick, void(StatusEffect this, entity actor))
{
    if(this.m_hidden)
        return;

    float currentTime = (autocvar__hud_configure) ? 15 : bound(0, actor.statuseffect_time[this.m_id] - time, 99);
    addPowerupItem(this.m_name, this.m_icon, autocvar_hud_progressbar_life_color, currentTime, this.m_lifetime, (actor.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_PERSISTENT));
}
#endif
