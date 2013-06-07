.vector steerto;

/**
    Uniform pull towards a point
**/
vector steerlib_pull(vector point)
{
    return normalize(point - self.origin);
}

/**
    Uniform push from a point
**/
#define steerlib_push(point) normalize(self.origin - point)
/*
vector steerlib_push(vector point)
{
    return normalize(self.origin - point);
}
*/
/**
    Pull toward a point, The further away, the stronger the pull.
**/
vector steerlib_arrive(vector point,float maximal_distance)
{
    float distance;
    vector direction;

    distance = bound(0.001,vlen(self.origin - point),maximal_distance);
    direction = normalize(point - self.origin);
    return  direction * (distance / maximal_distance);
}

/**
    Pull toward a point increasing the pull the closer we get
**/
vector steerlib_attract(vector point, float maximal_distance)
{
    float distance;
    vector direction;

    distance = bound(0.001,vlen(self.origin - point),maximal_distance);
    direction = normalize(point - self.origin);

    return  direction * (1-(distance / maximal_distance));
}

vector steerlib_attract2(vector point, float min_influense,float max_distance,float max_influense)
{
    float distance;
    vector direction;
    float influense;

    distance  = bound(0.00001,vlen(self.origin - point),max_distance);
    direction = normalize(point - self.origin);

    influense = 1 - (distance / max_distance);
    influense = min_influense + (influense * (max_influense - min_influense));

    return  direction * influense;
}

/*
vector steerlib_attract2(vector point, float maximal_distance,float min_influense,float max_influense,float distance)
{
    //float distance;
    vector current_direction;
    vector target_direction;
    float i_target,i_current;

    if(!distance)
        distance = vlen(self.origin - point);

    distance = bound(0.001,distance,maximal_distance);

    target_direction = normalize(point - self.origin);
    current_direction = normalize(self.velocity);

    i_target = bound(min_influense,(1-(distance / maximal_distance)),max_influense);
    i_current = 1 - i_target;

    // i_target = bound(min_influense,(1-(distance / maximal_distance)),max_influense);

    string s;
    s = ftos(i_target);
    bprint("IT: ",s,"\n");
    s = ftos(i_current);
    bprint("IC  : ",s,"\n");

    return  normalize((target_direction * i_target) + (current_direction * i_current));
}
*/
/**
    Move away from a point.
**/
vector steerlib_repell(vector point,float maximal_distance)
{
    float distance;
    vector direction;

    distance = bound(0.001,vlen(self.origin - point),maximal_distance);
    direction = normalize(self.origin - point);

    return  direction * (1-(distance / maximal_distance));
}

/**
    Try to keep at ideal_distance away from point
**/
vector steerlib_standoff(vector point,float ideal_distance)
{
    float distance;
    vector direction;

    distance = vlen(self.origin - point);


    if(distance < ideal_distance)
    {
        direction = normalize(self.origin - point);
        return direction * (distance / ideal_distance);
    }

    direction = normalize(point - self.origin);
    return direction * (ideal_distance / distance);

}

/**
    A random heading in a forward halfcicrle

    use like:
    self.target = steerlib_wander(256,32,self.target)

    where range is the cicrle radius and tresh is how close we need to be to pick a new heading.
**/
vector steerlib_wander(float range,float tresh,vector oldpoint)
{
    vector wander_point;
    wander_point = v_forward - oldpoint;

    if (vlen(wander_point) > tresh)
        return oldpoint;

    range = bound(0,range,1);

    wander_point = self.origin + v_forward * 128;
    wander_point = wander_point + randomvec() * (range * 128) - randomvec() * (range * 128);

    return normalize(wander_point - self.origin);
}

/**
    Dodge a point. dont work to well.
**/
vector steerlib_dodge(vector point,vector dodge_dir,float min_distance)
{
    float distance;

    distance = max(vlen(self.origin - point),min_distance);
    if (min_distance < distance)
        return '0 0 0';

    return dodge_dir * (min_distance/distance);
}

/**
    flocking by .flock_id
    Group will move towards the unified direction while keeping close to eachother.
**/
.float flock_id;
vector steerlib_flock(float radius, float standoff,float separation_force,float flock_force)
{
    entity flock_member;
    vector push = '0 0 0', pull = '0 0 0';
    float ccount = 0;

    flock_member = findradius(self.origin,radius);
    while(flock_member)
    {
        if(flock_member != self)
        if(flock_member.flock_id == self.flock_id)
        {
            ++ccount;
            push = push + (steerlib_repell(flock_member.origin,standoff) * separation_force);
            pull = pull + (steerlib_arrive(flock_member.origin + flock_member.velocity,radius) * flock_force);
        }
        flock_member = flock_member.chain;
    }
    return push + (pull* (1 / ccount));
}

