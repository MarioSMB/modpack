#define ANIM_NO         0
#define ANIM_TURN       1
#define ANIM_WALK       2
#define ANIM_RUN        3
#define ANIM_STRAFE_L   4
#define ANIM_STRAFE_R   5
#define ANIM_JUMP       6
#define ANIM_LAND       7
#define ANIM_PAIN       8
#define ANIM_MEELE      9
#define ANIM_SWIM       10
#define ANIM_ROAM       11
.float animflag;

#define WALKER_MIN '-70 -70 0'
#define WALKER_MAX '70 70 95'

#define WALKER_PATH(s,e) pathlib_astar(s,e)

float walker_firecheck()
{
    if (self.animflag == ANIM_MEELE)
        return 0;

    return turret_stdproc_firecheck();
}

void walker_meele_do_dmg()
{
    vector where;
    entity e;
    
    makevectors(self.angles);
    where = self.origin + v_forward * 128;

    e = findradius(where,32);
    while (e) 
    {
        if (turret_validate_target(self, e, self.target_validate_flags))
            if (e != self && e.owner != self)
                Damage(e, self, self, autocvar_g_turrets_unit_walker_std_meele_dmg, DEATH_TURRET_WALK_MEELE, '0 0 0', v_forward * autocvar_g_turrets_unit_walker_std_meele_force);

        e = e.chain;
    }
}

void walker_setnoanim()
{
    turrets_setframe(ANIM_NO, FALSE);
    self.animflag = self.frame;
}
void walker_rocket_explode()
{
    RadiusDamage (self, self.owner, autocvar_g_turrets_unit_walker_std_rocket_dmg, 0, autocvar_g_turrets_unit_walker_std_rocket_radius, self, autocvar_g_turrets_unit_walker_std_rocket_force, DEATH_TURRET_WALK_ROCKET, world);
    remove (self);
}

void walker_rocket_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.health = self.health - damage;
    self.velocity = self.velocity + vforce;
    
    if (self.health <= 0)
        W_PrepareExplosionByDamage(self.owner, walker_rocket_explode);
}

#define WALKER_ROCKET_MOVE movelib_move_simple(newdir, autocvar_g_turrets_unit_walker_std_rocket_speed, autocvar_g_turrets_unit_walker_std_rocket_turnrate); UpdateCSQCProjectile(self)
void walker_rocket_loop();
void walker_rocket_think()
{
    vector newdir;
    float edist;
    float itime;
    float m_speed;

    self.nextthink = time;

    edist = vlen(self.enemy.origin - self.origin);

    // Simulate crude guidance
    if (self.cnt < time)
    {
        if (edist < 1000)
            self.tur_shotorg = randomvec() * min(edist, 64);
        else
            self.tur_shotorg = randomvec() * min(edist, 256);

        self.cnt = time + 0.5;
    }

    if (edist < 128)
        self.tur_shotorg = '0 0 0';

    if (self.tur_health < time)
    {
        self.think      = walker_rocket_explode;
        self.nextthink  = time;
        return;
    }

    if (self.shot_dmg != 1337 && random() < 0.01)
    {
        walker_rocket_loop();
        return;
    }

    m_speed = vlen(self.velocity);

    // Enemy dead? just keep on the current heading then.
    if (self.enemy == world || self.enemy.deadflag != DEAD_NO)
        self.enemy = world;

    if (self.enemy)
    {
        itime = max(edist / m_speed, 1);
        newdir = steerlib_pull(self.enemy.origin + self.tur_shotorg);
    }
    else
        newdir  = normalize(self.velocity);

    WALKER_ROCKET_MOVE;
}

void walker_rocket_loop3()
{
    vector newdir;
    self.nextthink = time;

    if (self.tur_health < time)
    {
        self.think = walker_rocket_explode;
        return;
    }

    if (vlen(self.origin - self.tur_shotorg) < 100 )
    {
        self.think = walker_rocket_think;
        return;
    }

    newdir = steerlib_pull(self.tur_shotorg);
    WALKER_ROCKET_MOVE;

    self.angles = vectoangles(self.velocity);
}

