//FEATURE-DISABLED New vehicle: R22 Helicopter, it flies around and shoots things

#ifndef IMPLEMENTATION
//#include "r22heli.qh"

MSG_INFO_NOTIF(DEATH_MURDER_VH_HELI_DEATH,              1,  3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",               "notify_death",         _("^BG%s%s^K1 got caught in the blast when ^BG%s^K1's Helicopter exploded%s%s"), "")
MSG_INFO_NOTIF(DEATH_SELF_VH_HELI_DEATH,                1,  2, 1, "s1 s2loc spree_lost", "s1",      "notify_death",         _("^BG%s^K1 got caught in the blast of a Helicopter explosion%s%s"), "")
MSG_CENTER_NOTIF(DEATH_SELF_VH_HELI_DEATH,          1,      0, 0, "",               CPID_Null,              "0 0",  _("^K1You got caught in the blast of a Helicopter explosion!"), "")
MSG_MULTI_NOTIF(DEATH_MURDER_VH_HELI_DEATH,         1,  NULL,           INFO_DEATH_MURDER_VH_HELI_DEATH,        NULL)
MSG_MULTI_NOTIF(DEATH_SELF_VH_HELI_DEATH,           1,  NULL,           INFO_DEATH_SELF_VH_HELI_DEATH,          CENTER_DEATH_SELF_VH_HELI_DEATH)

REGISTER_DEATHTYPE(VH_HELI_DEATH,           DEATH_SELF_VH_HELI_DEATH,       DEATH_MURDER_VH_HELI_DEATH,     "vehicle")

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
/* mins       */ ATTRIB(R22Heli, m_mins, vector, '-60 -60 0');
/* maxs       */ ATTRIB(R22Heli, m_maxs, vector, '60 60 86');
/* view offset*/ ATTRIB(R22Heli, view_ofs, vector, '0 0 150');
/* view dist  */ ATTRIB(R22Heli, height, float, 250);
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
#include "propellers.qh"
// include for both client and server
#include "r22heli_weapons/all.inc"

#ifdef SVQC
AUTOCVAR(g_vehicle_r22heli, bool, false, "Enable R22 Helicopter vehicle (if allowed by mods)");
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

//AUTOCVAR(g_vehicle_r22heli_cannon_ammo, int, 100, "");
//AUTOCVAR(g_vehicle_r22heli_cannon_ammo_regen, int, 100, "");
//AUTOCVAR(g_vehicle_r22heli_cannon_ammo_regen_pause, float, 1, "");

AUTOCVAR(g_vehicle_r22heli_bouncefactor, float, 0.25, "");
AUTOCVAR(g_vehicle_r22heli_bouncestop, float, 0, "");
AUTOCVAR(g_vehicle_r22heli_bouncepain, vector, '70 3 250', "");

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

.entity bomb3, bomb4, bomb5, bomb6;
.entity bomb11;

bool r22heli_takeoff(entity this, float dt);
bool r22heli_pilot_frame(entity this, float dt);

void r22heli_deluge_add(entity vehic, string mountspot)
{
	//delugegun
	vehic.bomb11 = spawn();
	vehic.bomb11.colormap = vehic.colormap;
	setmodel(vehic.bomb11, MDL_MG_DELUGEGUN);
	setattachment(vehic.bomb11, vehic, mountspot);
		
	vehic.bomb11.angles_z = -90; // So ammo hose travels into fuselage
}

void r22heli_land(entity this)
{
	float hgt = vehicle_altitude(this, 512);    
	this.velocity = (this.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
	this.angles_x *= 0.95;
	this.angles_z *= 0.95;

	if(hgt < 128)
	if(hgt > 0)
		this.frame = (hgt / 128) * 25;

	if (this.waterlevel > 0)
	{
		this.bomb1.gun1.avelocity_y = this.bomb1.gun1.avelocity_y * 0.95;
		this.bomb1.gun2.avelocity_y = -this.bomb1.gun1.avelocity_y;
	}
	else
	{
		this.bomb1.gun1.avelocity_y = 90 + ((this.frame / 25) * 2000);
		this.bomb1.gun2.avelocity_y = -this.bomb1.gun1.avelocity_y;
	}

	if(hgt < 16)
	{
		set_movetype(this, MOVETYPE_TOSS);
		setthink(this, vehicles_think);
		this.frame    = 0;
	}

	this.nextthink = time;

	CSQCMODEL_AUTOUPDATE(this);
}

bool r22heli_takeoff(entity this, float dt)
{
	entity vehic = this.vehicle;
	return = true;

	// make sure it's valid?
	if(PHYS_INPUT_BUTTON_JUMP(this))
	if(!vehic.bomb1.gun1.count)
		vehic.bomb1.gun1.count = 1;
	
	if(vehic.sound_nexttime < time)
	if(this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		vehic.sound_nexttime = time + 2.3807; //soundlength("vehicles/raptor_fly.wav");
		sound(vehic, CH_TRIGGER_SINGLE, SND_CHOPPA_LANDED, VOL_VEHICLEENGINE, ATTN_NORM);
	}

	// takeoff sequence
	if(vehic.bomb1.gun1.count == 1)
	{
		set_movetype(vehic, MOVETYPE_BOUNCEMISSILE);
		if(vehic.frame < 25)
		{
			vehic.frame += 25 / (autocvar_g_vehicle_r22heli_takeofftime / sys_frametime);    
			if(this.waterlevel != WATERLEVEL_SUBMERGED)
			{
				vehic.velocity_z = min(vehic.velocity_z * 1.5, 256);
					vehic.bomb1.gun1.avelocity_y = 90 + ((vehic.frame / 25) * 25000);
					vehic.bomb1.gun2.avelocity_y = -vehic.bomb1.gun1.avelocity_y;
			}	
		}
		else
			this.PlayerPhysplug = r22heli_pilot_frame;
	}
	else
	{
		// engine off?
		set_movetype(vehic, MOVETYPE_BOUNCE);
		if (vehic.frame > 0)
		{
			vehic.frame -= 25 / (autocvar_g_vehicle_r22heli_takeofftime / sys_frametime);
			if(this.waterlevel != WATERLEVEL_SUBMERGED)
			{
				vehic.bomb1.gun1.avelocity_y = 90 + ((vehic.frame / 25) * 25000);
					vehic.bomb1.gun2.avelocity_y = -vehic.bomb1.gun1.avelocity_y;
			}
		}
		if(IS_ONGROUND(vehic))
			movelib_brake_simple(vehic, 1);
	}

	// cannon firing
	if(vehic.spawnflags & 32)
		r22heli_deluge(vehic, this, vehic.bomb11, dt);
	 
	if(vehic.spawnflags >= 64)
	{
		if(vehic.spawnflags & 64)
		{
			r22heli_minigun(vehic, this, vehic.bomb3, vehic.bomb3.gun1, vehic.bomb4, vehic.bomb4.gun1, dt);
		}
	
		if(vehic.spawnflags & 128)
		{
			r22heli_hmg(vehic, this, vehic.bomb5, vehic.bomb6, dt);
		}
	}

	// end takeoff weapons stuff
	
	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
	setorigin(this, vehic.origin + '0 0 32');

	if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(vehic, vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, dt, true);

	if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen_resource(vehic, vehic.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, dt, false, RESOURCE_HEALTH);

	if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(vehic, vehic.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, dt, false);

	vehic.bomb1.alpha = vehic.bomb2.alpha = (time - vehic.lip) / (vehic.delay - vehic.lip);
	this.vehicle_reload2 = bound(0, vehic.bomb1.alpha * 100, 100);

	VEHICLE_UPDATE_PLAYER_RESOURCE(this, vehic, health, r22heli, RESOURCE_HEALTH);
	VEHICLE_UPDATE_PLAYER(this, vehic, energy, r22heli);
	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, r22heli);

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
}

bool r22heli_gunner_frame(entity this, float dt)
{
	entity vehic = this.vehicle.owner;
	//entity gun = this.vehicle;
	return = true;

	setorigin(this, vehic.origin);
	this.velocity = vehic.velocity;

	VEHICLE_UPDATE_PLAYER_RESOURCE(this, vehic, health, r22heli, RESOURCE_HEALTH);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, r22heli);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * this.vehicle_reload1) + ('0 1 0' *(1 - this.vehicle_reload1)), ((this == vehic.gunner1) ? 1 : 2));

	vehic.solid = SOLID_BBOX;
	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
}

