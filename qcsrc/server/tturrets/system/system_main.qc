#define cvar_base "g_turrets_unit_"
.float clientframe;
void turrets_setframe(float _frame, float client_only)
{        
    if((client_only ? self.clientframe : self.frame ) != _frame)
    {
        self.SendFlags |= TNSF_ANIM;
        self.anim_start_time = time;
    }
    
     if(client_only)
        self.clientframe = _frame;
    else
        self.frame = _frame;
   
}

float turret_send(entity to, float sf)
{
	
	WriteByte(MSG_ENTITY, ENT_CLIENT_TURRET);    
	WriteByte(MSG_ENTITY, sf);
	if(sf & TNSF_SETUP)
	{
	    WriteByte(MSG_ENTITY, self.turret_type);
	    
	    WriteCoord(MSG_ENTITY, self.origin_x);
	    WriteCoord(MSG_ENTITY, self.origin_y);
	    WriteCoord(MSG_ENTITY, self.origin_z);
	    
	    WriteAngle(MSG_ENTITY, self.angles_x);
	    WriteAngle(MSG_ENTITY, self.angles_y);
    }
    
    if(sf & TNSF_ANG)
    {
        WriteShort(MSG_ENTITY, rint(self.tur_head.angles_x));
        WriteShort(MSG_ENTITY, rint(self.tur_head.angles_y));
    }
    
    if(sf & TNSF_AVEL)
    {        
        WriteShort(MSG_ENTITY, rint(self.tur_head.avelocity_x));
        WriteShort(MSG_ENTITY, rint(self.tur_head.avelocity_y));
    }
    
    if(sf & TNSF_MOVE)
    {
        WriteShort(MSG_ENTITY, rint(self.origin_x));
        WriteShort(MSG_ENTITY, rint(self.origin_y));
        WriteShort(MSG_ENTITY, rint(self.origin_z));

        WriteShort(MSG_ENTITY, rint(self.velocity_x));
        WriteShort(MSG_ENTITY, rint(self.velocity_y));
        WriteShort(MSG_ENTITY, rint(self.velocity_z));        
        
        WriteShort(MSG_ENTITY, rint(self.angles_y));        
    }
    
    if(sf & TNSF_ANIM)
    {
        WriteCoord(MSG_ENTITY, self.anim_start_time);
        WriteByte(MSG_ENTITY, self.frame);
    }
    
    if(sf & TNSF_STATUS)
    {
        WriteByte(MSG_ENTITY, self.team);
        
        if(self.health <= 0)
            WriteByte(MSG_ENTITY, 0);
        else
            WriteByte(MSG_ENTITY, ceil((self.health / self.tur_health) * 255));
    }
    
	return TRUE;
}

void load_unit_settings(entity ent, string unitname, float is_reload)
{
    string sbase;

    if (ent == world)
        return;

    if not (ent.turret_scale_damage)    ent.turret_scale_damage  = 1;
    if not (ent.turret_scale_range)     ent.turret_scale_range   = 1;
    if not (ent.turret_scale_refire)    ent.turret_scale_refire  = 1;
    if not (ent.turret_scale_ammo)      ent.turret_scale_ammo    = 1;
    if not (ent.turret_scale_aim)       ent.turret_scale_aim     = 1;
    if not (ent.turret_scale_health)    ent.turret_scale_health  = 1;
    if not (ent.turret_scale_respawn)   ent.turret_scale_respawn = 1;

    sbase = strcat(cvar_base,unitname);
    if (is_reload)
    {
        ent.enemy = world;
        ent.tur_head.avelocity = '0 0 0';

        ent.tur_head.angles = '0 0 0';
    }

    ent.health      = cvar(strcat(sbase,"_health")) * ent.turret_scale_health;
    ent.respawntime = cvar(strcat(sbase,"_respawntime")) * ent.turret_scale_respawn;

    ent.shot_dmg          = cvar(strcat(sbase,"_shot_dmg")) * ent.turret_scale_damage;
    ent.shot_refire       = cvar(strcat(sbase,"_shot_refire")) * ent.turret_scale_refire;
    ent.shot_radius       = cvar(strcat(sbase,"_shot_radius")) * ent.turret_scale_damage;
    ent.shot_speed        = cvar(strcat(sbase,"_shot_speed"));
    ent.shot_spread       = cvar(strcat(sbase,"_shot_spread"));
    ent.shot_force        = cvar(strcat(sbase,"_shot_force")) * ent.turret_scale_damage;
    ent.shot_volly        = cvar(strcat(sbase,"_shot_volly"));
    ent.shot_volly_refire = cvar(strcat(sbase,"_shot_volly_refire")) * ent.turret_scale_refire;

    ent.target_range         = cvar(strcat(sbase,"_target_range")) * ent.turret_scale_range;
    ent.target_range_min     = cvar(strcat(sbase,"_target_range_min")) * ent.turret_scale_range;
    ent.target_range_optimal = cvar(strcat(sbase,"_target_range_optimal")) * ent.turret_scale_range;
    //ent.target_range_fire    = cvar(strcat(sbase,"_target_range_fire")) * ent.turret_scale_range;

    ent.target_select_rangebias  = cvar(strcat(sbase,"_target_select_rangebias"));
    ent.target_select_samebias   = cvar(strcat(sbase,"_target_select_samebias"));
    ent.target_select_anglebias  = cvar(strcat(sbase,"_target_select_anglebias"));
    ent.target_select_playerbias = cvar(strcat(sbase,"_target_select_playerbias"));
    //ent.target_select_fov = cvar(cvar_gets(sbase,"_target_select_fov"));

    ent.ammo_max      = cvar(strcat(sbase,"_ammo_max")) * ent.turret_scale_ammo;
    ent.ammo_recharge = cvar(strcat(sbase,"_ammo_recharge")) * ent.turret_scale_ammo;

    ent.aim_firetolerance_dist = cvar(strcat(sbase,"_aim_firetolerance_dist"));
    ent.aim_speed    = cvar(strcat(sbase,"_aim_speed")) * ent.turret_scale_aim;
    ent.aim_maxrot   = cvar(strcat(sbase,"_aim_maxrot"));
    ent.aim_maxpitch = cvar(strcat(sbase,"_aim_maxpitch"));

    ent.track_type        = cvar(strcat(sbase,"_track_type"));
    ent.track_accel_pitch = cvar(strcat(sbase,"_track_accel_pitch"));
    ent.track_accel_rot   = cvar(strcat(sbase,"_track_accel_rot"));
    ent.track_blendrate   = cvar(strcat(sbase,"_track_blendrate"));

    if(is_reload)
        if(ent.turret_respawnhook)
            ent.turret_respawnhook();
}

