float autocvar_g_vehicles_crush_dmg;
float autocvar_g_vehicles_crush_force;
float autocvar_g_vehicles_delayspawn;
float autocvar_g_vehicles_delayspawn_jitter;

var float autocvar_g_vehicles_nex_damagerate = 0.5;
var float autocvar_g_vehicles_uzi_damagerate = 0.5;
var float autocvar_g_vehicles_rifle_damagerate = 0.75;
var float autocvar_g_vehicles_minstanex_damagerate = 0.001;
var float autocvar_g_vehicles_tag_damagerate = 5;

float autocvar_g_vehicles;

void vehicles_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);
void vehicles_return();
void vehicles_enter();
void vehicles_touch();
void vehicles_reset_colors();
void vehicles_clearrturn();
void vehicles_setreturn();


/** AuxiliaryXhair*
    Send additional points of interest to be drawn, to vehicle owner
**/
const float MAX_AXH = 4;
.entity AuxiliaryXhair[MAX_AXH];

float SendAuxiliaryXhair(entity to, float sf)
{

	WriteByte(MSG_ENTITY, ENT_CLIENT_AUXILIARYXHAIR);

	WriteByte(MSG_ENTITY, self.cnt);

	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);

    WriteByte(MSG_ENTITY, rint(self.colormod_x * 255));
    WriteByte(MSG_ENTITY, rint(self.colormod_y * 255));
    WriteByte(MSG_ENTITY, rint(self.colormod_z * 255));

    return TRUE;
}

void UpdateAuxiliaryXhair(entity own, vector loc, vector clr, float axh_id)
{
    if not(IS_REAL_CLIENT(own))
        return;

    entity axh;

    axh_id = bound(0, axh_id, MAX_AXH);
    axh = own.(AuxiliaryXhair[axh_id]);

    if(axh == world || wasfreed(axh))  // MADNESS? THIS IS QQQQCCCCCCCCC (wasfreed, why do you exsist?)
    {
        axh                     = spawn();
        axh.cnt                 = axh_id;
        axh.drawonlytoclient    = own;
        axh.owner               = own;
        Net_LinkEntity(axh, FALSE, 0, SendAuxiliaryXhair);
    }

    setorigin(axh, loc);
    axh.colormod            = clr;
    axh.SendFlags           = 0x01;
    own.(AuxiliaryXhair[axh_id]) = axh;
}

/*
// SVC_TEMPENTITY based, horrible with even 50 ping. hm.
// WriteByte(MSG_ONE, SVC_TEMPENTITY) uses reliable messagess, never use for thinsg that need continous updates.
void SendAuxiliaryXhair2(entity own, vector loc, vector clr, float axh_id)
{
	msgexntity = own;

	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_AUXILIARYXHAIR);

	WriteByte(MSG_ONE, axh_id);

	WriteCoord(MSG_ONE, loc_x);
	WriteCoord(MSG_ONE, loc_y);
	WriteCoord(MSG_ONE, loc_z);

    WriteByte(MSG_ONE, rint(clr_x * 255));
    WriteByte(MSG_ONE, rint(clr_y * 255));
    WriteByte(MSG_ONE, rint(clr_z * 255));

}
*/
// End AuxiliaryXhair

/**
    Notifies the client that he enterd a vehicle, and sends
    realavent data.

    only sends vehicle_id atm (wich is a HUD_* constant, ex. HUD_SPIDERBOT)
**/
void CSQCVehicleSetup(entity own, float vehicle_id)
{
    if not(IS_REAL_CLIENT(own))
        return;
	
	msg_entity = own;

	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_VEHICLESETUP);
	if(vehicle_id != 0)
	    WriteByte(MSG_ONE, vehicle_id);        
	else
        WriteByte(MSG_ONE, 1 + own.vehicle.vehicle_weapon2mode + HUD_VEHICLE_LAST);
}

/** vehicles_locktarget

    Generic target locking.

    Figure out if what target is "locked" (if any), for missile tracking as such.

    after calling, "if(self.lock_target != world && self.lock_strength == 1)" mean
    you have a locked in target.

    Exspects a crosshair_trace() or equivalent to be
    dont before calling.

**/
.entity lock_target;
.float  lock_strength;
.float  lock_time;
.float  lock_soundtime;
const float	DAMAGE_TARGETDRONE = 10;

vector targetdrone_getnewspot()
{

	vector spot;
	float i;
	for(i = 0; i < 100; ++i)
	{
		spot = self.origin + randomvec() * 1024;
		tracebox(spot, self.mins, self.maxs, spot, MOVE_NORMAL, self);
		if(trace_fraction == 1.0 && trace_startsolid == 0 && trace_allsolid == 0)
			return spot;
	}
	return self.origin;
}

