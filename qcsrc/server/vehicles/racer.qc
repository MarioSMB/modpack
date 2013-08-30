#define RACER_MIN '-120 -120 -40'
#define RACER_MAX '120 120 40'

#ifdef SVQC
void racer_exit(float eject);
void racer_enter();

// Auto cvars
float autocvar_g_vehicle_racer;

float autocvar_g_vehicle_racer_speed_afterburn;
float autocvar_g_vehicle_racer_afterburn_cost;

float autocvar_g_vehicle_racer_anglestabilizer;
float autocvar_g_vehicle_racer_downforce;

float autocvar_g_vehicle_racer_speed_forward;
float autocvar_g_vehicle_racer_speed_strafe;
float autocvar_g_vehicle_racer_springlength;
float autocvar_g_vehicle_racer_upforcedamper;
float autocvar_g_vehicle_racer_friction;

float autocvar_g_vehicle_racer_hovertype;
float autocvar_g_vehicle_racer_hoverpower;

float autocvar_g_vehicle_racer_turnroll;
float autocvar_g_vehicle_racer_turnspeed;
float autocvar_g_vehicle_racer_pitchspeed;

float autocvar_g_vehicle_racer_energy;
float autocvar_g_vehicle_racer_energy_regen;
float autocvar_g_vehicle_racer_energy_regen_pause;

float autocvar_g_vehicle_racer_health;
float autocvar_g_vehicle_racer_health_regen;
float autocvar_g_vehicle_racer_health_regen_pause;

float autocvar_g_vehicle_racer_shield;
float autocvar_g_vehicle_racer_shield_regen;
float autocvar_g_vehicle_racer_shield_regen_pause;

float autocvar_g_vehicle_racer_cannon_cost;
float autocvar_g_vehicle_racer_cannon_damage;
float autocvar_g_vehicle_racer_cannon_radius;
float autocvar_g_vehicle_racer_cannon_refire;
float autocvar_g_vehicle_racer_cannon_speed;
float autocvar_g_vehicle_racer_cannon_spread;
float autocvar_g_vehicle_racer_cannon_force;

float autocvar_g_vehicle_racer_rocket_accel;
float autocvar_g_vehicle_racer_rocket_damage;
float autocvar_g_vehicle_racer_rocket_radius;
float autocvar_g_vehicle_racer_rocket_force;
float autocvar_g_vehicle_racer_rocket_refire;
float autocvar_g_vehicle_racer_rocket_speed;
float autocvar_g_vehicle_racer_rocket_turnrate;

float autocvar_g_vehicle_racer_rocket_locktarget;
float autocvar_g_vehicle_racer_rocket_locking_time;
float autocvar_g_vehicle_racer_rocket_locking_releasetime;
float autocvar_g_vehicle_racer_rocket_locked_time;
float autocvar_g_vehicle_racer_rocket_locked_maxangle;
float autocvar_g_vehicle_racer_rocket_climbspeed;

float autocvar_g_vehicle_racer_respawntime;

float autocvar_g_vehicle_racer_blowup_radius;
float autocvar_g_vehicle_racer_blowup_coredamage;
float autocvar_g_vehicle_racer_blowup_edgedamage;
float autocvar_g_vehicle_racer_blowup_forceintensity;

float autocvar_g_vehicle_racer_bouncefactor;
float autocvar_g_vehicle_racer_bouncestop;
vector autocvar_g_vehicle_racer_bouncepain;

var vector racer_force_from_tag(string tag_name, float spring_length, float max_power);
void racer_spawn_default();

void racer_align4point(float _delta)
{
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    push_vector  = racer_force_from_tag("tag_engine_fr", autocvar_g_vehicle_racer_springlength, autocvar_g_vehicle_racer_hoverpower);
    fr_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_racer_collision_multiplier);

    push_vector += racer_force_from_tag("tag_engine_fl", autocvar_g_vehicle_racer_springlength, autocvar_g_vehicle_racer_hoverpower);
    fl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_racer_collision_multiplier);

    push_vector += racer_force_from_tag("tag_engine_br", autocvar_g_vehicle_racer_springlength, autocvar_g_vehicle_racer_hoverpower);
    br_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_racer_collision_multiplier);

    push_vector += racer_force_from_tag("tag_engine_bl", autocvar_g_vehicle_racer_springlength, autocvar_g_vehicle_racer_hoverpower);
    bl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_racer_collision_multiplier);

   self.velocity += push_vector * _delta;

    // Anti ocilation
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_racer_upforcedamper * _delta;

    push_vector_x =  (fl_push - bl_push);
    push_vector_x += (fr_push - br_push);
    push_vector_x *= 360;

    push_vector_z = (fr_push - fl_push);
    push_vector_z += (br_push - bl_push);
    push_vector_z *= 360;

    // Apply angle diffrance
    self.angles_z += push_vector_z * _delta;
    self.angles_x += push_vector_x * _delta;

    // Apply stabilizer
    self.angles_x *= 1 - (autocvar_g_vehicle_racer_anglestabilizer * _delta);
    self.angles_z *= 1 - (autocvar_g_vehicle_racer_anglestabilizer * _delta);
}