void turret_projectile_explode()
{
    
    self.takedamage = DAMAGE_NO;
    self.event_damage = func_null;    
#ifdef TURRET_DEBUG
    float d;
    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.realowner, self.owner.shot_dmg, 0, self.owner.shot_radius, self, self.owner.shot_force, self.totalfrags, world);
#endif
    remove(self);
}

void turret_projectile_touch()
{
    PROJECTILE_TOUCH;
    turret_projectile_explode();
}

void turret_projectile_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.velocity  += vforce;
    self.health    -= damage;
    //self.realowner  = attacker; // Dont change realowner, it does not make much sense for turrets
    if(self.health <= 0)
        W_PrepareExplosionByDamage(self.owner, turret_projectile_explode);
}

entity turret_projectile(string _snd, float _size, float _health, float _death, float _proj_type, float _cull, float _cli_anim)
{
    entity proj;

    sound (self, CH_WEAPON_A, _snd, VOL_BASE, ATTN_NORM);
    proj                 = spawn ();
    setorigin(proj, self.tur_shotorg);
    setsize(proj, '-0.5 -0.5 -0.5' * _size, '0.5 0.5 0.5' * _size);
    proj.owner           = self;
    proj.realowner       = self;
    proj.bot_dodge       = TRUE;
    proj.bot_dodgerating = self.shot_dmg;    
    proj.think           = turret_projectile_explode;
    proj.touch           = turret_projectile_touch;
    proj.nextthink       = time + 9;    
    proj.movetype        = MOVETYPE_FLYMISSILE;
    proj.velocity        = normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;    
    proj.flags           = FL_PROJECTILE;
    proj.enemy           = self.enemy;
    proj.totalfrags      = _death;
    PROJECTILE_MAKETRIGGER(proj);
    if(_health)
    {
        proj.health         = _health;
        proj.takedamage     = DAMAGE_YES;
        proj.event_damage   = turret_projectile_damage;
    }
    else
        proj.flags |= FL_NOTARGET;

    CSQCProjectile(proj, _cli_anim, _proj_type, _cull);
    
    return proj;
}

/**
** updates enemy distances, predicted impact point/time
** and updated aim<->predict impact distance.
**/
void turret_do_updates(entity t_turret)
{
    vector enemy_pos;
    entity oldself;

    oldself = self;
    self = t_turret;

    enemy_pos = real_origin(self.enemy);

    turret_tag_fire_update();

    self.tur_shotdir_updated = v_forward;
    self.tur_dist_enemy  = vlen(self.tur_shotorg - enemy_pos);
    self.tur_dist_aimpos = vlen(self.tur_shotorg - self.tur_aimpos);

    /*if((self.firecheck_flags & TFL_FIRECHECK_VERIFIED) && (self.enemy))
    {
        oldpos = self.enemy.origin;
        setorigin(self.enemy, self.tur_aimpos);
        tracebox(self.tur_shotorg, '-1 -1 -1', '1 1 1', self.tur_shotorg + (self.tur_shotdir_updated * self.tur_dist_aimpos), MOVE_NORMAL,self);
        setorigin(self.enemy, oldpos);

        if(trace_ent == self.enemy)
            self.tur_dist_impact_to_aimpos = 0;
        else
            self.tur_dist_impact_to_aimpos = vlen(trace_endpos - self.tur_aimpos);
    }
    else*/
        tracebox(self.tur_shotorg, '-1 -1 -1','1 1 1', self.tur_shotorg + (self.tur_shotdir_updated * self.tur_dist_aimpos), MOVE_NORMAL,self);
	
	self.tur_dist_impact_to_aimpos = vlen(trace_endpos - self.tur_aimpos) - (vlen(self.enemy.maxs - self.enemy.mins) * 0.5);		
	self.tur_impactent             = trace_ent;
	self.tur_impacttime            = vlen(self.tur_shotorg - trace_endpos) / self.shot_speed;

    self = oldself;
}

/*
vector turret_fovsearch_pingpong()
{
    vector wish_angle;
    if(self.phase < time)
    {
        if( self.tur_head.phase )
            self.tur_head.phase = 0;
        else
            self.tur_head.phase = 1;
        self.phase = time + 5;
    }

    if( self.tur_head.phase)
        wish_angle = self.idle_aim + '0 1 0' * (self.aim_maxrot * (self.target_select_fov / 360));
    else
        wish_angle = self.idle_aim - '0 1 0' * (self.aim_maxrot * (self.target_select_fov / 360));

    return wish_angle;
}

vector turret_fovsearch_steprot()
{
    vector wish_angle;
    //float rot_add;

    wish_angle   = self.tur_head.angles;
    wish_angle_x = self.idle_aim_x;

    if (self.phase < time)
    {
        //rot_add = self.aim_maxrot / self.target_select_fov;
        wish_angle_y += (self.target_select_fov * 2);

        if(wish_angle_y > 360)
            wish_angle_y = wish_angle_y - 360;

         self.phase = time + 1.5;
    }

    return wish_angle;
}

vector turret_fovsearch_random()
{
    vector wish_angle;

    if (self.phase < time)
    {
        wish_angle_y = random() * self.aim_maxrot;
        if(random() < 0.5)
            wish_angle_y *= -1;

        wish_angle_x = random() * self.aim_maxpitch;
        if(random() < 0.5)
            wish_angle_x *= -1;

        self.phase = time + 5;

        self.tur_aimpos = wish_angle;
    }

    return self.idle_aim + self.tur_aimpos;
}
*/

