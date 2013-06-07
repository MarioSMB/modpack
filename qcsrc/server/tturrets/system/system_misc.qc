/*
* Return a angle within +/- 360.
*/
float anglemods(float v)
{
	v = v - 360 * floor(v / 360);
	
	if(v >= 180)
		return v - 360;
	else if(v <= -180)
		return v + 360;
	else		
		return v;
}

/*
* Return the short angle
*/
float shortangle_f(float ang1, float ang2)
{
    if(ang1 > ang2)
    {
        if(ang1 > 180)
            return ang1 - 360;
    }
    else
    {
        if(ang1 < -180)
            return ang1 + 360;
    }

    return ang1;
}

vector shortangle_v(vector ang1, vector ang2)
{
    vector vtmp;

    vtmp_x = shortangle_f(ang1_x,ang2_x);
    vtmp_y = shortangle_f(ang1_y,ang2_y);
    vtmp_z = shortangle_f(ang1_z,ang2_z);

    return vtmp;
}

vector shortangle_vxy(vector ang1, vector ang2)
{
    vector vtmp = '0 0 0';

    vtmp_x = shortangle_f(ang1_x,ang2_x);
    vtmp_y = shortangle_f(ang1_y,ang2_y);

    return vtmp;
}


/*
* Get "real" origin, in worldspace, even if ent is attached to something else.
*/
vector real_origin(entity ent)
{
    entity e;
    vector v = ((ent.absmin + ent.absmax) * 0.5);

    e = ent.tag_entity;
    while(e)
    {
        v = v + ((e.absmin + e.absmax) * 0.5);
        e = e.tag_entity;
    }

    return v;
}

/*
* Return the angle between two enteties
*/
vector angleofs(entity from, entity to)
{
    vector v_res;
    
    v_res = normalize(to.origin - from.origin);
    v_res = vectoangles(v_res);
    v_res = v_res - from.angles;

    if (v_res_x < 0) 	v_res_x += 360;
    if (v_res_x > 180) 	v_res_x -= 360;

    if (v_res_y < 0) 	v_res_y += 360;
    if (v_res_y > 180) 	v_res_y -= 360;

    return v_res;
}

vector angleofs3(vector from, vector from_a, entity to)
{
    vector v_res;
    
    v_res = normalize(to.origin - from);
    v_res = vectoangles(v_res);
    v_res = v_res - from_a;

    if (v_res_x < 0) 	v_res_x += 360;
    if (v_res_x > 180) 	v_res_x -= 360;

    if (v_res_y < 0) 	v_res_y += 360;
    if (v_res_y > 180) 	v_res_y -= 360;

    return v_res;
}

/*
* Update self.tur_shotorg by getting up2date bone info
* NOTICE this func overwrites the global v_forward, v_right and v_up vectors.
*/
#define turret_tag_fire_update() self.tur_shotorg = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire"));v_forward = normalize(v_forward)
float turret_tag_fire_update_s()
{
    if(!self.tur_head)
    {
        error("Call to turret_tag_fire_update with self.tur_head missing!\n");
        self.tur_shotorg = '0 0 0';
        return FALSE;
    }

    self.tur_shotorg = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire"));
    v_forward = normalize(v_forward);

    return TRUE;
}

/*
* Railgun-like beam, but has thickness and suppots slowing of target 
*/
void FireImoBeam (vector start, vector end, vector smin, vector smax,
                  float bforce, float f_dmg, float f_velfactor, float deathtype)

{
    vector hitloc, force, endpoint, dir;
    entity ent;

    dir = normalize(end - start);
    force = dir * bforce;

    // go a little bit into the wall because we need to hit this wall later
    end = end + dir;

    // trace multiple times until we hit a wall, each obstacle will be made unsolid.
    // note down which entities were hit so we can damage them later
    while (1)
    {
        tracebox(start, smin, smax, end, FALSE, self);

        // if it is world we can't hurt it so stop now
        if (trace_ent == world || trace_fraction == 1)
            break;

        if (trace_ent.solid == SOLID_BSP)
            break;

        // make the entity non-solid so we can hit the next one
        trace_ent.railgunhit = TRUE;
        trace_ent.railgunhitloc = end;
        trace_ent.railgunhitsolidbackup = trace_ent.solid;

        // stop if this is a wall

        // make the entity non-solid
        trace_ent.solid = SOLID_NOT;
    }

    endpoint = trace_endpos;

    // find all the entities the railgun hit and restore their solid state
    ent = findfloat(world, railgunhit, TRUE);
    while (ent)
    {
        // restore their solid type
        ent.solid = ent.railgunhitsolidbackup;
        ent = findfloat(ent, railgunhit, TRUE);
    }

    // find all the entities the railgun hit and hurt them
    ent = findfloat(world, railgunhit, TRUE);
    while (ent)
    {
        // get the details we need to call the damage function
        hitloc = ent.railgunhitloc;
        ent.railgunhitloc = '0 0 0';
        ent.railgunhitsolidbackup = SOLID_NOT;
        ent.railgunhit = FALSE;

        // apply the damage
        if (ent.takedamage)
        {
            Damage (ent, self, self, f_dmg, deathtype, hitloc, force);
            ent.velocity = ent.velocity * f_velfactor;
            //ent.alpha = 0.25 + random() * 0.75;
        }

        // advance to the next entity
        ent = findfloat(ent, railgunhit, TRUE);
    }
    trace_endpos = endpoint;
}