/**
    flocking by .flock_id
    Group will move towards the unified direction while keeping close to eachother.
    xy only version (for ground movers).
**/
vector steerlib_flock2d(float radius, float standoff,float separation_force,float flock_force)
{
    entity flock_member;
    vector push = '0 0 0', pull = '0 0 0';
    float ccount = 0;

    flock_member = findradius(self.origin,radius);
    while(flock_member)
    {
        if(flock_member != self)
        if(flock_member.flock_id == self.flock_id)
        {
            ++ccount;
            push = push + (steerlib_repell(flock_member.origin, standoff) * separation_force);
            pull = pull + (steerlib_arrive(flock_member.origin + flock_member.velocity, radius) * flock_force);
        }
        flock_member = flock_member.chain;
    }

    push_z = 0;
    pull_z = 0;

    return push + (pull * (1 / ccount));
}

/**
    All members want to be in the center, and keep away from eachother.
    The furtehr form the center the more they want to be there.

    This results in a aligned movement (?!) much like flocking.
**/
vector steerlib_swarm(float radius, float standoff,float separation_force,float swarm_force)
{
    entity swarm_member;
    vector force = '0 0 0', center = '0 0 0';
    float ccount = 0;

    swarm_member = findradius(self.origin,radius);

    while(swarm_member)
    {
        if(swarm_member.flock_id == self.flock_id)
        {
            ++ccount;
            center = center + swarm_member.origin;
            force = force + (steerlib_repell(swarm_member.origin,standoff) * separation_force);
        }
        swarm_member = swarm_member.chain;
    }

    center = center * (1 / ccount);
    force = force + (steerlib_arrive(center,radius) * swarm_force);

    return force;
}

/**
    Steer towards the direction least obstructed.
    Run four tracelines in a forward funnel, bias each diretion negative if something is found there.
    You need to call makevectors() (or equivalent) before this function to set v_forward and v_right
**/
vector steerlib_traceavoid(float pitch,float length)
{
    vector vup_left,vup_right,vdown_left,vdown_right;
    float fup_left,fup_right,fdown_left,fdown_right;
    vector upwish,downwish,leftwish,rightwish;
    vector v_left,v_down;


    v_left = v_right * -1;
    v_down = v_up * -1;

    vup_left = (v_forward + (v_left * pitch + v_up * pitch)) * length;
    traceline(self.origin, self.origin +  vup_left,MOVE_NOMONSTERS,self);
    fup_left = trace_fraction;

    //te_lightning1(world,self.origin, trace_endpos);

    vup_right = (v_forward + (v_right * pitch + v_up * pitch)) * length;
    traceline(self.origin,self.origin + vup_right ,MOVE_NOMONSTERS,self);
    fup_right = trace_fraction;

    //te_lightning1(world,self.origin, trace_endpos);

    vdown_left = (v_forward + (v_left * pitch + v_down * pitch)) * length;
    traceline(self.origin,self.origin + vdown_left,MOVE_NOMONSTERS,self);
    fdown_left = trace_fraction;

    //te_lightning1(world,self.origin, trace_endpos);

    vdown_right = (v_forward + (v_right * pitch + v_down * pitch)) * length;
    traceline(self.origin,self.origin + vdown_right,MOVE_NOMONSTERS,self);
    fdown_right = trace_fraction;

    //te_lightning1(world,self.origin, trace_endpos);
    upwish    = v_up    * (fup_left   + fup_right);
    downwish  = v_down  * (fdown_left + fdown_right);
    leftwish  = v_left  * (fup_left   + fdown_left);
    rightwish = v_right * (fup_right  + fdown_right);

    return (upwish+leftwish+downwish+rightwish) * 0.25;

}

/**
    Steer towards the direction least obstructed.
    Run tracelines in a forward trident, bias each direction negative if something is found there.
**/
vector steerlib_traceavoid_flat(float pitch, float length, vector vofs)
{
    vector vt_left, vt_right,vt_front;
    float f_left, f_right,f_front;
    vector leftwish, rightwish,frontwish, v_left;

    v_left = v_right * -1;


    vt_front = v_forward * length;
    traceline(self.origin + vofs, self.origin + vofs + vt_front,MOVE_NOMONSTERS,self);
    f_front = trace_fraction;

    vt_left = (v_forward + (v_left * pitch)) * length;
    traceline(self.origin + vofs, self.origin + vofs + vt_left,MOVE_NOMONSTERS,self);
    f_left = trace_fraction;

    //te_lightning1(world,self.origin, trace_endpos);

    vt_right = (v_forward + (v_right * pitch)) * length;
    traceline(self.origin + vofs, self.origin + vofs + vt_right ,MOVE_NOMONSTERS,self);
    f_right = trace_fraction;

    //te_lightning1(world,self.origin, trace_endpos);

    leftwish  = v_left    * f_left;
    rightwish = v_right   * f_right;
    frontwish = v_forward * f_front;

    return normalize(leftwish + rightwish + frontwish);
}