/**
** Handles head rotation according to
** the units .track_type and .track_flags
**/
.float turret_framecounter;
void turret_stdproc_track()
{
    vector target_angle; // This is where we want to aim
    vector move_angle;   // This is where we can aim
    float f_tmp;
    vector v1, v2;
    v1 = self.tur_head.angles;
    v2 = self.tur_head.avelocity;
    
    if (self.track_flags == TFL_TRACK_NO)
        return;

    if not (self.active)
        target_angle = self.idle_aim - ('1 0 0' * self.aim_maxpitch);
    else if (self.enemy == world)
    {
        if(time > self.lip)
            target_angle = self.idle_aim + self.angles;
        else
            target_angle = vectoangles(normalize(self.tur_aimpos - self.tur_shotorg));
    }
    else
    {
        target_angle = vectoangles(normalize(self.tur_aimpos - self.tur_shotorg)); 
    }
    
    self.tur_head.angles_x = anglemods(self.tur_head.angles_x);
    self.tur_head.angles_y = anglemods(self.tur_head.angles_y);

    // Find the diffrence between where we currently aim and where we want to aim
    //move_angle = target_angle - (self.angles + self.tur_head.angles);
    //move_angle = shortangle_vxy(move_angle,(self.angles + self.tur_head.angles));
    
    move_angle = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(self.angles), AnglesTransform_FromAngles(target_angle))) - self.tur_head.angles; 
    move_angle = shortangle_vxy(move_angle, self.tur_head.angles);

    switch(self.track_type)
    {
        case TFL_TRACKTYPE_STEPMOTOR:
            f_tmp = self.aim_speed * self.ticrate; // dgr/sec -> dgr/tic
            if (self.track_flags & TFL_TRACK_PITCH)
            {
                self.tur_head.angles_x += bound(-f_tmp,move_angle_x, f_tmp);
                if(self.tur_head.angles_x > self.aim_maxpitch)
                    self.tur_head.angles_x = self.aim_maxpitch;

                if(self.tur_head.angles_x  < -self.aim_maxpitch)
                    self.tur_head.angles_x = self.aim_maxpitch;
            }

            if (self.track_flags & TFL_TRACK_ROT)
            {
                self.tur_head.angles_y += bound(-f_tmp, move_angle_y, f_tmp);
                if(self.tur_head.angles_y > self.aim_maxrot)
                    self.tur_head.angles_y = self.aim_maxrot;

                if(self.tur_head.angles_y  < -self.aim_maxrot)
                    self.tur_head.angles_y = self.aim_maxrot;
            }
            
            // CSQC
            self.SendFlags  |= TNSF_ANG;
            
            return;

        case TFL_TRACKTYPE_FLUIDINERTIA:
            f_tmp = self.aim_speed * self.ticrate; // dgr/sec -> dgr/tic
            move_angle_x = bound(-self.aim_speed, move_angle_x * self.track_accel_pitch * f_tmp, self.aim_speed);
            move_angle_y = bound(-self.aim_speed, move_angle_y * self.track_accel_rot * f_tmp, self.aim_speed);
            move_angle = (self.tur_head.avelocity * self.track_blendrate) + (move_angle * (1 - self.track_blendrate));
            break;

        case TFL_TRACKTYPE_FLUIDPRECISE:

            move_angle_y = bound(-self.aim_speed, move_angle_y, self.aim_speed);
            move_angle_x = bound(-self.aim_speed, move_angle_x, self.aim_speed);

            break;
    }

    //  pitch
    if (self.track_flags & TFL_TRACK_PITCH)
    {
        self.tur_head.avelocity_x = move_angle_x;
        if((self.tur_head.angles_x + self.tur_head.avelocity_x * self.ticrate) > self.aim_maxpitch)
        {
            self.tur_head.avelocity_x = 0;
            self.tur_head.angles_x = self.aim_maxpitch;
            
            self.SendFlags  |= TNSF_ANG;
        }
        
        if((self.tur_head.angles_x + self.tur_head.avelocity_x * self.ticrate) < -self.aim_maxpitch)
        {
            self.tur_head.avelocity_x = 0;
            self.tur_head.angles_x = -self.aim_maxpitch;
                        
            self.SendFlags  |= TNSF_ANG;
        }
    }

    //  rot
    if (self.track_flags & TFL_TRACK_ROT)
    {
        self.tur_head.avelocity_y = move_angle_y;

        if((self.tur_head.angles_y + self.tur_head.avelocity_y * self.ticrate) > self.aim_maxrot)
        {
            self.tur_head.avelocity_y = 0;
            self.tur_head.angles_y = self.aim_maxrot;
            
            self.SendFlags  |= TNSF_ANG;
        }

        if((self.tur_head.angles_y + self.tur_head.avelocity_y * self.ticrate) < -self.aim_maxrot)
        {
            self.tur_head.avelocity_y = 0;
            self.tur_head.angles_y = -self.aim_maxrot;
            
            self.SendFlags  |= TNSF_ANG;
        }
    }
        
    self.SendFlags  |= TNSF_AVEL;
    
    // Force a angle update every 10'th frame
    self.turret_framecounter += 1;
    if(self.turret_framecounter >= 10)
    {        
        self.SendFlags |= TNSF_ANG;
        self.turret_framecounter = 0;
    }            
}