#if 0
void targetdrone_think();
void targetdrone_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);
void targetdrone_renwe()
{
	self.think = targetdrone_think;
	self.nextthink = time + 0.1;
	setorigin(self, targetdrone_getnewspot());
	self.health = 200;
	self.takedamage = DAMAGE_TARGETDRONE;
	self.event_damage = targetdrone_damage;
	self.solid = SOLID_BBOX;
	setmodel(self, "models/runematch/rune.mdl");
	self.effects = EF_LOWPRECISION;
	self.scale = 10;
	self.movetype = MOVETYPE_BOUNCEMISSILE;
	setsize(self, '-100 -100 -100', '100 100 100');

}
void targetdrone_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health -= damage;
	if(self.health <= 0)
	{
		pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

		if(!self.cnt)
			remove(self);
		else
		{
			self.think = targetdrone_renwe;
			self.nextthink = time + 1 + random() * 2;
			self.solid = SOLID_NOT;
			setmodel(self, "");
		}
	}
}
entity targetdrone_getfear()
{
	entity fear;
	float i;

	for(i = 64; i <= 1024; i += 64)
	{
		fear = findradius(self.origin, i);
		while(fear)
		{
			if(fear.bot_dodge)
				return fear;

			fear = fear.chain;
		}
	}

	return world;
}
void targetdrone_think()
{
	self.nextthink = time + 0.1;

	if(self.wp00)
	if(self.wp00.deadflag != DEAD_NO)
		self.wp00 = targetdrone_getfear();

	if(!self.wp00)
		self.wp00 = targetdrone_getfear();

	vector newdir;

	if(self.wp00)
		newdir = steerlib_push(self.wp00.origin) + randomvec() * 0.75;
	else
		newdir = randomvec() * 0.75;

	newdir = newdir * 0.5 + normalize(self.velocity) * 0.5;

	if(self.wp00)
		self.velocity = normalize(newdir) * (500 + (1024 / min(vlen(self.wp00.origin - self.origin), 1024)) * 700);
	else
		self.velocity = normalize(newdir) * 750;

	tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 2, MOVE_NORMAL, self);
	if(trace_fraction != 1.0)
		self.velocity = self.velocity * -1;

	//normalize((normalize(self.velocity) * 0.5 + newdir * 0.5)) * 750;
}

void targetdrone_spawn(vector _where, float _autorenew)
{
	entity drone = spawn();
	setorigin(drone, _where);
	drone.think = targetdrone_renwe;
	drone.nextthink = time + 0.1;
	drone.cnt = _autorenew;
}
#endif

void vehicles_locktarget(float incr, float decr, float _lock_time)
{
    if(self.lock_target && self.lock_target.deadflag != DEAD_NO)
    {
        self.lock_target    = world;
        self.lock_strength  = 0;
        self.lock_time      = 0;
    }

    if(self.lock_time > time)
    {
        if(self.lock_target)
        if(self.lock_soundtime < time)
        {
            self.lock_soundtime = time + 0.5;
            play2(self.owner, "vehicles/locked.wav");
        }

        return;
    }

    if(trace_ent != world)
    {
        if(teamplay && trace_ent.team == self.team)
            trace_ent = world;

        if(trace_ent.deadflag != DEAD_NO)
            trace_ent = world;

        if not (trace_ent.vehicle_flags & VHF_ISVEHICLE ||
				trace_ent.turrcaps_flags & TFL_TURRCAPS_ISTURRET ||
				trace_ent.takedamage == DAMAGE_TARGETDRONE)
            trace_ent = world;
    }

    if(self.lock_target == world && trace_ent != world)
        self.lock_target = trace_ent;

    if(self.lock_target && trace_ent == self.lock_target)
    {
        if(self.lock_strength != 1 && self.lock_strength + incr >= 1)
        {
            play2(self.owner, "vehicles/lock.wav");
            self.lock_soundtime = time + 0.8;
        }
        else if (self.lock_strength != 1 && self.lock_soundtime < time)
        {
            play2(self.owner, "vehicles/locking.wav");
            self.lock_soundtime = time + 0.3;
        }

    }

    // Have a locking target
    // Trace hit current target
    if(trace_ent == self.lock_target && trace_ent != world)
    {
        self.lock_strength = min(self.lock_strength + incr, 1);
        if(self.lock_strength == 1)
            self.lock_time = time + _lock_time;
    }
    else
    {
        if(trace_ent)
            self.lock_strength = max(self.lock_strength - decr * 2, 0);
        else
            self.lock_strength = max(self.lock_strength - decr, 0);

        if(self.lock_strength == 0)
            self.lock_target = world;
    }
}

#define VEHICLE_UPDATE_PLAYER(ply,fld,vhname) \
ply.vehicle_##fld = (self.vehicle_##fld / autocvar_g_vehicle_##vhname##_##fld) * 100

#define vehicles_sweap_collision(orig,vel,dt,acm,mult) \
traceline(orig, orig + vel * dt, MOVE_NORMAL, self); \
if(trace_fraction != 1) \
    acm += normalize(self.origin - trace_endpos) * (vlen(vel) * mult)

// Hover movement support
float  force_fromtag_power;
float  force_fromtag_normpower;
vector force_fromtag_origin;
vector vehicles_force_fromtag_hover(string tag_name, float spring_length, float max_power)
{
    force_fromtag_origin = gettaginfo(self, gettagindex(self, tag_name));
    v_forward  = normalize(v_forward) * -1;
    traceline(force_fromtag_origin, force_fromtag_origin - (v_forward  * spring_length), MOVE_NORMAL, self);

    force_fromtag_power = (1 - trace_fraction) * max_power;
    force_fromtag_normpower = force_fromtag_power / max_power;

    return v_forward  * force_fromtag_power;
}

// Experimental hovermode wich uses attraction/repulstion from surface insted of gravity/repulsion
// Can possibly be use to move abt any surface (inclusing walls/celings)
vector vehicles_force_fromtag_maglev(string tag_name, float spring_length, float max_power)
{

    force_fromtag_origin = gettaginfo(self, gettagindex(self, tag_name));
    v_forward  = normalize(v_forward) * -1;
    traceline(force_fromtag_origin, force_fromtag_origin - (v_forward  * spring_length), MOVE_NORMAL, self);

    // TODO - this may NOT be compatible with wall/celing movement, unhardcode 0.25 (engine count multiplier)
    if(trace_fraction == 1.0)
    {
        force_fromtag_normpower = -0.25;
        return '0 0 -200';
    }

    force_fromtag_power = ((1 - trace_fraction) - trace_fraction) * max_power;
    force_fromtag_normpower = force_fromtag_power / max_power;

    return v_forward  * force_fromtag_power;
}