void r22heli_gunner_exit(entity this, int _exitflag)
{
	entity player = this.owner.gunner1;
	entity gunner = this;
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
	setsize(player, STAT(PL_MIN, player), STAT(PL_MAX, player));

	player.takedamage     = DAMAGE_AIM;
	player.solid          = SOLID_SLIDEBOX;
	set_movetype(player, MOVETYPE_WALK);
	player.effects       &= ~EF_NODRAW;
	player.alpha          = 1;
	player.PlayerPhysplug = func_null;
	player.view_ofs       = STAT(PL_VIEW_OFS, NULL);
	player.event_damage   = PlayerDamage;
	STAT(HUD, player)            = HUD_NORMAL;
	player.teleportable	  = TELEPORT_NORMAL;
	player.vehicle_enter_delay = time + 2;

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];
		player.(weaponentity).m_switchweapon = gunner.(weaponentity).m_switchweapon;
		delete(gunner.(weaponentity));
	}

	fixedmakevectors(vehic.angles);

	vector spot = real_origin(gunner);
	spot = spot + v_up * 128 + v_forward * 300 + v_right * 150;
	spot = vehicles_findgoodexit(vehic, player, spot);

	// TODO: figure a way to move player out of the gunner

	player.velocity = 0.75 * vehic.velocity + normalize(spot - vehic.origin) * 200;
	player.velocity_z += 10;

	gunner.phase = time + 5;
	gunner.vehicle_hudmodel.viewmodelforclient = gunner;

	MUTATOR_CALLHOOK(VehicleExit, player, gunner);

	vehic.gunner1 = NULL;
	player.vehicle = NULL;
}