/*
 + = implemented
 - = not implemented

 + TFL_FIRECHECK_NO
 + TFL_FIRECHECK_WORLD
 + TFL_FIRECHECK_DEAD
 + TFL_FIRECHECK_DISTANCES
 - TFL_FIRECHECK_LOS
 + TFL_FIRECHECK_AIMDIST
 + TFL_FIRECHECK_REALDIST
 - TFL_FIRECHECK_ANGLEDIST
 - TFL_FIRECHECK_TEAMCECK
 + TFL_FIRECHECK_AFF
 + TFL_FIRECHECK_OWM_AMMO
 + TFL_FIRECHECK_OTHER_AMMO
 + TFL_FIRECHECK_REFIRE
*/

/**
** Preforms pre-fire checks based on the uints firecheck_flags
**/
float turret_stdproc_firecheck()
{
    // This one just dont care =)
    if (self.firecheck_flags & TFL_FIRECHECK_NO) 
        return 1;

    if (self.enemy == world)
        return 0;

    // Ready?
    if (self.firecheck_flags & TFL_FIRECHECK_REFIRE)
        if (self.attack_finished_single > time) return 0;

    // Special case: volly fire turret that has to fire a full volly if a shot was fired.
    if (self.shoot_flags & TFL_SHOOT_VOLLYALWAYS)
        if (self.volly_counter != self.shot_volly)
			if(self.ammo >= self.shot_dmg)
				return 1;        	

    // Lack of zombies makes shooting dead things unnecessary :P
    if (self.firecheck_flags & TFL_FIRECHECK_DEAD)
        if (self.enemy.deadflag != DEAD_NO)
            return 0;

    // Own ammo?
    if (self.firecheck_flags & TFL_FIRECHECK_OWM_AMMO)
        if (self.ammo < self.shot_dmg)
            return 0;

    // Other's ammo? (support-supply units)
    if (self.firecheck_flags & TFL_FIRECHECK_OTHER_AMMO)
        if (self.enemy.ammo >= self.enemy.ammo_max)
            return 0;
	
	// Target of opertunity?
	if(turret_validate_target(self, self.tur_impactent, self.target_validate_flags) > 0)
	{
		self.enemy = self.tur_impactent;
		return 1;
	}				

    if (self.firecheck_flags & TFL_FIRECHECK_DISTANCES)
    {
        // To close?
        if (self.tur_dist_aimpos < self.target_range_min)
			if(turret_validate_target(self, self.tur_impactent, self.target_validate_flags) > 0) 			
				return 1; // Target of opertunity?
			else 
				return 0;				
    }

    // Try to avoid FF?
    if (self.firecheck_flags & TFL_FIRECHECK_AFF)
        if (self.tur_impactent.team == self.team)
            return 0;

    // aim<->predicted impact
    if (self.firecheck_flags & TFL_FIRECHECK_AIMDIST)
        if (self.tur_dist_impact_to_aimpos > self.aim_firetolerance_dist)
            return 0;

    // Volly status
    if (self.shot_volly > 1)
        if (self.volly_counter == self.shot_volly)
            if (self.ammo < (self.shot_dmg * self.shot_volly))
                return 0;

    /*if(self.firecheck_flags & TFL_FIRECHECK_VERIFIED)
        if(self.tur_impactent != self.enemy)
            return 0;*/

    return 1;
}

/*
 + TFL_TARGETSELECT_NO
 + TFL_TARGETSELECT_LOS
 + TFL_TARGETSELECT_PLAYERS
 + TFL_TARGETSELECT_MISSILES
 - TFL_TARGETSELECT_TRIGGERTARGET
 + TFL_TARGETSELECT_ANGLELIMITS
 + TFL_TARGETSELECT_RANGELIMTS
 + TFL_TARGETSELECT_TEAMCHECK
 - TFL_TARGETSELECT_NOBUILTIN
 + TFL_TARGETSELECT_OWNTEAM
*/

