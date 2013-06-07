#ifdef SVQC
// Auto cvars
float autocvar_g_vehicle_bumblebee_speed_forward;
float autocvar_g_vehicle_bumblebee_speed_strafe;
float autocvar_g_vehicle_bumblebee_speed_up;
float autocvar_g_vehicle_bumblebee_speed_down;
float autocvar_g_vehicle_bumblebee_turnspeed;
float autocvar_g_vehicle_bumblebee_pitchspeed;
float autocvar_g_vehicle_bumblebee_pitchlimit;
float autocvar_g_vehicle_bumblebee_friction;

float autocvar_g_vehicle_bumblebee_energy;
float autocvar_g_vehicle_bumblebee_energy_regen;
float autocvar_g_vehicle_bumblebee_energy_regen_pause;

float autocvar_g_vehicle_bumblebee_health;
float autocvar_g_vehicle_bumblebee_health_regen;
float autocvar_g_vehicle_bumblebee_health_regen_pause;

float autocvar_g_vehicle_bumblebee_shield;
float autocvar_g_vehicle_bumblebee_shield_regen;
float autocvar_g_vehicle_bumblebee_shield_regen_pause;

float autocvar_g_vehicle_bumblebee_cannon_cost;
float autocvar_g_vehicle_bumblebee_cannon_damage;
float autocvar_g_vehicle_bumblebee_cannon_radius;
float autocvar_g_vehicle_bumblebee_cannon_refire;
float autocvar_g_vehicle_bumblebee_cannon_speed;
float autocvar_g_vehicle_bumblebee_cannon_spread;
float autocvar_g_vehicle_bumblebee_cannon_force;

float autocvar_g_vehicle_bumblebee_cannon_turnspeed;
float autocvar_g_vehicle_bumblebee_cannon_pitchlimit_down;
float autocvar_g_vehicle_bumblebee_cannon_pitchlimit_up;
float autocvar_g_vehicle_bumblebee_cannon_turnlimit_in;
float autocvar_g_vehicle_bumblebee_cannon_turnlimit_out;

float autocvar_g_vehicle_bumblebee_respawntime;

float autocvar_g_vehicle_bumblebee_blowup_radius;
float autocvar_g_vehicle_bumblebee_blowup_coredamage;
float autocvar_g_vehicle_bumblebee_blowup_edgedamage;
float autocvar_g_vehicle_bumblebee_blowup_forceintensity;

#define BUMB_MIN '-120 -120 -40'
#define BUMB_MAX '120 120 40'

.entity gunner1;
//.entity gunner2;
.vector lastaim;
float bumb_gunner_frame()
{
    entity vehic, gun, gunner;
    float ftmp, ftmp2;
    vector vtmp;

    vehic   = self.vehicle;
    gun     = self.vehicle.gun1;
    gunner  = self;

    self    = vehic;
    vehic.solid = SOLID_NOT;
    crosshair_trace(gunner);

    //vtmp = gettaginfo(vehic, gettagindexvehic, "tag_hardpoint01"));
    vtmp = gettaginfo(gun, gettagindex(gun, "muzzle"));
    vtmp = vectoangles(normalize(trace_endpos - vtmp)); // Find the direction & angle
    vtmp = shortangle_vxy(vtmp - (vehic.angles + gun.angles), vehic.angles + gun.angles);     // Find aim offset

    // Bind to aimspeed
    ftmp2 = autocvar_g_vehicle_bumblebee_cannon_turnspeed * frametime; ftmp = -ftmp2;
    vtmp_x = bound(ftmp, vtmp_x, ftmp2);
    vtmp_y = bound(ftmp, vtmp_y, ftmp2);
    // Bind to limts
    gun.angles_x = bound(-autocvar_g_vehicle_bumblebee_cannon_pitchlimit_down, vtmp_x + gun.angles_x, autocvar_g_vehicle_bumblebee_cannon_pitchlimit_up);
    gun.angles_y = bound(-autocvar_g_vehicle_bumblebee_cannon_turnlimit_in,  vtmp_y + gun.angles_y, autocvar_g_vehicle_bumblebee_cannon_turnlimit_out);

    if(gunner.BUTTON_ATCK && gun.cnt <= time)
    {
        vtmp = gettaginfo(gun, gettagindex(gun, "muzzle"));
        v_forward = normalize(v_forward);
        vtmp += v_forward * 50;

        fireBullet (vtmp, v_forward, autocvar_g_vehicle_spiderbot_minigun_spread, autocvar_g_vehicle_spiderbot_minigun_damage,
            autocvar_g_vehicle_spiderbot_minigun_spread, DEATH_SBMINIGUN, 0);

        gun.cnt = time + 0.1;
    }

    setorigin(gunner, vehic.origin);
    gunner.velocity = vehic.velocity;

    vehic.solid = SOLID_BBOX;
    gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
    self = gunner;
    return 1;
}