// Generic vehile projectile system
void vehicles_projectile_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
    // Ignore damage from oterh projectiles from my owner (dont mess up volly's)
    if(inflictor.owner == self.owner)
        return;

    self.health -= damage;
    self.velocity += force;
    if(self.health < 1)
    {
        self.takedamage = DAMAGE_NO;
        self.event_damage = func_null;
        self.think = self.use;
        self.nextthink = time;
    }
}

void vehicles_projectile_explode()
{
    if(self.owner && other != world)
    {
        if(other == self.owner.vehicle)
            return;

        if(other == self.owner.vehicle.tur_head)
            return;
    }

	PROJECTILE_TOUCH;

	self.event_damage = func_null;
    RadiusDamage (self, self.realowner, self.shot_dmg, 0, self.shot_radius, self, self.shot_force, self.totalfrags, other);

    remove (self);
}

entity vehicles_projectile(string _mzlfx, string _mzlsound,
                           vector _org, vector _vel,
                           float _dmg, float _radi, float _force,  float _size,
                           float _deahtype, float _projtype, float _health,
                           float _cull, float _clianim, entity _owner)
{
    entity proj;

    proj = spawn();

    PROJECTILE_MAKETRIGGER(proj);
    setorigin(proj, _org);

    proj.shot_dmg         = _dmg;
    proj.shot_radius      = _radi;
    proj.shot_force       = _force;
    proj.totalfrags       = _deahtype;
    proj.solid            = SOLID_BBOX;
    proj.movetype         = MOVETYPE_FLYMISSILE;
    proj.flags            = FL_PROJECTILE;
    proj.bot_dodge        = TRUE;
    proj.bot_dodgerating  = _dmg;
    proj.velocity         = _vel;
    proj.touch            = vehicles_projectile_explode;
    proj.use              = vehicles_projectile_explode;
    proj.owner            = self;
    proj.realowner        = _owner;
    proj.think            = SUB_Remove;
    proj.nextthink        = time + 30;

    if(_health)
    {
        proj.takedamage       = DAMAGE_AIM;
        proj.event_damage     = vehicles_projectile_damage;
        proj.health           = _health;
    }
    else
        proj.flags           = FL_PROJECTILE | FL_NOTARGET;

    if(_mzlsound)
        sound (self, CH_WEAPON_A, _mzlsound, VOL_BASE, ATTEN_NORM);

    if(_mzlfx)
        pointparticles(particleeffectnum(_mzlfx), proj.origin, proj.velocity, 1);


    setsize (proj, '-1 -1 -1' * _size, '1 1 1' * _size);

    CSQCProjectile(proj, _clianim, _projtype, _cull);

    return proj;
}
// End generic vehile projectile system

/** vehicles_spawn
    Exetuted for all vehicles on (re)spawn.
    Sets defaults for newly spawned units.
**/
void vehicles_spawn()
{
    dprint("Spawning vehicle: ", self.netname, "\n");

    // De-own & reset
    self.vehicle_hudmodel.viewmodelforclient = self;

    self.owner              = world;
    self.touch              = vehicles_touch;
    self.event_damage       = vehicles_damage;
    self.iscreature         = TRUE;
    self.teleportable       = FALSE; // no teleporting for vehicles, too buggy
    self.damagedbycontents	= TRUE;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.takedamage         = DAMAGE_AIM;
	self.deadflag           = DEAD_NO;
    self.bot_attack         = TRUE;
    self.flags              = FL_NOTARGET;
    self.avelocity          = '0 0 0';
    self.velocity           = '0 0 0';

    // Reset locking
    self.lock_strength      = 0;
    self.lock_target        = world;
    self.misc_bulletcounter = 0;

    // Return to spawn
    self.angles             = self.pos2;
    setorigin(self, self.pos1 + '0 0 0');
    // Show it
    pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);
    
    if(self.vehicle_controller)
        self.team = self.vehicle_controller.team;
       
    vehicles_reset_colors();
    self.vehicle_spawn(VHSF_NORMAL);
}

// Better way of determening whats crushable needed! (fl_crushable?)
float vehicles_crushable(entity e)
{
    if(IS_PLAYER(e))
        return TRUE;

    if(e.flags & FL_MONSTER)
        return TRUE;

    return FALSE;
}

void vehilces_impact(float _minspeed, float _speedfac, float _maxpain)
{
    if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        return;

    if(self.play_time < time)
    {
        float wc = vlen(self.velocity - self.oldvelocity);
        //dprint("oldvel: ", vtos(self.oldvelocity), "\n");
        //dprint("vel: ", vtos(self.velocity), "\n");
        if(_minspeed < wc)
        {
            float take = min(_speedfac * wc, _maxpain);
            Damage (self, world, world, take, DEATH_FALL, self.origin, '0 0 0');
            self.play_time = time + 0.25;

            //dprint("wc: ", ftos(wc), "\n");
            //dprint("take: ", ftos(take), "\n");
        }
    }
}