/**
** Evaluate a entity for target valitity based on validate_flags
** NOTE: the caller must check takedamage before calling this, to inline this check.
**/
float turret_validate_target(entity e_turret, entity e_target, float validate_flags)
{
    vector v_tmp;
	
	turret_target = e_target;
	turret_flags = validate_flags;
	turret = e_turret;
	if(MUTATOR_CALLHOOK(TurretValidateTarget))
		return 1;
	e_target = turret_target;
	e_turret = turret;
        
    //if(!validate_flags & TFL_TARGETSELECT_NOBUILTIN)
    //    return -0.5;

    if(e_target.owner == e_turret)
        return -0.5;

    if not(checkpvs(e_target.origin, e_turret))
        return -1;        

    if not (e_target)
        return -2;

	if(g_onslaught)
		if (substring(e_target.classname, 0, 10) == "onslaught_") // don't attack onslaught targets, that's the player's job!
			return - 3;

    if (validate_flags & TFL_TARGETSELECT_NO)
        return -4;

    // If only this was used more..
    if (e_target.flags & FL_NOTARGET)
        return -5;

    // Cant touch this
    if(e_target.vehicle_flags & VHF_ISVEHICLE)    
    {
        if (e_target.vehicle_health <= 0)
            return -6;
    }
    else if (e_target.health <= 0)
        return -6;

    // player
    if (IS_CLIENT(e_target))
    {
        if not (validate_flags & TFL_TARGETSELECT_PLAYERS)
            return -7;

        if (e_target.deadflag != DEAD_NO)
            return -8;
    }

	// enemy turrets
	if (validate_flags & TFL_TARGETSELECT_NOTURRETS)
        if (e_target.turret_firefunc || e_target.owner.tur_head == e_target)
            if(e_target.team != e_turret.team) // Dont break support units.
                return -9;

    // Missile
    if (e_target.flags & FL_PROJECTILE)
        if not (validate_flags & TFL_TARGETSELECT_MISSILES)
            return -10;

    if (validate_flags & TFL_TARGETSELECT_MISSILESONLY)
        if not (e_target.flags & FL_PROJECTILE)
            return -10.5;

    // Team check
    if (validate_flags & TFL_TARGETSELECT_TEAMCHECK)
    {
        if (validate_flags & TFL_TARGETSELECT_OWNTEAM)
        {
            if (e_target.team != e_turret.team)
                return -11;

            if (e_turret.team != e_target.owner.team)
                return -12;
        }
        else
        {
            if (e_target.team == e_turret.team)
                return -13;

            if (e_turret.team == e_target.owner.team)
                return -14;
        }
    }

    // Range limits?
    tvt_dist = vlen(e_turret.origin - real_origin(e_target));
    if (validate_flags & TFL_TARGETSELECT_RANGELIMTS)
    {
        if (tvt_dist < e_turret.target_range_min)
            return -15;

        if (tvt_dist > e_turret.target_range)
            return -16;
    }

    // Can we even aim this thing?
    tvt_thadv = angleofs3(e_turret.tur_head.origin, e_turret.angles + e_turret.tur_head.angles, e_target);
    tvt_tadv  = shortangle_vxy(angleofs(e_turret, e_target), e_turret.angles);
    tvt_thadf = vlen(tvt_thadv);
    tvt_tadf  = vlen(tvt_tadv);

    /*
    if(validate_flags & TFL_TARGETSELECT_FOV)
    {
        if(e_turret.target_select_fov < tvt_thadf)
            return -21;
    }
    */

    if (validate_flags & TFL_TARGETSELECT_ANGLELIMITS)
    {
        if (fabs(tvt_tadv_x) > e_turret.aim_maxpitch)
            return -17;

        if (fabs(tvt_tadv_y) > e_turret.aim_maxrot)
            return -18;
    }

    // Line of sight?
    if (validate_flags & TFL_TARGETSELECT_LOS)
    {
        v_tmp = real_origin(e_target) + ((e_target.mins + e_target.maxs) * 0.5);

        traceline(e_turret.origin + '0 0 16', v_tmp, 0, e_turret);

        if (e_turret.aim_firetolerance_dist < vlen(v_tmp - trace_endpos))
            return -19;
    }

    if (e_target.classname == "grapplinghook")
        return -20;

    /*
    if (e_target.classname == "func_button")
        return -21;
    */

#ifdef TURRET_DEBUG_TARGETSELECT
    dprint("Target:",e_target.netname," is a valid target for ",e_turret.netname,"\n");
#endif

    return 1;
}

entity turret_select_target()
{
    entity e;        // target looper entity
    float  score;    // target looper entity score
    entity e_enemy;  // currently best scoreing target
    float  m_score;  // currently best scoreing target's score

    m_score = 0;
    if(self.enemy && self.enemy.takedamage && turret_validate_target(self,self.enemy,self.target_validate_flags) > 0)
    {
        e_enemy = self.enemy;
        m_score = self.turret_score_target(self,e_enemy) * self.target_select_samebias;
    }
    else
        e_enemy = self.enemy = world;

    e = findradius(self.origin, self.target_range);

    // Nothing to aim at?
    if (!e) 
		return world;

    while (e)
    {
		if(e.takedamage)
		{
		    float f = turret_validate_target(self, e, self.target_select_flags);
		    //dprint("F is: ", ftos(f), "\n");
			if ( f > 0)
			{
				score = self.turret_score_target(self,e);
				if ((score > m_score) && (score > 0))
				{
					e_enemy = e;
					m_score = score;
				}
			}
		}
        e = e.chain;
    }

    return e_enemy;
}

