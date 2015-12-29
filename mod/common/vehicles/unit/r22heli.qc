#ifndef VEHICLE_R22HELI
#define VEHICLE_R22HELI
//#include "r22heli.qh"

//#include "r22heli_weapons.qc"

SOUND(CHOPPA, "vehicles/choppa");
SOUND(CHOPPA_LANDED, "vehicles/choppa_landed");

MODEL(R22HELI_MILSPEC, "models/vehicles/r22edits_milspec.iqm");

MODEL(R22HELI_SPINNER, "models/vehicles/r22edits_spinner.iqm");
MODEL(R22HELI_SMALLSPINNER, "models/vehicles/r22edits_smallspinner.iqm");

MODEL(MG_M134GUN, "models/mountedguns/m134gun.iqm");
MODEL(MG_M134GUN_BARRELS, "models/mountedguns/m134gun_barrels.iqm");
MODEL(MG_BROWNING50GUN, "models/mountedguns/browning50gun.iqm");

CLASS(R22Heli, Vehicle)
/* spawnflags */ ATTRIB(R22Heli, spawnflags, int, VHF_DMGSHAKE);
/* mins       */ ATTRIB(R22Heli, mins, vector, '-60 -60 0');
/* maxs       */ ATTRIB(R22Heli, maxs, vector, '60 60 86');
/* model	  */ ATTRIB(R22Heli, mdl, string, "models/vehicles/r22edits.iqm");
/* model	  */ ATTRIB(R22Heli, model, string, "models/vehicles/r22edits.iqm");
/* head_model */ ATTRIB(R22Heli, head_model, string, "null");
/* hud_model  */ ATTRIB(R22Heli, hud_model, string, "null");
/* tags       */ ATTRIB(R22Heli, tag_head, string, "");
/* tags       */ ATTRIB(R22Heli, tag_hud, string, "");
/* tags       */ ATTRIB(R22Heli, tag_view, string, "tag_viewport");
/* netname    */ ATTRIB(R22Heli, netname, string, "r22heli");
/* fullname   */ ATTRIB(R22Heli, vehicle_name, string, _("R22 Helicopter"));
/* icon       */ ATTRIB(R22Heli, m_icon, string, "vehicle_helicopter");
ENDCLASS(R22Heli)
REGISTER_VEHICLE(R22HELI, NEW(R22Heli));

#endif

#ifdef IMPLEMENTATION

//#include "r22heli_weapons.qc"

#ifdef SVQC
#include "../propellers.qh"

AUTOCVAR(g_vehicle_r22heli, bool, true, _("Enable R22 Helicopter vehicle (if allowed by mods)"));
AUTOCVAR(g_vehicle_r22heli_respawntime, float, 30, "");

AUTOCVAR(g_vehicle_r22heli_blowup_radius, float, 500, "");
AUTOCVAR(g_vehicle_r22heli_blowup_coredamage, float, 500, "");
AUTOCVAR(g_vehicle_r22heli_blowup_edgedamage, float, 100, "");
AUTOCVAR(g_vehicle_r22heli_blowup_forceintensity, float, 600, "");

AUTOCVAR(g_vehicle_r22heli_health, int, 1200, "");
AUTOCVAR(g_vehicle_r22heli_health_regen, int, 20, "");
AUTOCVAR(g_vehicle_r22heli_health_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_r22heli_shield, int, 600, "");
AUTOCVAR(g_vehicle_r22heli_shield_regen, int, 30, "");
AUTOCVAR(g_vehicle_r22heli_shield_regen_pause, float, 1.5, "");

AUTOCVAR(g_vehicle_r22heli_energy, int, 100, "");
AUTOCVAR(g_vehicle_r22heli_energy_regen, int, 10, "");
AUTOCVAR(g_vehicle_r22heli_energy_regen_pause, float, 0.25, "");

AUTOCVAR(g_vehicle_r22heli_rocket_refire, float, 2, "");
AUTOCVAR(g_vehicle_r22heli_rocket_targetrange, float, 3000, "");
AUTOCVAR(g_vehicle_r22heli_rocket_damage, float, 100, "");

AUTOCVAR(g_vehicle_r22heli_cannon_lock, bool, false, "");
AUTOCVAR(g_vehicle_r22heli_cannon_turnspeed, float, 160, "");
AUTOCVAR(g_vehicle_r22heli_cannon_pitchlimit_down, float, 60, "");
AUTOCVAR(g_vehicle_r22heli_cannon_pitchlimit_up, float, 60, "");
AUTOCVAR(g_vehicle_r22heli_cannon_turnlimit_in, float, 20, "");
AUTOCVAR(g_vehicle_r22heli_cannon_turnlimit_out, float, 80, "");
AUTOCVAR(g_vehicle_r22heli_cannon_speed, float, 20000, "");
AUTOCVAR(g_vehicle_r22heli_cannon_ammo, int, 100, "");
AUTOCVAR(g_vehicle_r22heli_cannon_ammo_regen, int, 100, "");
AUTOCVAR(g_vehicle_r22heli_cannon_ammo_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_r22heli_bouncefactor, float, 0.25, "");
AUTOCVAR(g_vehicle_r22heli_bouncestop, float, 0, "");
AUTOCVAR(g_vehicle_r22heli_bouncepain, vector, '35 2 250', "");

AUTOCVAR(g_vehicle_r22heli_flare_range, float, 2000, "");
AUTOCVAR(g_vehicle_r22heli_bombs_refire, float, 5, "");

AUTOCVAR(g_vehicle_r22heli_movestyle, int, 1, "");
AUTOCVAR(g_vehicle_r22heli_takeofftime, float, 1.5, "");
AUTOCVAR(g_vehicle_r22heli_speed_forward, float, 1700, "");
AUTOCVAR(g_vehicle_r22heli_speed_strafe, float, 900, "");
AUTOCVAR(g_vehicle_r22heli_speed_up, float, 1700, "");
AUTOCVAR(g_vehicle_r22heli_speed_down, float, 1700, "");
AUTOCVAR(g_vehicle_r22heli_mass, float, 1000, "");
AUTOCVAR(g_vehicle_r22heli_friction, float, 2, "");
AUTOCVAR(g_vehicle_r22heli_pitchlimit, float, 45, "");
AUTOCVAR(g_vehicle_r22heli_pitchspeed, float, 50, "");
AUTOCVAR(g_vehicle_r22heli_turnspeed, float, 200, "");

const float R22HELIROTOR_HEIGHT = 148;

const vector R22HELIROTOR_MIN_HBF = '-50 -50 -1'; //Back and front trunk for this model
const vector R22HELIROTOR_MAX_HBF = '50 50 1';

