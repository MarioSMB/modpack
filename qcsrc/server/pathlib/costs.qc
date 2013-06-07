float pathlib_g_static(entity parent,vector to, float static_cost)
{
    return parent.pathlib_node_g + static_cost;
}

float pathlib_g_static_water(entity parent,vector to, float static_cost)
{
    if(inwater(to))
        return parent.pathlib_node_g + static_cost * pathlib_movecost_waterfactor;
    else
        return parent.pathlib_node_g + static_cost;
}

float pathlib_g_euclidean(entity parent,vector to, float static_cost)
{
    return parent.pathlib_node_g + vlen(parent.origin - to);
}

float pathlib_g_euclidean_water(entity parent,vector to, float static_cost)
{
    if(inwater(to))
        return parent.pathlib_node_g + vlen(parent.origin - to) * pathlib_movecost_waterfactor;
    else
        return parent.pathlib_node_g + vlen(parent.origin - to);
}


/**
    Manhattan Menas we expect to move up,down left or right
    No diagonal moves espected. (like moving bewteen city blocks)
**/
float pathlib_h_manhattan(vector a,vector b)
{
    //h(n) = D * (abs(n.x-goal.x) + abs(n.y-goal.y))

    float h;
    h  = fabs(a_x - b_x);
    h += fabs(a_y - b_y);
    h *= pathlib_gridsize;

    return h;
}

/**
    This heuristic consider both stright and disagonal moves
    to have teh same cost.
**/
float pathlib_h_diagonal(vector a,vector b)
{
    //h(n) = D * max(abs(n.x-goal.x), abs(n.y-goal.y))
    float h,x,y;

    x = fabs(a_x - b_x);
    y = fabs(a_y - b_y);
    h = pathlib_movecost * max(x,y);

    return h;
}

/**
    This heuristic only considers the stright line distance.
    Will usualy mean a lower H then G meaning A* Will speand more
    and run slower.
**/
float pathlib_h_euclidean(vector a,vector b)
{
    return vlen(a - b);
}

/**
    This heuristic consider both stright and disagonal moves,
    But has a separate cost for diagonal moves.
**/
float pathlib_h_diagonal2(vector a,vector b)
{
    float h_diag,h_str,h,x,y;

    /*
    h_diagonal(n) = min(abs(n.x-goal.x), abs(n.y-goal.y))
    h_straight(n) = (abs(n.x-goal.x) + abs(n.y-goal.y))
    h(n) = D2 * h_diagonal(n) + D * (h_straight(n) - 2*h_diagonal(n)))
    */

    x = fabs(a_x - b_x);
    y = fabs(a_y - b_y);

    h_diag = min(x,y);
    h_str = x + y;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    return h;
}

/**
    This heuristic consider both stright and disagonal moves,
    But has a separate cost for diagonal moves.
**/
float pathlib_h_diagonal2sdp(vector preprev,vector prev,vector point,vector end)
{
    float h_diag,h_str,h,x,y,z;

    //h_diagonal(n) = min(abs(n.x-goal.x), abs(n.y-goal.y))
    //h_straight(n) = (abs(n.x-goal.x) + abs(n.y-goal.y))
    //h(n) = D2 * h_diagonal(n) + D * (h_straight(n) - 2*h_diagonal(n)))

    x = fabs(point_x - end_x);
    y = fabs(point_y - end_y);
    z = fabs(point_z - end_z);

    h_diag = min3(x,y,z);
    h_str = x + y + z;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    float m;
    vector d1,d2;

    d1 = normalize(preprev - point);
    d2 = normalize(prev    - point);
    m = vlen(d1-d2);

    return h * m;
}


float pathlib_h_diagonal3(vector a,vector b)
{
    float h_diag,h_str,h,x,y,z;

    x = fabs(a_x - b_x);
    y = fabs(a_y - b_y);
    z = fabs(a_z - b_z);

    h_diag = min3(x,y,z);
    h_str = x + y + z;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    return h;
}