void turret_think()
{
    entity e;

    self.nextthink = time + self.ticrate;
    
    // ONS uses somewhat backwards linking.
    if (teamplay)
    {
        if (g_onslaught)
            if (self.target)
            {
                e = find(world, targetname,self.target);
                if (e != world)
                    self.team = e.team;
            }

        if (self.team != self.tur_head.team)
            turret_stdproc_respawn();
    }

#ifdef TURRET_DEBUG
    if (self.tur_dbg_tmr1 < time)
    {
        if (self.enemy) paint_target (self.enemy,128,self.tur_dbg_rvec,0.9);
        paint_target(self,256,self.tur_dbg_rvec,0.9);
        self.tur_dbg_tmr1 = time + 1;
    }
#endif

    // Handle ammo
    if not (self.spawnflags & TSF_NO_AMMO_REGEN)
    if (self.ammo < self.ammo_max)
        self.ammo = min(self.ammo + self.ammo_recharge, self.ammo_max);
			
    // Inactive turrets needs to run the think loop,
    // So they can handle animation and wake up if need be.
    if not (self.active)
    {
        turret_stdproc_track();
        return;
    }

    // This is typicaly used for zaping every target in range
    // turret_fusionreactor uses this to recharge friendlys.
    if (self.shoot_flags & TFL_SHOOT_HITALLVALID)
    {
        // Do a self.turret_fire for every valid target.
        e = findradius(self.origin,self.target_range);
        while (e)
        {
			if(e.takedamage)
			{
				if (turret_validate_target(self,e,self.target_validate_flags))
				{
					self.enemy = e;

					turret_do_updates(self);

					if (self.turret_firecheckfunc())
						turret_fire();
				}
			}

            e = e.chain;
        }
        self.enemy = world;
    }
    else if(self.shoot_flags & TFL_SHOOT_CUSTOM)
    {
        // This one is doing something.. oddball. assume its handles what needs to be handled.

        // Predict?
        if not(self.aim_flags & TFL_AIM_NO)
            self.tur_aimpos = turret_stdproc_aim_generic();

        // Turn & pitch?
        if not(self.track_flags & TFL_TRACK_NO)
            turret_stdproc_track();

        turret_do_updates(self);

        // Fire?
        if (self.turret_firecheckfunc())
            turret_fire();
    }
    else
    {
        // Special case for volly always. if it fired once it must compleate the volly.
        if(self.shoot_flags & TFL_SHOOT_VOLLYALWAYS)
            if(self.volly_counter != self.shot_volly)
            {
                // Predict or whatnot
                if not(self.aim_flags & TFL_AIM_NO)
                    self.tur_aimpos = turret_stdproc_aim_generic();

                // Turn & pitch
                if not(self.track_flags & TFL_TRACK_NO)
                    turret_stdproc_track();

                turret_do_updates(self);

                // Fire!
                if (self.turret_firecheckfunc() != 0)
                    turret_fire();

                if(self.turret_postthink)
                    self.turret_postthink();

                return;
            }

        // Check if we have a vailid enemy, and try to find one if we dont.

        // g_turrets_targetscan_maxdelay forces a target re-scan at least this often
        float do_target_scan = 0;
        if((self.target_select_time + autocvar_g_turrets_targetscan_maxdelay) < time)
            do_target_scan = 1;

        // Old target (if any) invalid?
        if(self.target_validate_time < time)
        if (turret_validate_target(self, self.enemy, self.target_validate_flags) <= 0)
        {
        	self.enemy = world;
        	self.target_validate_time = time + 0.5;
        	do_target_scan = 1;
        }

        // But never more often then g_turrets_targetscan_mindelay!
        if (self.target_select_time + autocvar_g_turrets_targetscan_mindelay > time)
            do_target_scan = 0;

        if(do_target_scan)
        {
            self.enemy = turret_select_target();
            self.target_select_time = time;
        }

        // No target, just go to idle, do any custom stuff and bail.
        if (self.enemy == world)
        {
            // Turn & pitch
            if not(self.track_flags & TFL_TRACK_NO)
                turret_stdproc_track();

            // do any per-turret stuff
            if(self.turret_postthink)
                self.turret_postthink();

            // And bail.
            return;
        }
        else
            self.lip = time + autocvar_g_turrets_aimidle_delay; // Keep track of the last time we had a target.

        // Predict?
        if not(self.aim_flags & TFL_AIM_NO)
            self.tur_aimpos = turret_stdproc_aim_generic();

        // Turn & pitch?
        if not(self.track_flags & TFL_TRACK_NO)
            turret_stdproc_track();

        turret_do_updates(self);

        // Fire?
        if (self.turret_firecheckfunc())
            turret_fire();
    }

    // do any custom per-turret stuff
    if(self.turret_postthink)
        self.turret_postthink();
}

void turret_fire()
{
    if (autocvar_g_turrets_nofire != 0)
        return;

    self.turret_firefunc();

    self.attack_finished_single = time + self.shot_refire;
    self.ammo -= self.shot_dmg;
    self.volly_counter = self.volly_counter - 1;

    if (self.volly_counter <= 0)
    {
        self.volly_counter = self.shot_volly;

        if (self.shoot_flags & TFL_SHOOT_CLEARTARGET)
            self.enemy = world;

        if (self.shot_volly > 1)
            self.attack_finished_single = time + self.shot_volly_refire;
    }

#ifdef TURRET_DEBUG
    if (self.enemy) paint_target3(self.tur_aimpos, 64, self.tur_dbg_rvec, self.tur_impacttime + 0.25);
#endif
}

void turret_stdproc_fire()
{
    dprint("^1Bang, ^3your dead^7 ",self.enemy.netname,"! ^1(turret with no real firefunc)\n");
}

/*
    When .used a turret switch team to activator.team.
    If activator is world, the turret go inactive.
*/
void turret_stdproc_use()
{
    dprint("Turret ",self.netname, " used by ", activator.classname, "\n");

    self.team = activator.team;

    if(self.team == 0)
        self.active = ACTIVE_NOT;
    else
        self.active = ACTIVE_ACTIVE;

}

void turret_link()
{
    Net_LinkEntity(self, TRUE, 0, turret_send);
    self.think      = turret_think;
    self.nextthink  = time;
    self.tur_head.effects = EF_NODRAW;
}

void turrets_manager_think()
{
    self.nextthink = time + 1;

    entity e;
    if (autocvar_g_turrets_reloadcvars == 1)
    {
        e = nextent(world);
        while (e)
        {
            if (e.turrcaps_flags & TFL_TURRCAPS_ISTURRET)
            {
                load_unit_settings(e,e.cvar_basename,1);
                if(e.turret_postthink)
                    e.turret_postthink();
            }

            e = nextent(e);
        }
        cvar_set("g_turrets_reloadcvars","0");
    }
}