float beamsweep_badpoint(vector point,float waterok)
{
    float pc,pc2;

    if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
        return 1;

    pc  = pointcontents(point);
    pc2 = pointcontents(point - '0 0 1');

    switch(pc)
    {
        case CONTENT_SOLID: break;
        case CONTENT_SLIME: break;
        case CONTENT_LAVA:  break;

        case CONTENT_SKY:
            return 1;

        case CONTENT_EMPTY:
            if (pc2 == CONTENT_SOLID)
                return 0;

            if (pc2 == CONTENT_WATER)
                if(waterok)
                    return 0;

            break;

        case CONTENT_WATER:
            if(waterok)
                return 0;

            break;
    }

    return 1;
}

//#define BEAMSTEER_VISUAL
float beamsweep(vector from, vector dir,float length, float step,float step_up, float step_down)
{
    float i;
    vector a,b,u,d;

    u = '0 0 1' * step_up;
    d = '0 0 1' * step_down;

    traceline(from + u, from - d,MOVE_NORMAL,self);
    if(trace_fraction == 1.0)
        return 0;

    if(beamsweep_badpoint(trace_endpos,0))
        return 0;

    a = trace_endpos;
    for(i = 0; i < length; i += step)
    {

        b = a + dir * step;
        tracebox(a + u,'-4 -4 -4','4 4 4', b + u,MOVE_NORMAL,self);
        if(trace_fraction != 1.0)
            return i / length;

        traceline(b + u, b - d,MOVE_NORMAL,self);
        if(trace_fraction == 1.0)
            return i / length;

        if(beamsweep_badpoint(trace_endpos,0))
            return i / length;
#ifdef BEAMSTEER_VISUAL
        te_lightning1(world,a+u,b+u);
        te_lightning1(world,b+u,b-d);
#endif
        a = trace_endpos;
    }

    return 1;
}

vector steerlib_beamsteer(vector dir, float length, float step, float step_up, float step_down)
{
    float bm_forward, bm_right, bm_left,p;
    vector vr,vl;

    dir_z *= 0.15;
    vr = vectoangles(dir);
    //vr_x *= -1;

    tracebox(self.origin + '0 0 1' * step_up, self.mins, self.maxs, ('0 0 1' * step_up) + self.origin +  (dir * length), MOVE_NOMONSTERS, self);
    if(trace_fraction == 1.0)
    {
        //te_lightning1(self,self.origin,self.origin +  (dir * length));
        return dir;
    }




    makevectors(vr);
    bm_forward = beamsweep(self.origin, v_forward, length, step, step_up, step_down);

    vr = normalize(v_forward + v_right * 0.125);
    vl = normalize(v_forward - v_right * 0.125);

    bm_right = beamsweep(self.origin, vr, length, step, step_up, step_down);
    bm_left  = beamsweep(self.origin, vl, length, step, step_up, step_down);


    p = bm_left + bm_right;
    if(p == 2)
    {
        //te_lightning1(self,self.origin + '0 0 32',self.origin + '0 0 32' + vr * length);
        //te_lightning1(self.tur_head,self.origin + '0 0 32',self.origin + '0 0 32' + vl * length);

        return v_forward;
    }

    p = 2 - p;

    vr = normalize(v_forward + v_right * p);
    vl = normalize(v_forward - v_right * p);
    bm_right = beamsweep(self.origin, vr, length, step, step_up, step_down);
    bm_left  = beamsweep(self.origin, vl, length, step, step_up, step_down);


    if(bm_left + bm_right < 0.15)
    {
        vr = normalize((v_forward*-1) + v_right * 0.75);
        vl = normalize((v_forward*-1) - v_right * 0.75);

        bm_right = beamsweep(self.origin, vr, length, step, step_up, step_down);
        bm_left  = beamsweep(self.origin, vl, length, step, step_up, step_down);
    }

    //te_lightning1(self,self.origin + '0 0 32',self.origin + '0 0 32' + vr * length);
    //te_lightning1(self.tur_head,self.origin + '0 0 32',self.origin + '0 0 32' + vl * length);

    bm_forward *= bm_forward;
    bm_right   *= bm_right;
    bm_left    *= bm_left;

    vr = vr * bm_right;
    vl = vl * bm_left;

    return normalize(vr + vl);

}


//////////////////////////////////////////////
//     Testting                             //
// Everything below this point is a mess :D //
//////////////////////////////////////////////
//#define TLIBS_TETSLIBS
#ifdef TLIBS_TETSLIBS
void flocker_die()
{
	pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);

    self.owner.cnt += 1;
    self.owner = world;

    self.nextthink = time;
    self.think = SUB_Remove;
}