const vector R22HELIROTOR_MIN_HBB = '-50 -50 -1'; //Middle
const vector R22HELIROTOR_MAX_HBB = '50 50 1';


const vector R22HELIROTOR_MIN_HBF_T = '-5 -5 -15'; //Back and front trunk for this model
const vector R22HELIROTOR_MAX_HBF_T = '5 5 15';

const vector R22HELIROTOR_MIN_HBB_T = '-5 -5 -30'; //Middle
const vector R22HELIROTOR_MAX_HBB_T = '5 5 30';

.entity bomb3, bomb4, bomb5, bomb6;
.entity bomb11;

////For spinning rotor death areas.
//front/back
.entity rotorboxft;
.entity rotorboxmf;
.entity rotorboxmb;
.entity rotorboxbk;

//side to side
.entity rotorboxftr;
.entity rotorboxmfr;
.entity rotorboxmbr;
.entity rotorboxbkr;

//diagnol 1
.entity rotorboxftd1;
.entity rotorboxmfd1;
.entity rotorboxmbd1;
.entity rotorboxbkd1;

//diagnol 2
.entity rotorboxftd2;
.entity rotorboxmfd2;
.entity rotorboxmbd2;
.entity rotorboxbkd2;

.vector rotoroffset;
.float rotor_is;

//tail rotor
.entity rotorboxft_t;
.entity rotorboxmf_t;
.entity rotorboxmid_t;
.entity rotorboxmb_t;
.entity rotorboxbk_t;

var vector r22heli_force_from_tag(string tag_name, float spring_length, float max_power);

float r22heli_takeoff();
float r22heli_pilot_frame();
void r22heli_minigun(entity gun, entity pilot, entity gunmount, entity mggun1);
void r22heli_hmg(entity gun, entity pilot, entity gunmount);

float r22heli_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
	return vlen(self.origin - trace_endpos);
}


void r22heli_land()
{    
	float hgt;
		
	hgt = r22heli_altitude(512);    
	self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
	self.angles_x *= 0.95;
	self.angles_z *= 0.95;

	if(hgt < 128)
	if(hgt > 0)
		self.frame = (hgt / 128) * 25;

	if (self.waterlevel > 0)
	{
	self.bomb1.gun1.avelocity_y = self.bomb1.gun1.avelocity_y * 0.95;
		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	} else {
		self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}

	if(hgt < 16)
	{
		self.movetype = MOVETYPE_TOSS;
		self.think    = vehicles_think;
		self.frame    = 0;
	}

	self.nextthink  = time;

	CSQCMODEL_AUTOUPDATE(self);
}

float r22heli_takeoff()
{
	entity player, r22heli;
	
	player = self;
	r22heli = self.vehicle;
	self   = r22heli;

	// make sure it's valid?
	if(player.BUTTON_JUMP)
	if(!r22heli.bomb1.gun1.count)
		r22heli.bomb1.gun1.count = 1;
	
	if(self.sound_nexttime < time)
	if(player.waterlevel != WATERLEVEL_SUBMERGED)
	{
		self.sound_nexttime = time + 2.3807; //soundlength("vehicles/raptor_fly.wav");
		sound(self, CH_TRIGGER_SINGLE, SND_CHOPPA_LANDED, VOL_VEHICLEENGINE, ATTN_NORM);
	}

	// takeoff sequence
	if(r22heli.bomb1.gun1.count == 1)
	{
		r22heli.movetype     = MOVETYPE_BOUNCEMISSILE;
		if(r22heli.frame < 25)
		{
			r22heli.frame += 25 / (autocvar_g_vehicle_r22heli_takeofftime / sys_frametime);    
			if(player.waterlevel != WATERLEVEL_SUBMERGED)
			{
				r22heli.velocity_z = min(r22heli.velocity_z * 1.5, 256);
					self.bomb1.gun1.avelocity_y = 90 + ((r22heli.frame / 25) * 25000);
					self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
			}	
			}
			else
			{
				player.PlayerPhysplug = r22heli_pilot_frame;
			}
	}
	else
	{
		// engine off?
		r22heli.movetype = MOVETYPE_BOUNCE;
		if (r22heli.frame > 0)
		{
			r22heli.frame -= 25 / (autocvar_g_vehicle_r22heli_takeofftime / sys_frametime);
			if(player.waterlevel != WATERLEVEL_SUBMERGED)
			{
				self.bomb1.gun1.avelocity_y = 90 + ((r22heli.frame / 25) * 25000);
					self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
			}
		}
		if(r22heli.flags & FL_ONGROUND)
			movelib_brake_simple(1);
	}

	// cannon firing
	helicopter_delugegun(r22heli, player, r22heli.bomb11);
	 
	if (r22heli.spawnflags >= 64)
	{
		if (self.spawnflags & 64)
		{
			r22heli_minigun(r22heli, player, r22heli.bomb3, r22heli.bomb3.gun1);
			r22heli_minigun(r22heli, player, r22heli.bomb4, r22heli.bomb4.gun1);
		}
	
		if (r22heli.spawnflags & 128)
		{
			r22heli_hmg(r22heli, player, r22heli.bomb5);
			r22heli_hmg(r22heli, player, r22heli.bomb6);
		}
	}

	// end takeoff weapons stuff
	
	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
	setorigin(player, r22heli.origin + '0 0 32');

	if(r22heli.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(r22heli.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, true);

	if(r22heli.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(r22heli.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, frametime, false);

	if(r22heli.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(r22heli.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, frametime, false);


	r22heli.bomb1.alpha = r22heli.bomb2.alpha = (time - r22heli.lip) / (r22heli.delay - r22heli.lip);
	player.vehicle_reload2 = bound(0, r22heli.bomb1.alpha * 100, 100);

	VEHICLE_UPDATE_PLAYER(player, health, r22heli);
	VEHICLE_UPDATE_PLAYER(player, energy, r22heli);
	if(self.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(player, shield, r22heli);

	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
	
	self = player;
	return 1;
}

float r22heli_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;

	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin);
	gunner.velocity = vehic.velocity;
	
	float _in, _out;
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	if((gun == vehic.gun1))
	{
		_in = autocvar_g_vehicle_r22heli_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_r22heli_cannon_turnlimit_out;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_r22heli_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_r22heli_cannon_turnlimit_in;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	vector ad;

	if(autocvar_g_vehicle_r22heli_cannon_lock)
	{
		if(gun.lock_time < time)
			gun.enemy = world;

		if(trace_ent)
			if(trace_ent.movetype)
				if(trace_ent.takedamage)
					if(!trace_ent.deadflag)
					{
						if(DIFF_TEAM(trace_ent, gunner))
						{
							gun.enemy = trace_ent;
							gun.lock_time = time + 5;
						}
					}
	}

	if(gun.enemy)
	{
		float i, distance, impact_time;

		vector vf = real_origin(gun.enemy);
		vector _vel = gun.enemy.velocity;
		if(gun.enemy.movetype == MOVETYPE_WALK)
			_vel_z *= 0.1;


		ad = vf;
		for(i = 0; i < 4; ++i)
		{
			distance = vlen(ad - gunner.origin);
			impact_time = distance / autocvar_g_vehicle_r22heli_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_r22heli_cannon_pitchlimit_down * -1, autocvar_g_vehicle_r22heli_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_r22heli_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_r22heli_cannon_pitchlimit_down * -1, autocvar_g_vehicle_r22heli_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_r22heli_cannon_turnspeed);

	

	VEHICLE_UPDATE_PLAYER(gunner, health, r22heli);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, r22heli);

	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), 0);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));

	vehic.solid = SOLID_BBOX;
	gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_r22heli_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

