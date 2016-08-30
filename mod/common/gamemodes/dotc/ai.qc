int dotc_find_attack_spot_direct_test(entity this)
{
    traceline(dotc_attack_spot_test_loc + '0 0 1024', dotc_attack_spot_test_loc - '0 0 2048', MOVE_NORMAL, this);
    if(trace_fraction == 1.0 || trace_startsolid)
        return 1;    
    dotc_attack_spot_test_loc = trace_endpos + '0 0 32';
    
    tracebox(this.origin, this.mins, this.maxs, dotc_attack_spot_test_loc, MOVE_NORMAL, this);
    if(trace_fraction != 1.0)
        return 2;
        
    traceline(dotc_attack_spot_test_loc, this.enemy.origin, MOVE_NORMAL, this);
    if(trace_fraction == 1.0 || trace_ent == this.enemy)
        return 0;
    
    return 3;
}   

int dotc_find_attack_spot_direct(entity this)
{
    if(this.dotc_attack_spot_timer > time)
        return -1;
    
    this.dotc_attack_spot_timer = time + 0.25 + random() * 0.1;
    bool _ok = false;
    int i;
    vector _dir, _spot, _test;
    _dir = normalize(this.origin - this.enemy.origin);
    _spot = this.enemy.origin + _dir * (0.5 * (this.target_range + this.target_range_min));
    dotc_attack_spot_test_loc = _spot;
    if(!dotc_find_attack_spot_direct_test(this))
    {
        this.dotc_attack_spot_loc = dotc_attack_spot_test_loc;
        return 0;
    }
    //_test = _spot;
    //for(_test_x = _spot_x - 256; _test_x >= _spot_x + 256; _test_x += 64)
    //for(_test_y = _spot_y - 256; _test_y >= _spot_y + 256; _test_y += 64)
    for(i = 0; i < 100; ++i)
    {
        _test = randomvec();
        _test_z = 0;
        _test = _spot + _test * (256 + random() * 256);
        te_lightning1(NULL, this.origin, _test);
        dotc_attack_spot_test_loc = _test;
        if(!dotc_find_attack_spot_direct_test(this))
        {
            this.dotc_attack_spot_loc = dotc_attack_spot_test_loc;
            _ok = false;
            //return 0;
            
        }
    }
    
    if(_ok)
        return 0;
    else
        return 1;
    
    //this.target_range_min
	//this.target_range
    
}

vector dotc_ai_aim_ballistic(entity this, vector vtarget, vector shootfrom, float proj_speed, float min_height, float max_height)
{
    vector e_org;
    float hgt;//, dist;
	int i;

	e_org = real_origin(this.squad.enemy);
	//dist = vlen(e_org - this.origin);

	// Find the height offset to the sky / celing
	//traceline(e_org + '0 0 4', e_org + ('0 0 1' * MAX_SHOT_DISTANCE),  MOVE_WORLDONLY, this);
	//hgt = 0.5 * vlen(e_org - trace_endpos) - 64;

	hgt = 128;
	vector pp;

	pp = e_org;
	for(i = 0 ; i < 3; ++i)
	{
		arc_projectile_calculatevelocity(this.tur_shotorg, pp, hgt);
		pp = e_org + this.squad.enemy.velocity * arc_projectile_flighttime;
	}
	dotc_ai_aim_ballistic_vel = arc_projectile_calculatevelocity(this.tur_shotorg, pp, hgt);
	return this.tur_shotorg + normalize(dotc_ai_aim_ballistic_vel) * 128;

}