void racer_fire_cannon(string tagname)
{
    vector v;
    entity bolt;

    v = gettaginfo(self, gettagindex(self, tagname));
    bolt = vehicles_projectile("wakizashi_gun_muzzleflash", "weapons/lasergun_fire.wav",
                           v, normalize(v_forward + randomvec() * autocvar_g_vehicle_racer_cannon_spread) * autocvar_g_vehicle_racer_cannon_speed,
                           autocvar_g_vehicle_racer_cannon_damage, autocvar_g_vehicle_racer_cannon_radius, autocvar_g_vehicle_racer_cannon_force,  0,
                           DEATH_VH_WAKI_GUN, PROJECTILE_WAKICANNON, 0, TRUE, TRUE, self.owner);

	// Fix z-aim (for chase mode)
    v = normalize(trace_endpos - bolt.origin);
    v_forward_z = v_z * 0.5;
    bolt.velocity = v_forward * autocvar_g_vehicle_racer_cannon_speed;
}

void racer_rocket_groundhugger()
{
    vector olddir, newdir;
    float oldvel, newvel;

    self.nextthink  = time;

    if(self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        self.use();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldvel = vlen(self.velocity);
    newvel = oldvel + self.lip;

    tracebox(self.origin, self.mins, self.maxs, self.origin + olddir * 64, MOVE_WORLDONLY,self);
    if(trace_fraction <= 0.5)
    {
        // Hitting somethign soon, just speed ahead
        self.velocity = olddir * newvel;
        UpdateCSQCProjectile(self);
        return;
    }

    traceline(trace_endpos, trace_endpos - '0 0 64', MOVE_NORMAL, self);
    if(trace_fraction != 1.0)
    {
        newdir = normalize(trace_endpos + '0 0 64' - self.origin) * autocvar_g_vehicle_racer_rocket_turnrate;
        self.velocity = normalize(olddir + newdir) * newvel;
    }
    else
    {
        self.velocity = olddir * newvel;
        self.velocity_z -= 1600 * sys_frametime; // 2x grav looks better for this one
    }

    UpdateCSQCProjectile(self);
    return;
}

void racer_rocket_tracker()
{
    vector olddir, newdir;
    float oldvel, newvel;

    self.nextthink  = time;

    if (self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        self.use();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldvel = vlen(self.velocity);
    newvel = oldvel + self.lip;
    makevectors(vectoangles(olddir));

	float time_to_impact = min(vlen(self.enemy.origin - self.origin) / vlen(self.velocity), 1);
	vector predicted_origin = self.enemy.origin + self.enemy.velocity * time_to_impact;

    traceline(self.origin, self.origin + v_forward * 64 - '0 0 32', MOVE_NORMAL, self);
    newdir = normalize(predicted_origin - self.origin);

    //vector
	float height_diff = predicted_origin_z - self.origin_z;

    if(vlen(newdir - v_forward) > autocvar_g_vehicle_racer_rocket_locked_maxangle)
    {
        //bprint("Target lost!\n");
        //dprint("OF:", ftos(vlen(newdir - v_forward)), "\n");
        self.think = racer_rocket_groundhugger;
        return;
    }

    if(trace_fraction != 1.0 && trace_ent != self.enemy)
        newdir_z += 16 * sys_frametime;

    self.velocity = normalize(olddir + newdir * autocvar_g_vehicle_racer_rocket_turnrate) * newvel;
    self.velocity_z -= 800 * sys_frametime;
    self.velocity_z += max(height_diff, autocvar_g_vehicle_racer_rocket_climbspeed) * sys_frametime ;

    UpdateCSQCProjectile(self);
    return;
}

void racer_fire_rocket(string tagname, entity trg)
{
    vector v = gettaginfo(self, gettagindex(self, tagname));
    entity rocket = rocket = vehicles_projectile("wakizashi_rocket_launch", "weapons/rocket_fire.wav",
                           v, v_forward * autocvar_g_vehicle_racer_rocket_speed,
                           autocvar_g_vehicle_racer_rocket_damage, autocvar_g_vehicle_racer_rocket_radius, autocvar_g_vehicle_racer_rocket_force, 3,
                           DEATH_VH_WAKI_ROCKET, PROJECTILE_WAKIROCKET, 20, FALSE, FALSE, self.owner);

    rocket.lip              = autocvar_g_vehicle_racer_rocket_accel * sys_frametime;
    rocket.wait             = autocvar_g_vehicle_racer_rocket_turnrate;
    rocket.nextthink        = time;
    rocket.enemy            = trg;
    rocket.cnt              = time + 15;

    if(trg)
        rocket.think            = racer_rocket_tracker;
    else
        rocket.think            = racer_rocket_groundhugger;
}

float racer_frame()
{
    entity player, racer;
    vector df;
    float ftmp;

	if(intermission_running)
		return 1;

    player  = self;
    racer   = self.vehicle;
    self    = racer;

    player.BUTTON_ZOOM = player.BUTTON_CROUCH = 0;

    vehicles_painframe();

    if(racer.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }

    racer_align4point(frametime);

    crosshair_trace(player);

    racer.angles_x *= -1;

    // Yaw
    ftmp = autocvar_g_vehicle_racer_turnspeed * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_y - racer.angles_y, racer.angles_y), ftmp);
    racer.angles_y = anglemods(racer.angles_y + ftmp);

    // Roll
    racer.angles_z += -ftmp * autocvar_g_vehicle_racer_turnroll * frametime;

    // Pitch
    ftmp = autocvar_g_vehicle_racer_pitchspeed  * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_x - racer.angles_x, racer.angles_x), ftmp);
    racer.angles_x = bound(-30, anglemods(racer.angles_x + ftmp), 30);

    makevectors(racer.angles);
    racer.angles_x *= -1;

    //ftmp = racer.velocity_z;
    df = racer.velocity * -autocvar_g_vehicle_racer_friction;
    //racer.velocity_z = ftmp;

    if(vlen(player.movement) != 0)
    {
        if(player.movement_x)
            df += v_forward * ((player.movement_x > 0) ? autocvar_g_vehicle_racer_speed_forward : -autocvar_g_vehicle_racer_speed_forward);

        if(player.movement_y)
            df += v_right * ((player.movement_y > 0) ? autocvar_g_vehicle_racer_speed_strafe : -autocvar_g_vehicle_racer_speed_strafe);

        if(self.sound_nexttime < time || self.sounds != 1)
        {
            self.sounds = 1;
            self.sound_nexttime = time + 10.922667; //soundlength("vehicles/racer_move.wav");
            sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_move.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
        }
    }
    else
    {
        if(self.sound_nexttime < time || self.sounds != 0)
        {
            self.sounds = 0;
            self.sound_nexttime = time + 11.888604; //soundlength("vehicles/racer_idle.wav");
            sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_idle.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
        }
    }

    // Afterburn
    if (player.BUTTON_JUMP && racer.vehicle_energy >= (autocvar_g_vehicle_racer_afterburn_cost * frametime))
    {
        if(time - racer.wait > 0.2)
            pointparticles(particleeffectnum("wakizashi_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

        racer.wait = time;
        racer.vehicle_energy -= autocvar_g_vehicle_racer_afterburn_cost * frametime;
        df += (v_forward * autocvar_g_vehicle_racer_speed_afterburn);

        if(racer.invincible_finished < time)
        {
            traceline(racer.origin, racer.origin - '0 0 256', MOVE_NORMAL, self);
            if(trace_fraction != 1.0)
                pointparticles(particleeffectnum("smoke_small"), trace_endpos, '0 0 0', 1);

            racer.invincible_finished = time + 0.1 + (random() * 0.1);
        }

        if(racer.strength_finished < time)
        {
            racer.strength_finished = time + 10.922667; //soundlength("vehicles/racer_boost.wav");
            sound (racer.tur_head, CH_TRIGGER_SINGLE, "vehicles/racer_boost.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
        }
    }
    else
    {
        racer.strength_finished = 0;
        sound (racer.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTEN_NORM);
    }

	df -= v_up * (vlen(racer.velocity) * autocvar_g_vehicle_racer_downforce);
    player.movement = racer.velocity += df * frametime;

    if(player.BUTTON_ATCK)
    if(time > racer.attack_finished_single)
    if(racer.vehicle_energy >= autocvar_g_vehicle_racer_cannon_cost)
    {
        racer.vehicle_energy -= autocvar_g_vehicle_racer_cannon_cost;
        racer.wait = time;

        crosshair_trace(player);
        if(racer.cnt)
        {
            racer_fire_cannon("tag_fire1");
            racer.cnt = 0;
        }
        else
        {
            racer_fire_cannon("tag_fire2");
            racer.cnt = 1;
        }
        racer.attack_finished_single = time + autocvar_g_vehicle_racer_cannon_refire;
    }

    if(autocvar_g_vehicle_racer_rocket_locktarget)
    {
        vehicles_locktarget((1 / autocvar_g_vehicle_racer_rocket_locking_time) * frametime,
                         (1 / autocvar_g_vehicle_racer_rocket_locking_releasetime) * frametime,
                         autocvar_g_vehicle_racer_rocket_locked_time);

        if(self.lock_target)
        {
            if(racer.lock_strength == 1)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '1 0 0', 0);
            else if(self.lock_strength > 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '0 1 0', 0);
            else if(self.lock_strength < 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '0 0 1', 0);
        }
    }

    if(time > racer.delay)
    if(player.BUTTON_ATCK2)
    {
        racer.misc_bulletcounter += 1;
        racer.delay = time + 0.3;

        if(racer.misc_bulletcounter == 1)
            racer_fire_rocket("tag_rocket_r", (racer.lock_strength == 1 && racer.lock_target) ? racer.lock_target : world);
        else if(racer.misc_bulletcounter == 2)
        {
            racer_fire_rocket("tag_rocket_l", (racer.lock_strength == 1 && racer.lock_target) ? racer.lock_target : world);
            racer.lock_strength  = 0;
            racer.lock_target    = world;
            racer.misc_bulletcounter = 0;

            racer.delay = time + autocvar_g_vehicle_racer_rocket_refire;
            racer.lip = time;
        }
    }
    player.vehicle_reload1 = bound(0, 100 * ((time - racer.lip) / (racer.delay - racer.lip)), 100);

    if(racer.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(racer.dmg_time, vehicle_shield, autocvar_g_vehicle_racer_shield, autocvar_g_vehicle_racer_shield_regen_pause, autocvar_g_vehicle_racer_shield_regen, frametime, TRUE);

    if(racer.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(racer.dmg_time, vehicle_health, autocvar_g_vehicle_racer_health, autocvar_g_vehicle_racer_health_regen_pause, autocvar_g_vehicle_racer_health_regen, frametime, FALSE);

    if(racer.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(racer.wait, vehicle_energy, autocvar_g_vehicle_racer_energy, autocvar_g_vehicle_racer_energy_regen_pause, autocvar_g_vehicle_racer_energy_regen, frametime, FALSE);


    VEHICLE_UPDATE_PLAYER(player, health, racer);
    VEHICLE_UPDATE_PLAYER(player, energy, racer);

    if(racer.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, racer);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    setorigin(player,racer.origin + '0 0 32');
    player.velocity = racer.velocity;

    self = player;
    return 1;
}

void racer_think()
{
    self.nextthink = time;

    float pushdeltatime = time - self.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    self.lastpushtime = time;
    if(!pushdeltatime) return;

    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_racer_springlength), MOVE_NORMAL, self);

    vector df = self.velocity * -autocvar_g_vehicle_racer_friction;
	df_z += (1 - trace_fraction) * autocvar_g_vehicle_racer_hoverpower + sin(time * 2) * (autocvar_g_vehicle_racer_springlength * 2);

	self.velocity += df * pushdeltatime;
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_racer_upforcedamper * pushdeltatime;

    self.angles_x *= 1 - (autocvar_g_vehicle_racer_anglestabilizer * pushdeltatime);
    self.angles_z *= 1 - (autocvar_g_vehicle_racer_anglestabilizer * pushdeltatime);
}

void racer_enter()
{
    self.movetype = MOVETYPE_BOUNCE;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_racer_health)  * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_racer_shield)  * 100;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-190 0 96');

	//targetdrone_spawn(self.origin + '0 0 512' + randomvec() * 256, 1);
}

