
#ifdef TURRET_DEBUG
void mark_error(vector where,float lifetime);
void mark_info(vector where,float lifetime);
entity mark_misc(vector where,float lifetime);
#endif

void pathlib_showpath(entity start)
{
    entity e;
    e = start;
    while(e.path_next)
    {
        te_lightning1(e,e.origin,e.path_next.origin);
        e = e.path_next;
    }
}

void path_dbg_think()
{
    pathlib_showpath(self);
    self.nextthink = time + 1;
}

void __showpath2_think()
{
    #ifdef TURRET_DEBUG 
	mark_info(self.origin,1);
	#endif
    if(self.path_next)
    {
        self.path_next.think     = __showpath2_think;
        self.path_next.nextthink = time + 0.15;
    }
    else
    {
        self.owner.think     = __showpath2_think;
        self.owner.nextthink = time + 0.15;
    }
}

void pathlib_showpath2(entity path)
{
    path.think     = __showpath2_think;
    path.nextthink = time;
}


void pathlib_showsquare2(entity node ,vector ncolor,float align)
{

    node.alpha     = 0.25;
    node.scale     = pathlib_gridsize / 512.001;
    node.solid     = SOLID_NOT;

    setmodel(node,"models/pathlib/square.md3");
    setorigin(node,node.origin);
    node.colormod = ncolor;

    if(align)
    {
        traceline(node.origin + '0 0 32', node.origin - '0 0 128', MOVE_WORLDONLY, node);
        node.angles = vectoangles(trace_plane_normal);
        node.angles_x -= 90;
    }
}

void pathlib_showsquare(vector where,float goodsquare,float lifetime)
{
    entity s;

    if(!lifetime)
        lifetime = time + 30;
    else
        lifetime += time;

    s           = spawn();
    s.alpha     = 0.25;
    s.think     = SUB_Remove;
    s.nextthink = lifetime;
    s.scale     = pathlib_gridsize / 512.001;
    s.solid     = SOLID_NOT;

    if(goodsquare)
        setmodel(s,"models/pathlib/goodsquare.md3");
    else
        setmodel(s,"models/pathlib/badsquare.md3");



    traceline(where + '0 0 32',where - '0 0 128',MOVE_WORLDONLY,s);

    s.angles = vectoangles(trace_plane_normal);
    s.angles_x -= 90;
    setorigin(s,where);
}

void pathlib_showedge(vector where,float lifetime,float rot)
{
    entity e;

    if(!lifetime)
        lifetime = time + 30;
    else
        lifetime += time;

    e           = spawn();
    e.alpha     = 0.25;
    e.think     = SUB_Remove;
    e.nextthink = lifetime;
    e.scale     = pathlib_gridsize / 512;
    e.solid     = SOLID_NOT;
    setorigin(e,where);
    setmodel(e,"models/pathlib/edge.md3");
    //traceline(where + '0 0 32',where - '0 0 128',MOVE_WORLDONLY,e);
    //e.angles = vectoangles(trace_plane_normal);
    e.angles_y = rot;
    //e.angles_x += 90;

}
