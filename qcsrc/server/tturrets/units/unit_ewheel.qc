#define ewheel_amin_stop 0
#define ewheel_amin_fwd_slow 1
#define ewheel_amin_fwd_fast 2
#define ewheel_amin_bck_slow 3
#define ewheel_amin_bck_fast 4

void ewheel_attack()
{
    float i;
    entity _mis;
    
    for (i = 0; i < 1; ++i)
    {
        turret_do_updates(self);

        _mis = turret_projectile("weapons/lasergun_fire.wav", 1, 0, DEATH_TURRET_EWHEEL, PROJECTILE_LASER, TRUE, TRUE); 
        _mis.missile_flags = MIF_SPLASH;

        pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);

        self.tur_head.frame += 2;

        if (self.tur_head.frame > 3)
            self.tur_head.frame = 0;
    }

}
//#define EWHEEL_FANCYPATH
void ewheel_move_path()
{
#ifdef EWHEEL_FANCYPATH
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
                    self.pathcurrent = pathlib_astar(self.pathgoal.origin,self.pathgoal.enemy.origin);
                    self.pathgoal = self.pathgoal.enemy;
                }
            }
            else
                self.pathgoal = world;
        }
        else
            self.pathcurrent = self.pathcurrent.path_next;

#else
    if (vlen(self.origin - self.pathcurrent.origin) < 64)    
        self.pathcurrent = self.pathcurrent.enemy;
#endif

    if (self.pathcurrent)
    {

        self.moveto = self.pathcurrent.origin;
        self.steerto = steerlib_attract2(self.moveto, 0.5, 500, 0.95);

        movelib_move_simple(v_forward, autocvar_g_turrets_unit_ewheel_speed_fast, 0.4);
    }
}

void  ewheel_move_enemy()
{

    float newframe;
    
    self.steerto = steerlib_arrive(self.enemy.origin,self.target_range_optimal);

    //self.steerto = steerlib_standoff(self.enemy.origin,self.target_range_optimal);
    //self.steerto = steerlib_beamsteer(self.steerto,1024,64,68,256);
    self.moveto  = self.origin + self.steerto * 128;

    if (self.tur_dist_enemy > self.target_range_optimal)
    {
        if ( self.tur_head.spawnshieldtime < 1 )
        {
            newframe = ewheel_amin_fwd_fast;
            movelib_move_simple(v_forward, autocvar_g_turrets_unit_ewheel_speed_fast, 0.4);
        }
        else if (self.tur_head.spawnshieldtime < 2)
        {

            newframe = ewheel_amin_fwd_slow;
            movelib_move_simple(v_forward, autocvar_g_turrets_unit_ewheel_speed_slow, 0.4);
       }
        else
        {
            newframe = ewheel_amin_fwd_slow;
            movelib_move_simple(v_forward, autocvar_g_turrets_unit_ewheel_speed_slower, 0.4);
        }
    }
    else if (self.tur_dist_enemy < self.target_range_optimal * 0.5)
    {
        newframe = ewheel_amin_bck_slow;
        movelib_move_simple(v_forward * -1, autocvar_g_turrets_unit_ewheel_speed_slow, 0.4);
    }
    else
    {
        newframe = ewheel_amin_stop;
        movelib_beak_simple(autocvar_g_turrets_unit_ewheel_speed_stop);
    }
    
    turrets_setframe(newframe , FALSE);
    
    /*if(self.frame != newframe)
    {
        self.frame = newframe;
        self.SendFlags |= TNSF_ANIM;
        self.anim_start_time = time;
    }*/
}


void ewheel_move_idle()
{
    if(self.frame != 0)
    {
        self.SendFlags |= TNSF_ANIM;
        self.anim_start_time = time;
    }

    self.frame = 0;
    if (vlen(self.velocity))
        movelib_beak_simple(autocvar_g_turrets_unit_ewheel_speed_stop);
}