void racer_exit(float eject)
{
    vector spot;

    self.think      = racer_think;
    self.nextthink  = time;
    self.movetype   = MOVETYPE_BOUNCE;
    sound (self.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTEN_NORM);

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
		if(vlen(self.velocity) > 2 * autocvar_sv_maxairspeed)
		{
			self.owner.velocity = normalize(self.velocity) * autocvar_sv_maxairspeed * 2;
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 32 + '0 0 32';
			spot = vehicles_findgoodexit(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 200 + '0 0 32';
			spot = vehicles_findgoodexit(spot);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	antilag_clear(self.owner);
    self.owner = world;
}

void racer_impact()
{
    if(autocvar_g_vehicle_racer_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_racer_bouncepain_x, autocvar_g_vehicle_racer_bouncepain_y, autocvar_g_vehicle_racer_bouncepain_z);
}

void racer_blowup()
{
    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);

    RadiusDamage (self, self.enemy, autocvar_g_vehicle_racer_blowup_coredamage,
					autocvar_g_vehicle_racer_blowup_edgedamage,
					autocvar_g_vehicle_racer_blowup_radius, world,
					autocvar_g_vehicle_racer_blowup_forceintensity,
					DEATH_VH_WAKI_DEATH, world);

    self.nextthink  = time + autocvar_g_vehicle_racer_respawntime;
    self.think      = racer_spawn_default;
    self.movetype   = MOVETYPE_NONE;
    self.effects    = EF_NODRAW;

    self.colormod  = '0 0 0';
    self.avelocity = '0 0 0';
    self.velocity  = '0 0 0';

    setorigin(self, self.pos1);
}

void racer_deadtouch()
{
    self.avelocity_x *= 0.7;
    self.cnt -= 1;
    if(self.cnt <= 0)
        racer_blowup();
}

void racer_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.wait         = time;
    self.cnt          = 1 + random() * 2;
    self.touch        = racer_deadtouch;

    pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

    if(random() < 0.5)
        self.avelocity_z  = 32;
    else
        self.avelocity_z  = -32;

    self.avelocity_x = -vlen(self.velocity) * 0.2;
    self.velocity   += '0 0 700';
    self.colormod    = '-0.5 -0.5 -0.5';

	self.think     = racer_blowup;
	self.nextthink = 2 + time + random() * 3;
}
void racer_spawn(float _spawnflag)
{
    if(self.scale != 0.5)
    {
        if(autocvar_g_vehicle_racer_hovertype != 0)
            racer_force_from_tag = vehicles_force_fromtag_maglev;
        else
            racer_force_from_tag = vehicles_force_fromtag_hover;

        // FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        self.scale = 0.5;
        setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self, "tag_viewport");

        self.mass               = 900;
    }

    self.think          = racer_think;
    self.nextthink      = time;
    self.vehicle_health = autocvar_g_vehicle_racer_health;
    self.vehicle_shield = autocvar_g_vehicle_racer_shield;

    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.delay          = time;
    self.scale          = 0.5;

    setsize(self, RACER_MIN * 0.5, RACER_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_racer_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_racer_bouncestop;
    self.vehicle_impact = racer_impact;
    self.damageforcescale = 0.5;
    //self.destvec = autocvar_g_vehicle_racer_bouncepain;
}
void racer_spawn_default()
{
	racer_spawn(0);
}



