const vector SPIDERBOT_MIN = '-75 -75 10';
const vector SPIDERBOT_MAX  = '75 75 125';

#ifdef SVQC
float autocvar_g_vehicle_spiderbot;

float autocvar_g_vehicle_spiderbot_respawntime;

float autocvar_g_vehicle_spiderbot_speed_stop;
float autocvar_g_vehicle_spiderbot_speed_strafe;
float autocvar_g_vehicle_spiderbot_speed_walk;
float autocvar_g_vehicle_spiderbot_turnspeed;
float autocvar_g_vehicle_spiderbot_turnspeed_strafe;
float autocvar_g_vehicle_spiderbot_movement_inertia;

float autocvar_g_vehicle_spiderbot_springlength;
float autocvar_g_vehicle_spiderbot_springup;
float autocvar_g_vehicle_spiderbot_springblend;
float autocvar_g_vehicle_spiderbot_tiltlimit;

float autocvar_g_vehicle_spiderbot_head_pitchlimit_down;
float autocvar_g_vehicle_spiderbot_head_pitchlimit_up;
float autocvar_g_vehicle_spiderbot_head_turnlimit;
float autocvar_g_vehicle_spiderbot_head_turnspeed;

//float autocvar_g_vehicle_spiderbot_energy;
//float autocvar_g_vehicle_spiderbot_energy_regen;
//float autocvar_g_vehicle_spiderbot_energy_regen_pause;

float autocvar_g_vehicle_spiderbot_health;
float autocvar_g_vehicle_spiderbot_health_regen;
float autocvar_g_vehicle_spiderbot_health_regen_pause;

float autocvar_g_vehicle_spiderbot_shield;
float autocvar_g_vehicle_spiderbot_shield_regen;
float autocvar_g_vehicle_spiderbot_shield_regen_pause;

float autocvar_g_vehicle_spiderbot_minigun_damage;
float autocvar_g_vehicle_spiderbot_minigun_refire;
float autocvar_g_vehicle_spiderbot_minigun_spread;
float autocvar_g_vehicle_spiderbot_minigun_ammo_cost;
float autocvar_g_vehicle_spiderbot_minigun_ammo_max;
float autocvar_g_vehicle_spiderbot_minigun_ammo_regen;
float autocvar_g_vehicle_spiderbot_minigun_ammo_regen_pause;
float autocvar_g_vehicle_spiderbot_minigun_force;
float autocvar_g_vehicle_spiderbot_minigun_speed;
float autocvar_g_vehicle_spiderbot_minigun_bulletconstant;

float autocvar_g_vehicle_spiderbot_rocket_damage;
float autocvar_g_vehicle_spiderbot_rocket_force;
float autocvar_g_vehicle_spiderbot_rocket_radius;
float autocvar_g_vehicle_spiderbot_rocket_speed;
float autocvar_g_vehicle_spiderbot_rocket_spread;
float autocvar_g_vehicle_spiderbot_rocket_refire;
float autocvar_g_vehicle_spiderbot_rocket_refire2;
float autocvar_g_vehicle_spiderbot_rocket_reload;
float autocvar_g_vehicle_spiderbot_rocket_health;
float autocvar_g_vehicle_spiderbot_rocket_noise;
float autocvar_g_vehicle_spiderbot_rocket_turnrate;
float autocvar_g_vehicle_spiderbot_rocket_lifetime;

vector autocvar_g_vehicle_spiderbot_bouncepain;


void spiderbot_exit(float eject);
void spiderbot_enter();
void spiderbot_spawn(float);
#define SBRM_FIRST 0
#define SBRM_VOLLY 0
#define SBRM_GUIDE 1
#define SBRM_ARTILLERY 2
#define SBRM_LAST 2

void spiderbot_rocket_artillery()
{
    self.nextthink  = time;
    UpdateCSQCProjectile(self);
}

