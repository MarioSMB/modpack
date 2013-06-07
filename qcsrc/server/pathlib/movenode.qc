vector pathlib_wateroutnode(vector start,vector end, float doedge)
{
    vector surface;

    pathlib_movenode_goodnode = 0;

    end_x = fsnap(end_x, pathlib_gridsize);
    end_y = fsnap(end_y, pathlib_gridsize);

    traceline(end + ('0 0 0.25' * pathlib_gridsize),end - ('0 0 1' * pathlib_gridsize),MOVE_WORLDONLY,self);
    end = trace_endpos;

    if not(pointcontents(end - '0 0 1') == CONTENT_SOLID)
        return end;

    for(surface = start ; surface_z < (end_z + 32); ++surface_z)
    {
        if(pointcontents(surface) == CONTENT_EMPTY)
            break;
    }

    if(pointcontents(surface + '0 0 1') != CONTENT_EMPTY)
        return end;

    tracebox(start + '0 0 64', movenode_boxmin,movenode_boxmax, end + '0 0 64', MOVE_WORLDONLY, self);
    if(trace_fraction == 1)
        pathlib_movenode_goodnode = 1;

    if(fabs(surface_z - end_z) > 32)
        pathlib_movenode_goodnode = 0;

    return end;
}

vector pathlib_swimnode(vector start,vector end, float doedge)
{
    pathlib_movenode_goodnode = 0;

    if(pointcontents(start) != CONTENT_WATER)
        return end;

    end_x = fsnap(end_x, pathlib_gridsize);
    end_y = fsnap(end_y, pathlib_gridsize);

    if(pointcontents(end) == CONTENT_EMPTY)
        return pathlib_wateroutnode( start, end, doedge);

    tracebox(start, movenode_boxmin,movenode_boxmax, end, MOVE_WORLDONLY, self);
    if(trace_fraction == 1)
        pathlib_movenode_goodnode = 1;

    return end;
}

vector pathlib_flynode(vector start,vector end, float doedge)
{
    pathlib_movenode_goodnode = 0;

    end_x = fsnap(end_x, pathlib_gridsize);
    end_y = fsnap(end_y, pathlib_gridsize);

    tracebox(start, movenode_boxmin,movenode_boxmax, end, MOVE_WORLDONLY, self);
    if(trace_fraction == 1)
        pathlib_movenode_goodnode = 1;

    return end;
}

void a_think()
{
    te_lightning1(self,self.origin, self.pos1);
    if(self.cnt < time)
        remove(self);
    else
        self.nextthink = time + 0.2;
}

vector pathlib_walknode(vector start,vector end,float doedge)
{
    vector direction,point,last_point,s,e;
    float steps, distance, i;

    dprint("Walking node from ", vtos(start), " to ", vtos(end), "\n");

    pathlib_movenode_goodnode = 0;

    end_x = fsnap(end_x,pathlib_gridsize);
    end_y = fsnap(end_y,pathlib_gridsize);
    start_x = fsnap(start_x,pathlib_gridsize);
    start_y = fsnap(start_y,pathlib_gridsize);

    // Find the floor
    traceline(start + movenode_stepup, start - movenode_maxdrop, MOVE_WORLDONLY, self);
    if(trace_fraction == 1.0)
    {
        entity a;
        a = spawn();
        a.think = a_think;
        a.nextthink = time;
        setorigin(a,start + movenode_stepup);
        a.pos1 = trace_endpos;
        //start - movenode_maxdrop
        a.cnt = time + 10;

        dprint("I cant walk on air!\n");
        return trace_endpos;
    }

    start = trace_endpos;

    // Find the direcion, without Z
    s   = start; e   = end;
    //e_z = 0; s_z = 0;
    direction = normalize(e - s);

    distance  = vlen(start - end);
    steps     = rint(distance / movenode_stepsize);

    last_point = start;
    for(i = 1; i < steps; ++i)
    {
        point = last_point + (direction * movenode_stepsize);
        traceline(point + movenode_stepup,point - movenode_maxdrop,MOVE_WORLDONLY,self);
        if(trace_fraction == 1.0)
            return trace_endpos;

        last_point = trace_endpos;
    }

    point = last_point + (direction * movenode_stepsize);
    point_x = fsnap(point_x,pathlib_gridsize);
    point_y = fsnap(point_y,pathlib_gridsize);

    //dprint("end_x:  ",ftos(end_x),  "  end_y:  ",ftos(end_y),"\n");
    //dprint("point_x:",ftos(point_x),"  point_y:",ftos(point_y),"\n\n");

    traceline(point + movenode_stepup, point - movenode_maxdrop,MOVE_WORLDONLY,self);
    if(trace_fraction == 1.0)
        return trace_endpos;

    last_point = trace_endpos;

    tracebox(start + movenode_boxup, movenode_boxmin,movenode_boxmax, last_point + movenode_boxup, MOVE_WORLDONLY, self);
    if(trace_fraction != 1.0)
        return trace_endpos;

    pathlib_movenode_goodnode = 1;
    return last_point;
}
