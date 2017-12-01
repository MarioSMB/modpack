AUTOCVAR_SAVE(cl_snowproblem,          bool,  true,  "Show snow around the player (for that extra cool view)");
AUTOCVAR_SAVE(cl_snowproblem_radius,   float, 500,  "");
AUTOCVAR_SAVE(cl_snowproblem_height,   float, 250,  "");
AUTOCVAR_SAVE(cl_snowproblem_count,    int,   250,  "");
AUTOCVAR_SAVE(cl_snowproblem_speed,    vector,'0 0 -100',  "");

REGISTER_MUTATOR(snow, true);

MUTATOR_HOOKFUNCTION(snow, HUD_Draw_overlay)
{
    if(!autocvar_cl_snowproblem)
        return false;

    vector org = view_origin + '0 0 1' * autocvar_cl_snowproblem_height;
    vector thesize = '1 1 0' * autocvar_cl_snowproblem_radius;
    thesize.z = 3;

    te_particlesnow(org - thesize, org + thesize, autocvar_cl_snowproblem_speed, floor(autocvar_cl_snowproblem_count * drawframetime + random()), 12);
}