void ewheel_postthink()
{
    float vz;
    vector wish_angle, real_angle;

    vz = self.velocity_z;

    self.angles_x = anglemods(self.angles_x);
    self.angles_y = anglemods(self.angles_y);

    fixedmakevectors(self.angles);

    wish_angle = normalize(self.steerto);
    wish_angle = vectoangles(wish_angle);
    real_angle = wish_angle - self.angles;
    real_angle = shortangle_vxy(real_angle, self.tur_head.angles);

    self.tur_head.spawnshieldtime = fabs(real_angle_y);
    real_angle_y  = bound(-self.tur_head.aim_speed, real_angle_y, self.tur_head.aim_speed);
    self.angles_y = (self.angles_y + real_angle_y);

    if(self.enemy)
        ewheel_move_enemy();
    else if(self.pathcurrent)
        ewheel_move_path();
    else
        ewheel_move_idle();


    self.velocity_z = vz;
    
    if(vlen(self.velocity))
        self.SendFlags |= TNSF_MOVE;
}

void ewheel_respawnhook()
{
    entity e;

    // Respawn is called & first spawn to, to set team. need to make sure we do not move the initial spawn.
    if(self.movetype != MOVETYPE_WALK)
		return;
		
    self.velocity = '0 0 0';
    self.enemy = world;

    setorigin(self, self.pos1);

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            dprint("Initital waypoint for ewheel does NOT exsist, fix your map!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {

#ifdef EWHEEL_FANCYPATH
            self.pathcurrent = WALKER_PATH(self.origin,e.origin);
            self.pathgoal = e;
#else
            self.pathcurrent  = e;
#endif
        }
    }
}

void ewheel_diehook()
{
    self.velocity = '0 0 0';

#ifdef EWHEEL_FANCYPATH
    if (self.pathcurrent)
        pathlib_deletepath(self.pathcurrent.owner);
#endif
    self.pathcurrent = world;
}

void turret_ewheel_dinit()
{
    entity e;

    if (self.netname == "")      
        self.netname     = "eWheel Turret";

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            bprint("Warning! initital waypoint for ewheel does NOT exsist!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
            self.goalcurrent = e;
    }

    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MOVE | TFL_TURRCAPS_ROAM ;
    self.turret_respawnhook = ewheel_respawnhook;

    self.turret_diehook = ewheel_diehook;

    if (turret_stdproc_init("ewheel_std", "models/turrets/ewheel-base2.md3", "models/turrets/ewheel-gun1.md3", TID_EWHEEL) == 0)
    {
        remove(self);
        return;
    }
    
    self.frame = 1;
    self.target_select_flags   = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.iscreature = TRUE;
    self.teleportable = TELEPORT_NORMAL;
    self.damagedbycontents = TRUE;
    self.movetype   = MOVETYPE_WALK;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;
    self.idle_aim   = '0 0 0';
    self.pos1       = self.origin;

    setsize(self, '-32 -32 0', '32 32 48');

    // Our fire routine
    self.turret_firefunc  = ewheel_attack;
    self.turret_postthink = ewheel_postthink;
    self.tur_head.frame = 1;

    // Convert from dgr / sec to dgr / tic
    self.tur_head.aim_speed = autocvar_g_turrets_unit_ewheel_turnrate;
    self.tur_head.aim_speed = self.tur_head.aim_speed / (1 / self.ticrate);

    //setorigin(self,self.origin + '0 0 128');
    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            dprint("Initital waypoint for ewheel does NOT exsist, fix your map!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
#ifdef EWHEEL_FANCYPATH
            self.pathcurrent = WALKER_PATH(self.origin, e.origin);
            self.pathgoal = e;
#else
            self.pathcurrent = e;
#endif
        }
    }
}

void spawnfunc_turret_ewheel()
{
    g_turrets_common_precash();

    precache_model ("models/turrets/ewheel-base2.md3");
    precache_model ("models/turrets/ewheel-gun1.md3");

    self.think = turret_ewheel_dinit;
    self.nextthink = time + 0.5;
}
