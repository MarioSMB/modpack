//#define TURRET_DEBUG_HK

#ifdef TURRET_DEBUG_HK
.float atime;
#endif

void spawnfunc_turret_hk();
void turret_hk_dinit();
void turret_hk_attack();


float hk_is_valid_target(entity e_target)
{
    if (e_target == world)
        return 0;

    // If only this was used more..
    if (e_target.flags & FL_NOTARGET)
        return 0;

    // Cant touch this
    if ((e_target.takedamage == DAMAGE_NO) || (e_target.health < 0))
        return 0;

    // player
    if (IS_CLIENT(e_target))
    {
        if (self.owner.target_select_playerbias < 0)
            return 0;

        if (e_target.deadflag != DEAD_NO)
            return 0;
    }

    // Missile
    if ((e_target.flags & FL_PROJECTILE) && (self.owner.target_select_missilebias < 0))
        return 0;

    // Team check
    if ((e_target.team == self.owner.team) || (self.owner.team == e_target.owner.team))
        return 0;

    return 1;
}
void turret_hk_missile_think()
{
    vector vu, vd, vf, vl, vr, ve;  // Vector (direction)
    float  fu, fd, ff, fl, fr, fe;  // Fraction to solid
    vector olddir,wishdir,newdir;   // Final direction
    float lt_for;   // Length of Trace FORwrad
    float lt_seek;  // Length of Trace SEEK (left, right, up down)
    float pt_seek;  // Pitch of Trace SEEK (How mutch to angele left, right up, down trace towards v_forward)
    vector pre_pos;
    float myspeed;
    entity e;
    float ad,edist;

    self.nextthink = time + self.ticrate;

    //if (self.cnt < time)
    //    turret_hk_missile_explode();

    if (self.enemy.deadflag != DEAD_NO)
        self.enemy = world;

    // Pick the closest valid target.
    if (!self.enemy)
    {
        e = findradius(self.origin, 5000);
        while (e)
        {
            if (hk_is_valid_target(e))
            {
                if (!self.enemy)
                    self.enemy = e;
                else
                    if (vlen(self.origin - e.origin) < vlen(self.origin - self.enemy.origin))
                        self.enemy = e;
            }
            e = e.chain;
        }
    }

    self.angles = vectoangles(self.velocity);
    self.angles_x = self.angles_x * -1;
    makevectors(self.angles);
    self.angles_x = self.angles_x * -1;

    if (self.enemy)
    {
        edist = vlen(self.origin - self.enemy.origin);
        // Close enougth to do decent damage?
        if ( edist <= (self.owner.shot_radius * 0.25) )
        {
            turret_projectile_explode();
            return;
        }

        // Get data on enemy position
        pre_pos = self.enemy.origin +
                  self.enemy.velocity *
                  min((vlen(self.enemy.origin - self.origin) / vlen(self.velocity)),0.5);

        traceline(self.origin, pre_pos,TRUE,self.enemy);
        ve = normalize(pre_pos - self.origin);
        fe = trace_fraction;

    }
    else
    {
	edist = 0;
	ve = '0 0 0';
        fe = 0;
    }

    if ((fe != 1) || (self.enemy == world) || (edist > 1000))
    {
        myspeed = vlen(self.velocity);

        lt_for  = myspeed * 3;
        lt_seek = myspeed * 2.95;

        // Trace forward
        traceline(self.origin, self.origin + v_forward * lt_for,FALSE,self);
        vf = trace_endpos;
        ff = trace_fraction;

        // Find angular offset
        ad = vlen(vectoangles(normalize(self.enemy.origin - self.origin)) - self.angles);

        // To close to something, Slow down!
        if ( ((ff < 0.7) || (ad > 4)) && (myspeed > autocvar_g_turrets_unit_hk_std_shot_speed) )
            myspeed = max(myspeed * autocvar_g_turrets_unit_hk_std_shot_speed_decel, autocvar_g_turrets_unit_hk_std_shot_speed);

        // Failry clear, accelerate.
        if ( (ff > 0.7) && (myspeed < autocvar_g_turrets_unit_hk_std_shot_speed_max) )
            myspeed = min(myspeed * autocvar_g_turrets_unit_hk_std_shot_speed_accel, autocvar_g_turrets_unit_hk_std_shot_speed_max);

        // Setup trace pitch
        pt_seek = 1 - ff;
        pt_seek = bound(0.15,pt_seek,0.8);
        if (ff < 0.5) pt_seek = 1;

        // Trace left
        traceline(self.origin, self.origin + (-1 * (v_right * pt_seek) + (v_forward * ff)) * lt_seek,FALSE,self);
        vl = trace_endpos;
        fl = trace_fraction;

        // Trace right
        traceline(self.origin,  self.origin + ((v_right * pt_seek) + (v_forward * ff)) * lt_seek ,FALSE,self);
        vr = trace_endpos;
        fr = trace_fraction;

        // Trace up
        traceline(self.origin,  self.origin + ((v_up * pt_seek) + (v_forward * ff)) * lt_seek ,FALSE,self);
        vu = trace_endpos;
        fu = trace_fraction;

        // Trace down
        traceline(self.origin,  self.origin + (-1 * (v_up * pt_seek) + (v_forward * ff)) * lt_seek ,FALSE,self);
        vd = trace_endpos;
        fd = trace_fraction;

        vl = normalize(vl - self.origin);
        vr = normalize(vr - self.origin);
        vu = normalize(vu - self.origin);
        vd = normalize(vd - self.origin);

        // Panic tresh passed, find a single direction and turn as hard as we can
        if (pt_seek == 1)
        {
            wishdir = v_right;
            if (fl > fr) wishdir = -1 * v_right;
            if (fu > fl) wishdir = v_up;
            if (fd > fu) wishdir = -1 * v_up;
        }
        else
        {
            // Normalize our trace vectors to make a smooth path
            wishdir = normalize( (vl * fl) + (vr * fr) +  (vu * fu) +  (vd * fd) );
        }

        if (self.enemy)
        {
            if (fe < 0.1) fe = 0.1; // Make sure we always try to move sligtly towards our target
            wishdir = (wishdir * (1 - fe)) + (ve * fe);
        }
    }
    else
    {
        // Got a clear path to target, speed up fast (if not at full speed) and go straight for it.
        myspeed = vlen(self.velocity);
        if (myspeed < autocvar_g_turrets_unit_hk_std_shot_speed_max)
            myspeed = min(myspeed * autocvar_g_turrets_unit_hk_std_shot_speed_accel2,autocvar_g_turrets_unit_hk_std_shot_speed_max);

        wishdir = ve;
    }

    if ((myspeed > autocvar_g_turrets_unit_hk_std_shot_speed) && (self.cnt > time))
        myspeed = min(myspeed * autocvar_g_turrets_unit_hk_std_shot_speed_accel2,autocvar_g_turrets_unit_hk_std_shot_speed_max);

    // Ranoutagazfish?
    if (self.cnt < time)
    {
        self.cnt = time + 0.25;
        self.nextthink = 0;
        self.movetype         = MOVETYPE_BOUNCE;
        return;
    }

    // Calculate new heading
    olddir = normalize(self.velocity);
    newdir = normalize(olddir + wishdir * autocvar_g_turrets_unit_hk_std_shot_speed_turnrate);

    // Set heading & speed
    self.velocity = newdir * myspeed;

    // Align model with new heading
    self.angles = vectoangles(self.velocity);


#ifdef TURRET_DEBUG_HK
    //if(self.atime < time) {
    if ((fe <= 0.99)||(edist > 1000))
    {
        te_lightning2(world,self.origin, self.origin + vr * lt_seek);
        te_lightning2(world,self.origin, self.origin + vl * lt_seek);
        te_lightning2(world,self.origin, self.origin + vu * lt_seek);
        te_lightning2(world,self.origin, self.origin + vd * lt_seek);
        te_lightning2(world,self.origin, vf);
    }
    else
    {
        te_lightning2(world,self.origin, self.enemy.origin);
    }
    bprint("Speed: ", ftos(rint(myspeed)), "\n");
    bprint("Trace to solid: ", ftos(rint(ff * 100)), "%\n");
    bprint("Trace to target:", ftos(rint(fe * 100)), "%\n");
    self.atime = time + 0.2;
    //}
#endif

	UpdateCSQCProjectile(self);
}