/*
* Standard turret initialization. use this!
* (unless you have a very good reason not to)
* if the return value is 0, the turret should be removed.
*/
float turret_stdproc_init (string cvar_base_name, string base, string head, float _turret_type)
{
	entity e, ee = world;

    // Are turrets allowed?
    if (autocvar_g_turrets == 0)
        return 0;
    
    if(_turret_type < 1 || _turret_type > TID_LAST)
    {
        dprint("Invalid / Unkown turret type\"", ftos(_turret_type), "\", aborting!\n");
        return 0;
    }    
    self.turret_type = _turret_type;
    
    e = find(world, classname, "turret_manager");
    if not (e)
    {
        e = spawn();
        e.classname = "turret_manager";
        e.think = turrets_manager_think;
        e.nextthink = time + 2;
    }
    
    if not (self.spawnflags & TSF_SUSPENDED)
        builtin_droptofloor(); // why can't we use regular droptofloor here?

    // Terrainbase spawnflag. This puts a enlongated model
    // under the turret, so it looks ok on uneaven surfaces.
    /*  TODO: Handle this with CSQC
    if (self.spawnflags & TSF_TERRAINBASE)
    {
        entity tb;
        tb = spawn();
        setmodel(tb,"models/turrets/terrainbase.md3");
        setorigin(tb,self.origin);
        tb.solid = SOLID_BBOX;
    }
    */

    self.cvar_basename = cvar_base_name;
    load_unit_settings(self, self.cvar_basename, 0);

    self.effects = EF_NODRAW;
    
    // Handle turret teams.
    if not (teamplay)
		self.team = MAX_SHOT_DISTANCE; // Group all turrets into the same team, so they dont kill eachother.
	else if(g_onslaught && self.targetname)
	{
		e = find(world,target,self.targetname);
		if(e != world)
		{
			self.team = e.team;
			ee = e;
		}
	}
	else if(!self.team)
		self.team = MAX_SHOT_DISTANCE; // Group all turrets into the same team, so they dont kill eachother.

    /*
    * Try to guess some reasonaly defaults
    * for missing params and do sanety checks
    * thise checks could produce some "interesting" results
    * if it hits a glitch in my logic :P so try to set as mutch
    * as possible beforehand.
    */
    if not(self.ticrate)
    {        
        if (self.turrcaps_flags & TFL_TURRCAPS_SUPPORT)
            self.ticrate = 0.2;     // Support units generaly dont need to have a high speed ai-loop
        else
            self.ticrate = 0.1;     // 10 fps for normal turrets
    }
    
    self.ticrate = bound(sys_frametime, self.ticrate, 60);  // keep it sane

// General stuff
    if (self.netname == "")
        self.netname = self.classname;

    if not (self.respawntime)
        self.respawntime = 60;
    self.respawntime = max(-1, self.respawntime);

    if not (self.health)
        self.health = 1000;
    self.tur_health = max(1, self.health);
	self.max_health = self.tur_health;
	self.bot_attack = TRUE;
    self.monster_attack = TRUE;

    if not (self.turrcaps_flags)
        self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;

    if not (self.damage_flags)
        self.damage_flags = TFL_DMG_YES | TFL_DMG_RETALIATE | TFL_DMG_AIMSHAKE;

// Shot stuff.
    if not (self.shot_refire)
        self.shot_refire = 1;
    self.shot_refire = bound(0.01, self.shot_refire, 9999);

    if not (self.shot_dmg)
        self.shot_dmg  = self.shot_refire * 50;
    self.shot_dmg = max(1, self.shot_dmg);

    if not (self.shot_radius)
        self.shot_radius = self.shot_dmg * 0.5;
    self.shot_radius = max(1, self.shot_radius);

    if not (self.shot_speed)
        self.shot_speed = 2500;
    self.shot_speed = max(1, self.shot_speed);

    if not (self.shot_spread)
        self.shot_spread = 0.0125;
    self.shot_spread = bound(0.0001, self.shot_spread, 500);

    if not (self.shot_force)
        self.shot_force = self.shot_dmg * 0.5 + self.shot_radius * 0.5;
    self.shot_force = bound(0.001, self.shot_force, 5000);

    if not (self.shot_volly)
        self.shot_volly = 1;
    self.shot_volly = bound(1, self.shot_volly, floor(self.ammo_max / self.shot_dmg));

    if not (self.shot_volly_refire)
        self.shot_volly_refire = self.shot_refire * self.shot_volly;
    self.shot_volly_refire = bound(self.shot_refire, self.shot_volly_refire, 60);

    if not (self.firecheck_flags)
        self.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES |
                               TFL_FIRECHECK_LOS | TFL_FIRECHECK_AIMDIST | TFL_FIRECHECK_TEAMCECK |
                               TFL_FIRECHECK_OWM_AMMO | TFL_FIRECHECK_REFIRE;

// Range stuff.
    if not (self.target_range)
        self.target_range = self.shot_speed * 0.5;
    self.target_range = bound(0, self.target_range, MAX_SHOT_DISTANCE);

    if not (self.target_range_min)
        self.target_range_min = self.shot_radius * 2;
    self.target_range_min = bound(0, self.target_range_min, MAX_SHOT_DISTANCE);

    if not (self.target_range_optimal)
        self.target_range_optimal = self.target_range * 0.5;
    self.target_range_optimal = bound(0, self.target_range_optimal, MAX_SHOT_DISTANCE);


// Aim stuff.
    if not (self.aim_maxrot)
        self.aim_maxrot = 90;
    self.aim_maxrot = bound(0, self.aim_maxrot, 360);

    if not (self.aim_maxpitch)
        self.aim_maxpitch = 20;
    self.aim_maxpitch = bound(0, self.aim_maxpitch, 90);

    if not (self.aim_speed)
        self.aim_speed = 36;
    self.aim_speed  = bound(0.1, self.aim_speed, 1000);

    if not (self.aim_firetolerance_dist)
        self.aim_firetolerance_dist  = 5 + (self.shot_radius * 2);
    self.aim_firetolerance_dist = bound(0.1, self.aim_firetolerance_dist, MAX_SHOT_DISTANCE);

    if not (self.aim_flags)
    {
        self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
        if(self.turrcaps_flags & TFL_TURRCAPS_RADIUSDMG)
            self.aim_flags |= TFL_AIM_GROUNDGROUND;
    }

    if not (self.track_type)
        self.track_type = TFL_TRACKTYPE_STEPMOTOR;

    if (self.track_type != TFL_TRACKTYPE_STEPMOTOR)
    {
        // Fluid / Ineria mode. Looks mutch nicer.
        // Can reduce aim preformance alot, needs a bit diffrent aimspeed

        if not (self.aim_speed)
            self.aim_speed = 180;
        self.aim_speed = bound(0.1, self.aim_speed, 1000);

        if not (self.track_accel_pitch)
            self.track_accel_pitch = 0.5;

        if not (self.track_accel_rot)
            self.track_accel_rot   = 0.5;

        if not (self.track_blendrate)
            self.track_blendrate   = 0.35;
    }

    if (!self.track_flags)
        self.track_flags = TFL_TRACK_PITCH | TFL_TRACK_ROT;


// Target selection stuff.
    if not (self.target_select_rangebias)
        self.target_select_rangebias = 1;
    self.target_select_rangebias = bound(-10, self.target_select_rangebias, 10);

    if not (self.target_select_samebias)
        self.target_select_samebias = 1;
    self.target_select_samebias = bound(-10, self.target_select_samebias, 10);

    if not (self.target_select_anglebias)
        self.target_select_anglebias = 1;
    self.target_select_anglebias = bound(-10, self.target_select_anglebias, 10);

    if not (self.target_select_missilebias)
        self.target_select_missilebias = -10;

    self.target_select_missilebias = bound(-10, self.target_select_missilebias, 10);
    self.target_select_playerbias = bound(-10, self.target_select_playerbias, 10);

    if not (self.target_select_flags)
    {
            self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_TEAMCHECK
                                     | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_ANGLELIMITS;

        if (self.turrcaps_flags & TFL_TURRCAPS_MISSILEKILL)
            self.target_select_flags |= TFL_TARGETSELECT_MISSILES;

        if (self.turrcaps_flags & TFL_TURRCAPS_PLAYERKILL)
            self.target_select_flags |= TFL_TARGETSELECT_PLAYERS;
        //else
        //    self.target_select_flags = TFL_TARGETSELECT_NO;
    }

    self.target_validate_flags = self.target_select_flags;

// Ammo stuff
    if not (self.ammo_max)
        self.ammo_max = self.shot_dmg * 10;
    self.ammo_max = max(self.shot_dmg, self.ammo_max);

    if not (self.ammo)
        self.ammo = self.shot_dmg * 5;
    self.ammo = bound(0,self.ammo, self.ammo_max);

    if not (self.ammo_recharge)
        self.ammo_recharge = self.shot_dmg * 0.5;
    self.ammo_recharge = max(0 ,self.ammo_recharge);

    // Convert the recharge from X per sec to X per ticrate
    self.ammo_recharge = self.ammo_recharge * self.ticrate;

    if not (self.ammo_flags)
        self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE;

// Damage stuff
    if(self.spawnflags & TSL_NO_RESPAWN)
        if not (self.damage_flags & TFL_DMG_DEATH_NORESPAWN)
            self.damage_flags |= TFL_DMG_DEATH_NORESPAWN;

// Offsets & origins
    if (!self.tur_shotorg)   self.tur_shotorg = '50 0 50';
    
    if (!self.health)
        self.health = 150;

// Game hooks
	if(MUTATOR_CALLHOOK(TurretSpawn))
		return 0;

// End of default & sanety checks, start building the turret.

// Spawn extra bits
    self.tur_head         = spawn();
    self.tur_head.netname = self.tur_head.classname = "turret_head";
    self.tur_head.team    = self.team;
    self.tur_head.owner   = self;

    setmodel(self, base);
    setmodel(self.tur_head, head);

    setsize(self, '-32 -32 0', '32 32 64');
    setsize(self.tur_head, '0 0 0', '0 0 0');

    setorigin(self.tur_head, '0 0 0');
    setattachment(self.tur_head, self, "tag_head");

    self.tur_health          = self.health;
    self.solid               = SOLID_BBOX;
    self.tur_head.solid      = SOLID_NOT;
    self.takedamage          = DAMAGE_AIM;
    self.tur_head.takedamage = DAMAGE_NO;
    self.movetype            = MOVETYPE_NOCLIP;
    self.tur_head.movetype   = MOVETYPE_NOCLIP;

    // Defend mode?
    if not (self.tur_defend)
    if (self.target != "")
    {
        self.tur_defend = find(world, targetname, self.target);
        if (self.tur_defend == world)
        {
            self.target = "";
            dprint("Turret has invalid defendpoint!\n");
        }
    }

    // In target defend mode, aim on the spot to defend when idle.
    if (self.tur_defend)
        self.idle_aim  = self.tur_head.angles + angleofs(self.tur_head, self.tur_defend);
    else
        self.idle_aim  = '0 0 0';

    // Attach stdprocs. override when and what needed
    self.turret_firecheckfunc   = turret_stdproc_firecheck;
    self.turret_firefunc        = turret_stdproc_fire;
    self.event_damage           = turret_stdproc_damage;
    
    if (self.turrcaps_flags & TFL_TURRCAPS_SUPPORT)
        self.turret_score_target    = turret_stdproc_targetscore_support;
    else
        self.turret_score_target    = turret_stdproc_targetscore_generic;

    self.use = turret_stdproc_use;

    ++turret_count;
    self.nextthink = time + 1;
    self.nextthink +=  turret_count * sys_frametime;

    self.tur_head.team = self.team;
    self.view_ofs = '0 0 0';

#ifdef TURRET_DEBUG
    self.tur_dbg_start = self.nextthink;
    while (vlen(self.tur_dbg_rvec) < 2)
        self.tur_dbg_rvec  = randomvec() * 4;

    self.tur_dbg_rvec_x = fabs(self.tur_dbg_rvec_x);
    self.tur_dbg_rvec_y = fabs(self.tur_dbg_rvec_y);
    self.tur_dbg_rvec_z = fabs(self.tur_dbg_rvec_z);
#endif

    // Its all good.
    self.turrcaps_flags |= TFL_TURRCAPS_ISTURRET;

    self.classname = "turret_main";

    self.active = ACTIVE_ACTIVE;

    // In ONS mode, and linked to a ONS ent. need to call the use to set team.
    if (g_onslaught && ee)
    {
        activator = ee;
        self.use();
    }
    
	turret_link();
	turret_stdproc_respawn();	    
    turret_tag_fire_update();
    
    return 1;
}