vector r22heli_gunner_findgoodexit(vector prefer_spot, entity gunner, entity player)
{
	//vector exitspot;
	float mysize;

	tracebox(gunner.origin + '0 0 32', STAT(PL_MIN, NULL), STAT(PL_MAX, NULL), prefer_spot, MOVE_NORMAL, player);
	if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
		return prefer_spot;

	mysize = 1.5 * vlen(STAT(PL_MAX, NULL) - STAT(PL_MIN, NULL)); // can't use gunner's size, as they don't have a size
	float i;
	vector v, v2;
	v2 = 0.5 * (gunner.absmin + gunner.absmax);
	for(i = 0; i < 100; ++i)
	{
		v = randomvec();
		v_z = 0;
		v = v2 + normalize(v) * mysize;
		tracebox(v2, STAT(PL_MIN, NULL), STAT(PL_MAX, NULL), v, MOVE_NORMAL, player);
		if(trace_fraction == 1.0 && !trace_startsolid && !trace_allsolid)
			return v;
	}

	return prefer_spot; // this should be considered a fallback?!
}

void r22heli_gunner_exit(int _exitflag)
{
	entity player = self;
	entity gunner = player.vehicle;
	entity vehic = gunner.owner;

	if(IS_REAL_CLIENT(player))
	{
		msg_entity = player;
		WriteByte(MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, player);

		WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 0);
		WriteAngle(MSG_ONE, vehic.angles.y);
		WriteAngle(MSG_ONE, 0);
	}

	CSQCVehicleSetup(player, HUD_NORMAL);
	setsize(player, STAT(PL_MIN, NULL), STAT(PL_MAX, NULL));

	player.takedamage     = DAMAGE_AIM;
	player.solid          = SOLID_SLIDEBOX;
	player.movetype       = MOVETYPE_WALK;
	player.effects       &= ~EF_NODRAW;
	player.alpha          = 1;
	player.PlayerPhysplug = func_null;
	player.view_ofs       = STAT(PL_VIEW_OFS, NULL);
	player.event_damage   = PlayerDamage;
	player.hud            = HUD_NORMAL;
	player.teleportable	  = TELEPORT_NORMAL;
	PS(player).m_switchweapon = PS(gunner).m_switchweapon;
	player.vehicle_enter_delay = time + 2;

	fixedmakevectors(vehic.angles);

	if(player == vehic.gunner1) { vehic.gunner1 = world; }
	if(player == vehic.gunner2) { vehic.gunner2 = world; v_right *= -1; }

	vector spot = real_origin(gunner);
	spot = spot + v_up * 128 + v_forward * 300 + v_right * 150;
	spot = r22heli_gunner_findgoodexit(spot, gunner, player);

	// TODO: figure a way to move player out of the gunner

	player.velocity = 0.75 * vehic.velocity + normalize(spot - vehic.origin) * 200;
	player.velocity_z += 10;

	gunner.phase = time + 5;
	gunner.vehicle_hudmodel.viewmodelforclient = gunner;

	MUTATOR_CALLHOOK(VehicleExit, player, gunner);

	player.vehicle = world;
}

bool r22heli_gunner_enter()
{
	entity vehic = self;
	entity player = other;
	entity gunner = world;

	if(!vehic.gunner1 && time >= vehic.gun1.phase) 	{ gunner = vehic.gun1; vehic.gunner1 = player; }
	else { dprint("Vehicle is full, fail\n"); return false; }

	player.vehicle 			= gunner;
	player.angles 			= vehic.angles;
	player.takedamage 		= DAMAGE_NO;
	player.solid 			= SOLID_NOT;
	player.alpha 			= -1;
	player.movetype 		= MOVETYPE_NOCLIP;
	player.event_damage 	= func_null;
	player.view_ofs 		= '0 0 0';
	player.hud 				= gunner.hud;
	player.teleportable 	= false;
	player.PlayerPhysplug 	= gunner.PlayerPhysplug;
	player.vehicle_ammo1 	= vehic.vehicle_ammo1;
	player.vehicle_ammo2 	= vehic.vehicle_ammo2;
	player.vehicle_reload1 	= vehic.vehicle_reload1;
	player.vehicle_reload2 	= vehic.vehicle_reload2;
	player.vehicle_energy 	= vehic.vehicle_energy;
	player.flags 		   &= ~FL_ONGROUND;

	RemoveGrapplingHook(player);

	PS(gunner).m_switchweapon = PS(player).m_switchweapon;
	gunner.vehicle_exit = r22heli_gunner_exit;
	gunner.vehicle_hudmodel.viewmodelforclient = player;

	if(IS_REAL_CLIENT(player))
	{
		msg_entity = player;
		WriteByte(MSG_ONE, 		SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, 	gunner.vehicle_viewport);

		WriteByte(MSG_ONE, 		SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 	gunner.angles_x + vehic.angles_x); // tilt
		WriteAngle(MSG_ONE, 	gunner.angles_y + vehic.angles_y); // yaw
		WriteAngle(MSG_ONE, 	0); // roll
	}

	CSQCVehicleSetup(player, player.hud);

	MUTATOR_CALLHOOK(VehicleEnter, player, gunner);

	return true;
}

bool vehicles_valid_pilot();

void r22heli_touch()
{
	if(autocvar_g_vehicles_enter) { return; }

	if(self.gunner1 != world)
	{
		vehicles_touch();
		return;
	}

	if(vehicles_valid_pilot())
	{
		if(time >= other.vehicle_enter_delay && time >= self.gun1.phase)
			if(r22heli_gunner_enter())
				return;
	}

	vehicles_touch();
}