void bumb_gunner_enter()
{
    if(self.gunner1 != world)
        return;

    self.gunner1         = other;
    self.gunner1.vehicle = self;

    msg_entity = other;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity(MSG_ONE, self.gun1);
    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
    if(self.tur_head)
    {
        WriteAngle(MSG_ONE, self.gun1.angles_x + self.angles_x); // tilt
        WriteAngle(MSG_ONE, self.gun1.angles_y + self.angles_y); // yaw
        WriteAngle(MSG_ONE, 0);                                  // roll
    }
    other.PlayerPhysplug = bumb_gunner_frame;
}

float bumb_pilot_frame()
{
    entity pilot, gunner, vehic;
    vector newvel;

    pilot = self;
    vehic = self.vehicle;
    self   = vehic;

    if(pilot.BUTTON_USE && vehic.deadflag == DEAD_NO)
    {
        self = vehic;
        vehicles_exit(VHEF_NORMAL);
        self = pilot;
        return 0;
    }

    if(vehic.deadflag != DEAD_NO)
    {
        self = pilot;
        pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
        return 1;
    }

    crosshair_trace(pilot);

    vector vang;
    float ftmp;

    vang = vehic.angles;
    newvel = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
    vang_x *= -1;
    newvel_x *= -1;
    if(newvel_x > 180)  newvel_x -= 360;
    if(newvel_x < -180) newvel_x += 360;
    if(newvel_y > 180)  newvel_y -= 360;
    if(newvel_y < -180) newvel_y += 360;

    ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    vehic.avelocity_y = bound(-autocvar_g_vehicle_bumblebee_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_bumblebee_turnspeed);

    // Pitch
    ftmp = 0;
    if(pilot.movement_x > 0 && vang_x < autocvar_g_vehicle_bumblebee_pitchlimit) ftmp = 5;
    else if(pilot.movement_x < 0 && vang_x > -autocvar_g_vehicle_bumblebee_pitchlimit) ftmp = -20;

    newvel_x = bound(-autocvar_g_vehicle_bumblebee_pitchlimit, newvel_x , autocvar_g_vehicle_bumblebee_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_bumblebee_pitchlimit, newvel_x + ftmp, autocvar_g_vehicle_bumblebee_pitchlimit);
    vehic.avelocity_x = bound(-autocvar_g_vehicle_bumblebee_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_bumblebee_pitchspeed);

    vehic.angles_x = anglemods(vehic.angles_x);
    vehic.angles_y = anglemods(vehic.angles_y);
    vehic.angles_z = anglemods(vehic.angles_z);

    makevectors('0 1 0' * vehic.angles_y);
    newvel = vehic.velocity * -autocvar_g_vehicle_bumblebee_friction;

    if(pilot.movement_x != 0)
    {
        if(pilot.movement_x > 0)
            newvel += v_forward  * autocvar_g_vehicle_bumblebee_speed_forward;
        else if(pilot.movement_x < 0)
            newvel -= v_forward  * autocvar_g_vehicle_bumblebee_speed_forward;
    }

    if(pilot.movement_y != 0)
    {
        if(pilot.movement_y < 0)
            newvel -= v_right * autocvar_g_vehicle_bumblebee_speed_strafe;
        else if(pilot.movement_y > 0)
            newvel += v_right * autocvar_g_vehicle_bumblebee_speed_strafe;
        ftmp = newvel * v_right;
        ftmp *= frametime * 0.1;
        vehic.angles_z = bound(-15, vehic.angles_z + ftmp, 15);
    }
    else
    {
        vehic.angles_z *= 0.95;
        if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
            vehic.angles_z = 0;
    }

    if(pilot.BUTTON_CROUCH)
        newvel -=   v_up * autocvar_g_vehicle_bumblebee_speed_down;
    else if (pilot.BUTTON_JUMP)
        newvel +=  v_up * autocvar_g_vehicle_bumblebee_speed_up;

    vehic.velocity  += newvel * frametime;
    pilot.velocity = pilot.movement  = vehic.velocity;
    setorigin(pilot,vehic.origin + '0 0 32');


    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(dmg_time, vehicle_shield, autocvar_g_vehicle_bumblebee_shield, autocvar_g_vehicle_bumblebee_shield_regen_pause, autocvar_g_vehicle_bumblebee_shield_regen, frametime);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(dmg_time, vehicle_health, autocvar_g_vehicle_bumblebee_health, autocvar_g_vehicle_bumblebee_health_regen_pause, autocvar_g_vehicle_bumblebee_health_regen, frametime);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(cnt, vehicle_energy, autocvar_g_vehicle_bumblebee_energy, autocvar_g_vehicle_bumblebee_energy_regen_pause, autocvar_g_vehicle_bumblebee_energy_regen, frametime);

    VEHICLE_UPDATE_PLAYER(health, bumblebee);
    VEHICLE_UPDATE_PLAYER(energy, bumblebee);
    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(shield, bumblebee);

    pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = pilot.BUTTON_CROUCH = 0;
    self = pilot;

    return 1;
}

