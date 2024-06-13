#ifdef SVQC

const int FUNC_FADE_STATE_HIDDEN = 0;
const int FUNC_FADE_STATE_VISIBLE = 1;

const float FUNC_FADE_DISTANCE_MAXSPEED = 320; 

float func_fade_get_shortest_playerdistance(entity this)
{
    float dist = 32767;
    entity nearest = NULL;
    FOREACH_CLIENT(true,
    {
        vector vpos = it.origin + it.view_ofs;
        float newdist = vlen2(this.oldorigin - vpos);
        if(!nearest || newdist < dist)
        {
            dist = newdist;
            nearest = it;
        }
    });
    return (nearest) ? vlen(this.oldorigin - (nearest.origin + nearest.view_ofs)) : 32767;
}

void func_fade_set_nextthink_for_distance(entity this, float dist)
{
    this.nextthink = this.ltime + bound(0.05, dist / FUNC_FADE_DISTANCE_MAXSPEED, 2.0);
}

void func_fade_set_alpha(entity this, float a, float force)
{
    a = bound(0, a, 1);
    if(!force && fabs(a - this.alpha) < 0.001)
        return;
    if(this.state == FUNC_FADE_STATE_HIDDEN && a > 0)
    {
        this.state = FUNC_FADE_STATE_VISIBLE;
        _setmodel(this, this.mdl);
    }
    else if(this.state == FUNC_FADE_STATE_VISIBLE && a == 0)
    {
        this.state = FUNC_FADE_STATE_HIDDEN;
        setmodel(this, MDL_Null);
    }
    this.alpha = a;
}

void func_fade_think(entity this)
{
    float dist = func_fade_get_shortest_playerdistance(this);
    float diff = dist - this.distance;

    if(diff < 0)
    {
        //Outside the transition zone, inside the circle
        func_fade_set_alpha(this, 1, false);
        dist = -diff;
        func_fade_set_nextthink_for_distance(this, dist);
    }
    else if(diff > this.lip)
    {
        //Outside the transition zone, outside the circle
        func_fade_set_alpha(this, 0, false);
        dist = diff - this.lip;
        func_fade_set_nextthink_for_distance(this, dist);
    }
    else
    {
        //In the transition zone
        diff /= this.lip;
        func_fade_set_alpha(this, 1 - diff, false);
        this.nextthink = this.ltime + 0.05;
    }
}

spawnfunc(func_fade)
{
#if 1
    if(true)
    {
        LOG_DEBUG("WARNING: A func_fade was spawned. This entity is obsolete, and was converted to a func_wall instead.");
        spawnfunc_func_wall(this);
        return;
    }
#else

    if(!this.distance) this.distance = 2048; //Radius of fade circle
    if(!this.lip) this.lip = 256; // Lip around fade circle

    this.waitmax = this.distance + this.lip;

    this.solid = SOLID_BSP;
    set_movetype(this, MOVETYPE_PUSH);

    this.mdl = this.model;
    _setmodel(this, this.mdl);
    this.oldorigin = this.mins + ((this.maxs - this.mins) * 0.5);

    this.state = FUNC_FADE_STATE_VISIBLE;

    setthink(this, func_fade_think);
    this.nextthink = this.ltime + 0.2 + random() * 0.2;

    func_fade_set_alpha(this, 0, true);
#endif
}
#endif