void r22heli_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_r22heli_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_r22heli_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_r22heli_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, true);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, frametime, false);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, frametime, false);

}

void r22heli_minigun(entity gun, entity pilot, entity gunmount, entity mggun1)
{
	if(pilot.BUTTON_ATCK)
	{
		mg_m134_fire(gun, pilot, gunmount, mggun1);
		gun.count = 1; // auto reload // will have to press R to resume reload
	}
	else
	{
		//if (gun.count == 1)
		//{
			//vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, true);
			vehicles_regen(gun.cnt, vehicle_ammo1,  autocvar_g_mountedgun_m134_machinegun_ammo_max,
													autocvar_g_mountedgun_m134_machinegun_ammo_regen_pause,
													autocvar_g_mountedgun_m134_machinegun_ammo_regen, frametime, false);
		//}
		/*else if (pilot.impulse == 20)
		{
			if(pilot.BUTTON_HOOK)
			{
				// reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
				//vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
			}
			else
			{
				gun.count = 1;
				sound (gun, CH_WEAPON_A, W_Sound("reload"), VOL_BASE, ATTN_NORM);
			}
		}*/
	}
}

void r22heli_hmg(entity gun, entity pilot, entity gunmount)
{
	if(!forbidWeaponUse(pilot))
	if(pilot.BUTTON_ATCK)
		mg_browning50_fire(gun, pilot, gunmount);
	else
		vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_mountedgun_browning50_machinegun_ammo_max,
										   autocvar_g_mountedgun_browning50_machinegun_ammo_regen_pause,
										   autocvar_g_mountedgun_browning50_machinegun_ammo_regen, frametime, false);
}

entity r22heli_rocket_gettarget(entity player)
{
	entity closest = world;
	
	FOREACH_ENTITY_FLAGS(vehicle_flags, VHF_ISVEHICLE, LAMBDA(
		if(DIFF_TEAM(player, it))
		if(it.deadflag == DEAD_NO)
			if(vlen(it.origin - player.origin) < autocvar_g_vehicle_r22heli_rocket_targetrange)
			if(!closest || vlen(it.origin - player.origin) < vlen(it.origin - closest.origin))
				closest = it;
	));

	if(!closest)
	{
		FOREACH_ENTITY_FLAGS(turret_flags, TUR_FLAG_ISTURRET, LAMBDA(
			if(DIFF_TEAM(player, it))
			if(it.deadflag == DEAD_NO)
				if(vlen(it.origin - player.origin) < autocvar_g_vehicle_r22heli_rocket_targetrange)
				if(!closest || vlen(it.origin - player.origin) < vlen(it.origin - closest.origin))
					closest = it;
		));
	}

	if(!closest)
	{
		FOREACH_CLIENT(IS_PLAYER(it), LAMBDA(
			if(DIFF_TEAM(player, it))
			if(it.deadflag == DEAD_NO)
			if(!it.alpha || it.alpha > 0.5)
				if(vlen(it.origin - player.origin) < autocvar_g_vehicle_r22heli_rocket_targetrange)
				if(!closest || vlen(it.origin - player.origin) < vlen(it.origin - closest.origin))
					closest = it;
		));
	}

	return closest;
}

void r22heli_rocket_tracker();
void r22heli_rocket_groundhugger();

void r22heli_fire_rocket(entity player, vector org, vector dir)
{SELFPARAM();
	entity rocket = vehicles_projectile(EFFECT_RACER_ROCKETLAUNCH.eent_eff_name, SND(ROCKET_FIRE),
						   org, dir * autocvar_g_vehicle_racer_rocket_speed,
						   autocvar_g_vehicle_r22heli_rocket_damage, autocvar_g_vehicle_racer_rocket_radius, autocvar_g_vehicle_racer_rocket_force, 3,
						   DEATH_VH_WAKI_ROCKET.m_id, PROJECTILE_WAKIROCKET, 20, false, false, player);

   entity trg = r22heli_rocket_gettarget(player);


	rocket.lip			  = autocvar_g_vehicle_racer_rocket_accel * sys_frametime;
	rocket.wait			 = autocvar_g_vehicle_racer_rocket_turnrate;
	rocket.nextthink		= time;
	rocket.enemy			= trg;
	rocket.cnt			  = time + 15;

	if(trg)
		rocket.think			= r22heli_rocket_tracker;
	else
		rocket.think			= r22heli_rocket_groundhugger;
}

