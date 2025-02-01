#include "mini.qh"

#ifdef SVQC
void minishroom_ResetSize(entity this)
{
    STAT(PL_MIN, this) = autocvar_sv_player_mins;
    STAT(PL_MAX, this) = autocvar_sv_player_maxs;
    STAT(PL_VIEW_OFS, this) = autocvar_sv_player_viewoffset;
    STAT(PL_CROUCH_MIN, this) = autocvar_sv_player_crouch_mins;
    STAT(PL_CROUCH_MAX, this) = autocvar_sv_player_crouch_maxs;
    STAT(PL_CROUCH_VIEW_OFS, this) = autocvar_sv_player_crouch_viewoffset;
}

METHOD(Mini, m_remove, void(StatusEffect this, entity actor, int removal_type))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(removal_type == STATUSEFFECT_REMOVE_TIMEOUT && wasactive && IS_PLAYER(actor))
    {
        //Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_POWERDOWN_MINI, actor.netname);
        Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_POWERDOWN_MINI);
    }
    if(wasactive)
    {
        stopsound(actor, CH_TRIGGER_SINGLE); // get rid of the pickup sound
        if(IS_DUCKED(actor))
            setsize(actor, autocvar_sv_player_crouch_mins, autocvar_sv_player_crouch_maxs);
        else
            setsize(actor, autocvar_sv_player_mins, autocvar_sv_player_maxs);
        actor.scale = 0; // 0 is default, it'll do for now
        if(actor.mini_oldgravity)
        {
            actor.gravity = ((actor.trigger_gravity_check) ? actor.trigger_gravity_check.enemy.gravity : actor.mini_oldgravity);
            if(actor.gravity == 1)
                actor.gravity = 0; // just reset it
        }
        actor.mini_oldgravity = 0;
        actor.dphitcontentsmask &= ~DPCONTENTS_LIQUIDSMASK;
        // physics doesn't run while player is dead, so we must assume defaults here
        minishroom_ResetSize(actor);
        vector offset = '0 0 -1' * (PL_MIN_CONST.z - (PL_MIN_CONST.z * max(0, autocvar_g_powerup_mini_size)));
        setorigin(actor, actor.origin + offset + '0 0 1'); // restore player's location
        tracebox(actor.origin, actor.mins, actor.maxs, actor.origin, MOVE_NOMONSTERS, actor);
        // if player is going to be stuck in solid when they grow, just kill them
        if(trace_startsolid)
             Damage(actor, actor, actor, 100000, DEATH_VH_CRUSH.m_id, DMG_NOWEP, actor.origin, '0 0 0');
    }
    SUPER(Mini).m_remove(this, actor, removal_type);
}
METHOD(Mini, m_apply, void(StatusEffect this, entity actor, float eff_time, float eff_flags))
{
    bool wasactive = (actor.statuseffects && (actor.statuseffects.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_ACTIVE));
    if(!wasactive && IS_PLAYER(actor))
    {
        if(!g_cts)
            Send_Notification(NOTIF_ALL, NULL, MSG_INFO, INFO_POWERUP_MINI, actor.netname);
        Send_Notification(NOTIF_ONE, actor, MSG_CENTER, CENTER_POWERUP_MINI);
        float myscale = max(0, autocvar_g_powerup_mini_size);
        STAT(PL_MIN, actor) = PL_MIN_CONST * myscale;
        STAT(PL_MAX, actor) = PL_MAX_CONST * myscale;
        STAT(PL_CROUCH_MIN, actor) = PL_CROUCH_MIN_CONST * myscale;
        STAT(PL_CROUCH_MAX, actor) = PL_CROUCH_MAX_CONST * myscale;
        STAT(PL_VIEW_OFS, actor) = PL_VIEW_OFS_CONST * myscale;
        STAT(PL_CROUCH_VIEW_OFS, actor) = PL_CROUCH_VIEW_OFS_CONST * myscale;
        if(IS_DUCKED(actor))
            setsize(actor, STAT(PL_CROUCH_MIN, actor), STAT(PL_CROUCH_MAX, actor));
        else
            setsize(actor, STAT(PL_MIN, actor), STAT(PL_MAX, actor));
        actor.mini_oldgravity = ((actor.gravity != 0) ? actor.gravity : 1);
        actor.scale = myscale;
        actor.gravity = autocvar_g_powerup_mini_gravity;
    }
    SUPER(Mini).m_apply(this, actor, eff_time, eff_flags);
}
METHOD(Mini, m_tick, void(StatusEffect this, entity actor))
{
    play_countdown(actor, StatusEffects_gettime(this, actor), SND_POWEROFF);
    SUPER(Mini).m_tick(this, actor);
}
#endif
#ifdef CSQC
AUTOCVAR_SAVE(hud_progressbar_mini_color,   vector,   '0.2 0.2 0.8',   "");

METHOD(Mini, m_tick, void(StatusEffect this, entity actor))
{
    if(this.m_hidden)
        return;

    float currentTime = (autocvar__hud_configure) ? 15 : bound(0, actor.statuseffect_time[this.m_id] - time, 99);
    addPowerupItem(this.m_name, this.m_icon, autocvar_hud_progressbar_mini_color, currentTime, this.m_lifetime, (actor.statuseffect_flags[this.m_id] & STATUSEFFECT_FLAG_PERSISTENT));
}
#endif