vector dotc_ai_aim_projectile(entity etarget, vector shootfrom, float proj_speed, float nextfire)
{
    vector start_pos, pre_pos, prep;
    float distance, impact_time = 0, i, mintime, vz;

    mintime = max(nextfire - time, 0) + sys_frametime;

    // Baseline
    start_pos = real_origin(etarget);
	pre_pos = start_pos;

	prep = pre_pos;
	for(i = 0; i < 4; ++i)
	{
		distance = vlen(prep - shootfrom);
		impact_time = distance / proj_speed;
		prep = pre_pos + etarget.velocity * impact_time;
	}
	prep = pre_pos + (etarget.velocity * (impact_time + mintime));

	if(!(etarget.flags & FL_ONGROUND))
	if(etarget.move_movetype == MOVETYPE_WALK || etarget.move_movetype == MOVETYPE_TOSS || etarget.move_movetype == MOVETYPE_BOUNCE)
	{
		prep_z = pre_pos_z;
		vz = etarget.velocity_z;
		for(i = 0; i < impact_time; i += sys_frametime)
		{
			vz = vz - (autocvar_sv_gravity * sys_frametime);
			prep_z = prep_z + vz * sys_frametime;
		}
	}
	pre_pos = prep;

	// pre_pos = pre_pos + target.velocity * mintime;


    //if(etarget.aim_flags & TFL_AIM_GROUND2)
    //{
        //tracebox(pre_pos + '0 0 32',etarget.mins,target.maxs,pre_pos -'0 0 64',MOVE_WORLDONLY,target);
        traceline(start_pos, pre_pos, MOVE_WORLDONLY, etarget);
        if(trace_fraction != 1.0)
            pre_pos = trace_endpos;
    //}


    return pre_pos;
}

vector arc_projectile_calculatevelocity(vector org, vector tgt, float ht)
{
	local float grav, sdist, zdist, vs, vz, jumpheight;
	local vector sdir, torg;

	torg = tgt;

	grav = autocvar_sv_gravity;

	zdist = torg_z - org_z;
	sdist = vlen(torg - org - zdist * '0 0 1');
	sdir = normalize(torg - org - zdist * '0 0 1');

	// how high do we need to push the player?
	jumpheight = fabs(ht);
	if(zdist > 0)
		jumpheight = jumpheight + zdist;

	// push him so high...
	vz = sqrt(2 * grav * jumpheight); // NOTE: sqrt(positive)!

	// we start with downwards velocity only if it's a downjump and the jump apex should be outside the jump!
	if(ht < 0)
		if(zdist < 0)
			vz = -vz;

	vector solution;
	solution = solve_quadratic(0.5 * grav, -vz, zdist); // equation "z(ti) = zdist"
	// ALWAYS solvable because jumpheight >= zdist
	if(!solution_z)
		solution_y = solution_x; // just in case it is not solvable due to roundoff errors, assume two equal solutions at their center (this is mainly for the usual case with ht == 0)
	if(zdist == 0)
		solution_x = solution_y; // solution_x is 0 in this case, so don't use it, but rather use solution_y (which will be sqrt(0.5 * jumpheight / grav), actually)

	if(zdist < 0)
	{
		// down-jump
		if(ht < 0)
		{
			// almost straight line type
			// jump apex is before the jump
			// we must take the larger one
			arc_projectile_flighttime = solution_y;
		}
		else
		{
			// regular jump
			// jump apex is during the jump
			// we must take the larger one too
			arc_projectile_flighttime = solution_y;
		}
	}
	else
	{
		// up-jump
		if(ht < 0)
		{
			// almost straight line type
			// jump apex is after the jump
			// we must take the smaller one
			arc_projectile_flighttime = solution_x;
		}
		else
		{
			// regular jump
			// jump apex is during the jump
			// we must take the larger one
			arc_projectile_flighttime = solution_y;
		}
	}
	vs = sdist / arc_projectile_flighttime;

	// finally calculate the velocity
	return sdir * vs + '0 0 1' * vz;
}

vector dotc_ai_aim_arc(entity this, entity etarget, vector shootfrom, float proj_speed, float proj_gravity, float nextfire)
{

    vector start_pos, pre_pos, prep, da;
    float distance, impact_time = 0, i, mintime, drop;

    mintime = max(nextfire - time, 0) + sys_frametime;

    // Baseline
    start_pos = real_origin(etarget);
	pre_pos = start_pos;

	prep = pre_pos;
	for(i = 0; i < 40; ++i)
	{
		distance = vlen(prep - shootfrom);
		impact_time = distance / proj_speed;
		prep = pre_pos + etarget.velocity * impact_time;
	}
	prep = pre_pos + (etarget.velocity * (impact_time + mintime));
	drop = autocvar_sv_gravity * proj_gravity * impact_time;
	da = prep;
	da_z -= drop;

	traceline(prep, da, MOVE_WORLDONLY, this);
	while(trace_fraction < 0.97)
	{
		da_z += 10;
		++i;
		traceline(prep, da, MOVE_WORLDONLY, this);
		if(i > 100)
		{
			dprint("Predict runaway!\n");
			return da;
		}
	}
	return da;
}