void r22heli_rocket_tracker()
{SELFPARAM();
	vector olddir, newdir;
	float oldvel, newvel;

	self.nextthink  = time;

	if (self.owner.deadflag != DEAD_NO || self.cnt < time)
	{
		self.use();
		return;
	}

	if(!self.realowner.vehicle)
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
	   // self.think = r22heli_rocket_groundhugger;
		self.enemy = r22heli_rocket_gettarget(self.realowner);
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

void r22heli_rocket_groundhugger()
{SELFPARAM();
	vector olddir, newdir;
	float oldvel, newvel;

	self.nextthink  = time;

	if(self.owner.deadflag != DEAD_NO || self.cnt < time)
	{
		self.use();
		return;
	}

	if(!self.realowner.vehicle)
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

	int cont = pointcontents(self.origin - '0 0 32');
	if(cont == CONTENT_WATER || cont == CONTENT_LAVA || cont == CONTENT_SLIME)
		self.velocity_z += 200;

	UpdateCSQCProjectile(self);
	return;
}

void r22heli_fire_rocket_aim(entity player, entity gunmount, string tagname)
{
	vector v = gettaginfo(gunmount, gettagindex(gunmount, tagname));
	r22heli_fire_rocket(player, v, v_forward);
}

void r22heli_rocket(entity gun, entity pilot)
{
	if(!forbidWeaponUse(pilot))
	if(time > gun.delay)
	if(pilot.BUTTON_ATCK2)
	{
		r22heli_fire_rocket_aim(pilot, gun.bomb5, "tag_mgun");
		r22heli_fire_rocket_aim(pilot, gun.bomb6, "tag_mgun");

		gun.lock_strength  = 0;
		gun.lock_target	= world;
		gun.misc_bulletcounter = 0;
		gun.delay = time + autocvar_g_vehicle_r22heli_rocket_refire;
		gun.lip = time;
		pilot.vehicle_ammo2 = 0;
	}
	else if(gun.misc_bulletcounter == 0)
		pilot.vehicle_ammo2 = 100;
}

float r22heli_pilot_frame()
{
	entity pilot, vehic;
	vector df;
	float ftmp = 0;
	
	if(intermission_running)
	{
		self.vehicle.velocity = '0 0 0';
		self.vehicle.avelocity = '0 0 0';
		return 1;
	}

	pilot = self;
	vehic = self.vehicle;
	self  = vehic;

	vehicles_painframe();
		
	if(self.sound_nexttime < time)
	if(pilot.waterlevel != WATERLEVEL_SUBMERGED)
	{
		self.sound_nexttime = time + 2.3807; 
		sound(self, CH_TRIGGER_SINGLE, SND_CHOPPA, 1, ATTN_NORM);
		self.wait = ftmp;
	}        
	/*
	else if(fabs(ftmp - self.wait) > 0.2)
	{
		sound (self.tur_head, CH_TRIGGER_SINGLE, "", 1 - ftmp,   ATTN_NORM );
		sound (self, CH_TRIGGER_SINGLE, "", ftmp, ATTN_NORM);        
		self.wait = ftmp;
	}
	*/
	
	if(vehic.deadflag != DEAD_NO)
	{
		self = pilot;
		pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
		return 1;
	}
	crosshair_trace(pilot);

	vector vang;
	vang = vehic.angles;
	df = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
	vang_x *= -1;
	df_x *= -1;
	if(df_x > 180)  df_x -= 360;
	if(df_x < -180) df_x += 360;
	if(df_y > 180)  df_y -= 360;
	if(df_y < -180) df_y += 360;
	
	
	//print("wl: ", ftos(vehic.waterlevel), "\n");
	//print(sprintf("waterlevel: %f vehic to player %f\n", vehic.waterlevel, pilot.waterlevel));
	
	if(pilot.waterlevel != WATERLEVEL_SUBMERGED)
	{
		// gotta do it this way as vehicles waterlevel is always 1
		// thus we check players water level instead.
		/////////////////////////////////////////////////////////////////////////
		//BEGIN If not in water
		/////////////////////////////////////////////////////////////////////////

		ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
		if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
		vehic.avelocity_y = bound(-autocvar_g_vehicle_r22heli_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_r22heli_turnspeed);

		// Pitch
		ftmp = 0;
		if(!((pilot.BUTTON_HOOK) && (pilot.movement_x < 0)))
		{
			if(pilot.movement_x > 0 && vang_x < autocvar_g_vehicle_r22heli_pitchlimit)
				ftmp = 5;
			else if(pilot.movement_x < 0 && vang_x > -autocvar_g_vehicle_r22heli_pitchlimit)
				ftmp = -20;
		}

		df_x = bound(-autocvar_g_vehicle_r22heli_pitchlimit, df_x , autocvar_g_vehicle_r22heli_pitchlimit);
		ftmp = vang_x - bound(-autocvar_g_vehicle_r22heli_pitchlimit, df_x + ftmp, autocvar_g_vehicle_r22heli_pitchlimit);
		vehic.avelocity_x = bound(-autocvar_g_vehicle_r22heli_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_r22heli_pitchspeed);

		vehic.angles_x = anglemods(vehic.angles_x);
		vehic.angles_y = anglemods(vehic.angles_y);
		vehic.angles_z = anglemods(vehic.angles_z);

		if(autocvar_g_vehicle_r22heli_movestyle == 1)
			makevectors('0 1 0' * vehic.angles_y);
		else
			makevectors(pilot.v_angle);

		df = vehic.velocity * -autocvar_g_vehicle_r22heli_friction;
		
		if(pilot.BUTTON_HOOK)
		{
			if(r22heli_altitude(512) < 16) 
			{
				pilot.PlayerPhysplug = r22heli_takeoff;
				vehic.bomb1.gun1.count = 0;
			}	 
		}
		else
		{
			if(pilot.movement_x != 0)
			{
				if(pilot.movement_x > 0)
					df += v_forward  * autocvar_g_vehicle_r22heli_speed_forward;
				else if(pilot.movement_x < 0)
					df -= v_forward  * autocvar_g_vehicle_r22heli_speed_forward;
			}
		}

		if(pilot.movement_y != 0)
		{
			if(pilot.movement_y < 0)
				df -= v_right * autocvar_g_vehicle_r22heli_speed_strafe;
			else if(pilot.movement_y > 0)
				df += v_right * autocvar_g_vehicle_r22heli_speed_strafe;

			vehic.angles_z = bound(-30,vehic.angles_z + (pilot.movement_y / autocvar_g_vehicle_r22heli_speed_strafe),30);
		}
		else
		{
			vehic.angles_z *= 0.95;
			if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
				vehic.angles_z = 0;
		}
		
		//Cannon firing
		helicopter_delugegun(vehic, pilot, vehic.bomb11);
		 
		if (vehic.spawnflags >= 64)
		{
			if (self.spawnflags & 64)
			{
				r22heli_minigun(vehic, pilot, vehic.bomb3, vehic.bomb3.gun1);
				r22heli_minigun(vehic, pilot, vehic.bomb4, vehic.bomb4.gun1);
			}
		
			if (vehic.spawnflags & 128)
			{
				r22heli_hmg(vehic, pilot, vehic.bomb5);
				r22heli_hmg(vehic, pilot, vehic.bomb6);

				r22heli_rocket(vehic, pilot);
			}
		}

		if(pilot.BUTTON_CROUCH)
			df -= v_up * autocvar_g_vehicle_r22heli_speed_down;
		else if (pilot.BUTTON_JUMP)
			df += v_up * autocvar_g_vehicle_r22heli_speed_up;
		
		
		vehic.velocity  += df * frametime;
		vehic.movetype       = MOVETYPE_BOUNCEMISSILE;
	}
	else
	{
		/////////////////////////////////////////////////////////////////////////
		//END If not in water
		/////////////////////////////////////////////////////////////////////////
		vehic.velocity  = '0 0 0';
		vehic.velocity_x = 0;
		vehic.velocity_y = 0;
		vehic.velocity_z = 0;
		vehic.avelocity_x = 0;
		vehic.avelocity_y = 0;
		vehic.avelocity_z = 0;
		vehic.movetype  = MOVETYPE_TOSS;
		vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun1.avelocity_y * 0.95;
			vehic.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	
	pilot.velocity = pilot.movement  = vehic.velocity;
	setorigin(pilot, vehic.origin + '0 0 32');

	// Target lock & predict

	if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, true);

	if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, frametime, false);

	if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, frametime, false);

	//Bomb dropping removed
	
	vehic.bomb1.alpha = vehic.bomb2.alpha = (time - vehic.lip) / (vehic.delay - vehic.lip);
	pilot.vehicle_reload2 = bound(0, vehic.bomb1.alpha * 100, 100);

	if(self.bomb1.cnt < time)
	{
		entity _missile = findchainentity(enemy, vehic);
		float _incomming = 0;
		while(_missile)
		{
			if(_missile.flags & FL_PROJECTILE)
			if(MISSILE_IS_TRACKING(_missile))
			if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_r22heli_flare_range)
				++_incomming;

			_missile = _missile.chain;
		}
		
		if(_incomming)
			sound(self, CH_PAIN_SINGLE, SND_VEH_MISSILE_ALARM, VOL_BASE, ATTEN_NONE);
		
		self.bomb1.cnt = time + 1;
	}

	// weapons removed

	VEHICLE_UPDATE_PLAYER(pilot, health, r22heli);
	VEHICLE_UPDATE_PLAYER(pilot, energy, r22heli);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(pilot, shield, r22heli);

	pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = pilot.BUTTON_CROUCH = 0;
	setorigin(pilot,vehic.origin + '0 0 32');
	pilot.velocity = vehic.velocity;

	//pilot.vehicle_ammo1 = (vehic.gun1.vehicle_energy / autocvar_g_vehicle_r22heli_cannon_ammo) * 100;
	//pilot.vehicle_ammo2 = (vehic.gun2.vehicle_energy / autocvar_g_vehicle_r22heli_cannon_ammo) * 100;
	
	self = pilot;

	return 1;
}