void spiderbot_rocket_unguided()
{
    vector newdir, olddir;

    self.nextthink  = time;

    olddir = normalize(self.velocity);
    newdir = normalize(self.pos1 - self.origin) + randomvec() * autocvar_g_vehicle_spiderbot_rocket_noise;
    self.velocity = normalize(olddir + newdir * autocvar_g_vehicle_spiderbot_rocket_turnrate) * autocvar_g_vehicle_spiderbot_rocket_speed;

    UpdateCSQCProjectile(self);

    if (self.owner.deadflag != DEAD_NO || self.cnt < time || vlen(self.pos1 - self.origin) < 16)
        self.use();
}

void spiderbot_rocket_guided()
{
    vector newdir, olddir;

    self.nextthink  = time;

    if not (self.realowner.vehicle)
        self.think = spiderbot_rocket_unguided;

    crosshair_trace(self.realowner);
    olddir = normalize(self.velocity);
    newdir = normalize(trace_endpos - self.origin) + randomvec() * autocvar_g_vehicle_spiderbot_rocket_noise;
    self.velocity = normalize(olddir + newdir * autocvar_g_vehicle_spiderbot_rocket_turnrate) * autocvar_g_vehicle_spiderbot_rocket_speed;

    UpdateCSQCProjectile(self);

    if (self.owner.deadflag != DEAD_NO || self.cnt < time)
        self.use();
}

void spiderbot_guide_release()
{
    entity rkt;
    rkt = findchainentity(realowner, self.owner);
    if not (rkt)
        return;

    crosshair_trace(self.owner);
    while(rkt)
    {
        if(rkt.think == spiderbot_rocket_guided)
        {
            rkt.pos1 = trace_endpos;
            rkt.think = spiderbot_rocket_unguided;
        }
        rkt = rkt.chain;
    }
}

float spiberbot_calcartillery_flighttime;  
vector spiberbot_calcartillery(vector org, vector tgt, float ht)
{
	float grav, sdist, zdist, vs, vz, jumpheight;
	vector sdir;
	
	grav  = autocvar_sv_gravity;
	zdist = tgt_z - org_z;
	sdist = vlen(tgt - org - zdist * '0 0 1');
	sdir  = normalize(tgt - org - zdist * '0 0 1');

	// how high do we need to go?
	jumpheight = fabs(ht);
	if(zdist > 0)
		jumpheight = jumpheight + zdist;

	// push so high...
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
			spiberbot_calcartillery_flighttime = solution_y;
		}
		else
		{
			// regular jump
			// jump apex is during the jump
			// we must take the larger one too
			spiberbot_calcartillery_flighttime = solution_y;
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
			spiberbot_calcartillery_flighttime = solution_x;
		}
		else
		{
			// regular jump
			// jump apex is during the jump
			// we must take the larger one
			spiberbot_calcartillery_flighttime = solution_y;
		}
	}
	vs = sdist / spiberbot_calcartillery_flighttime;

	// finally calculate the velocity
	return sdir * vs + '0 0 1' * vz;
}