bool r22heli_gunner_enter(entity this, entity player)
{
	entity vehic = this;
	entity gunner = vehic.gun1;

	if(vehic.gunner1)
		return false; // already occupied

	if(vehic.gun1.phase > time)
		return false; // too soon

	vehic.gunner1 = player;

	player.vehicle 			= gunner;
	player.angles 			= vehic.angles;
	player.takedamage 		= DAMAGE_NO;
	player.solid 			= SOLID_NOT;
	player.alpha 			= -1;
	set_movetype(player, MOVETYPE_NOCLIP);
	player.event_damage 	= func_null;
	player.view_ofs 		= '0 0 0';
	STAT(HUD, player) 				= STAT(HUD, gunner);
	player.teleportable 	= false;
	player.PlayerPhysplug 	= gunner.PlayerPhysplug;
	player.vehicle_ammo1 	= vehic.vehicle_ammo1;
	player.vehicle_ammo2 	= vehic.vehicle_ammo2;
	player.vehicle_reload1 	= vehic.vehicle_reload1;
	player.vehicle_reload2 	= vehic.vehicle_reload2;
	player.vehicle_energy 	= vehic.vehicle_energy;
	UNSET_ONGROUND(player);

	RemoveGrapplingHooks(player);

	gunner.vehicle_exit = r22heli_gunner_exit;
	gunner.vehicle_hudmodel.viewmodelforclient = player;

	for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
	{
		.entity weaponentity = weaponentities[slot];

		gunner.(weaponentity) = new(temp_wepent);
		gunner.(weaponentity).m_switchweapon = player.(weaponentity).m_switchweapon;
	}

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

	CSQCVehicleSetup(player, STAT(HUD, player));

	MUTATOR_CALLHOOK(VehicleEnter, player, gunner);

	return true;
}

bool vehicles_valid_pilot(entity this, entity toucher);

void r22heli_touch(entity this, entity toucher)
{
	if(autocvar_g_vehicles_enter) { return; }

	if(this.gunner1 != NULL)
	{
		vehicles_touch(this, toucher);
		return;
	}

	if(vehicles_valid_pilot(this, toucher))
	{
		if(time >= toucher.vehicle_enter_delay && time >= this.gun1.phase)
			if(r22heli_gunner_enter(this, toucher))
				return;
	}

	vehicles_touch(this, toucher);
}