void r22heli_exit(float eject)
{
	self.touch = vehicles_touch;
	self.think = vehicles_think;
	self.nextthink = time;
	
	if(!self.owner)
		return;
	
	// add from sparrow	
	if(self.deadflag == DEAD_NO)
	{
		self.think      = r22heli_land;
		self.nextthink  = time;
	}

	self.bomb1.gun1.count = 1;
	
	makevectors(self.angles);
	if(eject)
	{
		vector spot = self.origin + v_forward * 100 + '0 0 64';
		spot = vehicles_findgoodexit(spot);
		setorigin(self.owner , spot);
		self.owner.velocity = (v_up + v_forward * 0.25) * 750;
		self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		vector spot;
		if(vlen(self.velocity) > 2 * PHYS_MAXAIRSPEED(self.owner))
		{
			self.owner.velocity = normalize(self.velocity) * PHYS_MAXAIRSPEED(self.owner) * 2;
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

void r22heli_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_r22heli_blowup_coredamage,
				 autocvar_g_vehicle_r22heli_blowup_edgedamage,
				 autocvar_g_vehicle_r22heli_blowup_radius, self, world,
				 autocvar_g_vehicle_r22heli_blowup_forceintensity,
				 DEATH_VH_BUMB_DEATH.m_id, world);

	sound(self, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_MIN);
	Send_Effect(EFFECT_EXPLOSION_BIG, (self.origin + '0 0 100') + (randomvec() * 80), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void r22heli_diethink()
{
	if(time >= self.wait)
		self.think = r22heli_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_MIN);
		Send_Effect(EFFECT_EXPLOSION_SMALL, randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void r22heli_die()
{
	entity oldself = self;
	
	if(self.gunner1)
	{
		self = self.gunner1;
		if(oldself.gun1.vehicle_exit)
			oldself.gun1.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}

	if(self.vehicle_exit)
		self.vehicle_exit(VHEF_EJECT);
	
	fixedmakevectors(self.angles);
	vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		_body.touch = r22heli_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 1;
	_body.think = r22heli_diethink;
	_body.nextthink = time;
	_body.wait = time + 2 + (random() * 8);
	_body.owner = self;
	_body.enemy = self.enemy;
	
	Send_Effect(EFFECT_EXPLOSION_SMALL, findbetterlocation(self.origin, 16), '0 0 0', 1);
	
	self.health			= 0;
	self.event_damage	= func_null;
	self.solid			= SOLID_CORPSE;
	self.takedamage		= DAMAGE_NO;
	self.deadflag		= DEAD_DYING;
	self.movetype		= MOVETYPE_NONE;
	self.effects		= EF_NODRAW;
	self.colormod		= '0 0 0';
	self.avelocity		= '0 0 0';
	self.velocity		= '0 0 0';
	self.touch 			= func_null;
	self.nextthink 		= 0;

	setorigin(self, self.pos1);

	helicopter_rotor_die(self.rotorboxft); // using this, sets .think to something other than null, but not much :)
		helicopter_rotor_die(self.rotorboxmf); // middle front
	helicopter_rotor_die(self.rotorboxmb); // mid back
		helicopter_rotor_die(self.rotorboxbk);
	
	helicopter_rotor_die(self.rotorboxftr); 
		helicopter_rotor_die(self.rotorboxmfr); // middle front
	helicopter_rotor_die(self.rotorboxmbr); // mid back
		helicopter_rotor_die(self.rotorboxbkr);
	
	helicopter_rotor_die(self.rotorboxftd1); 
		helicopter_rotor_die(self.rotorboxmfd1); // middle front
	helicopter_rotor_die(self.rotorboxmbd1); // mid back
		helicopter_rotor_die(self.rotorboxbkd1);
	
	helicopter_rotor_die(self.rotorboxftd2); 
		helicopter_rotor_die(self.rotorboxmfd2); // middle front
	helicopter_rotor_die(self.rotorboxmbd2); // mid back
		helicopter_rotor_die(self.rotorboxbkd2);
	
	helicopter_rotor_die(self.rotorboxft_t); // using this, sets .think to something other than null, but not much :)
		helicopter_rotor_die(self.rotorboxmf_t); // middle front
	helicopter_rotor_die(self.rotorboxmid_t);
	helicopter_rotor_die(self.rotorboxmb_t); // mid back
		helicopter_rotor_die(self.rotorboxbk_t);
}

// if we dont do this every now and then, the r22heli's rotors
// stop working, presumably due to angle overflow
void r22heli_rotor_anglefix()
{
	self.gun1.angles_y = anglemods(self.gun1.angles_y);
	self.gun2.angles_y = anglemods(self.gun2.angles_y);
	self.nextthink = time + 15;
}

void r22heli_spawn()
{
	if(!self.gun1)
	{
		entity spinner;
	
		// for some reason, autosizing of the shield entity refuses to work for this one so set it up in advance.
		self.vehicle_shieldent = spawn();
		self.vehicle_shieldent.effects = EF_LOWPRECISION;
		_setmodel(self.vehicle_shieldent, "models/vhshield.md3");
		setattachment(self.vehicle_shieldent, self, "");
		setorigin(self.vehicle_shieldent, real_origin(self) - self.origin);
		self.vehicle_shieldent.scale       = 512 / vlen(self.maxs - self.mins);
		self.vehicle_shieldent.think       = shieldhit_think;
		self.vehicle_shieldent.alpha = -1;
		self.vehicle_shieldent.effects = EF_LOWPRECISION | EF_NODRAW;
	 
		self.frame = 0;

		self.bomb1 = spawn();
		self.bomb2 = spawn();
		self.gun1  = spawn();
		self.gun2  = spawn();

		_setmodel(self.bomb1,"null");
		_setmodel(self.bomb2,"null");
		_setmodel(self.gun1, "null");
		_setmodel(self.gun2, "null");
		//_setmodel(self.tur_head, "models/vehicles/r22heliedits_body.iqm");

		setattachment(self.bomb1, self, "bombmount_left");
		setattachment(self.bomb2, self, "bombmount_right");
		//setattachment(self.tur_head, self,"root");

		// FIXMODEL guns mounts to angled bones
		self.bomb1.angles = self.angles;
		self.angles = '0 0 0';

		self.angles = self.bomb1.angles;
		self.bomb1.angles = '0 0 0';

		spinner = spawn();
		spinner.owner = self;
		setmodel(spinner, MDL_R22HELI_SPINNER);
		setattachment(spinner, self, "engine_left");
		spinner.movetype = MOVETYPE_NOCLIP;
		spinner.avelocity = '0 90 0';
		//spinner.scale = 3.0;
		self.bomb1.gun1 = spinner;

		spinner = spawn();
		spinner.owner = self;
		setmodel(spinner, MDL_R22HELI_SMALLSPINNER);
		setattachment(spinner, self, "engine_right");
		spinner.movetype = MOVETYPE_NOCLIP;
		spinner.avelocity = '0 -90 0';
		self.bomb1.gun2 = spinner;

		// sigh
		self.bomb1.think = r22heli_rotor_anglefix;
		self.bomb1.nextthink = time;

		setattachment(self.vehicle_viewport, self, "tag_camera");
		//self.mass               = 1 ;
		self.mass               = autocvar_g_vehicle_r22heli_mass;
		
		self.vehicle_flags |= VHF_MULTISLOT;

		self.gun1.owner = self;
			
		setattachment(self.gun1, self, "tag_pass1");
		
		vehicle_addplayerslot(self, self.gun1, HUD_BUMBLEBEE_GUN, "null", r22heli_gunner_frame, r22heli_gunner_exit, r22heli_gunner_enter);
		
		helicopter_delugegun_add(self, "forwardmount_left");
		
		self.rotorboxft = spawn();
		self.rotorboxmf = spawn();
		self.rotorboxmb = spawn();
		self.rotorboxbk = spawn();
		
		self.rotorboxftr = spawn();
		self.rotorboxmfr = spawn();
		self.rotorboxmbr = spawn();
		self.rotorboxbkr = spawn();
		
		self.rotorboxftd1 = spawn();
		self.rotorboxmfd1 = spawn();
		self.rotorboxmbd1 = spawn();
		self.rotorboxbkd1 = spawn();
		
		self.rotorboxftd2 = spawn();
		self.rotorboxmfd2 = spawn();
		self.rotorboxmbd2 = spawn();
		self.rotorboxbkd2 = spawn();
		
		self.rotorboxft_t = spawn();
		self.rotorboxmf_t = spawn();
		self.rotorboxmid_t = spawn();
		self.rotorboxmb_t = spawn();
		self.rotorboxbk_t = spawn();
	
		if (self.spawnflags & 64)
		{
			// minigun left stuff
			self.bomb3 = spawn();
			setmodel(self.bomb3, MDL_MG_M134GUN);
			setattachment(self.bomb3, self, "gunmount_left");
				
			// minigun left barrels
			self.bomb3.gun1 = spawn();
			setmodel(self.bomb3.gun1, MDL_MG_M134GUN_BARRELS);
			setattachment(self.bomb3.gun1, self.bomb3, "tag_axis");
			self.bomb3.gun1.count = 100; //autocvar_g_mountedgun_m134_machinegun_refire;
			
			self.bomb3.angles_z = -110; // so ammo chain travels into fuselage
			
			// minigun right stuff
			self.bomb4 = spawn();
			setmodel(self.bomb4, MDL_MG_M134GUN);
			setattachment(self.bomb4, self, "gunmount_right");
			
			// minigun right barrels
			self.bomb4.gun1 = spawn();
			setmodel(self.bomb4.gun1, MDL_MG_M134GUN_BARRELS);
			setattachment(self.bomb4.gun1, self.bomb4, "tag_axis");
			self.bomb4.gun1.count = 100; //autocvar_g_mountedgun_m134_machinegun_refire;
			
			self.bomb4.angles_z = 120; // so ammo chain travels into fuselage
		}
	
		if (self.spawnflags & 128)
		{
			// .50 left stuff
			self.bomb5 = spawn();
			setmodel(self.bomb5, MDL_MG_BROWNING50GUN);
			setattachment(self.bomb5, self, "forwardmount_left");
				
			self.bomb5.angles_z = -90; // so ammo chain travels into fuselage
			
			// .50 right stuff
			self.bomb6 = spawn();
			setmodel(self.bomb6, MDL_MG_BROWNING50GUN);
			setattachment(self.bomb6, self, "forwardmount_right");
			
			self.bomb6.angles_z = 90; // so ammo chain travels into fuselage
		}
	}

	self.frame          = 0;
	self.vehicle_health = autocvar_g_vehicle_r22heli_health;
	self.vehicle_shield = autocvar_g_vehicle_r22heli_shield;
	self.movetype       = MOVETYPE_TOSS;
	self.solid          = SOLID_SLIDEBOX;
	self.vehicle_energy = 1;

	self.bomb1.gun1.avelocity_y = 90;
	self.bomb1.gun2.avelocity_y = -90;

	//setsize(self, R22HELI_MIN, R22HELI_MAX );
	self.delay = time;
		
	self.bouncefactor = autocvar_g_vehicle_r22heli_bouncefactor;
	self.bouncestop = autocvar_g_vehicle_r22heli_bouncestop;
	self.damageforcescale = 0.25;
	
	float oldy;
	oldy = self.angles_y;
	self.angles_y = 0; // so we can do the init math correctly	

	// spinning rotor death areas
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 150, 0, R22HELIROTOR_HEIGHT);
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 100, 0, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, -100, 0, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, -150, 0, R22HELIROTOR_HEIGHT);
	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftr, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 0, 150, R22HELIROTOR_HEIGHT);
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfr, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 0, 100, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbr, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 0, -100, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkr, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 0, -150, R22HELIROTOR_HEIGHT);	
	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftd1, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 90, 90, R22HELIROTOR_HEIGHT);
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfd1, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 50, 50, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbd1, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, -50, -50, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkd1, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, -90, -90, R22HELIROTOR_HEIGHT);
	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftd2, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, -90, 90, R22HELIROTOR_HEIGHT);
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfd2, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, -50, 50, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbd2, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 50, -50, R22HELIROTOR_HEIGHT);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkd2, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 90, -90, R22HELIROTOR_HEIGHT);

	local vector vorg;
	vorg = gettaginfo(self, gettagindex(self, "engine_right"));
	vorg -= self.origin;
	vorg_y = vorg_y - 15; // move it to one side. where the rotor is
	// tail rotor
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft_t, R22HELIROTOR_MIN_HBF_T, R22HELIROTOR_MAX_HBF_T, vorg_x+20, vorg_y, vorg_z);
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf_t, R22HELIROTOR_MIN_HBB_T, R22HELIROTOR_MAX_HBB_T, vorg_x+8, vorg_y, vorg_z);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmid_t, R22HELIROTOR_MIN_HBB_T, R22HELIROTOR_MAX_HBB_T, vorg_x, vorg_y, vorg_z);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb_t, R22HELIROTOR_MIN_HBB_T, R22HELIROTOR_MAX_HBB_T, vorg_x-8, vorg_y, vorg_z);	
	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk_t, R22HELIROTOR_MIN_HBF_T, R22HELIROTOR_MAX_HBF_T, vorg_x-20, vorg_y, vorg_z);

	self.angles_y = oldy; // done doing the init math, reset.
}