void spiderbot_rocket_do()
{

    vector v;
    entity rocket = world;

    if (self.wait != -10)
    {        
        if (self.owner.BUTTON_ATCK2 && self.vehicle_weapon2mode == SBRM_GUIDE)
        {
            if (self.wait == 1)
            if (self.tur_head.frame == 9 || self.tur_head.frame == 1)
            {
                if(self.gun2.cnt < time && self.tur_head.frame == 9)
                    self.tur_head.frame = 1;

                return;
            }
            self.wait = 1;
        }
        else
        {
            if(self.wait)
                spiderbot_guide_release();

            self.wait = 0;
        }
    }
    
    if(self.gun2.cnt > time)
        return;

    if (self.tur_head.frame >= 9)
    {
        self.tur_head.frame = 1;
        self.wait = 0;
    }
        
    if (self.wait != -10)
        if not (self.owner.BUTTON_ATCK2)
            return;


    v = gettaginfo(self.tur_head,gettagindex(self.tur_head,"tag_fire"));
    
    switch(self.vehicle_weapon2mode)
    {
        case SBRM_VOLLY:
            rocket = vehicles_projectile("spiderbot_rocket_launch", "weapons/rocket_fire.wav",
                                   v, normalize(randomvec() * autocvar_g_vehicle_spiderbot_rocket_spread + v_forward) * autocvar_g_vehicle_spiderbot_rocket_speed,
                                   autocvar_g_vehicle_spiderbot_rocket_damage, autocvar_g_vehicle_spiderbot_rocket_radius, autocvar_g_vehicle_spiderbot_rocket_force, 1,
                                   DEATH_VH_SPID_ROCKET, PROJECTILE_SPIDERROCKET, autocvar_g_vehicle_spiderbot_rocket_health, FALSE, TRUE, self.owner);
            crosshair_trace(self.owner);
            float _dist = (random() * autocvar_g_vehicle_spiderbot_rocket_radius) + vlen(v - trace_endpos);
            _dist -= (random() * autocvar_g_vehicle_spiderbot_rocket_radius) ;
            rocket.nextthink  = time + (_dist / autocvar_g_vehicle_spiderbot_rocket_speed);
            rocket.think     = vehicles_projectile_explode;

            if(self.owner.BUTTON_ATCK2 && self.tur_head.frame == 1)
                self.wait = -10;
            break;
        case SBRM_GUIDE:
            rocket = vehicles_projectile("spiderbot_rocket_launch", "weapons/rocket_fire.wav",
                                   v, normalize(v_forward) * autocvar_g_vehicle_spiderbot_rocket_speed,
                                   autocvar_g_vehicle_spiderbot_rocket_damage, autocvar_g_vehicle_spiderbot_rocket_radius, autocvar_g_vehicle_spiderbot_rocket_force, 1,
                                   DEATH_VH_SPID_ROCKET, PROJECTILE_SPIDERROCKET, autocvar_g_vehicle_spiderbot_rocket_health, FALSE, FALSE, self.owner);
            crosshair_trace(self.owner);
            rocket.pos1       = trace_endpos;
            rocket.nextthink  = time;
            rocket.think      = spiderbot_rocket_guided;

                
        break;
        case SBRM_ARTILLERY:
            rocket = vehicles_projectile("spiderbot_rocket_launch", "weapons/rocket_fire.wav",
                                   v, normalize(v_forward) * autocvar_g_vehicle_spiderbot_rocket_speed,
                                   autocvar_g_vehicle_spiderbot_rocket_damage, autocvar_g_vehicle_spiderbot_rocket_radius, autocvar_g_vehicle_spiderbot_rocket_force, 1,
                                   DEATH_VH_SPID_ROCKET, PROJECTILE_SPIDERROCKET, autocvar_g_vehicle_spiderbot_rocket_health, FALSE, TRUE, self.owner);
            
            crosshair_trace(self.owner);
            
            rocket.pos1       = trace_endpos + randomvec() * (0.75 * autocvar_g_vehicle_spiderbot_rocket_radius);
            rocket.pos1_z       = trace_endpos_z;
            
            traceline(v, v + '0 0 1' * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, self);             
            float h1 = 0.75 * vlen(v - trace_endpos);
            
            //v = trace_endpos;
            traceline(v , rocket.pos1 + '0 0 1' * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, self); 
            float h2 = 0.75 * vlen(rocket.pos1 - v);
            
            rocket.velocity  = spiberbot_calcartillery(v, rocket.pos1, ((h1 < h2) ? h1 : h2));
            rocket.movetype  = MOVETYPE_TOSS;            
            rocket.gravity   = 1;
            //rocket.think     = spiderbot_rocket_artillery;   
        break;
    }
    rocket.classname  = "spiderbot_rocket";
    
    rocket.cnt = time + autocvar_g_vehicle_spiderbot_rocket_lifetime;
    
    self.tur_head.frame += 1;
    if (self.tur_head.frame == 9)
        self.attack_finished_single = autocvar_g_vehicle_spiderbot_rocket_reload;
    else
        self.attack_finished_single = ((self.vehicle_weapon2mode ==  SBRM_VOLLY) ? autocvar_g_vehicle_spiderbot_rocket_refire2 : autocvar_g_vehicle_spiderbot_rocket_refire);

    self.gun2.cnt = time + self.attack_finished_single;
}