bool r22heli_pilot_frame(entity this, float dt)
{
	entity vehic = this.vehicle;
	return = true;

	if(intermission_running)
	{
		vehic.velocity = '0 0 0';
		vehic.avelocity = '0 0 0';
		return;
	}
	
	float ftmp = 0;
	if(vehic.sound_nexttime < time)
	if(this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		vehic.sound_nexttime = time + 2.3807; 
		sound(vehic, CH_TRIGGER_SINGLE, SND_CHOPPA, 1, ATTN_NORM);
		vehic.wait = ftmp;
	}
	/*
	else if(fabs(ftmp - vehic.wait) > 0.2)
	{
		sound (vehic.tur_head, CH_TRIGGER_SINGLE, "", 1 - ftmp,   ATTN_NORM );
		sound (vehic, CH_TRIGGER_SINGLE, "", ftmp, ATTN_NORM);        
		vehic.wait = ftmp;
	}
	*/
	
	if(IS_DEAD(vehic))
	{
		PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = 0;
		return;
	}
	//crosshair_trace(this);
	makevectors(this.v_angle);
	trace_endpos = this.origin + v_forward * max_shot_distance;

	vector vang;
	vang = vehic.angles;
	vector df = vectoangles(normalize(trace_endpos - vehic.origin + '0 0 32'));
	vang_x *= -1;
	df_x *= -1;
	if(df_x > 180)  df_x -= 360;
	if(df_x < -180) df_x += 360;
	if(df_y > 180)  df_y -= 360;
	if(df_y < -180) df_y += 360;
	
	
	//print("wl: ", ftos(vehic.waterlevel), "\n");
	//print(sprintf("waterlevel: %f vehic to player %f\n", vehic.waterlevel, this.waterlevel));
	
	if(this.waterlevel != WATERLEVEL_SUBMERGED)
	{
		// gotta do it this way as vehicles waterlevel is always 1
		// thus we check players water level instead.
		/////////////////////////////////////////////////////////////////////////
		//BEGIN If not in water
		/////////////////////////////////////////////////////////////////////////

		ftmp = shortangle_f(this.v_angle_y - vang_y, vang_y);
		if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
		vehic.avelocity_y = bound(-autocvar_g_vehicle_r22heli_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_r22heli_turnspeed);

		// Pitch
		ftmp = 0;
		if(!((PHYS_INPUT_BUTTON_HOOK(this)) && (this.movement_x < 0)))
		{
			if(this.movement_x > 0 && vang_x < autocvar_g_vehicle_r22heli_pitchlimit)
				ftmp = 5;
			else if(this.movement_x < 0 && vang_x > -autocvar_g_vehicle_r22heli_pitchlimit)
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
			makevectors(this.v_angle);

		df = vehic.velocity * -autocvar_g_vehicle_r22heli_friction;
		
		if(PHYS_INPUT_BUTTON_HOOK(this))
		{
			if(vehicle_altitude(this, 512) < 16) 
			{
				this.PlayerPhysplug = r22heli_takeoff;
				vehic.bomb1.gun1.count = 0;
			}	 
		}
		else
		{
			if(this.movement_x != 0)
			{
				if(this.movement_x > 0)
					df += v_forward  * autocvar_g_vehicle_r22heli_speed_forward;
				else if(this.movement_x < 0)
					df -= v_forward  * autocvar_g_vehicle_r22heli_speed_forward;
			}
		}

		if(this.movement_y != 0)
		{
			if(this.movement_y < 0)
				df -= v_right * autocvar_g_vehicle_r22heli_speed_strafe;
			else if(this.movement_y > 0)
				df += v_right * autocvar_g_vehicle_r22heli_speed_strafe;

			vehic.angles_z = bound(-30,vehic.angles_z + (this.movement_y / autocvar_g_vehicle_r22heli_speed_strafe),30);
		}
		else
		{
			vehic.angles_z *= 0.95;
			if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
				vehic.angles_z = 0;
		}

		if(PHYS_INPUT_BUTTON_CROUCH(this))
			df -= v_up * autocvar_g_vehicle_r22heli_speed_down;
		else if (PHYS_INPUT_BUTTON_JUMP(this))
			df += v_up * autocvar_g_vehicle_r22heli_speed_up;
		
		//Cannon firing
		if(vehic.spawnflags & 32)
			r22heli_deluge(vehic, this, vehic.bomb11, dt);
		 
		if(vehic.spawnflags >= 64)
		{
			if (vehic.spawnflags & 64)
				r22heli_minigun(vehic, this, vehic.bomb3, vehic.bomb3.gun1, vehic.bomb4, vehic.bomb4.gun1, dt);
		
			if (vehic.spawnflags & 128)
			{
				r22heli_hmg(vehic, this, vehic.bomb5, vehic.bomb6, dt);

				r22heli_rocket(vehic, this);
			}

			entity gunmount = vehic.bomb5;
			vector ad = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
			vector vf = v_forward;
			ad += gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
			vf += v_forward;
			ad = ad * 0.5;
			v_forward = vf * 0.5;
			traceline(ad, ad + v_forward * max_shot_distance, MOVE_NORMAL, vehic);
			UpdateAuxiliaryXhair(this, trace_endpos, ('1 0 0' * this.vehicle_reload1) + ('0 1 0' * (1 - this.vehicle_reload1)), 0);
		}

		vehic.velocity += df * dt;
		set_movetype(vehic, MOVETYPE_BOUNCEMISSILE);
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
		set_movetype(vehic, MOVETYPE_TOSS);
		vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun1.avelocity_y * 0.95;
			vehic.bomb1.gun2.avelocity_y = -vehic.bomb1.gun1.avelocity_y;
	}
	
	this.velocity = this.movement = vehic.velocity;
	setorigin(this, vehic.origin + '0 0 32');

	// Target lock & predict

	if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(vehic, vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, dt, true);

	if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen_resource(vehic, vehic.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, dt, false, RESOURCE_HEALTH);

	if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(vehic, vehic.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, dt, false);

	//Bomb dropping removed
	
	vehic.bomb1.alpha = vehic.bomb2.alpha = (time - vehic.lip) / (vehic.delay - vehic.lip);
	this.vehicle_reload2 = bound(0, vehic.bomb1.alpha * 100, 100);
	this.vehicle_ammo2 = (this.vehicle_reload2 == 100) ? 100 : 0;

	if(vehic.bomb1.cnt < time)
	{
		bool incoming = false;
		FOREACH_ENTITY_ENT(enemy, vehic,
		{
			if(it.flags & FL_PROJECTILE)
			if(MISSILE_IS_TRACKING(it))
			if(vdist(vehic.origin - it.origin, <, 2 * autocvar_g_vehicle_r22heli_flare_range))
			{
				incoming = true;
				break;
			}
		});

		if(incoming)
		{
			msg_entity = this;
			soundto(MSG_ONE, vehic, CH_PAIN_SINGLE, SND(VEH_MISSILE_ALARM), VOL_BASE, ATTEN_NONE);
		}
		
		vehic.bomb1.cnt = time + 1;
	}

	// weapons removed

	VEHICLE_UPDATE_PLAYER_RESOURCE(this, vehic, health, r22heli, RESOURCE_HEALTH);
	VEHICLE_UPDATE_PLAYER(this, vehic, energy, r22heli);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(this, vehic, shield, r22heli);

	PHYS_INPUT_BUTTON_ATCK(this) = PHYS_INPUT_BUTTON_ATCK2(this) = PHYS_INPUT_BUTTON_CROUCH(this) = 0;
	setorigin(this,vehic.origin + '0 0 32');
	this.velocity = vehic.velocity;

	//this.vehicle_ammo1 = (vehic.gun1.vehicle_energy / autocvar_g_vehicle_r22heli_cannon_ammo) * 100;
	//this.vehicle_ammo2 = (vehic.gun2.vehicle_energy / autocvar_g_vehicle_r22heli_cannon_ammo) * 100;
}

void r22heli_exit(entity this, int eject)
{
	settouch(this, vehicles_touch);
	setthink(this, vehicles_think);
	this.nextthink = time;
	
	if(!this.owner)
		return;
	
	// add from sparrow	
	if(!IS_DEAD(this))
	{
		setthink(this, r22heli_land);
		this.nextthink  = time;
	}

	this.bomb1.gun1.count = 0;
	
	makevectors(this.angles);
	if(eject)
	{
		vector spot = this.origin + v_forward * 100 + '0 0 64';
		spot = vehicles_findgoodexit(this, this.owner, spot);
		setorigin(this.owner, spot);
		this.owner.velocity = (v_up + v_forward * 0.25) * 750;
		this.owner.oldvelocity = this.owner.velocity;
	}
	else
	{
		vector spot;
		if(vdist(this.velocity, >, 2 * PHYS_MAXAIRSPEED(this.owner)))
		{
			this.owner.velocity = normalize(this.velocity) * PHYS_MAXAIRSPEED(this.owner) * 2;
			this.owner.velocity_z += 200;
			spot = this.origin + v_forward * 32 + '0 0 32';
			spot = vehicles_findgoodexit(this, this.owner, spot);
		}
		else
		{
			this.owner.velocity = this.velocity * 0.5;
			this.owner.velocity_z += 10;
			spot = this.origin - v_forward * 200 + '0 0 32';
			spot = vehicles_findgoodexit(this, this.owner, spot);
		}
		this.owner.oldvelocity = this.owner.velocity;
		setorigin(this.owner, spot);
	}
	
	antilag_clear(this.owner, CS(this.owner));
	this.owner = NULL;
}

void r22heli_blowup(entity this)
{
	RadiusDamage(this, this.enemy, autocvar_g_vehicle_r22heli_blowup_coredamage,
				 autocvar_g_vehicle_r22heli_blowup_edgedamage,
				 autocvar_g_vehicle_r22heli_blowup_radius, this, NULL,
				 autocvar_g_vehicle_r22heli_blowup_forceintensity,
				 DEATH_VH_HELI_DEATH.m_id, DMG_NOWEP, NULL);

	sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_MIN);
	Send_Effect(EFFECT_EXPLOSION_MEDIUM, (this.origin + '0 0 50') + (randomvec() * 80), '0 0 0', 1);
	
	if(this.owner.deadflag == DEAD_DYING)
		this.owner.deadflag = DEAD_DEAD;
	
	delete(this);
}

