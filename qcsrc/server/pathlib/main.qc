void pathlib_deletepath(entity start)
{
    entity e;

    e = findchainentity(owner, start);
    while(e)
    {
        e.think = SUB_Remove;
        e.nextthink = time;
        e = e.chain;
    }
}

//#define PATHLIB_NODEEXPIRE 0.05
#define PATHLIB_NODEEXPIRE 20

void dumpnode(entity n)
{
    n.is_path_node = FALSE;
    n.think        = SUB_Remove;
    n.nextthink    = time;
}

entity pathlib_mknode(vector where,entity parent)
{
    entity node;

    node = pathlib_nodeatpoint(where);
    if(node)
    {
    	#ifdef TURRET_DEBUG
        mark_error(where, 60);
        #endif
        return node;
    }

    node = spawn();

    node.think        = SUB_Remove;
    node.nextthink    = time + PATHLIB_NODEEXPIRE;
    node.is_path_node = TRUE;
    node.owner        = openlist;
    node.path_prev    = parent;


    setsize(node, '0 0 0', '0 0 0');

    setorigin(node, where);
    node.medium = pointcontents(where);
    pathlib_showsquare(where, 1 ,15);

    ++pathlib_made_cnt;
    ++pathlib_open_cnt;

    return node;
}

float pathlib_makenode_adaptive(entity parent,vector start, vector to, vector goal,float cost)
{
    entity node;
    float h,g,f,doedge = 0;
    vector where;

    ++pathlib_searched_cnt;

    if(inwater(parent.origin))
    {
        dprint("FromWater\n");
        pathlib_expandnode = pathlib_expandnode_box;
        pathlib_movenode   = pathlib_swimnode;
    }
    else
    {
        if(inwater(to))
        {
            dprint("ToWater\n");
            pathlib_expandnode = pathlib_expandnode_box;
            pathlib_movenode   = pathlib_walknode;
        }
        else
        {
            dprint("LandToLoand\n");
            //if(edge_check(parent.origin))
            //    return 0;

            pathlib_expandnode = pathlib_expandnode_star;
            pathlib_movenode   = pathlib_walknode;
            doedge = 1;
        }
    }

    node = pathlib_nodeatpoint(to);
    if(node)
    {
        dprint("NodeAtPoint\n");
        ++pathlib_merge_cnt;

        if(node.owner == openlist)
        {
            h = pathlib_heuristic(node.origin,goal);
            g = pathlib_cost(parent,node.origin,cost);
            f = g + h;

            if(node.pathlib_node_g > g)
            {
                node.pathlib_node_h = h;
                node.pathlib_node_g = g;
                node.pathlib_node_f = f;

                node.path_prev = parent;
            }

            if not (best_open_node)
                best_open_node = node;
            else if(best_open_node.pathlib_node_f > node.pathlib_node_f)
                best_open_node = node;
        }

        return 1;
    }

    where = pathlib_movenode(parent.origin, to, 0);

    if not(pathlib_movenode_goodnode)
    {
        //pathlib_showsquare(where, 0 ,30);
        //pathlib_showsquare(parent.origin, 1 ,30);
        dprint("pathlib_movenode_goodnode = 0\n");
        return 0;
    }

    //pathlib_showsquare(where, 1 ,30);

    if(pathlib_nodeatpoint(where))
    {
        dprint("NAP WHERE :",vtos(where),"\n");
        dprint("not NAP TO:",vtos(to),"\n");
        dprint("NAP-NNAP:",ftos(vlen(to-where)),"\n\n");
        return 0;
    }


    if(doedge)
        if not (tile_check(where))
        {
            dprint("tile_check fail\n");
            pathlib_showsquare(where, 0 ,30);
            return 0;
        }


    h = pathlib_heuristic(where,goal);
    g = pathlib_cost(parent,where,cost);
    f = g + h;

    /*
    node = findradius(where,pathlib_gridsize * 0.5);
    while(node)
    {
        if(node.is_path_node == TRUE)
        {
            ++pathlib_merge_cnt;
            if(node.owner == openlist)
            {
                if(node.pathlib_node_g > g)
                {
                    //pathlib_movenode(where,node.origin,0);
                    //if(pathlib_movenode_goodnode)
                    //{
                        //mark_error(node.origin + '0 0 128',30);
                        node.pathlib_node_h = h;
                        node.pathlib_node_g = g;
                        node.pathlib_node_f = f;
                        node.path_prev = parent;
                    //}
                }

                if not (best_open_node)
                    best_open_node = node;
                else if(best_open_node.pathlib_node_f > node.pathlib_node_f)
                    best_open_node = node;
            }

            return 1;
        }
        node = node.chain;
    }
    */

    node = pathlib_mknode(where, parent);
    node.pathlib_node_h = h;
    node.pathlib_node_g = g;
    node.pathlib_node_f = f;

    if not (best_open_node)
        best_open_node = node;
    else if(best_open_node.pathlib_node_f > node.pathlib_node_f)
        best_open_node = node;

    return 1;
}