void bumb_think()
{
    self.velocity = self.velocity * 0.99;
    self.nextthink = time + 0.1;
}

void bumb_enter()
{
    self.touch  = bumb_gunner_enter;
}

void bumb_exit(float eject)
{
    self.owner = world;
    self.touch = vehicles_touch;
}

void bumb_spawn()
{
    self.vehicle_health = autocvar_g_vehicle_bumblebee_health;
    self.vehicle_shield = autocvar_g_vehicle_bumblebee_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_BBOX;
    //self.vehicle_energy = 1;
    self.movetype = MOVETYPE_FLY;
    setorigin(self, self.origin + '0 0 25');
}

void bumb_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;

    pointparticles(particleeffectnum("rocket_explode"), findbetterlocation (self.origin, 16), '0 0 0', 1);
}

void bumb_dinit()
{
    if not (vehicle_initialize(
             "Bumblebee",
             "models/vehicles/bumblebee_body.dpm",
             "",
             "models/vehicles/spiderbot_cockpit.dpm",
             "", "", "tag_viewport",
             HUD_BUMBLEBEE,
             BUMB_MIN, BUMB_MAX,
             FALSE,
             bumb_spawn, autocvar_g_vehicle_bumblebee_respawntime,
             bumb_pilot_frame,
             bumb_enter, bumb_exit,
             bumb_die,   bumb_think,
             FALSE))
    {
        remove(self);
        return;
    }
    self.gun1 = spawn();
    setmodel(self.gun1, "models/vehicles/bumblebee_ray.dpm");
    setattachment(self.gun1, self, "tag_hardpoint03");

    self.gun1 = spawn();
    self.gun2 = spawn();

    self.gun1.owner = self;
    self.gun2.owner = self;

    setmodel(self.gun1, "models/vehicles/bumblebee_plasma_right.dpm");
    setmodel(self.gun2, "models/vehicles/bumblebee_plasma_left.dpm");

    setattachment(self.gun1, self, "tag_hardpoint01");
    setattachment(self.gun2, self, "tag_hardpoint02");

    vector ofs;
    ofs = gettaginfo(self, gettagindex(self, "tag_hardpoint01"));
    ofs -= self.origin;
    setattachment(self.gun1, self, "");
    setorigin(self.gun1, ofs);

    ofs = gettaginfo(self, gettagindex(self, "tag_hardpoint02"));
    ofs -= self.origin;
    setattachment(self.gun2, self, "");
    setorigin(self.gun2, ofs);


}

void spawnfunc_vehicle_bumblebee()
{

    precache_model ("models/vehicles/bumblebee_body.dpm");
    precache_model ("models/vehicles/bumblebee_plasma_left.dpm");
    precache_model ("models/vehicles/bumblebee_plasma_right.dpm");
    precache_model ("models/vehicles/bumblebee_ray.dpm");

    //vehicles_configcheck("vehicle_bumblebee.cfg", autocvar_g_vehicle_bumblebee_health);

    if(autocvar_g_vehicle_bumblebee_energy)
        if(autocvar_g_vehicle_bumblebee_energy_regen)
            self.vehicle_flags |= VHF_ENERGYREGEN;

    if(autocvar_g_vehicle_bumblebee_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_bumblebee_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_bumblebee_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    self.think = bumb_dinit;
    self.nextthink = time + 1;
}
#endif // SVQC

#ifdef CSQC
void bumblebee_draw()
{

}

void bumblebee_draw2d()
{

}

void bumblebee_read_extra()
{

}

void vehicle_bumblebee_assemble()
{

}
#endif //CSQC