// Plug this into wherever precache is done.
void g_turrets_common_precash()
{
    precache_model ("models/turrets/c512.md3");
    precache_model ("models/marker.md3");
}

void turrets_precache_debug_models()
{
    precache_model ("models/turrets/c512.md3");
    precache_model ("models/pathlib/goodsquare.md3");
    precache_model ("models/pathlib/badsquare.md3");
    precache_model ("models/pathlib/square.md3");
    precache_model ("models/pathlib/edge.md3");
}

void turrets_precash()
{
    #ifdef TURRET_DEBUG
	turrets_precache_debug_models();
	#endif
}


#ifdef TURRET_DEBUG
void SUB_Remove();
void marker_think()
{
    if(self.cnt)
    if(self.cnt < time)
    {
        self.think = SUB_Remove;
        self.nextthink = time;
        return;
    }

    self.frame += 1;
    if(self.frame > 29)
        self.frame = 0;

    self.nextthink = time;
}

void mark_error(vector where,float lifetime)
{
    entity err;

    err = spawn();
    err.classname = "error_marker";
    setmodel(err,"models/marker.md3");
    setorigin(err,where);
    err.movetype = MOVETYPE_NONE;
    err.think = marker_think;
    err.nextthink = time;
    err.skin = 0;
    if(lifetime)
        err.cnt = lifetime + time;
}

void mark_info(vector where,float lifetime)
{
    entity err;

    err = spawn();
    err.classname = "info_marker";
    setmodel(err,"models/marker.md3");
    setorigin(err,where);
    err.movetype = MOVETYPE_NONE;
    err.think = marker_think;
    err.nextthink = time;
    err.skin = 1;
    if(lifetime)
        err.cnt = lifetime + time;
}

entity mark_misc(vector where,float lifetime)
{
    entity err;

    err = spawn();
    err.classname = "mark_misc";
    setmodel(err,"models/marker.md3");
    setorigin(err,where);
    err.movetype = MOVETYPE_NONE;
    err.think = marker_think;
    err.nextthink = time;
    err.skin = 3;
    if(lifetime)
        err.cnt = lifetime + time;
    return err;
}

/*
* Paint a v_color colord circle on target onwho
* that fades away over f_time
*/
void paint_target(entity onwho, float f_size, vector v_color, float f_time)
{
    entity e;

    e = spawn();
    setmodel(e, "models/turrets/c512.md3"); // precision set above
    e.scale = (f_size/512);
    //setsize(e, '0 0 0', '0 0 0');
    //setattachment(e,onwho,"");
    setorigin(e,onwho.origin + '0 0 1');
    e.alpha = 0.15;
    e.movetype = MOVETYPE_FLY;

    e.velocity = (v_color * 32); // + '0 0 1' * 64;

    e.colormod = v_color;
    SUB_SetFade(e,time,f_time);
}

void paint_target2(entity onwho, float f_size, vector v_color, float f_time)
{
    entity e;

    e = spawn();
    setmodel(e, "models/turrets/c512.md3"); // precision set above
    e.scale = (f_size/512);
    setsize(e, '0 0 0', '0 0 0');

    setorigin(e,onwho.origin + '0 0 1');
    e.alpha = 0.15;
    e.movetype = MOVETYPE_FLY;

    e.velocity = (v_color * 32); // + '0 0 1' * 64;
    e.avelocity_x = -128;

    e.colormod = v_color;
    SUB_SetFade(e,time,f_time);
}

void paint_target3(vector where, float f_size, vector v_color, float f_time)
{
    entity e;
    e = spawn();
    setmodel(e, "models/turrets/c512.md3"); // precision set above
    e.scale = (f_size/512);
    setsize(e, '0 0 0', '0 0 0');
    setorigin(e,where+ '0 0 1');
    e.movetype = MOVETYPE_NONE;
    e.velocity = '0 0 0';
    e.colormod = v_color;
    SUB_SetFade(e,time,f_time);
}
#endif 