spawnfunc(vehicle_r22heli)
{
	if(!autocvar_g_vehicle_r22heli) { remove(self); return; }
	if(!vehicle_initialize(VEH_R22HELI, false)) { remove(self); return; }
}

spawnfunc(vehicle_r22heli_milspec)
{
	if(self.spawnflags < 64)
		self.spawnflags |= 64; // so we spawn weapons
	if(self.colormap < 1024)
		self.colormap = 1024; // black
	spawnfunc_vehicle_r22heli(this);
}

		METHOD(R22Heli, vr_impact, void(R22Heli thisveh))
		{
			if(autocvar_g_vehicle_r22heli_bouncepain)
				vehicles_impact(autocvar_g_vehicle_r22heli_bouncepain_x, autocvar_g_vehicle_r22heli_bouncepain_y, autocvar_g_vehicle_r22heli_bouncepain_z);
		}
		METHOD(R22Heli, vr_enter, void(R22Heli thisveh))
		{
			self.touch = r22heli_touch;
			self.nextthink = 0;
			self.movetype = MOVETYPE_BOUNCE;
			//self.vehicle_weapon2mode = RSM_BOMB;
			self.owner.PlayerPhysplug = r22heli_takeoff;
			self.movetype       = MOVETYPE_BOUNCEMISSILE;
			self.solid          = SOLID_SLIDEBOX;
			self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
			self.tur_head.exteriormodeltoclient = self.owner;

			self.delay = time + autocvar_g_vehicle_r22heli_bombs_refire;
			self.lip   = time;

			CSQCVehicleSetup(self.owner, 0);
			self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_r22heli_health) * 100;
			self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_r22heli_shield) * 100;

			if(self.owner.flagcarried)
				setorigin(self.owner.flagcarried, '-20 0 96');
		}
		METHOD(R22Heli, vr_think, void(R22Heli thisveh))
		{
			if(!self.owner)
			{
				entity oldself = self;		
				if(self.gunner1)
				{
					self = self.gunner1;
					if(oldself.gun1.vehicle_exit)
						oldself.gun1.vehicle_exit(VHEF_EJECT);
					entity oldother = other;
					other = self;
					self = oldself;
					self.phase = 0;
					self.touch();
					other = oldother;
				}
				
			}
		}
		METHOD(R22Heli, vr_death, void(R22Heli thisveh))
		{
			CSQCModel_UnlinkEntity(self); // networking the death scene would be a nightmare
			r22heli_die();
		}
		METHOD(R22Heli, vr_spawn, void(R22Heli thisveh))
		{
			r22heli_spawn();
		}
		METHOD(R22Heli, vr_setup, void(R22Heli thisveh))
		{
			if(autocvar_g_vehicle_r22heli_energy)
			if(autocvar_g_vehicle_r22heli_energy_regen)
				self.vehicle_flags |= VHF_ENERGYREGEN;

			if(autocvar_g_vehicle_r22heli_shield)
				self.vehicle_flags |= VHF_HASSHIELD;

			if(autocvar_g_vehicle_r22heli_shield_regen)
				self.vehicle_flags |= VHF_SHIELDREGEN;

			if(autocvar_g_vehicle_r22heli_health_regen)
				self.vehicle_flags |= VHF_HEALTHREGEN;

			self.vehicle_exit = r22heli_exit;
			self.respawntime = autocvar_g_vehicle_r22heli_respawntime;
			self.vehicle_health = autocvar_g_vehicle_r22heli_health;
			self.vehicle_shield = autocvar_g_vehicle_r22heli_shield;
			self.max_health = self.vehicle_health;
		}
		METHOD(R22Heli, vr_precache, void(R22Heli thisveh))
		{
			string bodymodel;

			//if(self.spawnflags)
			//{
				//RandomSelection_Init();

				//RandomSelection_Add(world, 0, string_null, 1, 1);
				//RandomSelection_Add(world, 32, string_null, 1, 1);
				//RandomSelection_Add(world, 64, string_null, 1, 1);
				//RandomSelection_Add(world, 128, string_null, 1, 1);

				//self.spawnflags = RandomSelection_chosen_float;
				self.spawnflags |= 128;
			//}
			
			if(self.spawnflags >= 64)
				bodymodel = MDL_R22HELI_MILSPEC.model_str();
			else
				bodymodel = VEH_R22HELI.mdl;

			self.mdl = bodymodel; // override default function
		}

#elif defined(CSQC)

		METHOD(R22Heli, vr_hud, void(R22Heli thisveh))
		{
			Vehicles_drawHUD(VEH_R22HELI.m_icon, "vehicle_helicopter_weapon1", "vehicle_helicopter_weapon2",
							 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
							 "vehicle_icon_ammo2", autocvar_hud_progressbar_vehicles_ammo1_color);
		}
		METHOD(R22Heli, vr_crosshair, void(R22Heli thisveh))
		{
			Vehicles_drawCrosshair(vCROSS_LOCK);
		}
		METHOD(R22Heli, vr_setup, void(R22Heli thisveh))
		{
			AuxiliaryXhair[0].axh_image = vCROSS_HINT; // Minigun1
			AuxiliaryXhair[1].axh_image = vCROSS_HINT; // Minigun2
		}

#endif // CSQC

#endif // IMPLEMENTATION?