.void() vehicle_impact;
void vehicles_touch()
{
	if(MUTATOR_CALLHOOK(VehicleTouch))
		return;
	
    // Vehicle currently in use
    if(self.owner)
    {
        if(other != world)
        if(vehicles_crushable(other))
        {
            if(vlen(self.velocity) != 0)
                Damage(other, self, self.owner, autocvar_g_vehicles_crush_dmg, DEATH_VH_CRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);

            return; // Dont do selfdamage when hitting "soft targets".
        }

        if(self.play_time < time)
        if(self.vehicle_impact)
            self.vehicle_impact();

        return;
    }

    if not(IS_PLAYER(other))
        return;

    if(other.deadflag != DEAD_NO)
        return;
		
	if(other.frozen)
		return;

    if(other.vehicle != world)
        return;

    vehicles_enter();
}
var float autocvar_g_vehicles_allow_bots = 0;
void vehicles_enter()
{
   // Remove this when bots know how to use vehicles
   
    if (IS_BOT_CLIENT(other))    
        if (autocvar_g_vehicles_allow_bots)
            dprint("Bot enters vehicle\n"); // This is where we need to disconnect (some, all?) normal bot AI and hand over to vehicle's _aiframe()
        else
            return;

    if(self.phase > time)
        return;
		
	if(other.frozen)
		return;

    if(teamplay)
    if(self.team)
    if(self.team != other.team)
        return;

    RemoveGrapplingHook(other);

    self.vehicle_ammo1   = 0;
    self.vehicle_ammo2   = 0;
    self.vehicle_reload1 = 0;
    self.vehicle_reload2 = 0;
    self.vehicle_energy  = 0;

    self.owner          = other;
    self.switchweapon   = other.switchweapon;

    // .viewmodelforclient works better.
    //self.vehicle_hudmodel.drawonlytoclient = self.owner;

    self.vehicle_hudmodel.viewmodelforclient = self.owner;

    self.event_damage         = vehicles_damage;
    self.nextthink            = 0;
    self.owner.angles         = self.angles;
    self.owner.takedamage     = DAMAGE_NO;
    self.owner.solid          = SOLID_NOT;
    self.owner.movetype       = MOVETYPE_NOCLIP;
    self.owner.alpha          = -1;
    self.owner.vehicle        = self;
    self.owner.event_damage   = func_null;
    self.owner.view_ofs       = '0 0 0';
    self.colormap             = self.owner.colormap;
    if(self.tur_head)
        self.tur_head.colormap    = self.owner.colormap;

    self.owner.hud            = self.hud;
    self.owner.PlayerPhysplug = self.PlayerPhysplug;

    self.owner.vehicle_ammo1    = self.vehicle_ammo1;
    self.owner.vehicle_ammo2    = self.vehicle_ammo2;
    self.owner.vehicle_reload1  = self.vehicle_reload1;
    self.owner.vehicle_reload2  = self.vehicle_reload2;

    // Cant do this, hides attached objects too.
    //self.exteriormodeltoclient = self.owner;
    //self.tur_head.exteriormodeltoclient = self.owner;

    other.flags &= ~FL_ONGROUND;
    self.flags  &= ~FL_ONGROUND;

    self.team                 = self.owner.team;
    self.flags               -= FL_NOTARGET;
	self.monster_attack		  = TRUE;
    
    if (IS_REAL_CLIENT(other))
    {
	Send_Notification(NOTIF_ONE, other, MSG_CENTER, CENTER_VEHICLE_ENTER);
	
        msg_entity = other;
        WriteByte (MSG_ONE, SVC_SETVIEWPORT);
        WriteEntity(MSG_ONE, self.vehicle_viewport);
                
        WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
        if(self.tur_head)
        {
            WriteAngle(MSG_ONE, self.tur_head.angles_x + self.angles_x); // tilt
            WriteAngle(MSG_ONE, self.tur_head.angles_y + self.angles_y); // yaw
            WriteAngle(MSG_ONE, 0);                                      // roll
        }
        else
        {
            WriteAngle(MSG_ONE,  self.angles_x * -1); // tilt
            WriteAngle(MSG_ONE,  self.angles_y);      // yaw
            WriteAngle(MSG_ONE,  0);                  // roll
        }
    }

    vehicles_clearrturn();

    CSQCVehicleSetup(self.owner, self.hud);
    
    vh_player = other;
    vh_vehicle = self;
    MUTATOR_CALLHOOK(VehicleEnter);
    other = vh_player;
    self = vh_vehicle;

    self.vehicle_enter();
    antilag_clear(other);
}

/** vehicles_findgoodexit
    Locates a valid location for the player to exit the vehicle.
    Will first try prefer_spot, then up 100 random spots arround the vehicle
    wich are in direct line of sight and empty enougth to hold a players bbox
**/
vector vehicles_findgoodexit(vector prefer_spot)
{
    //vector exitspot;
    float mysize;

    tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, prefer_spot, MOVE_NORMAL, self.owner);
    if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
        return prefer_spot;

    mysize = 1.5 * vlen(self.maxs - self.mins);
    float i;
    vector v, v2;
    v2 = 0.5 * (self.absmin + self.absmax);
    for(i = 0; i < 100; ++i)
    {
        v = randomvec();
        v_z = 0;
        v = v2 + normalize(v) * mysize;
        tracebox(v2, PL_MIN, PL_MAX, v, MOVE_NORMAL, self.owner);
        if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
            return v;
    }

    /*
    exitspot = (self.origin + '0 0 48') + v_forward * mysize;
    tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
    if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
        return exitspot;

    exitspot = (self.origin + '0 0 48') - v_forward * mysize;
    tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
    if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
        return exitspot;

    exitspot = (self.origin + '0 0 48') + v_right * mysize;
    tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
    if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
        return exitspot;

    exitspot = (self.origin + '0 0 48') - v_right * mysize;
    tracebox(self.origin + '0 0 32', PL_MIN, PL_MAX, exitspot, MOVE_NORMAL, self.owner);
    if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
        return exitspot;
    */

    return self.origin;
}