float spiderbot_aiframe()
{
    return FALSE;
}

float spiderbot_frame()
{
    vector ad, vf;
    entity player, spider;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    spider = self.vehicle;
    self   = spider;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    

#if 1 // 0 to enable per-gun impact aux crosshairs
    // Avarage gun impact point's -> aux cross
    ad = gettaginfo(spider.tur_head, gettagindex(spider.tur_head, "tag_hardpoint01"));
    vf = v_forward;
    ad += gettaginfo(spider.tur_head, gettagindex(spider.tur_head, "tag_hardpoint02"));
    vf += v_forward;
    ad = ad * 0.5;
    v_forward = vf * 0.5;
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, spider);
    UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
#else
    ad = gettaginfo(spider.gun1, gettagindex(spider.gun1, "barrels"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, spider);
    UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    vf = ad;
    ad = gettaginfo(spider.gun2, gettagindex(spider.gun2, "barrels"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, spider);
    UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 1);
    ad = 0.5 * (ad + vf);
#endif

    crosshair_trace(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(spider.angles), AnglesTransform_FromAngles(ad))) - spider.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_spiderbot_head_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    spider.tur_head.angles_y = bound(autocvar_g_vehicle_spiderbot_head_turnlimit * -1, spider.tur_head.angles_y + ad_y, autocvar_g_vehicle_spiderbot_head_turnlimit);

    // Pitch head
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    spider.tur_head.angles_x = bound(autocvar_g_vehicle_spiderbot_head_pitchlimit_down, spider.tur_head.angles_x + ad_x, autocvar_g_vehicle_spiderbot_head_pitchlimit_up);


    //fixedmakevectors(spider.angles);
    makevectors(spider.angles + '-2 0 0' * spider.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_spiderbot_springlength, autocvar_g_vehicle_spiderbot_springup, autocvar_g_vehicle_spiderbot_springblend, autocvar_g_vehicle_spiderbot_tiltlimit);

    if(spider.flags & FL_ONGROUND)
    {
        if(spider.frame == 4 && self.tur_head.wait != 0)
        {
            sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_land.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
            spider.frame = 5;            
        }
        
        if(player.BUTTON_JUMP && self.tur_head.wait < time)
        {        
            sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_jump.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
            //dprint("spiderbot_jump:", ftos(soundlength("vehicles/spiderbot_jump.wav")), "\n");
            self.delay = 0;

            self.tur_head.wait = time + 2;
            player.BUTTON_JUMP = 0;
            spider.velocity   = v_forward * 700 + v_up * 600;
            spider.frame = 4;
        }
        else
        {
            if(vlen(player.movement) == 0)
            {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6.486500; //soundlength("vehicles/spiderbot_idle.wav");
                    //dprint("spiderbot_idle:", ftos(soundlength("vehicles/spiderbot_idle.wav")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_idle.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_spiderbot_speed_stop);
                spider.frame = 5;
            }
            else
            {
                // Turn Body
                if(player.movement_x == 0 && player.movement_y != 0)
                    ftmp = autocvar_g_vehicle_spiderbot_turnspeed_strafe * sys_frametime;
                else
                    ftmp = autocvar_g_vehicle_spiderbot_turnspeed * sys_frametime;
                
                ftmp = bound(-ftmp, spider.tur_head.angles_y, ftmp);                
                spider.angles_y = anglemods(spider.angles_y + ftmp);
                spider.tur_head.angles_y -= ftmp;

                if(player.movement_x != 0)
                {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                        spider.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        spider.frame = 1;
                    }
                    player.movement_y = 0;
                    movelib_move_simple(normalize(v_forward * player.movement_x),autocvar_g_vehicle_spiderbot_speed_walk,autocvar_g_vehicle_spiderbot_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 6.486500; //soundlength("vehicles/spiderbot_walk.wav");
                        sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_walk.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
                        //dprint("spiderbot_walk:", ftos(soundlength("vehicles/spiderbot_walk.wav")), "\n");
                    }
                }
                else if(player.movement_y != 0)
                {
                    if(player.movement_y < 0)
                    {
                        player.movement_y = -1;
                        spider.frame = 2;
                    }
                    else if(player.movement_y > 0)
                    {
                        player.movement_y = 1;
                        spider.frame = 3;
                    }
                    movelib_move_simple(normalize(v_right * player.movement_y),autocvar_g_vehicle_spiderbot_speed_strafe,autocvar_g_vehicle_spiderbot_movement_inertia);
                    if(self.sound_nexttime < time || self.delay != 2)
                    {                        
                        self.delay = 2;
                        self.sound_nexttime = time + 6.486500; //soundlength("vehicles/spiderbot_strafe.wav");
                        sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_strafe.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
                        //dprint("spiderbot_strafe:", ftos(soundlength("vehicles/spiderbot_strafe.wav")), "\n");
                    }
                }
            }
        }
    }

    self.angles_x = bound(-autocvar_g_vehicle_spiderbot_tiltlimit, self.angles_x, autocvar_g_vehicle_spiderbot_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_spiderbot_tiltlimit, self.angles_z, autocvar_g_vehicle_spiderbot_tiltlimit);

    if(player.BUTTON_ATCK)
    {
        spider.cnt = time;
        if(spider.vehicle_ammo1 >= autocvar_g_vehicle_spiderbot_minigun_ammo_cost && spider.tur_head.attack_finished_single <= time)
        {
            entity gun;
            vector v;
            spider.misc_bulletcounter += 1;

            self = player;

            mod(spider.misc_bulletcounter, 2) ? gun = spider.gun1 : gun = spider.gun2;
            v = gettaginfo(gun, gettagindex(gun, "barrels"));
            v_forward = normalize(v_forward);
            v += v_forward * 50;

//void fireBallisticBullet(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float force, float dtype, float tracereffects, float gravityfactor, float bulletconstant)

            fireBallisticBullet(v, v_forward, autocvar_g_vehicle_spiderbot_minigun_spread, autocvar_g_vehicle_spiderbot_minigun_speed,
                                5, autocvar_g_vehicle_spiderbot_minigun_damage, autocvar_g_vehicle_spiderbot_minigun_force, DEATH_VH_SPID_MINIGUN, 0, 1, autocvar_g_vehicle_spiderbot_minigun_bulletconstant);

            endFireBallisticBullet();

//            fireBullet (v, v_forward, autocvar_g_vehicle_spiderbot_minigun_spread, autocvar_g_vehicle_spiderbot_minigun_damage,
//                autocvar_g_vehicle_spiderbot_minigun_spread, DEATH_VH_SPID_MINIGUN, 0);

            sound (gun, CH_WEAPON_A, "weapons/uzi_fire.wav", VOL_BASE, ATTEN_NORM);
            //trailparticles(self, particleeffectnum("spiderbot_minigun_trail"), v, trace_endpos);
            pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);

            self = spider;

            spider.vehicle_ammo1 -= autocvar_g_vehicle_spiderbot_minigun_ammo_cost;
            spider.tur_head.attack_finished_single = time + autocvar_g_vehicle_spiderbot_minigun_refire;
            player.vehicle_ammo1 = (spider.vehicle_ammo1 / autocvar_g_vehicle_spiderbot_minigun_ammo_max) * 100;
            spider.gun1.angles_z += 45;
            spider.gun2.angles_z -= 45;
            if(spider.gun1.angles_z >= 360)
            {
                spider.gun1.angles_z = 0;
                spider.gun2.angles_z = 0;
            }
        }
    }
    else
        vehicles_regen(spider.cnt, vehicle_ammo1, autocvar_g_vehicle_spiderbot_minigun_ammo_max,
                                           autocvar_g_vehicle_spiderbot_minigun_ammo_regen_pause,
                                           autocvar_g_vehicle_spiderbot_minigun_ammo_regen, frametime, FALSE);
        

    spiderbot_rocket_do();

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(spider.dmg_time, vehicle_shield, autocvar_g_vehicle_spiderbot_shield, autocvar_g_vehicle_spiderbot_shield_regen_pause, autocvar_g_vehicle_spiderbot_shield_regen, frametime, TRUE);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(spider.dmg_time, vehicle_health, autocvar_g_vehicle_spiderbot_health, autocvar_g_vehicle_spiderbot_health_regen_pause, autocvar_g_vehicle_spiderbot_health_regen, frametime, FALSE);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    player.vehicle_ammo2 = spider.tur_head.frame;

    if(spider.gun2.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((spider.gun2.cnt - time) / spider.attack_finished_single) * 100;

    setorigin(player, spider.origin + '0 0 1' * SPIDERBOT_MAX_z);
    player.velocity = spider.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, spiderbot);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, spiderbot);

    self = player;
    return 1;    
}
void spiderbot_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_spiderbot_speed_stop);

    self.nextthink = time;
}

