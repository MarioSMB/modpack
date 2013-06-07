float fsnap(float val,float fsize)
{
    return rint(val / fsize) * fsize;
}

vector vsnap(vector point,float fsize)
{
    vector vret;

    vret_x = rint(point_x / fsize) * fsize;
    vret_y = rint(point_y / fsize) * fsize;
    vret_z = ceil(point_z / fsize) * fsize;

    return vret;
}

float location_isok(vector point, float water_isok, float air_isok)
{
    float pc,pc2;

    if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
        return 0;

    pc  = pointcontents(point);
    pc2 = pointcontents(point - '0 0 1');

    switch(pc)
    {
        case CONTENT_SOLID:
            break;

        case CONTENT_SLIME:
            break;

        case CONTENT_LAVA:
            break;

        case CONTENT_SKY:
            break;

        case CONTENT_EMPTY:
            if (pc2 == CONTENT_SOLID)
                return 1;

            if (pc2 == CONTENT_EMPTY)
                if(air_isok)
                    return 1;

            if (pc2 == CONTENT_WATER)
                if(water_isok)
                    return 1;

            break;

        case CONTENT_WATER:
            if (water_isok)
                return 1;

            break;
    }

    return 0;
}

entity pathlib_nodeatpoint(vector where)
{
    entity node;

    ++pathlib_searched_cnt;

    where_x = fsnap(where_x,pathlib_gridsize);
    where_y = fsnap(where_y,pathlib_gridsize);

    node = findradius(where,pathlib_gridsize * 0.5);
    while(node)
    {
        if(node.is_path_node == TRUE)
            return node;

        node = node.chain;
    }

    return world;
}

float tile_check_cross(vector where)
{
    vector p,f,r;

    f = PLIB_FORWARD * tile_check_size;
    r = PLIB_RIGHT   * tile_check_size;


    // forward-right
    p = where + f + r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if not (location_isok(trace_endpos, 1, 0))
        return 0;

    // Forward-left
    p = where + f - r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if not (location_isok(trace_endpos, 1, 0))
        return 0;

    // Back-right
    p = where - f + r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if not (location_isok(trace_endpos, 1 ,0))
        return 0;

    //Back-left
    p = where - f - r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if not (location_isok(trace_endpos, 1, 0))
        return 0;

    return 1;
}

float tile_check_plus(vector where)
{
    vector p,f,r;

    f = PLIB_FORWARD * tile_check_size;
    r = PLIB_RIGHT   * tile_check_size;

    // forward
    p = where + f;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if not (location_isok(trace_endpos,1,0))
        return 0;


    //left
    p = where - r;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if not (location_isok(trace_endpos,1,0))
        return 0;

    // Right
    p = where + r;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if not (location_isok(trace_endpos,1,0))
        return 0;

    //Back
    p = where - f;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if not (location_isok(trace_endpos,1,0))
        return 0;

    return 1;
}

float tile_check_plus2(vector where)
{
    vector p,f,r;
    float i = 0, e = 0;

    f = PLIB_FORWARD * pathlib_gridsize;
    r = PLIB_RIGHT   * pathlib_gridsize;

//#define pathlib_node_edgeflag_left    2
//#define pathlib_node_edgeflag_right   4
//#define pathlib_node_edgeflag_forward 8
//#define pathlib_node_edgeflag_back    16

    // forward
    p = where + f;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if (location_isok(trace_endpos,1,0))
    {
       ++i;
       e |= pathlib_node_edgeflag_forward;
    }


    //left
    p = where - r;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if (location_isok(trace_endpos,1,0))
    {
       ++i;
       e |= pathlib_node_edgeflag_left;
    }


    // Right
    p = where + r;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if (location_isok(trace_endpos,1,0))
    {
       ++i;
       e |= pathlib_node_edgeflag_right;
    }

    //Back
    p = where - f;
    traceline(p+tile_check_up,p-tile_check_down,MOVE_WORLDONLY,self);
    if (location_isok(trace_endpos,1,0))
    {
       ++i;
       e |= pathlib_node_edgeflag_back;
    }

    // forward-right
    p = where + f + r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if (location_isok(trace_endpos, 1, 0))
    {
       ++i;
       e |= pathlib_node_edgeflag_forwardright;
    }

    // Forward-left
    p = where + f - r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if (location_isok(trace_endpos, 1, 0))
    {
       ++i;
       e |= pathlib_node_edgeflag_forwardleft;
    }

    // Back-right
    p = where - f + r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if (location_isok(trace_endpos, 1 ,0))
    {
       ++i;
       e |= pathlib_node_edgeflag_backright;
    }

    //Back-left
    p = where - f - r;
    traceline(p + tile_check_up, p - tile_check_down, MOVE_WORLDONLY, self);
    if (location_isok(trace_endpos, 1, 0))
    {
       ++i;
       e |= pathlib_node_edgeflag_backleft;
    }


    if(i == 0)
        e = pathlib_node_edgeflag_none;

    return e;
}

float tile_check_star(vector where)
{
    if(tile_check_plus(where))
        return tile_check_cross(where);

    return 0;
}