/** vehicles_exit
    Standarrd vehicle release fucntion.
    custom code goes in self.vehicle_exit
**/
float vehicles_exit_running;
void vehicles_exit(float eject)
{
    entity _vehicle;
    entity _player;
    entity _oldself = self;
    
    if(vehicles_exit_running)
    {
        dprint("^1vehicles_exit allready running! this is not good..\n");
        return;
    }
    
    vehicles_exit_running = TRUE;
    if(IS_CLIENT(self))
    {
        _vehicle = self.vehicle;
            
        if (_vehicle.vehicle_flags & VHF_PLAYERSLOT)
        {
            _vehicle.vehicle_exit(eject);
            self = _oldself;
            vehicles_exit_running = FALSE;
            return;            
        }
    }
    else
        _vehicle = self;
    
    _player = _vehicle.owner;
    
    self = _vehicle;

    if (_player)
    {
        if (IS_REAL_CLIENT(_player))
        {
            msg_entity = _player;
            WriteByte (MSG_ONE, SVC_SETVIEWPORT);
            WriteEntity( MSG_ONE, _player);

            WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
            WriteAngle(MSG_ONE, 0);
            WriteAngle(MSG_ONE, _vehicle.angles_y);
            WriteAngle(MSG_ONE, 0);
        }
        
        setsize(_player, PL_MIN,PL_MAX);

        _player.takedamage     = DAMAGE_AIM;
        _player.solid          = SOLID_SLIDEBOX;
        _player.movetype       = MOVETYPE_WALK;
        _player.effects        &= ~EF_NODRAW;
        _player.alpha          = 1;
        _player.PlayerPhysplug = func_null;
        _player.vehicle        = world;
        _player.view_ofs       = PL_VIEW_OFS;
        _player.event_damage   = PlayerDamage;
        _player.hud            = HUD_NORMAL;
        _player.switchweapon   = _vehicle.switchweapon;

        CSQCVehicleSetup(_player, HUD_NORMAL);
    }
    _vehicle.flags |= FL_NOTARGET;
    
    if(_vehicle.deadflag == DEAD_NO)
        _vehicle.avelocity          = '0 0 0';
    
    _vehicle.tur_head.nodrawtoclient             = world;
    
    if(!teamplay)
        _vehicle.team = 0;

    vh_player = _player;
    vh_vehicle = _vehicle;
    MUTATOR_CALLHOOK(VehicleExit);
    _player = vh_player;
    _vehicle = vh_vehicle;

    _vehicle.team = _vehicle.tur_head.team;
        
    sound (_vehicle, CH_TRIGGER_SINGLE, "misc/null.wav", 1, ATTEN_NORM);
    _vehicle.vehicle_hudmodel.viewmodelforclient = _vehicle;	
    _vehicle.phase = time + 1;
	_vehicle.monster_attack = FALSE;
    
    _vehicle.vehicle_exit(eject);
    
    vehicles_setreturn();
    vehicles_reset_colors();        
    _vehicle.owner = world;
    self = _oldself;
    
    vehicles_exit_running = FALSE;
}


void vehicles_regen(float timer, .float regen_field, float field_max, float rpause, float regen, float delta_time, float _healthscale)
{
    if(self.regen_field < field_max)
    if(timer + rpause < time)
    {
        if(_healthscale)
            regen = regen * (self.vehicle_health / self.tur_health);
            
        self.regen_field = min(self.regen_field + regen * delta_time, field_max);

        if(self.owner)
            self.owner.regen_field = (self.regen_field / field_max) * 100;
    }
}

void shieldhit_think()
{
    self.alpha -= 0.1;
    if (self.alpha <= 0)
    {
        //setmodel(self, "");
        self.alpha = -1;
        self.effects |= EF_NODRAW;
    }
    else
    {
        self.nextthink = time + 0.1;
    }
}

void vehicles_painframe()
{
    if(self.owner.vehicle_health <= 50)
    if(self.pain_frame < time)
    {
        float _ftmp;
        _ftmp = self.owner.vehicle_health / 50;
        self.pain_frame = time + 0.1 + (random() * 0.5 * _ftmp);
        pointparticles(particleeffectnum("smoke_small"), (self.origin + (randomvec() * 80)), '0 0 0', 1);

        if(self.vehicle_flags & VHF_DMGSHAKE)
            self.velocity += randomvec() * 30;

        if(self.vehicle_flags & VHF_DMGROLL)
            if(self.vehicle_flags & VHF_DMGHEADROLL)
                self.tur_head.angles += randomvec();
            else
                self.angles += randomvec();

    }
}