void spiderbot_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_spiderbot_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_spiderbot_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void spiderbot_exit(float eject)
{
    entity e;
    vector spot;
    
    e = findchain(classname,"spiderbot_rocket");
    while(e)
    {
        if(e.owner == self.owner)
        {
            e.realowner = self.owner;
            e.owner = world;
        }
        e = e.chain;
    }

    //self.velocity   = '0 0 0';
    self.think      = spiderbot_think;
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_WALK;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_spiderbot_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit(spot);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void spider_impact()
{
    if(autocvar_g_vehicle_spiderbot_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_spiderbot_bouncepain_x, autocvar_g_vehicle_spiderbot_bouncepain_y, autocvar_g_vehicle_spiderbot_bouncepain_z);    
}

void spiderbot_headfade()
{
	self.think = spiderbot_headfade;
	self.nextthink = self.fade_time;
	self.alpha = 1 - (time - self.fade_time) * self.fade_rate;

    if(self.cnt < time || self.alpha < 0.1)
    {
        if(self.alpha > 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
            pointparticles(particleeffectnum("explosion_big"), self.origin + '0 0 100', '0 0 0', 1);
        }
        remove(self);
    }
}

void spiderbot_blowup()
{
    if(self.cnt > time)
    {
        if(random() < 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
            pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
        }
        self.nextthink = time + 0.1;
        return;
    }
    
    entity h, g1, g2, b;
    b = spawn();
    h = spawn();
    g1 = spawn();
    g2 = spawn();

    setmodel(b,  "models/vehicles/spiderbot.dpm");
    setmodel(h,  "models/vehicles/spiderbot_top.dpm");
    setmodel(g1, "models/vehicles/spiderbot_barrels.dpm");
    setmodel(g2, "models/vehicles/spiderbot_barrels.dpm");

    setorigin(b, self.origin);
    b.frame         = 11;
    b.angles        = self.angles;
    setsize(b, self.mins, self.maxs);

    setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
    h.movetype      = MOVETYPE_BOUNCE;
    h.solid         = SOLID_BBOX;
    h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
    h.modelflags    = MF_ROCKET;
    h.effects       = EF_FLAME | EF_LOWPRECISION;
    h.avelocity     = randomvec() * 360;

    h.alpha         = 1;
    h.cnt           = time + (3.5 * random());
    h.fade_rate     = 1 / min(autocvar_g_vehicle_spiderbot_respawntime, 10);
    h.fade_time     = time;
    h.think         = spiderbot_headfade;
    h.nextthink     = time;

    setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
    g1.movetype     = MOVETYPE_TOSS;
    g1.solid        = SOLID_CORPSE;
    g1.velocity     = v_forward * 700 + (randomvec() * 32);
    g1.avelocity    = randomvec() * 180;

    setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
    g2.movetype     = MOVETYPE_TOSS;
    g2.solid        = SOLID_CORPSE;
    g2.velocity     = v_forward * 700 + (randomvec() * 32);
    g2.avelocity    = randomvec() * 180;

    h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_spiderbot_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_spiderbot_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_spiderbot_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_spiderbot_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_VH_SPID_DEATH, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &=  ~EF_FLAME;
    self.vehicle_hudmodel.viewmodelforclient = self;
}

void spiderbot_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = spiderbot_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
}