void flocker_think()
{
    vector dodgemove,swarmmove;
    vector reprellmove,wandermove,newmove;

    self.angles_x = self.angles_x * -1;
    makevectors(self.angles);
    self.angles_x = self.angles_x * -1;

    dodgemove   = steerlib_traceavoid(0.35,1000);
    swarmmove   = steerlib_flock(500,75,700,500);
    reprellmove = steerlib_repell(self.owner.enemy.origin+self.enemy.velocity,2000) * 700;

    if(vlen(dodgemove) == 0)
    {
        self.pos1 = steerlib_wander(0.5,0.1,self.pos1);
        wandermove  = self.pos1 * 50;
    }
    else
        self.pos1 = normalize(self.velocity);

    dodgemove = dodgemove * vlen(self.velocity) * 5;

    newmove = swarmmove + reprellmove + wandermove + dodgemove;
    self.velocity = movelib_inertmove_byspeed(newmove,300,0.2,0.9);
    //self.velocity  = movelib_inertmove(dodgemove,0.65);

    self.velocity = movelib_dragvec(0.01,0.6);

    self.angles = vectoangles(self.velocity);

    if(self.health <= 0)
        flocker_die();
    else
        self.nextthink = time + 0.1;
}


void spawn_flocker()
{
    entity flocker;

    flocker = spawn ();

    setorigin(flocker, self.origin + '0 0 32');
    setmodel (flocker, "models/turrets/rocket.md3");
    setsize (flocker, '-3 -3 -3', '3 3 3');

    flocker.flock_id   = self.flock_id;
    flocker.classname  = "flocker";
    flocker.owner      = self;
    flocker.think      = flocker_think;
    flocker.nextthink  = time + random() * 5;
    PROJECTILE_MAKETRIGGER(flocker);
    flocker.movetype   = MOVETYPE_BOUNCEMISSILE;
    flocker.effects    = EF_LOWPRECISION;
    flocker.velocity   = randomvec() * 300;
    flocker.angles     = vectoangles(flocker.velocity);
    flocker.health     = 10;
    flocker.pos1      = normalize(flocker.velocity + randomvec() * 0.1);

    self.cnt = self.cnt -1;

}

void flockerspawn_think()
{


    if(self.cnt > 0)
        spawn_flocker();

    self.nextthink = time + self.delay;

}

void flocker_hunter_think()
{
    vector dodgemove,attractmove,newmove;
    entity e,ee;
    float d,bd;

    self.angles_x = self.angles_x * -1;
    makevectors(self.angles);
    self.angles_x = self.angles_x * -1;

    if(self.enemy)
    if(vlen(self.enemy.origin - self.origin) < 64)
    {
        ee = self.enemy;
        ee.health = -1;
        self.enemy = world;

    }

    if(!self.enemy)
    {
        e = findchainfloat(flock_id,self.flock_id);
        while(e)
        {
            d = vlen(self.origin - e.origin);

            if(e != self.owner)
            if(e != ee)
            if(d > bd)
            {
                self.enemy = e;
                bd = d;
            }
            e = e.chain;
        }
    }

    if(self.enemy)
        attractmove = steerlib_attract(self.enemy.origin+self.enemy.velocity * 0.1,5000) * 1250;
    else
        attractmove = normalize(self.velocity) * 200;

    dodgemove = steerlib_traceavoid(0.35,1500) * vlen(self.velocity);

    newmove = dodgemove + attractmove;
    self.velocity = movelib_inertmove_byspeed(newmove,1250,0.3,0.7);
    self.velocity = movelib_dragvec(0.01,0.5);


    self.angles = vectoangles(self.velocity);
    self.nextthink = time + 0.1;
}


float globflockcnt;
void spawnfunc_flockerspawn()
{
    precache_model ( "models/turrets/rocket.md3");
    precache_model("models/turrets/c512.md3");
    ++globflockcnt;

    if(!self.cnt)      self.cnt = 20;
    if(!self.delay)    self.delay = 0.25;
    if(!self.flock_id) self.flock_id = globflockcnt;

    self.think     = flockerspawn_think;
    self.nextthink = time + 0.25;

    self.enemy = spawn();

    setmodel(self.enemy, "models/turrets/rocket.md3");
    setorigin(self.enemy,self.origin + '0 0 768' + (randomvec() * 128));

    self.enemy.classname = "FLock Hunter";
    self.enemy.scale     = 3;
    self.enemy.effects   = EF_LOWPRECISION;
    self.enemy.movetype  = MOVETYPE_BOUNCEMISSILE;
    PROJECTILE_MAKETRIGGER(self.enemy);
    self.enemy.think     = flocker_hunter_think;
    self.enemy.nextthink = time + 10;
    self.enemy.flock_id  = self.flock_id;
    self.enemy.owner     = self;
}
#endif