void r22heli_blowup_touch(entity this, entity toucher)
{
	r22heli_blowup(this);
}

void r22heli_diethink(entity this)
{
	if(time >= this.wait)
		setthink(this, r22heli_blowup);

	if(random() < 0.1)
	{
		sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_MIN);
		Send_Effect(EFFECT_EXPLOSION_SMALL, randomvec() * 80 + (this.origin + '0 0 50'), '0 0 0', 1);
	}

	this.nextthink = time + 0.1;
}

void r22heli_die(entity this)
{
	if(this.gunner1)
	{
		if(this.gun1.vehicle_exit)
			this.gun1.vehicle_exit(this.gun1, VHEF_EJECT);
	}

	if(this.vehicle_exit)
		this.vehicle_exit(this, VHEF_EJECT);
	
	fixedmakevectors(this.angles);
	vehicle_tossgib(this, this.gun1, this.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(this, this, this.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		settouch(_body, r22heli_blowup_touch);
	else
		settouch(_body, func_null);
		
	_body.scale          = 1;
	setthink(_body, r22heli_diethink);
	_body.nextthink = time;
	_body.wait = time + 2 + (random() * 8);
	_body.owner = this;
	_body.enemy = this.enemy;
	
	Send_Effect(EFFECT_EXPLOSION_SMALL, findbetterlocation(this.origin, 16), '0 0 0', 1);
	
	SetResourceAmountExplicit(this, RESOURCE_HEALTH, 0);
	this.event_damage	= func_null;
	this.solid			= SOLID_CORPSE;
	this.takedamage		= DAMAGE_NO;
	this.deadflag		= DEAD_DYING;
	set_movetype(this, MOVETYPE_NONE);
	this.effects		= EF_NODRAW;
	this.colormod		= '0 0 0';
	this.avelocity		= '0 0 0';
	this.velocity		= '0 0 0';
	settouch(this, func_null);
	this.nextthink 		= 0;

	setorigin(this, this.pos1);

	helicopter_rotor_die(this.rotorbox); // using this, sets .think to something other than null, but not much :)
}

// if we dont do this every now and then, the r22heli's rotors
// stop working, presumably due to angle overflow
void r22heli_rotor_anglefix(entity this)
{
	this.gun1.angles_y = anglemods(this.gun1.angles_y);
	this.gun2.angles_y = anglemods(this.gun2.angles_y);
	this.nextthink = time + 15;
}

spawnfunc(vehicle_r22heli)
{
	if(!autocvar_g_vehicle_r22heli) { delete(this); return; }
	if(!vehicle_initialize(this, VEH_R22HELI, false)) { delete(this); return; }
}

spawnfunc(vehicle_r22heli_milspec)
{
	if(this.spawnflags < 64)
		this.spawnflags |= 64; // so we spawn weapons
	if(this.colormap < 1024)
		this.colormap = 1024; // black
	spawnfunc_vehicle_r22heli(this);
}

METHOD(R22Heli, vr_impact, void(R22Heli thisveh, entity instance))
{
	if(autocvar_g_vehicle_r22heli_bouncepain)
		vehicles_impact(instance, autocvar_g_vehicle_r22heli_bouncepain.x, autocvar_g_vehicle_r22heli_bouncepain.y, autocvar_g_vehicle_r22heli_bouncepain.z);
}
METHOD(R22Heli, vr_enter, void(R22Heli thisveh, entity instance))
{
	settouch(instance, r22heli_touch);
	instance.nextthink = 0;
	set_movetype(instance, MOVETYPE_BOUNCE);
	//instance.vehicle_weapon2mode = RSM_BOMB;
	instance.owner.PlayerPhysplug = r22heli_takeoff;
	set_movetype(instance, MOVETYPE_BOUNCEMISSILE);
	instance.solid          = SOLID_SLIDEBOX;
	instance.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
	instance.tur_head.exteriormodeltoclient = instance.owner;

	instance.delay = time + autocvar_g_vehicle_r22heli_bombs_refire;
	instance.lip   = time;

	CSQCVehicleSetup(instance.owner, 0);
	instance.owner.vehicle_health = (GetResourceAmount(instance, RESOURCE_HEALTH) / autocvar_g_vehicle_r22heli_health) * 100;
	instance.owner.vehicle_shield = (instance.vehicle_shield / autocvar_g_vehicle_r22heli_shield) * 100;

	if(instance.owner.flagcarried)
		setorigin(instance.owner.flagcarried, '-20 0 96');
}
METHOD(R22Heli, vr_think, void(R22Heli thisveh, entity instance))
{
	if(!instance.owner)
	{	
		if(instance.gunner1)
		{
			if(instance.gun1.vehicle_exit)
				instance.gun1.vehicle_exit(instance.gun1, VHEF_EJECT);
			instance.phase = 0;
			if(gettouch(instance))
				gettouch(instance)(instance, instance.gunner1);
		}
				
	}
}
METHOD(R22Heli, vr_death, void(R22Heli thisveh, entity actor))
{
	CSQCModel_UnlinkEntity(actor); // networking the death scene would be a nightmare
	r22heli_die(actor);
}
METHOD(R22Heli, vr_spawn, void(R22Heli thisveh, entity actor))
{
	if(!actor.gun1)
	{
		entity spinner;
	
		// for some reason, autosizing of the shield entity refuses to work for this one so set it up in advance.
		actor.vehicle_shieldent = spawn();
		actor.vehicle_shieldent.effects = EF_LOWPRECISION;
		_setmodel(actor.vehicle_shieldent, "models/vhshield.md3");
		setattachment(actor.vehicle_shieldent, actor, "");
		setorigin(actor.vehicle_shieldent, real_origin(actor) - actor.origin);
		actor.vehicle_shieldent.scale       = 512 / vlen(actor.maxs - actor.mins);
		setthink(actor.vehicle_shieldent, shieldhit_think);
		actor.vehicle_shieldent.alpha = -1;
		actor.vehicle_shieldent.effects = EF_LOWPRECISION | EF_NODRAW;
	 
		actor.frame = 0;

		actor.bomb1 = spawn();
		actor.bomb2 = spawn();
		actor.gun1  = spawn();
		actor.gun2  = spawn();

		_setmodel(actor.bomb1,"null");
		_setmodel(actor.bomb2,"null");
		_setmodel(actor.gun1, "null");
		_setmodel(actor.gun2, "null");
		//_setmodel(actor.tur_head, "models/vehicles/r22heliedits_body.iqm");

		setattachment(actor.bomb1, actor, "bombmount_left");
		setattachment(actor.bomb2, actor, "bombmount_right");
		//setattachment(actor.tur_head, actor,"root");

		// FIXMODEL guns mounts to angled bones
		actor.bomb1.angles = actor.angles;
		actor.angles = '0 0 0';

		actor.angles = actor.bomb1.angles;
		actor.bomb1.angles = '0 0 0';

		spinner = spawn();
		spinner.owner = actor;
		setmodel(spinner, MDL_R22HELI_SPINNER);
		setattachment(spinner, actor, "engine_left");
		set_movetype(spinner, MOVETYPE_NOCLIP);
		spinner.avelocity = '0 90 0';
		//spinner.scale = 3.0;
		actor.bomb1.gun1 = spinner;

		spinner = spawn();
		spinner.owner = actor;
		setmodel(spinner, MDL_R22HELI_SMALLSPINNER);
		setattachment(spinner, actor, "engine_right");
		set_movetype(spinner, MOVETYPE_NOCLIP);
		spinner.avelocity = '0 -90 0';
		actor.bomb1.gun2 = spinner;

		// sigh
		setthink(actor.bomb1, r22heli_rotor_anglefix);
		actor.bomb1.nextthink = time;

		setattachment(actor.vehicle_viewport, actor, "tag_camera");
		//actor.mass               = 1 ;
		actor.mass               = autocvar_g_vehicle_r22heli_mass;
		
		actor.vehicle_flags |= VHF_MULTISLOT;

		actor.gun1.owner = actor;
			
		setattachment(actor.gun1, actor, "tag_pass1");
		
		vehicle_addplayerslot(actor, actor.gun1, HUD_BUMBLEBEE_GUN, MDL_Null, r22heli_gunner_frame, r22heli_gunner_exit, r22heli_gunner_enter);

		if(actor.spawnflags & 32)
			r22heli_deluge_add(actor, "forwardmount_left");

		actor.rotorbox = spawn();
	
		if(actor.spawnflags & 64)
		{
			// minigun left stuff
			actor.bomb3 = spawn();
			setmodel(actor.bomb3, MDL_MG_M134GUN);
			setattachment(actor.bomb3, actor, "gunmount_left");
				
			// minigun left barrels
			actor.bomb3.gun1 = spawn();
			setmodel(actor.bomb3.gun1, MDL_MG_M134GUN_BARRELS);
			setattachment(actor.bomb3.gun1, actor.bomb3, "tag_axis");
			actor.bomb3.gun1.count = 100; //autocvar_g_vehicle_lightapc_minigun_refire;
			
			actor.bomb3.angles_z = -110; // so ammo chain travels into fuselage
			
			// minigun right stuff
			actor.bomb4 = spawn();
			setmodel(actor.bomb4, MDL_MG_M134GUN);
			setattachment(actor.bomb4, actor, "gunmount_right");
			
			// minigun right barrels
			actor.bomb4.gun1 = spawn();
			setmodel(actor.bomb4.gun1, MDL_MG_M134GUN_BARRELS);
			setattachment(actor.bomb4.gun1, actor.bomb4, "tag_axis");
			actor.bomb4.gun1.count = 100; //autocvar_g_vehicle_lightapc_minigun_refire;
			
			actor.bomb4.angles_z = 120; // so ammo chain travels into fuselage
		}
	
		if(actor.spawnflags & 128)
		{
			// .50 left stuff
			actor.bomb5 = spawn();
			setmodel(actor.bomb5, MDL_MG_BROWNING50GUN);
			setattachment(actor.bomb5, actor, "forwardmount_left");
				
			actor.bomb5.angles_z = -90; // so ammo chain travels into fuselage
			
			// .50 right stuff
			actor.bomb6 = spawn();
			setmodel(actor.bomb6, MDL_MG_BROWNING50GUN);
			setattachment(actor.bomb6, actor, "forwardmount_right");
			
			actor.bomb6.angles_z = 90; // so ammo chain travels into fuselage
		}
	}

	actor.frame = 0;
	SetResourceAmountExplicit(actor, RESOURCE_HEALTH, autocvar_g_vehicle_r22heli_health);
	actor.vehicle_shield = autocvar_g_vehicle_r22heli_shield;
	set_movetype(actor, MOVETYPE_TOSS);
	actor.solid = SOLID_SLIDEBOX;
	actor.vehicle_energy = 1;

	actor.bomb1.gun1.avelocity_y = 90;
	actor.bomb1.gun2.avelocity_y = -90;

	//setsize(actor, R22HELI_MIN, R22HELI_MAX );
	actor.delay = time;
		
	actor.bouncefactor = autocvar_g_vehicle_r22heli_bouncefactor;
	actor.bouncestop = autocvar_g_vehicle_r22heli_bouncestop;
	actor.damageforcescale = 0.25;

	float oldy = actor.angles_y;
	actor.angles_y = 0; // so we can do the init math correctly

	// spinning rotor death area
	float R22HELIROTOR_HEIGHT = 145;
	helicopter_rotor_spawn_hitbox(0, actor, actor.rotorbox, '-140 -140 -1', '140 140 1', 0, 0, R22HELIROTOR_HEIGHT);

	actor.angles_y = oldy; // done doing the init math, reset.
}
METHOD(R22Heli, vr_setup, void(R22Heli thisveh, entity instance))
{
	string bodymodel;

	//if(instance.spawnflags)
	//{
		//RandomSelection_Init();

		//RandomSelection_Add(NULL, 0, string_null, 1, 1);
		//RandomSelection_Add(NULL, 32, string_null, 1, 1);
		//RandomSelection_Add(NULL, 64, string_null, 1, 1);
		//RandomSelection_Add(NULL, 128, string_null, 1, 1);

		//instance.spawnflags = RandomSelection_chosen_float;
		instance.spawnflags |= 128;
	//}
			
	if(instance.spawnflags >= 64)
		bodymodel = MDL_R22HELI_MILSPEC.model_str();
	else
		bodymodel = VEH_R22HELI.mdl;

	instance.mdl = bodymodel; // override default function
	_setmodel(instance, instance.mdl);
	setsize(instance, thisveh.m_mins, thisveh.m_maxs);

	if(autocvar_g_vehicle_r22heli_energy)
	if(autocvar_g_vehicle_r22heli_energy_regen)
		instance.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_r22heli_shield)
		instance.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_r22heli_shield_regen)
		instance.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_r22heli_health_regen)
		instance.vehicle_flags |= VHF_HEALTHREGEN;

	instance.vehicle_exit = r22heli_exit;
	instance.respawntime = autocvar_g_vehicle_r22heli_respawntime;
	SetResourceAmountExplicit(instance, RESOURCE_HEALTH, autocvar_g_vehicle_r22heli_health);
	instance.vehicle_shield = autocvar_g_vehicle_r22heli_shield;
	instance.max_health = GetResourceAmount(instance, RESOURCE_HEALTH);
}