float spiderbot_impulse(float _imp)
{
    switch(_imp)
    {
        case 10:
        case 15:        
        case 18:
            self.vehicle.vehicle_weapon2mode += 1;
            if(self.vehicle.vehicle_weapon2mode > SBRM_LAST)
                self.vehicle.vehicle_weapon2mode = SBRM_FIRST;
            
            //centerprint(self, strcat("Rocket mode is ", ftos(self.vehicle.vehicle_weapon2mode)));
            CSQCVehicleSetup(self, 0);
            return TRUE;
        case 12:
        case 16:
        case 19:
            self.vehicle.vehicle_weapon2mode -= 1;
            if(self.vehicle.vehicle_weapon2mode < SBRM_FIRST)
                self.vehicle.vehicle_weapon2mode = SBRM_LAST;
            
            //centerprint(self, strcat("Rocket mode is ", ftos(self.vehicle.vehicle_weapon2mode)));
            CSQCVehicleSetup(self, 0);
            return TRUE;

        /*			
        case 17: // toss gun, could be used to exit?
            break;
        case 20: // Manual minigun reload?
            break;
        */
    }    
    return FALSE;
}

void spiderbot_spawn(float _f)
{
    if(!self.gun1)
    {        
        self.vehicles_impusle   = spiderbot_impulse;
        self.gun1               = spawn();
        self.gun2               = spawn();    
        setmodel(self.gun1, "models/vehicles/spiderbot_barrels.dpm");
        setmodel(self.gun2, "models/vehicles/spiderbot_barrels.dpm");
        setattachment(self.gun1, self.tur_head, "tag_hardpoint01");
        setattachment(self.gun2, self.tur_head, "tag_hardpoint02");
        self.gravity            = 2;
        self.mass               = 5000;
    }

    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = spiderbot_think;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_spiderbot_health;
    self.vehicle_shield     = autocvar_g_vehicle_spiderbot_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = 1;
    self.tur_head.angles    = '0 0 0';    

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = spider_impact;
    self.damageforcescale = 0.03;
}