entity pathlib_getbestopen()
{
    entity node;
    entity bestnode;

    if(best_open_node)
    {
        ++pathlib_bestcash_hits;
        pathlib_bestcash_saved += pathlib_open_cnt;

        return best_open_node;
    }

    node = findchainentity(owner,openlist);
    if(!node)
        return world;

    bestnode = node;
    while(node)
    {
        ++pathlib_bestopen_seached;
        if(node.pathlib_node_f < bestnode.pathlib_node_f)
            bestnode = node;

        node = node.chain;
    }

    return bestnode;
}

void pathlib_close_node(entity node,vector goal)
{

    if(node.owner == closedlist)
    {
        dprint("Pathlib: Tried to close a closed node!\n");
        return;
    }

    if(node == best_open_node)
        best_open_node = world;

    ++pathlib_closed_cnt;
    --pathlib_open_cnt;

    node.owner = closedlist;

    if(vlen(node.origin - goal) <= pathlib_gridsize)
    {
        vector goalmove;

        goalmove = pathlib_walknode(node.origin,goal,1);
        if(pathlib_movenode_goodnode)
        {
            goal_node         = node;
            pathlib_foundgoal = TRUE;
        }
    }
}

void pathlib_cleanup()
{
    best_open_node = world;

    //return;

    entity node;

    node = findfloat(world,is_path_node, TRUE);
    while(node)
    {
        /*
        node.owner = openlist;
        node.pathlib_node_g = 0;
        node.pathlib_node_h = 0;
        node.pathlib_node_f = 0;
        node.path_prev = world;
        */

        dumpnode(node);
        node = findfloat(node,is_path_node, TRUE);
    }

    if(openlist)
        remove(openlist);

    if(closedlist)
        remove(closedlist);

    openlist       = world;
    closedlist     = world;

}

float Cosine_Interpolate(float a, float b, float x)
{
    float ft,f;

	ft = x * 3.1415927;
	f = (1 - cos(ft)) * 0.5;

	return  a*(1-f) + b*f;
}

float buildpath_nodefilter_directional(vector n,vector c,vector p)
{
    vector d1,d2;

    d2 = normalize(p - c);
    d1 = normalize(c - n);

    if(vlen(d1-d2) < 0.25)
    {
        //mark_error(c,30);
        return 1;
    }
    //mark_info(c,30);
    return 0;
}

float buildpath_nodefilter_moveskip(vector n,vector c,vector p)
{
    pathlib_walknode(p,n,1);
    if(pathlib_movenode_goodnode)
        return 1;

    return 0;
}

float buildpath_nodefilter_none(vector n,vector c,vector p)
{
    return 0;
}

entity path_build(entity next, vector where, entity prev, entity start)
{
    entity path;

    if(prev && next)
        if(buildpath_nodefilter)
            if(buildpath_nodefilter(next.origin,where,prev.origin))
                return next;


    path           = spawn();
    path.owner     = start;
    path.path_next = next;

    setorigin(path,where);

    if(!next)
        path.classname = "path_end";
    else
    {
        if(!prev)
            path.classname = "path_start";
        else
            path.classname = "path_node";
    }

    return path;
}