void vehicles_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
    self.dmg_time = time;
    
    if(DEATH_ISWEAPON(deathtype, WEP_NEX))
        damage *= autocvar_g_vehicles_nex_damagerate;
        
    if(DEATH_ISWEAPON(deathtype, WEP_UZI))
        damage *= autocvar_g_vehicles_uzi_damagerate;
        
    if(DEATH_ISWEAPON(deathtype, WEP_RIFLE))
        damage *= autocvar_g_vehicles_rifle_damagerate;
        
    if(DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
        damage *= autocvar_g_vehicles_minstanex_damagerate;

    if(DEATH_ISWEAPON(deathtype, WEP_SEEKER))
        damage *= autocvar_g_vehicles_tag_damagerate;
    
    self.enemy = attacker;
    
    if((self.vehicle_flags & VHF_HASSHIELD) && (self.vehicle_shield > 0))
    {
        if (wasfreed(self.vehicle_shieldent) || self.vehicle_shieldent == world)
        {
            self.vehicle_shieldent = spawn();
            self.vehicle_shieldent.effects = EF_LOWPRECISION;

            setmodel(self.vehicle_shieldent, "models/vhshield.md3");
            setattachment(self.vehicle_shieldent, self, "");
            setorigin(self.vehicle_shieldent, real_origin(self) - self.origin);
            self.vehicle_shieldent.scale       = 256 / vlen(self.maxs - self.mins);
            self.vehicle_shieldent.think       = shieldhit_think;
        }

        self.vehicle_shieldent.colormod    = '1 1 1';
        self.vehicle_shieldent.alpha       = 0.45;
        self.vehicle_shieldent.angles      = vectoangles(normalize(hitloc - (self.origin + self.vehicle_shieldent.origin))) - self.angles;
        self.vehicle_shieldent.nextthink   = time;
        self.vehicle_shieldent.effects &= ~EF_NODRAW;

        self.vehicle_shield -= damage;

        if(self.vehicle_shield < 0)
        {
            self.vehicle_health            -= fabs(self.vehicle_shield);
            self.vehicle_shieldent.colormod = '2 0 0';
            self.vehicle_shield             = 0;
            self.vehicle_shieldent.alpha    = 0.75;

        	if(sound_allowed(MSG_BROADCAST, attacker))
                spamsound (self, CH_PAIN, "onslaught/ons_hit2.wav", VOL_BASE, ATTEN_NORM);   // FIXME: PLACEHOLDER
        }
        else
        	if(sound_allowed(MSG_BROADCAST, attacker))
                spamsound (self, CH_PAIN, "onslaught/electricity_explode.wav", VOL_BASE, ATTEN_NORM);  // FIXME: PLACEHOLDER

    }
    else
    {
        self.vehicle_health -= damage;

        if(sound_allowed(MSG_BROADCAST, attacker))
            spamsound (self, CH_PAIN, "onslaught/ons_hit2.wav", VOL_BASE, ATTEN_NORM);  // FIXME: PLACEHOLDER
    }
    
	if(self.damageforcescale < 1 && self.damageforcescale > 0)
		self.velocity += force * self.damageforcescale;
	else
		self.velocity += force;

    if(self.vehicle_health <= 0)
    {
        if(self.owner)
            if(self.vehicle_flags & VHF_DEATHEJECT)
                vehicles_exit(VHEF_EJECT);
            else
                vehicles_exit(VHEF_RELESE);


        antilag_clear(self);

        self.vehicle_die();
        vehicles_setreturn();
    }
}

void vehicles_clearrturn()
{
    entity ret;
    // Remove "return helper", if any.
    ret = findchain(classname, "vehicle_return");
    while(ret)
    {
        if(ret.wp00 == self)
        {
            ret.classname   = "";
            ret.think       = SUB_Remove;
            ret.nextthink   = time + 0.1;

            if(ret.waypointsprite_attached)
                WaypointSprite_Kill(ret.waypointsprite_attached);

            return;
        }
        ret = ret.chain;
    }
}

void vehicles_return()
{
    pointparticles(particleeffectnum("teleport"), self.wp00.origin + '0 0 64', '0 0 0', 1);

    self.wp00.think     = vehicles_spawn;
    self.wp00.nextthink = time;

    if(self.waypointsprite_attached)
        WaypointSprite_Kill(self.waypointsprite_attached);

    remove(self);
}

void vehicles_showwp_goaway()
{
    if(self.waypointsprite_attached)
        WaypointSprite_Kill(self.waypointsprite_attached);

    remove(self);

}

void vehicles_showwp()
{
    entity oldself = world;
    vector rgb;

    if(self.cnt)
    {
        self.think      = vehicles_return;
        self.nextthink  = self.cnt;
    }
    else
    {
        self.think      = vehicles_return;
        self.nextthink  = time +1;

        oldself = self;
        self = spawn();
        setmodel(self, "null");
        self.team = oldself.wp00.team;
        self.wp00 = oldself.wp00;
        setorigin(self, oldself.wp00.pos1);

        self.nextthink = time + 5;
        self.think = vehicles_showwp_goaway;
    }

    if(teamplay && self.team)
	    rgb = Team_ColorRGB(self.team);
    else
	    rgb = '1 1 1';
    WaypointSprite_Spawn("vehicle", 0, 0, self, '0 0 64', world, 0, self, waypointsprite_attached, TRUE, RADARICON_POWERUP, rgb);
    if(self.waypointsprite_attached)
    {
        WaypointSprite_UpdateRule(self.waypointsprite_attached, self.wp00.team, SPRITERULE_DEFAULT);
        if(oldself == world)
            WaypointSprite_UpdateBuildFinished(self.waypointsprite_attached, self.nextthink);
        WaypointSprite_Ping(self.waypointsprite_attached);
    }

    if(oldself != world)
        self = oldself;
}

void vehicles_setreturn()
{
    entity ret;

    vehicles_clearrturn();

    ret = spawn();
    ret.classname   = "vehicle_return";
    ret.wp00       = self;
    ret.team        = self.team;
    ret.think       = vehicles_showwp;

    if(self.deadflag != DEAD_NO)
    {
        ret.cnt         = time + self.vehicle_respawntime;
        ret.nextthink   = min(time + self.vehicle_respawntime, time + self.vehicle_respawntime - 5);
    }
    else
    {
        ret.nextthink   = min(time + self.vehicle_respawntime, time + self.vehicle_respawntime - 1);
    }

    setmodel(ret, "null");
    setorigin(ret, self.pos1 + '0 0 96');

}