#elif defined(CSQC)

METHOD(R22Heli, vr_hud, void(R22Heli thisveh))
{
	Vehicles_drawHUD(VEH_R22HELI.m_icon, "vehicle_helicopter_weapon1", "vehicle_helicopter_weapon2",
					 "vehicle_icon_ammo1", autocvar_hud_progressbar_vehicles_ammo1_color,
					 "vehicle_icon_ammo2", autocvar_hud_progressbar_vehicles_ammo1_color);
}
METHOD(R22Heli, vr_crosshair, void(R22Heli thisveh, entity player))
{
	Vehicles_drawCrosshair(vCROSS_LOCK);
}
METHOD(R22Heli, vr_setup, void(R22Heli thisveh, entity actor))
{
	AuxiliaryXhair[0].axh_image = vCROSS_HINT; // Minigun1
	AuxiliaryXhair[1].axh_image = vCROSS_HINT; // Minigun2
}

#endif // CSQC

#ifdef CSQC
REGISTER_MUTATOR(cl_r22heli, true);

MUTATOR_HOOKFUNCTION(cl_r22heli, DamageInfo)
{
	entity dmgent = M_ARGV(0, entity);
	int w_deathtype = M_ARGV(1, int);

	// the deathtype is marked as vehicle death, so we can get away with not performing the additional traces!
	if(DEATH_ENT(w_deathtype) == DEATH_VH_HELI_DEATH)
	{
		sound(dmgent, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, 0.2);
		pointparticles(EFFECT_EXPLOSION_BIG, dmgent.origin, w_backoff * 1000, 1);
	}
}
#endif

#endif // IMPLEMENTATION?
