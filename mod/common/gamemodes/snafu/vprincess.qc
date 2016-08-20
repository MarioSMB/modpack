#ifdef SVQC

int princess_roam(entity verb, entity own, int msg)
{
	switch(msg)
	{
	case VCM_EVAL:

		if(own.enemy)
			return VS_CALL_NO;

		return verb.verb_static_value;

	case VCM_DO:

		own.moveto = v_forward * 128;
		own.steerto = v_forward; //steerlib_beamsteer(v_forward,512,32,34,64);

		return VS_CALL_YES_DOING;
	}
	return VS_CALL_WTF;
}

int princess_pain(entity verb, entity own, int msg)
{
	switch(msg)
	{
	case VCM_EVAL:

		if(own.pain_finished > time)
			return VS_EBASE_MODAL + VS_EBASE_BUMP;

		return VS_CALL_NO;

	case VCM_DO:
        if(own.pain_finished < time)
            return VS_CALL_WTF;
        
        own.pain_finished = time + 0.5;
        if(random() < 0.5)
        {
            own.frame = princess_pain1;
            sound(own, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN1, VOL_BASEVOICE, ATTN_NORM);
        }
        else
        {                
            own.frame = princess_pain2;
            sound(own, CH_PAIN_SINGLE, SND_SNAFU_ZOMBIE_PAIN2, VOL_BASEVOICE, ATTN_NORM);    
        }
        own.nextthink = own.pain_finished;
        return VS_CALL_YES_DOING;
	}
	return VS_CALL_WTF;
}

int princess_find_target(entity verb, entity own, int msg)
{
	switch(msg)
	{
	case VCM_EVAL:
        if(own.snafu_ai_enemy_select_timer > time)
            return verb.verb_static_value;
		
		/*
		if(own.enemy && own.enemy.deadflag == DEAD_NO)
			return VS_CALL_NO;
        */
        
		return VS_CALL_NO;

	case VCM_DO:
		snafu_zombie_localtarget(own, autocvar_g_snafu_prinsess_range_target);

		return VS_CALL_YES_DONE;
	}

	return VS_CALL_WTF;
}

int princess_attack(entity verb, entity own, int msg)
{
	switch(msg)
	{
	case VCM_EVAL:
		if(!own.enemy || own.enemy.deadflag != DEAD_NO || own.pain_finished > time)
			return VS_CALL_NO;

        if(own.attack_finished_single[0] < time && own.cnt)
            return VS_EBASE_MODAL;		
                
        if(own.snafu_ai_enemy_dist <= autocvar_g_snafu_prinsess_range_attack)
            return verb.verb_static_value;
        
        return VS_CALL_NO;
        
	case VCM_DO:
		if(own.attack_finished_single[0] > time)
		{
            if(own.cnt < time && own.cnt != 0)
            {
                own.cnt = 0;
                snafu_zombie_domelee(own, 32 , 64, 10, 150);
                return VS_CALL_YES_DOING;
            }
            /*
            else if(own.cnt > time && own.pain_finished > time)
                return VS_CALL_NO;
            else
            */
            return VS_CALL_YES_DOING;
		}		
		
        own.attack_finished_single[0] = time + 1.5;                
        own.frame = princess_slap1 + rint(random() * 4);
        own.cnt = time + 0.5;
        _sound(own, CH_PAIN_SINGLE, SND(SNAFU_ZOMBIE_ATTACK_FRAME(own.frame - 2)), VOL_BASEVOICE, ATTN_NORM);
        return VS_CALL_YES_DOING;
	}

	return VS_CALL_WTF;
}