void spawnfunc_vehicle_racer()
{
    if(!autocvar_g_vehicle_racer)
    {
        remove(self);
        return;
    }        
    
    self.vehicle_flags |= VHF_DMGSHAKE;
    self.vehicle_flags |= VHF_DMGROLL;

    precache_sound ("weapons/lasergun_fire.wav");
    precache_sound ("weapons/rocket_fire.wav");

    precache_sound ("vehicles/racer_idle.wav");
    precache_sound ("vehicles/racer_move.wav");
    precache_sound ("vehicles/racer_boost.wav");

    precache_model ("models/vhshield.md3");
    precache_model ("models/vehicles/wakizashi.dpm");
    precache_model ("models/vehicles/wakizashi_cockpit.dpm");

    if(autocvar_g_vehicle_racer_energy)
        if(autocvar_g_vehicle_racer_energy_regen)
            self.vehicle_flags |= VHF_ENERGYREGEN;

    if(autocvar_g_vehicle_racer_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_racer_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_racer_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if not (vehicle_initialize(
             "Wakizashi",
             "models/vehicles/wakizashi.dpm",
             "null", // we need this so tur_head is networked and usable for sounds
             "models/vehicles/wakizashi_cockpit.dpm",
             "", "", "tag_viewport",
             HUD_WAKIZASHI,
             0.5 * RACER_MIN, 0.5 * RACER_MAX,
             FALSE,
             racer_spawn, autocvar_g_vehicle_racer_respawntime,
             racer_frame,
             racer_enter, racer_exit,
             racer_die,   racer_think,
             TRUE, 
             autocvar_g_vehicle_racer_health,
             autocvar_g_vehicle_racer_shield))
    {
        remove(self);
        return;
    }
}
#endif // SVQC