const int DOTC_AI_TRACK_OK = 1;
const int DOTC_AI_TRACK_ROTLIMIT = 2;
const int DOTC_AI_TRACK_PITCHLIMIT = 4;
vector dotc_ai_moveangle(entity this, vector input_angels, vector goal_angels, vector minmax)
{
    vector move_angle;   // This is where we can aim
    float rneg;

    // Find the diffrence between where we currently aim and where we want to aim
    move_angle = goal_angels - (this.angles + input_angels);
    move_angle = shortangle_vxy(move_angle, this.angles + input_angels);

	rneg = minmax_z * -1;

	if(input_angels_y + move_angle_y > minmax_z)
		if ( (input_angels_y + (move_angle_y - 360) < minmax_z) && (input_angels_y + (move_angle_y - 360) > rneg) )
			move_angle_y -= 360;

	if(input_angels_y + move_angle_y < rneg)
		if ( (input_angels_y + (move_angle_y + 360) < minmax_z) && (input_angels_y + (move_angle_y + 360) > rneg) )
			 move_angle_y += 360;

	return move_angle;
}

int dotc_ai_track_combined_step(entity this, entity turret, vector shot_org, vector aimloc, float turnspeed, float pitchspeed, vector aim_minmax, float delta)
{
    float f_tmp;
    int ret = 0;

    turret.angles_x = anglemods(turret.angles_x);
    turret.angles_y = anglemods(turret.angles_y);

	dotc_ai_track_targetoffset = dotc_ai_moveangle(this, turret.angles, vectoangles(normalize(aimloc - shot_org)), aim_minmax);

	f_tmp = pitchspeed * delta;
	turret.angles_x += bound(-f_tmp, dotc_ai_track_targetoffset_x, f_tmp);

	f_tmp = turnspeed * delta;
	turret.angles_y += bound(-f_tmp, dotc_ai_track_targetoffset_y, f_tmp);

	// Pitch
	if(turret.angles_x > aim_minmax_x)
	{
		turret.angles_x = aim_minmax_x;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

	if(turret.angles_x < aim_minmax_y)
	{
		turret.angles_x = aim_minmax_y;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

	// Turn
	if(turret.angles_y > aim_minmax_z)
	{
		turret.angles_y = aim_minmax_z;
		ret = DOTC_AI_TRACK_ROTLIMIT;
	}
	if(turret.angles_y < aim_minmax_z * -1)
	{
		turret.angles_y = aim_minmax_z * -1;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

	return ret | DOTC_AI_TRACK_OK;
}


int dotc_ai_track_combined_inert(entity this, entity turret, vector shot_org, vector aimloc, vector turnspeed, float blend, vector aim_minmax, float delta)
{
    float f_tmp;
    int ret = 0;

    // +/- 360
    turret.angles_x = anglemods(turret.angles_x);
    turret.angles_y = anglemods(turret.angles_y);

	// Get angle from gun to target
	dotc_ai_track_targetoffset = dotc_ai_moveangle(this, turret.angles, vectoangles(normalize(aimloc - shot_org)), aim_minmax);

	// Calc turret elevation
	f_tmp = turnspeed_x * turnspeed_z * delta;
	turret.avelocity_x = bound(turnspeed_x * -1, blend * turret.avelocity_x + (1 - blend) * dotc_ai_track_targetoffset_x * f_tmp, turnspeed_x);

	// Calc turret rotation
	f_tmp = turnspeed_y * turnspeed_z * delta;
	turret.avelocity_y 	= bound(turnspeed_y * -1, blend * turret.avelocity_y + (1 - blend) * dotc_ai_track_targetoffset_y * f_tmp, turnspeed_y);

    //  Limit gun elevation
	f_tmp = turret.angles_x + turret.avelocity_x * delta;
	if(f_tmp > aim_minmax_x)
	{
		turret.avelocity_x = 0;
		turret.angles_x = aim_minmax_x;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

	if(f_tmp < aim_minmax_y)
	{
		turret.avelocity_x = 0;
		turret.angles_x = aim_minmax_y;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

    //  Limit turret rotation.
	f_tmp = turret.angles_y + turret.avelocity_y * delta;
	if(f_tmp > aim_minmax_z)
	{
		turret.avelocity_y = 0;
		turret.angles_y = aim_minmax_z;
		ret = ret | DOTC_AI_TRACK_ROTLIMIT;
	}

	if(f_tmp < aim_minmax_z * -1)
	{
		turret.avelocity_y = 0;
		turret.angles_y = aim_minmax_z * -1;
		ret = ret | DOTC_AI_TRACK_ROTLIMIT;
	}

	return ret | DOTC_AI_TRACK_OK;
}

int dotc_ai_track_separate_inert(entity this, entity turret, entity gun, vector shot_org, vector aimloc, vector turnspeed, float blend, vector aim_minmax, float delta)
{
    float f_tmp;
    int ret = 0;

    // +/- 360
    gun.angles_x = anglemods(gun.angles_x);
    turret.angles_y = anglemods(turret.angles_y);

	// Get angle from gun to target
	dotc_ai_track_targetoffset = dotc_ai_moveangle(this, turret.angles + gun.angles, vectoangles(normalize(aimloc - shot_org)), aim_minmax);

	// Calc gun elevation
	f_tmp = turnspeed_x * turnspeed_z * delta;
	gun.avelocity_x = bound(turnspeed_x * -1, blend * gun.avelocity_x + (1 - blend) * dotc_ai_track_targetoffset_x * f_tmp, turnspeed_x);

	// Calc turret rotation
	f_tmp = turnspeed_y * turnspeed_z * delta;
	turret.avelocity_y 	= bound(turnspeed_y * -1, blend * turret.avelocity_y + (1 - blend) * dotc_ai_track_targetoffset_y * f_tmp, turnspeed_y);

    //  Limit gun elevation
	f_tmp = gun.angles_x + gun.avelocity_x * delta;
	if(f_tmp > aim_minmax_x)
	{
		gun.avelocity_x = 0;
		gun.angles_x = aim_minmax_x;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

	if(f_tmp < aim_minmax_y)
	{
		gun.avelocity_x = 0;
		gun.angles_x = aim_minmax_y;
		ret = DOTC_AI_TRACK_PITCHLIMIT;
	}

    //  Limit turret rotation.
	f_tmp = turret.angles_y + turret.avelocity_y * delta;
	if(f_tmp > aim_minmax_z)
	{
		turret.avelocity_y = 0;
		turret.angles_y = aim_minmax_z;
		ret = ret | DOTC_AI_TRACK_ROTLIMIT;
	}

	if(f_tmp < aim_minmax_z * -1)
	{
		turret.avelocity_y = 0;
		turret.angles_y = aim_minmax_z * -1;
		ret = ret | DOTC_AI_TRACK_ROTLIMIT;
	}

	return ret | DOTC_AI_TRACK_OK;
}

int dotc_ai_valid_target(entity me, entity trg)
{
	// TODO
	float dist;

	if(!trg)
		return -1;

	if(wasfreed(trg))
		return -2;

	if(trg.health <= 0)
		return -3;

	if(trg.deadflag != DEAD_NO)
		return -4;

	// Spectator
	if(trg.team < 0)
		return -90;

	if(SAME_TEAM(trg, me))
		return -5;

	dist = vlen(me.origin - trg.origin);
	if(dist <= me.target_range_min)
		return -6;

	if(dist >= me.target_range)
		return -7;

	traceline(me.origin + '0 0 32' , real_origin(trg), MOVE_WORLDONLY, me);
	if((trace_ent != trg) && (trace_fraction != 1.0))
	{
		return -8;
	}

	if (me.target_validate_flags & DOTC_TARGET_DRONES)
	if (trg.dotc_targetflags & DOTC_TARGET_DRONES)
		return 22;

	if (me.target_validate_flags & DOTC_TARGET_TURRETS)
	if (trg.dotc_targetflags & DOTC_TARGET_TURRETS)
		return 33;

	if (IS_CLIENT(trg))
	if (me.target_validate_flags & DOTC_TARGET_PLAYERS)
		return 44;

	return -666;
}

entity dotc_ai_acquire_target(entity this)
{
	entity targ, best_targ = NULL;
	float dist, best_dist;
	int r;
	best_dist = 300000;

	targ = findradius(this.origin, this.target_range);
	while(targ)
	{
		r = dotc_ai_valid_target(this, targ);
		if(r > 0)
		{
			dist = vlen(this.origin - targ.origin);
			if(dist < best_dist)
			{
				best_dist = dist;
				best_targ = targ;
			}
		}

		targ = targ.chain;
	}

	return best_targ;
}

/*
vector dotc_find_firelocation_range(vector from, float step)
{
	//drone.target_range_optimal	
}


vector dotc_find_firelocation_los2(entity this, vector from, float gridsize)
{
	float dist;
	vector v1, v2;
	
	dist = vlen(this.origin - this.enemy.origin);
	if(dist < this.target_range_optimal) //close enougth?
	{
		traceline(from , real_origin(this.enemy), MOVE_NORMAL, this);
		if(trace_fraction == 1 || trace_ent == this.enemy)
			return this.origin;
		
		fixedmakevectors(this.angles);
		
		if(random() < 0.5)
		{
			v1 = from + v_right * gridsize;
			v2 = from + v_right * -gridsize;
		}
		else
		{
			v2 = from + v_right * gridsize;
			v1 = from + v_right * -gridsize;			
		}
		
		tracebox(from + '0 0 64', this.mins, this.maxs, v1 + '0 0 64', MOVE_NORMAL, this);			
		if(trace_fraction == 1.0)
		{			
			traceline(v1, real_origin(this.enemy), MOVE_NORMAL, this);
			if(trace_fraction == 1 || trace_ent == this.enemy)
			{
				dprint("Found good spot!\n");
				return v1;		
			}
		}
		
		tracebox(from + '0 0 64', this.mins, this.maxs, v2 + '0 0 64', MOVE_NORMAL, this);			
		if(trace_fraction == 1.0)
		{			
			traceline(v2, real_origin(this.enemy), MOVE_NORMAL, this);
			if(trace_fraction == 1 || trace_ent == this.enemy)
			{
				dprint("Found good spot!\n");
				return v2;		
			}
		}
		return this.origin;
	}
	else
	{
		traceline(from , real_origin(this.enemy), MOVE_NORMAL, this);
		if(trace_fraction == 1 || trace_ent == this.enemy)
			return this.origin + normalize(this.enemy.origin - this.origin) * this.target_range_optimal;
		
		if(random() < 0.5)
			return v_forward * gridsize + v_right * gridsize + this.origin; // + normalize(this.enemy.origin - this.origin) * this.target_range_optimal;
		else
			return v_forward * gridsize + v_right * -gridsize + this.origin; // + normalize(this.enemy.origin - this.origin) * this.target_range_optimal;
	}
	
	return this.origin;
}

vector dotc_find_firelocation_los(entity this, vector from, float gridsize)
{
	float x, y;
	vector v;
	
	// Currelt location acceptable?
	traceline(from , real_origin(this.enemy), MOVE_NORMAL, this);
	if(trace_fraction == 1 || trace_ent == this.enemy)
		return this.origin;
		
	// If not, try the 8 nigbhor squares
	//for(i = 0; i < 8; ++i)
	for(x = from_x - gridsize; x < from_x + gridsize; x += gridsize)
	for(y = from_y - gridsize; y < from_y + gridsize; y += gridsize)
	{		
		v = from;
		v_x = x;
		v_y = y;
		
		te_lightning2(NULL, this.origin , v);
		tracebox(from + '0 0 64', this.mins, this.maxs, v + '0 0 64', MOVE_NORMAL, this);			
		if(trace_fraction == 1.0)
		{			
			traceline(v , real_origin(this.enemy), MOVE_NORMAL, this);
			if(trace_fraction == 1 || trace_ent == this.enemy)
			{
				dprint("Found good spot!\n");
				return v;		
			}
		}
	}
	
	dprint("Found no good spot =(\n");
	return '0 0 0';
}
*/
