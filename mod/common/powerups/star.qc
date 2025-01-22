#include "star.qh"

#ifdef SVQC
METHOD(Star, m_remove, void(StatusEffect this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(removal_type == STATUSEFFECT_REMOVE_TIMEOUT && wasactive && IS_PLAYER(actor))
    {
        //Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_POWERDOWN_STAR, actor.netname);
        Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_POWERDOWN_STAR);
    }
    if(wasactive)
    {
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
        actor.colormod = actor.star_oldcolormod;
    }
    actor.star_oldcolormod = '0 0 0';
    actor.effects &= ~(EF_DIMLIGHT | EF_FULLBRIGHT);
    SUPER(Star).m_remove(this, actor, removal_type);
}
METHOD(Star, m_apply, void(StatusEffect this, entity actor, float eff_time, float eff_flags))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(!wasactive && IS_PLAYER(actor))
    {
        if(!g_cts)
            Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_POWERUP_STAR, actor.netname);
        Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_POWERUP_STAR);
        actor.star_oldcolormod = actor.colormod;
    }
    SUPER(Star).m_apply(this, actor, eff_time, eff_flags);
}
METHOD(Star, m_tick, void(StatusEffect this, entity actor))
{
    play_countdown(actor, StatusEffects_gettime(this, actor), SND_POWEROFF);
    actor.effects |= (EF_DIMLIGHT | EF_FULLBRIGHT);
    actor.colormod = randomvec() * ((autocvar_g_player_brightness) ? autocvar_g_player_brightness : 1);
    if(time > actor.star_touch_time)
    if(!game_stopped && IS_PLAYER(actor))
    if(!IS_DEAD(actor) && !STAT(FROZEN, actor))
    if(!IS_INDEPENDENT_PLAYER(actor))
    {
        FOREACH_CLIENT(IS_PLAYER(it) && it != actor,
        {
            if(time > it.star_touch_time)
            if(!IS_DEAD(it) && !STAT(FROZEN, it))
            if(!IS_INDEPENDENT_PLAYER(it))
            if(boxesoverlap(actor.absmin, actor.absmax, it.absmin, it.absmax))
            {
                Damage(it, actor, actor, 999, DEATH_CHEAT.m_id, DMG_NOWEP, it.origin, it.origin);
                actor.star_touch_time = it.star_touch_time = time + autocvar_g_powerup_star_touch_delay;
            }
        });
    }
    SUPER(Star).m_tick(this, actor);
}
#endif
#ifdef CSQC
entity rainbowvision_noise2;

AUTOCVAR_SAVE(hud_progressbar_star_color,   vector,   '0.8 0.8 0.1',   "");

METHOD(Star, m_tick, void(StatusEffect this, entity actor))
{
    if(this.m_hidden)
        return;

    float currentTime = (autocvar__hud_configure) ? 15 : bound(0, actor.statuseffect_time[this.m_id] - time, 99);
    addPowerupItem(this.m_name, this.m_icon, autocvar_hud_progressbar_star_color, currentTime, this.m_lifetime, (actor.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_PERSISTENT));

    // apply rainbow vision effect

    if(!rainbowvision_noise2)
        rainbowvision_noise2 = new_pure(rainbowvision_noise2);

    // draw BG
    float a = Noise_Pink(rainbowvision_noise2, frametime * 1.5) * 0.05 + 0.15;
    vector rgb = '1 1 1';
    vector tc_00 = '0 0 0' + '0.2 0 0' * sin(time * 0.3) + '0 0.3 0' * cos(time * 0.7);
    vector tc_01 = '0 2.25 0' + '0.6 0 0' * cos(time * 1.2) - '0 0.3 0' * sin(time * 2.2);
    vector tc_10 = '1.5 0 0' - '0.2 0 0' * sin(time * 0.5) + '0 0.5 0' * cos(time * 1.7);
    //tc_11 = '1 1 0' + '0.6 0 0' * sin(time * 0.6) + '0 0.3 0' * cos(time * 0.1);
    vector tc_11 = tc_01 + tc_10 - tc_00;
    R_BeginPolygon("gfx/rainbow.tga", DRAWFLAG_ADDITIVE, true);
    R_PolygonVertex('0 0 0', tc_00, rgb, a);
    R_PolygonVertex(autocvar_vid_conwidth * '1 0 0', tc_10, rgb, a);
    R_PolygonVertex(autocvar_vid_conwidth * '1 0 0' + autocvar_vid_conheight * '0 1 0', tc_11, rgb, a);
    R_PolygonVertex(autocvar_vid_conheight * '0 1 0', tc_01, rgb, a);
    R_EndPolygon();
}
#endif