void vehicles_reset_colors()
{
    entity e;
    float _effects = 0, _colormap;
    vector _glowmod, _colormod;

    if(autocvar_g_nodepthtestplayers)
        _effects |= EF_NODEPTHTEST;

    if(autocvar_g_fullbrightplayers)
        _effects |= EF_FULLBRIGHT;

    if(self.team)
        _colormap = 1024 + (self.team - 1) * 17;
    else
        _colormap = 1024;

    _glowmod  = '0 0 0';
    _colormod = '0 0 0';

    // Find all ents attacked to main model and setup effects, colormod etc.
    e = findchainentity(tag_entity, self);
    while(e)
    {
        if(e != self.vehicle_shieldent)
        {
            e.effects   = _effects; //  | EF_LOWPRECISION;
            e.colormod  = _colormod;
            e.colormap  = _colormap;
            e.alpha     = 1;
        }
        e = e.chain;
    }

    self.vehicle_hudmodel.effects  = self.effects  = _effects; // | EF_LOWPRECISION;
    self.vehicle_hudmodel.colormod = self.colormod = _colormod;
    self.vehicle_hudmodel.colormap = self.colormap = _colormap;
    self.vehicle_viewport.effects = (EF_ADDITIVE | EF_DOUBLESIDED | EF_FULLBRIGHT | EF_NODEPTHTEST | EF_NOGUNBOB | EF_NOSHADOW | EF_LOWPRECISION | EF_SELECTABLE | EF_TELEPORT_BIT);

    self.alpha     = 1;
    self.avelocity = '0 0 0';
    self.velocity  = '0 0 0';
    self.effects   = _effects;
}

void vehicle_use()
{
    dprint("vehicle ",self.netname, " used by ", activator.classname, "\n");

    self.tur_head.team = activator.team;

    if(self.tur_head.team == 0)
        self.active = ACTIVE_NOT;
    else
        self.active = ACTIVE_ACTIVE;
    
    if(self.active == ACTIVE_ACTIVE && self.deadflag == DEAD_NO)
    {
        dprint("^3Eat shit yall!\n");
        vehicles_setreturn();
        vehicles_reset_colors();
    }
    else if(self.active == ACTIVE_NOT && self.deadflag != DEAD_NO)
    {
        
    }
}

float vehicle_addplayerslot(    entity _owner, 
                                entity _slot, 
                                float _hud, 
                                string _hud_model,
                                float() _framefunc, 
                                void(float) _exitfunc)
{
    if not (_owner.vehicle_flags & VHF_MULTISLOT)
        _owner.vehicle_flags |= VHF_MULTISLOT;

    _slot.PlayerPhysplug = _framefunc;
    _slot.vehicle_exit = _exitfunc;
    _slot.hud = _hud;
    _slot.vehicle_flags = VHF_PLAYERSLOT;
    _slot.vehicle_viewport = spawn();
    _slot.vehicle_hudmodel = spawn();
    _slot.vehicle_hudmodel.viewmodelforclient = _slot;
    _slot.vehicle_viewport.effects = (EF_ADDITIVE | EF_DOUBLESIDED | EF_FULLBRIGHT | EF_NODEPTHTEST | EF_NOGUNBOB | EF_NOSHADOW | EF_LOWPRECISION | EF_SELECTABLE | EF_TELEPORT_BIT);
    
    setmodel(_slot.vehicle_hudmodel, _hud_model);
    setmodel(_slot.vehicle_viewport, "null");
    
    setattachment(_slot.vehicle_hudmodel, _slot, "");
    setattachment(_slot.vehicle_viewport, _slot.vehicle_hudmodel, "");
    
    return TRUE;
}

