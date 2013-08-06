float turret_stdproc_targetscore_support(entity _turret,entity _target)
{
    float score;        // Total score
    float s_score = 0, d_score;

    if (_turret.enemy == _target) s_score = 1;

    d_score = min(_turret.target_range_optimal,tvt_dist) / max(_turret.target_range_optimal,tvt_dist);

    score = (d_score * _turret.target_select_rangebias) +
            (s_score * _turret.target_select_samebias);

    return score;
}

/*
* Generic bias aware score system.
*/
float turret_stdproc_targetscore_generic(entity _turret, entity _target)
{
    float d_dist;       // Defendmode Distance
    float score;        // Total score
    float d_score;      // Distance score
    float a_score;      // Angular score
    float m_score = 0;  // missile score
    float p_score = 0;  // player score
    float ikr;          // ideal kill range

    if (_turret.tur_defend)
    {
        d_dist = vlen(real_origin(_target) - _turret.tur_defend.origin);
        ikr = vlen(_turret.origin - _turret.tur_defend.origin);
        d_score = 1 - d_dist / _turret.target_range;
    }
    else
    {
        // Make a normlized value base on the targets distance from our optimal killzone
        ikr = _turret.target_range_optimal;
        d_score = min(ikr, tvt_dist) / max(ikr, tvt_dist);
    }

    a_score = 1 - tvt_thadf / _turret.aim_maxrot;

    if ((_turret.target_select_missilebias > 0) && (_target.flags & FL_PROJECTILE))
        m_score = 1;

    if ((_turret.target_select_playerbias > 0) && IS_CLIENT(_target))
        p_score = 1;

    d_score = max(d_score, 0);
    a_score = max(a_score, 0);
    m_score = max(m_score, 0);
    p_score = max(p_score, 0);

    score = (d_score * _turret.target_select_rangebias) +
            (a_score * _turret.target_select_anglebias) +
            (m_score * _turret.target_select_missilebias) +
            (p_score * _turret.target_select_playerbias);

    if(_turret.target_range < vlen(_turret.tur_shotorg - real_origin(_target)))
    {
        //dprint("Wtf?\n");
        score *= 0.001;
    }

#ifdef TURRET_DEBUG
    string sd,sa,sm,sp,ss;
    string sdt,sat,smt,spt;

    sd = ftos(d_score);
    d_score *= _turret.target_select_rangebias;
    sdt = ftos(d_score);

    //sv = ftos(v_score);
    //v_score *= _turret.target_select_samebias;
    //svt = ftos(v_score);

    sa = ftos(a_score);
    a_score *= _turret.target_select_anglebias;
    sat = ftos(a_score);

    sm = ftos(m_score);
    m_score *= _turret.target_select_missilebias;
    smt = ftos(m_score);

    sp = ftos(p_score);
    p_score *= _turret.target_select_playerbias;
    spt = ftos(p_score);


    ss = ftos(score);
    bprint("^3Target scores^7 \[  ",_turret.netname, "  \] ^3for^7 \[  ", _target.netname,"  \]\n");
    bprint("^5Range:\[  ",sd,  "  \]^2+bias:\[  ",sdt,"  \]\n");
    bprint("^5Angle:\[  ",sa,  "  \]^2+bias:\[  ",sat,"  \]\n");
    bprint("^5Missile:\[  ",sm,"  \]^2+bias:\[  ",smt,"  \]\n");
    bprint("^5Player:\[  ",sp, "  \]^2+bias:\[  ",spt,"  \]\n");
    bprint("^3Total (w/bias):\[^1",ss,"\]\n");

#endif

    return score;
}

/*
float turret_stdproc_targetscore_close(entity _turret,entity _target)
{
    return 1 - (tvt_dist / _turret.target_range);
}

float turret_stdproc_targetscore_far (entity _turret,entity _target)
{
    return  tvt_dist / _turret.target_range;
}

float turret_stdproc_targetscore_optimal(entity _turret,entity _target)
{
    return  min(_turret.target_range_optimal,tvt_dist) / max(_turret.target_range_optimal,tvt_dist);
}

float turret_stdproc_score_angular(entity _turret,entity _target)
{
    return 1 - (tvt_thadf / _turret.aim_maxrot);
}

float turret_stdproc_targetscore_defend(entity _turret,entity _target)
{
    return 0;
    //min(_target.origin,_turret.tur_defend.origin) / max(_target.origin,_turret.tur_defend.origin);
}
*/