void spawnfunc_vehicle_spiderbot()
{
    if(!autocvar_g_vehicle_spiderbot)
    {
        remove(self);
        return;
    }        

    self.vehicle_flags |= VHF_DMGSHAKE;
    //self.vehicle_flags |= VHF_DMGROLL;
    //self.vehicle_flags |= VHF_DMGHEADROLL;
    
    precache_model ( "models/vhshield.md3");
    precache_model ( "models/vehicles/spiderbot.dpm");
    precache_model ( "models/vehicles/spiderbot_top.dpm");
    precache_model ( "models/vehicles/spiderbot_barrels.dpm");
    precache_model ( "models/vehicles/spiderbot_cockpit.dpm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/uzi_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    precache_sound ( "vehicles/spiderbot_die.wav");
    precache_sound ( "vehicles/spiderbot_idle.wav");
    precache_sound ( "vehicles/spiderbot_jump.wav");
    precache_sound ( "vehicles/spiderbot_strafe.wav");
    precache_sound ( "vehicles/spiderbot_walk.wav");
    precache_sound ( "vehicles/spiderbot_land.wav");

    if(autocvar_g_vehicle_spiderbot_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_spiderbot_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_spiderbot_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "Spiderbot",
             "models/vehicles/spiderbot.dpm",
             "models/vehicles/spiderbot_top.dpm",
             "models/vehicles/spiderbot_cockpit.dpm",
             "tag_head", "tag_hud", "",
             HUD_SPIDERBOT,
             SPIDERBOT_MIN, SPIDERBOT_MAX,
             FALSE,
             spiderbot_spawn, autocvar_g_vehicle_spiderbot_respawntime,
             spiderbot_frame,
             spiderbot_enter, spiderbot_exit,
             spiderbot_die,   spiderbot_think,
             FALSE, 
             autocvar_g_vehicle_spiderbot_health,
             autocvar_g_vehicle_spiderbot_shield))
    {
        remove(self);
        return;
    }
}
#endif // SVQC