void walker_rocket_loop2()
{
    vector newdir;

    self.nextthink = time;

    if (self.tur_health < time)
    {
        self.think = walker_rocket_explode;
        return;
    }

    if (vlen(self.origin - self.tur_shotorg) < 100 )
    {
        self.tur_shotorg = self.origin - '0 0 200';
        self.think = walker_rocket_loop3;
        return;
    }

    newdir = steerlib_pull(self.tur_shotorg);
    WALKER_ROCKET_MOVE;
}

void walker_rocket_loop()
{
    self.nextthink = time;
    self.tur_shotorg = self.origin + '0 0 300';
    self.think = walker_rocket_loop2;
    self.shot_dmg = 1337;
}

void walker_fire_rocket(vector org)
{
    entity rocket;
 
    fixedmakevectors(self.angles);

    te_explosion (org);

    rocket = spawn ();
    setorigin(rocket, org);

    sound (self, CH_WEAPON_A, "weapons/hagar_fire.wav", VOL_BASE, ATTEN_NORM);
    setsize (rocket, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

    rocket.classname          = "walker_rocket";
    rocket.owner              = self;
    rocket.bot_dodge          = TRUE;
    rocket.bot_dodgerating    = 50;
    rocket.takedamage         = DAMAGE_YES;
    rocket.damageforcescale   = 2;
    rocket.health             = 25;
    rocket.tur_shotorg        = randomvec() * 512;
    rocket.cnt                = time + 1;
    rocket.enemy              = self.enemy;
    
    if (random() < 0.01)
        rocket.think          = walker_rocket_loop;
    else
        rocket.think          = walker_rocket_think;

    rocket.event_damage       = walker_rocket_damage;

    rocket.nextthink          = time;
    rocket.movetype           = MOVETYPE_FLY;
    rocket.velocity           = normalize((v_forward + v_up * 0.5) + (randomvec() * 0.2)) * autocvar_g_turrets_unit_walker_std_rocket_speed;
    rocket.angles             = vectoangles(rocket.velocity);
    rocket.touch              = walker_rocket_explode;
    rocket.flags              = FL_PROJECTILE;
    rocket.solid              = SOLID_BBOX;
    rocket.tur_health         = time + 9;
    rocket.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_GUIDED_HEAT;
    
    CSQCProjectile(rocket, FALSE, PROJECTILE_ROCKET, FALSE); // no culling, has fly sound
}

.vector enemy_last_loc;
.float enemy_last_time;
void walker_move_to(vector _target, float _dist)
{
    switch (self.waterlevel)
    {
    case WATERLEVEL_NONE:
        if (_dist > 500)
            self.animflag = ANIM_RUN;
        else
            self.animflag = ANIM_WALK;
    case WATERLEVEL_WETFEET:
    case WATERLEVEL_SWIMMING:
        if (self.animflag != ANIM_SWIM)
            self.animflag = ANIM_WALK;
        else
            self.animflag = ANIM_SWIM;
        break;
    case WATERLEVEL_SUBMERGED:
        self.animflag = ANIM_SWIM;
    }

    self.moveto = _target;
    self.steerto = steerlib_attract2(self.moveto, 0.5, 500, 0.95);

    if(self.enemy)
    {
        self.enemy_last_loc = _target;
        self.enemy_last_time = time;        
    }
}

//#define WALKER_FANCYPATHING

void walker_move_path()
{
#ifdef WALKER_FANCYPATHING
    // Are we close enougth to a path node to switch to the next?
    if (vlen(self.origin  - self.pathcurrent.origin) < 64)
        if (self.pathcurrent.path_next == world)
        {
            // Path endpoint reached
            pathlib_deletepath(self.pathcurrent.owner);
            self.pathcurrent = world;

            if (self.pathgoal)
            {
                if (self.pathgoal.use)
                    self.pathgoal.use();

                if (self.pathgoal.enemy)
                {
                    self.pathcurrent = WALKER_PATH(self.pathgoal.origin,self.pathgoal.enemy.origin);
                    self.pathgoal = self.pathgoal.enemy;
                }
            }
            else
                self.pathgoal = world;
        }
        else
            self.pathcurrent = self.pathcurrent.path_next;

    self.moveto = self.pathcurrent.origin;
    self.steerto = steerlib_attract2(self.moveto,0.5,500,0.95);
    walker_move_to(self.moveto, 0);

#else
    if (vlen(self.origin - self.pathcurrent.origin) < 64)    
        self.pathcurrent = self.pathcurrent.enemy;
    
    if(!self.pathcurrent)
        return;
    
    self.moveto = self.pathcurrent.origin;
    self.steerto = steerlib_attract2(self.moveto, 0.5, 500, 0.95);
    walker_move_to(self.moveto, 0);
#endif
}

.float idletime;
void walker_postthink()
{
    fixedmakevectors(self.angles);

    if (self.spawnflags & TSF_NO_PATHBREAK && self.pathcurrent)
        walker_move_path();
    else if (self.enemy == world)
    {
        if(self.pathcurrent)
            walker_move_path();
        else
        {
            if(self.enemy_last_time != 0)
            {
                if(vlen(self.origin - self.enemy_last_loc) < 128 || time - self.enemy_last_time > 10)
                    self.enemy_last_time = 0;
                else                
                    walker_move_to(self.enemy_last_loc, 0);
            }
            else
            {        
                if(self.animflag != ANIM_NO)
                {                    
                    traceline(self.origin + '0 0 64', self.origin + '0 0 64' + v_forward * 128, MOVE_NORMAL, self);
                    
                    if(trace_fraction != 1.0)
                        self.tur_head.idletime = -1337;
                    else
                    {
                        traceline(trace_endpos, trace_endpos - '0 0 256', MOVE_NORMAL, self);            
                        if(trace_fraction == 1.0)
                            self.tur_head.idletime = -1337;
                    }
                    
                    if(self.tur_head.idletime == -1337)
                    {
                        self.moveto = self.origin + randomvec() * 256;        
                        self.tur_head.idletime = 0;
                    }

                    self.moveto = self.moveto * 0.9 + ((self.origin + v_forward * 500) + randomvec() * 400) * 0.1;
                    self.moveto_z = self.origin_z + 64;            
                    walker_move_to(self.moveto, 0);
                }         
                
                if(self.idletime < time)
                {
                    if(random() < 0.5 || !(self.spawnflags & TSL_ROAM))
                    {
                        self.idletime = time + 1 + random() * 5;
                        self.moveto = self.origin;
                        self.animflag = ANIM_NO;
                    }
                    else
                    {
                        self.animflag = ANIM_WALK;
                        self.idletime = time + 4 + random() * 2;
                        self.moveto = self.origin + randomvec() * 256;        
                        self.tur_head.moveto = self.moveto;
                        self.tur_head.idletime = 0;
                    }
                }
            }            
        }
    }
    else
    {
        if (self.tur_dist_enemy < autocvar_g_turrets_unit_walker_std_meele_range && self.animflag != ANIM_MEELE)
        {
            vector wish_angle;
            
            wish_angle = angleofs(self, self.enemy);    
            if (self.animflag != ANIM_SWIM)
            if (fabs(wish_angle_y) < 15)
            {
                self.moveto   = self.enemy.origin;
                self.steerto  = steerlib_attract2(self.moveto, 0.5, 500, 0.95);
                self.animflag = ANIM_MEELE;
            }
        }
        else if (self.tur_head.attack_finished_single < time)
        {            
            if(self.tur_head.shot_volly)
            {
                self.animflag = ANIM_NO;
                
                self.tur_head.shot_volly = self.tur_head.shot_volly -1;
                if(self.tur_head.shot_volly == 0)
                    self.tur_head.attack_finished_single = time + autocvar_g_turrets_unit_walker_std_rocket_refire;
                else
                    self.tur_head.attack_finished_single = time + 0.2;
                
                if(self.tur_head.shot_volly > 1)
                    walker_fire_rocket(gettaginfo(self, gettagindex(self, "tag_rocket01")));
                else
                    walker_fire_rocket(gettaginfo(self, gettagindex(self, "tag_rocket02")));
            }
            else
            {
                if (self.tur_dist_enemy > autocvar_g_turrets_unit_walker_std_rockets_range_min)        
                if (self.tur_dist_enemy < autocvar_g_turrets_unit_walker_std_rockets_range)
                    self.tur_head.shot_volly = 4;
            }
        }
        else
        {            
            if (self.animflag != ANIM_MEELE)
                walker_move_to(self.enemy.origin, self.tur_dist_enemy);
        }
    }

    //if(self.animflag != ANIM_NO)
    {
        vector real_angle;
        float turny = 0, turnx = 0;
        float  vz;

        real_angle = vectoangles(self.steerto) - self.angles;
        vz         = self.velocity_z;
            
        switch (self.animflag)
        {
            case ANIM_NO:
                movelib_beak_simple(autocvar_g_turrets_unit_walker_speed_stop);
                break;

            case ANIM_TURN:
                turny = autocvar_g_turrets_unit_walker_turn;
                movelib_beak_simple(autocvar_g_turrets_unit_walker_speed_stop);
                break;

            case ANIM_WALK:
                turny = autocvar_g_turrets_unit_walker_turn_walk;
                movelib_move_simple(v_forward, autocvar_g_turrets_unit_walker_speed_walk, 0.6);
                break;

            case ANIM_RUN:
                turny = autocvar_g_turrets_unit_walker_turn_run;
                movelib_move_simple(v_forward, autocvar_g_turrets_unit_walker_speed_run, 0.6);
                break;

            case ANIM_STRAFE_L:
                turny = autocvar_g_turrets_unit_walker_turn_strafe;
                movelib_move_simple(v_right * -1, autocvar_g_turrets_unit_walker_speed_walk, 0.8);
                break;

            case ANIM_STRAFE_R:
                turny = autocvar_g_turrets_unit_walker_turn_strafe;
                movelib_move_simple(v_right, autocvar_g_turrets_unit_walker_speed_walk, 0.8);
                break;

            case ANIM_JUMP:
                self.velocity += '0 0 1' * autocvar_g_turrets_unit_walker_speed_jump;
                break;

            case ANIM_LAND:
                break;

            case ANIM_PAIN:
                if(self.frame != ANIM_PAIN)
                    defer(0.25, walker_setnoanim);
                
                break;

            case ANIM_MEELE:
                if(self.frame != ANIM_MEELE)
                {
                    defer(0.41, walker_setnoanim);
                    defer(0.21, walker_meele_do_dmg);
                }

                movelib_beak_simple(autocvar_g_turrets_unit_walker_speed_stop);
                break;

            case ANIM_SWIM:
                turny = autocvar_g_turrets_unit_walker_turn_swim;
                turnx = autocvar_g_turrets_unit_walker_turn_swim;
                
                self.angles_x += bound(-10, shortangle_f(real_angle_x, self.angles_x), 10);
                movelib_move_simple(v_forward, autocvar_g_turrets_unit_walker_speed_swim, 0.3);
                vz = self.velocity_z + sin(time * 4) * 8;
                break;

            case ANIM_ROAM:
                turny = autocvar_g_turrets_unit_walker_turn_walk;
                movelib_move_simple(v_forward ,autocvar_g_turrets_unit_walker_speed_roam, 0.5);
                break;
        }
            
        if(turny)
        {        
            turny = bound( turny * -1, shortangle_f(real_angle_y, self.angles_y), turny );
            self.angles_y += turny;
        }

        if(turnx)
        {        
            turnx = bound( turnx * -1, shortangle_f(real_angle_x, self.angles_x), turnx );
            self.angles_x += turnx;
        }

        self.velocity_z = vz;        
    }

    
    if(self.origin != self.oldorigin)
        self.SendFlags |= TNSF_MOVE;
    
    self.oldorigin = self.origin;
    turrets_setframe(self.animflag, FALSE);
}

void walker_attack()
{
    sound (self, CH_WEAPON_A, "weapons/uzi_fire.wav", VOL_BASE, ATTEN_NORM);
    fireBallisticBullet (self.tur_shotorg, self.tur_shotdir_updated, self.shot_spread, self.shot_speed, 5, self.shot_dmg, self.shot_force, DEATH_TURRET_WALK_GUN, 0, 1, autocvar_g_balance_uzi_bulletconstant);
    endFireBallisticBullet();
    pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);
}