float vehicle_initialize(string  net_name,
                         string  bodymodel,
                         string  topmodel,
                         string  hudmodel,
                         string  toptag,
                         string  hudtag,
                         string  viewtag,
                         float   vhud,
                         vector  min_s,
                         vector  max_s,
                         float   nodrop,
                         void(float _spawnflag)  spawnproc,
                         float   _respawntime,
                         float() physproc,
                         void()  enterproc,
                         void(float extflag) exitfunc,
                         void() dieproc,
                         void() thinkproc,
                         float  use_csqc,
                         float _max_health,
                         float _max_shield)
{
	if(!autocvar_g_vehicles)
		return FALSE;
	
    if(self.targetname)
    {
        self.vehicle_controller = find(world, target, self.targetname);
        if(!self.vehicle_controller)
        {
            bprint("^1WARNING: ^7Vehicle with invalid .targetname\n");
        }
        else
        {
            self.team = self.vehicle_controller.team;        
            self.use = vehicle_use;
            
            if(teamplay)
            {
                if(self.vehicle_controller.team == 0)
                    self.active = ACTIVE_NOT;
                else
                    self.active = ACTIVE_ACTIVE;                
            }
        }
    }
    
    precache_sound("onslaught/ons_hit2.wav");
    precache_sound("onslaught/electricity_explode.wav");


    addstat(STAT_HUD, AS_INT,  hud);
	addstat(STAT_VEHICLESTAT_HEALTH,  AS_INT, vehicle_health);
	addstat(STAT_VEHICLESTAT_SHIELD,  AS_INT, vehicle_shield);
	addstat(STAT_VEHICLESTAT_ENERGY,  AS_INT, vehicle_energy);

	addstat(STAT_VEHICLESTAT_AMMO1,   AS_INT, vehicle_ammo1);
	addstat(STAT_VEHICLESTAT_RELOAD1, AS_INT, vehicle_reload1);

	addstat(STAT_VEHICLESTAT_AMMO2,   AS_INT, vehicle_ammo2);
	addstat(STAT_VEHICLESTAT_RELOAD2, AS_INT, vehicle_reload2);

    if(bodymodel == "")
        error("vehicles: missing bodymodel!");

    if(hudmodel == "")
        error("vehicles: missing hudmodel!");

    if(net_name == "")
        self.netname = self.classname;
    else
        self.netname = net_name;

    if(self.team && !teamplay)
        self.team = 0;

    self.vehicle_flags |= VHF_ISVEHICLE;

    setmodel(self, bodymodel);

    self.vehicle_viewport   = spawn();
    self.vehicle_hudmodel   = spawn();
    self.tur_head           = spawn();
    self.tur_head.owner     = self;
    self.takedamage         = DAMAGE_AIM;
    self.bot_attack         = TRUE;
    self.iscreature         = TRUE;
    self.teleportable       = FALSE; // no teleporting for vehicles, too buggy
    self.damagedbycontents	= TRUE;
    self.hud                = vhud;
    self.tur_health          = _max_health;
    self.tur_head.tur_health = _max_shield;
    self.vehicle_die         = dieproc;
    self.vehicle_exit        = exitfunc;
    self.vehicle_enter       = enterproc;
    self.PlayerPhysplug      = physproc;
    self.event_damage        = func_null;
    self.touch               = vehicles_touch;
    self.think               = vehicles_spawn;
    self.nextthink           = time;
    self.vehicle_respawntime = _respawntime;
    self.vehicle_spawn       = spawnproc;
    self.effects             = EF_NODRAW;
	self.dphitcontentsmask	 = DPCONTENTS_BODY | DPCONTENTS_SOLID;
    if(!autocvar_g_vehicles_delayspawn)
        self.nextthink = time + game_starttime;
    else
        self.nextthink = time + _respawntime + (random() * autocvar_g_vehicles_delayspawn_jitter);

	if(autocvar_g_playerclip_collisions)
		self.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;

    if(autocvar_g_nodepthtestplayers)
        self.effects = self.effects | EF_NODEPTHTEST;

    if(autocvar_g_fullbrightplayers)
        self.effects = self.effects | EF_FULLBRIGHT;

    setmodel(self.vehicle_hudmodel, hudmodel);
    setmodel(self.vehicle_viewport, "null");

    if(topmodel != "")
    {
        setmodel(self.tur_head, topmodel);
        setattachment(self.tur_head, self, toptag);
        setattachment(self.vehicle_hudmodel, self.tur_head, hudtag);
        setattachment(self.vehicle_viewport, self.vehicle_hudmodel, viewtag);
    }
    else
    {
        setattachment(self.tur_head, self, "");
        setattachment(self.vehicle_hudmodel, self, hudtag);
        setattachment(self.vehicle_viewport, self.vehicle_hudmodel, viewtag);
    }

    setsize(self, min_s, max_s);
    if not (nodrop)
    {
        setorigin(self, self.origin);
        tracebox(self.origin + '0 0 100', min_s, max_s, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
        setorigin(self, trace_endpos);
    }
    
    self.pos1 = self.origin;
    self.pos2 = self.angles;
    self.tur_head.team = self.team;
	
	if(MUTATOR_CALLHOOK(VehicleSpawn))
		return FALSE;

    return TRUE;
}

vector vehicle_aimturret(entity _vehic, vector _target, entity _turrret, string _tagname, 
                         float _pichlimit_min, float _pichlimit_max, 
                         float _rotlimit_min, float _rotlimit_max, float _aimspeed)
{
    vector vtmp, vtag;
    float ftmp;
    vtag = gettaginfo(_turrret, gettagindex(_turrret, _tagname));
    vtmp = vectoangles(normalize(_target - vtag));
    vtmp = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(_vehic.angles), AnglesTransform_FromAngles(vtmp))) - _turrret.angles;
    vtmp = AnglesTransform_Normalize(vtmp, TRUE);
    ftmp = _aimspeed * frametime;
    vtmp_y = bound(-ftmp, vtmp_y, ftmp);
    vtmp_x = bound(-ftmp, vtmp_x, ftmp);
    _turrret.angles_y = bound(_rotlimit_min, _turrret.angles_y + vtmp_y, _rotlimit_max);    
    _turrret.angles_x = bound(_pichlimit_min, _turrret.angles_x + vtmp_x, _pichlimit_max);
    return vtag;
}

void vehicles_gib_explode()
{
	sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTEN_NORM);
	pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	remove(self);
}

void vehicles_gib_think()
{
	self.alpha -= 0.1;
	if(self.cnt >= time)
		remove(self);
	else
		self.nextthink = time + 0.1;
}

entity vehicle_tossgib(entity _template, vector _vel, string _tag, float _burn, float _explode, float _maxtime, vector _rot)
{
	entity _gib = spawn();
	setmodel(_gib, _template.model);
	setorigin(_gib, gettaginfo(self, gettagindex(self, _tag)));
	_gib.velocity = _vel;
	_gib.movetype = MOVETYPE_TOSS;
	_gib.solid = SOLID_CORPSE;
	_gib.colormod = '-0.5 -0.5 -0.5';
	_gib.effects = EF_LOWPRECISION;	
	_gib.avelocity = _rot;
	
	if(_burn)
		_gib.effects |= EF_FLAME;
	
	if(_explode)
	{
		_gib.think = vehicles_gib_explode; 
		_gib.nextthink = time + random() * _explode;
		_gib.touch = vehicles_gib_explode;
	}
	else
	{
		_gib.cnt = time + _maxtime;
		_gib.think = vehicles_gib_think; 
		_gib.nextthink = time + _maxtime - 1;		
		_gib.alpha = 1;
	}
	return _gib;
}

/*
vector predict_target(entity _targ, vector _from, float _shot_speed)
{
    float i;                // loop
    float _distance;        // How far to target
    float _impact_time;     // How long untill projectile impacts
    vector _predict_pos;    // Predicted enemy location
    vector _original_origin;// Where target is before predicted

     _original_origin = real_origin(_targ); // Typicaly center of target BBOX

    _predict_pos = _original_origin;
    for(i = 0; i < 4; ++i)  // Loop a few times to increase prediction accuracy (increase loop count if accuracy is to low)
    {
        _distance = vlen(_predict_pos - _from); // Get distance to previos predicted location
        _impact_time = _distance / _shot_speed; // Calculate impact time
        _predict_pos = _original_origin + _targ.velocity * _impact_time; // Calculate new predicted location
    }

    return _predict_pos;
}
*/