entity pathlib_astar(vector from,vector to)
{
    entity path, start, end, open, n, ln;
    float ptime, ftime, ctime;

    ptime = gettime(GETTIME_REALTIME);
    pathlib_starttime = ptime;

    pathlib_cleanup();

    // Select water<->land capable node make/link
    pathlib_makenode     = pathlib_makenode_adaptive;

    // Select XYZ cost estimate
    //pathlib_heuristic    = pathlib_h_diagonal3;
    pathlib_heuristic    = pathlib_h_diagonal;

    // Select distance + waterfactor cost
    pathlib_cost         = pathlib_g_euclidean_water;

    // Select star expander
    pathlib_expandnode   = pathlib_expandnode_star;

    // Select walk simulation movement test
    pathlib_movenode     = pathlib_walknode;

    // Filter final nodes by direction
    buildpath_nodefilter = buildpath_nodefilter_directional;

    // Filter tiles with cross pattern
    tile_check = tile_check_cross;

    // If the start is in water we need diffrent settings
    if(inwater(from))
    {
        // Select volumetric node expaner
        pathlib_expandnode = pathlib_expandnode_box;

        // Water movement test
        pathlib_movenode   = pathlib_swimnode;
    }

    if not(openlist)
        openlist       = spawn();

    if not(closedlist)
        closedlist     = spawn();

    pathlib_closed_cnt       = 0;
    pathlib_open_cnt         = 0;
    pathlib_made_cnt         = 0;
    pathlib_merge_cnt        = 0;
    pathlib_searched_cnt     = 0;
    pathlib_bestopen_seached = 0;
    pathlib_bestcash_hits    = 0;
    pathlib_bestcash_saved   = 0;

    pathlib_gridsize       = 128;
    pathlib_movecost       = pathlib_gridsize;
    pathlib_movecost_diag  = vlen(('1 1 0' * pathlib_gridsize));
    pathlib_movecost_waterfactor = 25000000;
    pathlib_foundgoal      = 0;

    movenode_boxmax   = self.maxs * 1.1;
    movenode_boxmin   = self.mins * 1.1;

    movenode_stepsize = pathlib_gridsize * 0.25;

    tile_check_size = pathlib_gridsize * 0.5;
    tile_check_up   = '0 0 2' * pathlib_gridsize;
    tile_check_up   = '0 0 128';
    tile_check_down = '0 0 3' * pathlib_gridsize;
    tile_check_down = '0 0 256';

    //movenode_stepup   = '0 0 128';
    movenode_stepup   = '0 0 36';
    movenode_maxdrop  = '0 0 512';
    //movenode_maxdrop  = '0 0 512';
    movenode_boxup    = '0 0 72';

    from_x = fsnap(from_x, pathlib_gridsize);
    from_y = fsnap(from_y, pathlib_gridsize);
    //from_z += 32;

    to_x = fsnap(to_x, pathlib_gridsize);
    to_y = fsnap(to_y, pathlib_gridsize);
    //to_z += 32;

    dprint("AStar init\n");
    path = pathlib_mknode(from, world);
    pathlib_close_node(path, to);
    if(pathlib_foundgoal)
    {
        dprint("AStar: Goal found on first node!\n");

        open           = spawn();
        open.owner     = open;
        open.classname = "path_end";
        setorigin(open,path.origin);

        pathlib_cleanup();

        return open;
    }

    if(pathlib_expandnode(path, from, to) <= 0)
    {
        dprint("AStar path fail.\n");
        pathlib_cleanup();

        return world;
    }

    best_open_node = pathlib_getbestopen();
    n = best_open_node;
    pathlib_close_node(best_open_node, to);
    if(inwater(n.origin))
        pathlib_expandnode_box(n, from, to);
    else
        pathlib_expandnode_star(n, from, to);

    while(pathlib_open_cnt)
    {
        if((gettime(GETTIME_REALTIME) - pathlib_starttime) > pathlib_maxtime)
        {
            dprint("Path took to long to compute!\n");
            dprint("Nodes - created: ", ftos(pathlib_made_cnt),"\n");
            dprint("Nodes -    open: ", ftos(pathlib_open_cnt),"\n");
            dprint("Nodes -  merged: ", ftos(pathlib_merge_cnt),"\n");
            dprint("Nodes -  closed: ", ftos(pathlib_closed_cnt),"\n");

            pathlib_cleanup();
            return world;
        }

        best_open_node = pathlib_getbestopen();
        n = best_open_node;
        pathlib_close_node(best_open_node,to);

        if(inwater(n.origin))
            pathlib_expandnode_box(n,from,to);
        else
            pathlib_expandnode(n,from,to);

        if(pathlib_foundgoal)
        {
            dprint("Target found. Rebuilding and filtering path...\n");
            ftime = gettime(GETTIME_REALTIME);
            ptime = ftime - ptime;

            start = path_build(world,path.origin,world,world);
            end   = path_build(world,goal_node.origin,world,start);
            ln    = end;

            open = goal_node;
            for(open = goal_node; open.path_prev != path; open = open.path_prev)
            {
                n    = path_build(ln,open.origin,open.path_prev,start);
                ln.path_prev = n;
                ln = n;
            }
            start.path_next = n;
            n.path_prev = start;
            ftime = gettime(GETTIME_REALTIME) - ftime;

            ctime = gettime(GETTIME_REALTIME);
            pathlib_cleanup();
            ctime = gettime(GETTIME_REALTIME) - ctime;


#ifdef DEBUGPATHING
            pathlib_showpath2(start);

            dprint("Time used -      pathfinding: ", ftos(ptime),"\n");
            dprint("Time used - rebuild & filter: ", ftos(ftime),"\n");
            dprint("Time used -          cleanup: ", ftos(ctime),"\n");
            dprint("Time used -            total: ", ftos(ptime + ftime + ctime),"\n");
            dprint("Time used -         # frames: ", ftos(ceil((ptime + ftime + ctime) / sys_frametime)),"\n\n");
            dprint("Nodes -         created: ", ftos(pathlib_made_cnt),"\n");
            dprint("Nodes -            open: ", ftos(pathlib_open_cnt),"\n");
            dprint("Nodes -          merged: ", ftos(pathlib_merge_cnt),"\n");
            dprint("Nodes -          closed: ", ftos(pathlib_closed_cnt),"\n");
            dprint("Nodes -        searched: ", ftos(pathlib_searched_cnt),"\n");
            dprint("Nodes bestopen searched: ", ftos(pathlib_bestopen_seached),"\n");
            dprint("Nodes bestcash -   hits: ", ftos(pathlib_bestcash_hits),"\n");
            dprint("Nodes bestcash -   save: ", ftos(pathlib_bestcash_saved),"\n");
            dprint("AStar done.\n");
#endif
            return start;
        }
    }

    dprint("A* Faild to find a path! Try a smaller gridsize.\n");

    pathlib_cleanup();

    return world;
}