void walker_respawnhook()
{
    entity e;

    // Respawn is called & first spawn to, to set team. need to make sure we do not move the initial spawn.
    if(self.movetype != MOVETYPE_WALK)
		return;
		
    setorigin(self, self.pos1);
    self.angles = self.pos2;
    
    if (self.target != "")
    {
        e = find(world, targetname, self.target);
        if (!e)
        {
            dprint("Warning! initital waypoint for Walker does NOT exsist!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
 #ifdef WALKER_FANCYPATHING
            self.pathcurrent = WALKER_PATH(self.origin, e.origin);
            self.pathgoal = e;
#else
            self.pathcurrent = e;
#endif
        }
    }
}

void walker_diehook()
{
#ifdef WALKER_FANCYPATHING
    if (self.pathcurrent)
        pathlib_deletepath(self.pathcurrent.owner);
#endif
    self.pathcurrent = world;
}

void turret_walker_dinit()
{
    entity e;

    if (self.netname == "")      self.netname     = "Walker Turret";

    self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MOVE ;
    self.aim_flags = TFL_AIM_LEAD;

    if (autocvar_g_antilag_bullets)
        self.turrcaps_flags |= TFL_TURRCAPS_HITSCAN;
    else
        self.aim_flags      |= TFL_AIM_SHOTTIMECOMPENSATE;


    self.turret_respawnhook = walker_respawnhook;
    self.turret_diehook = walker_diehook;

    self.ticrate = 0.05;
    if (turret_stdproc_init("walker_std", "models/turrets/walker_body.md3", "models/turrets/walker_head_minigun.md3", TID_WALKER) == 0)
    {
        remove(self);
        return;
    }
    setsize(self, WALKER_MIN, WALKER_MAX);
    self.target_select_flags   = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.iscreature = TRUE;
    self.teleportable = TELEPORT_NORMAL;
    self.damagedbycontents = TRUE;
    self.movetype   = MOVETYPE_WALK;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;    
    setorigin(self, self.origin);
    tracebox(self.origin + '0 0 128', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_NORMAL, self);
    setorigin(self, trace_endpos + '0 0 4');
    self.pos1 = self.origin;
    self.pos2 = self.angles;
    self.idle_aim = '0 0 0';
    self.turret_firecheckfunc = walker_firecheck;
    self.turret_firefunc      = walker_attack;
    self.turret_postthink     = walker_postthink;

    if (self.target != "")
    {
        e = find(world, targetname, self.target);
        if (!e)
        {
            dprint("Initital waypoint for walker does NOT exsist, fix your map!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
#ifdef WALKER_FANCYPATHING
            self.pathcurrent = WALKER_PATH(self.origin, e.origin);
            self.pathgoal = e;
#else
            self.pathcurrent = e;
#endif
        }
    }
}


void spawnfunc_turret_walker()
{
    g_turrets_common_precash();

    precache_model ("models/turrets/walker_head_minigun.md3");
    precache_model ("models/turrets/walker_body.md3");
    precache_model ( "models/turrets/rocket.md3");
    precache_sound ( "weapons/rocket_impact.wav" );

    self.think = turret_walker_dinit;
    self.nextthink = time + 0.5;
}