void turret_hk_attack()
{
    entity missile;

    missile = turret_projectile("weapons/rocket_fire.wav", 6, 10, DEATH_TURRET_HK, PROJECTILE_ROCKET, FALSE, FALSE);
    te_explosion (missile.origin);

    missile.think            = turret_hk_missile_think;
    missile.nextthink        = time + 0.25;
    missile.movetype         = MOVETYPE_BOUNCEMISSILE;
    missile.velocity         = self.tur_shotdir_updated * (self.shot_speed * 0.75);
    missile.angles           = vectoangles(missile.velocity);
    missile.cnt              = time + 30;
    missile.ticrate          = max(autocvar_sys_ticrate, 0.05);
    missile.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_GUIDED_AI;
    
    if (self.tur_head.frame == 0)
        self.tur_head.frame = self.tur_head.frame + 1;

}

void turret_hk_postthink()
{
    if (self.tur_head.frame != 0)
        self.tur_head.frame = self.tur_head.frame + 1;

    if (self.tur_head.frame > 5)
        self.tur_head.frame = 0;
}

float turret_hk_addtarget(entity e_target,entity e_sender)
{
    if (e_target)
    {
        if (turret_validate_target(self,e_target,self.target_validate_flags) > 0)
        {
            self.enemy = e_target;
            return 1;
        }
    }

    return 0;
}

void turret_hk_dinit()
{
    if (self.netname == "")      
        self.netname  = "Hunter-killer turret";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_RECIVETARGETS;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags = TFL_AIM_SIMPLE;
    self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_TRIGGERTARGET | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;
    self.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_TEAMCECK  | TFL_FIRECHECK_REFIRE | TFL_FIRECHECK_AFF;
    self.shoot_flags = TFL_SHOOT_CLEARTARGET;

    if (turret_stdproc_init("hk_std", "models/turrets/base.md3", "models/turrets/hk.md3", TID_HK) == 0)
    {
        remove(self);
        return;
    }

    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_TEAMCHECK;

    // Our fire routine
    self.turret_firefunc  = turret_hk_attack;

    // re-color badge & handle recoil effect
    self.turret_postthink = turret_hk_postthink;

    // What to do when reciveing foreign target data
    self.turret_addtarget = turret_hk_addtarget;
}


/*QUAKED turret_hk (0 .5 .8) ?
* Turret that fires Hunter-killer missiles.
* Missiles seek their target and try to avoid obstacles. If target dies early, they
* pick a new one on their own.
*/

void spawnfunc_turret_hk()
{
    precache_model ("models/turrets/base.md3");
    precache_model ("models/turrets/hk.md3");

    self.think = turret_hk_dinit;
    self.nextthink = time + 0.5;
}