int princess_chase(entity verb, entity own, int msg)
{
	switch(msg)
	{
	case VCM_EVAL:
        if(own.attack_finished_single[0] > time)
            return VS_CALL_NO;
		
		/*
        if(!own.enemy || own.enemy.deadflag != DEAD_NO || own.pain_finished > time)
			return VS_CALL_NO;
        */
                
        if(own.snafu_ai_enemy_dist >= autocvar_g_snafu_prinsess_range_attack)
            return verb.verb_static_value;
        
        return VS_CALL_NO;

	case VCM_DO:
        if(own.snafu_ai_enemy_dist > autocvar_g_snafu_prinsess_range_walk)
            own.frame = princess_run;
        else
            own.frame = princess_walk;

        own.moveto = own.enemy.origin;        
        
        return VS_CALL_YES_DOING;
	}

	return VS_CALL_WTF;
}

void snafu_vprincess_think(entity this)
{    
    this.nextthink = time + 0.2;
    float _delta = time - this.snafu_ai_lastupdate;
    this.snafu_ai_lastupdate = time;    
    if (_delta > 0.5)
        return;
    
    this.angles = normalize(this.moveto - this.origin);
    this.angles = vectoangles(this.angles);
    
    this.angles_x = this.angles_z = 0;    
    fixedmakevectors(this.angles);
    this.snafu_ai_enemy_dist = vlen(this.enemy.origin - this.origin);
    
    // Need to check flying first since we dont want to apply friction in-air
    tracebox(this.origin, this.mins, this.maxs, this.origin - '0 0 16', MOVE_NORMAL, this);
    if(trace_fraction == 1.0)
    {
        if(this.pain_finished < time)
        if(this.attack_finished_single[0] < time)
            this.frame = princess_falling;
        
        return;
    }
    
    this.velocity -= (this.velocity * (autocvar_g_snafu_prinsess_friction * _delta));
    
    verbstack_pop(this.verbs_attack);
    
    if(this.frame == princess_run)
    
        this.velocity += v_forward * autocvar_g_snafu_prinsess_speed_run * _delta;
        
    if(this.frame == princess_walk)
        this.velocity += v_forward * autocvar_g_snafu_prinsess_speed_walk * _delta;
}

void snafu_vprincess_create(entity own)
{
    entity zom = spawn();
    setmodel(zom, MDL_SNAFU_PRINCESS);    
    setsize(zom, PRINCESS_MIN, PRINCESS_MAX);
    
    vector _where = own.origin;
    _where_x += random() * own.mins_x;
    _where_x += random() * own.maxs_x;
    _where_y += random() * own.mins_y;
    _where_y += random() * own.maxs_y;
    
    tracebox(_where + '0 0 64', PRINCESS_MIN, PRINCESS_MAX, _where - '0 0 1' * MAX_SHOT_DISTANCE, MOVE_NORMAL, own);    
    setorigin(zom, trace_endpos);
    
    set_movetype(zom, MOVETYPE_WALK);
    zom.solid           = SOLID_SLIDEBOX;
    zom.deadflag        = DEAD_NO;
    zom.takedamage      = DAMAGE_AIM;
    zom.event_damage    = snafu_princess_damage;    
    zom.snafu_ai_flags  = SAF_ZOMBIE;
    zom.health          = autocvar_g_snafu_prinsess_health;
    setthink(zom, snafu_vprincess_think);
    zom.nextthink       = time;
    zom.classname       = "zombie";
    zom.netname         = "Princess (verb based)";
    
    zom.verbs_idle   = spawn();
    zom.verbs_attack = spawn();

    zom.verbs_idle.owner = zom;
    zom.verbs_attack.owner = zom;
        
    
    verbstack_push(zom.verbs_attack, princess_pain, VS_EBASE_LOW - VS_EBASE_BUMP, 0, zom);
    verbstack_push(zom.verbs_attack, princess_find_target, VS_EBASE_NORMAL + VS_EBASE_NUDGE, 0, zom);
    verbstack_push(zom.verbs_attack, princess_attack, VS_EBASE_HIGH, 0, zom);
    verbstack_push(zom.verbs_attack, princess_chase, VS_EBASE_NORMAL, 0, zom);
    
    
    ++snafu_zombie_spawned;
    ++snafu_zombie_alive;
}

#endif

